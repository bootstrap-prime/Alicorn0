-- provide ways to construct all terms
-- checker untyped term and typechecking context -> typed term
-- evaluator takes typed term and runtime context -> value

-- type checker monad
-- error handling and metavariable unification facilities
--
-- typechecker is allowed to fail, typechecker monad carries failures upwards
--   for now fail fast, but design should vaguely support multiple failures

-- metavariable unification
--   a metavariable is like a variable butmore meta
--   create a set of variables -> feed into code -> evaluate with respect to them
--   in order for the values produced by these two invocations to be the same, what would the metavariales need to be bound to?
--   (this is like symbolic execution)
--
-- in the typechecking monad we create a metavariable which takes a type and produces a term or value of that type and
-- we can unfy two values against each other to solve their metavariables or it can fail
-- for now unification with equality is the only kind of constraint. eventuall may be others but that's hard/no need right now

-- we will use lua errors for handling here - use if, error not assert so JIT understands
-- metavariables = table, edit the table, this is the stateful bit the monad has
-- methods on metavariable that bind equal to some value, if it is already bound it has to unify which can fail, failure cascades
-- thing passed to bind equl method on metavariable is a 'value' - enumerated datatype, like term but less cases
--   scaffolding - need to add cases here foreach new value variant
--
-- create metavariable, pass in as arg to lambda, get back result, unify against another type
--   it's ok if a metavariable never gets constrained during part of typechecking
-- give metavariables sequential ids (tracked in typechecker_state)

-- metavariable state transitions, can skip steps but must always move down

-- unbound
-- vvv
-- bound to exactly another metavariable - have a reference to a metavariable
-- vvv
-- bound to a value - have a reference to a value

-- when binding to another metavariable bind the one with a greater index to the lesser index

local metalang = require './metalanguage'
local types = require './typesystem'

local trie = require './lazy-prefix-tree'
local fibbuf = require './fibonacci-buffer'

local gen = require './terms-generators'
local derivers = require './derivers'
local map = gen.declare_map
local array = gen.declare_array

local function getmvinfo(id, mvs)
  if mvs == nil then
    return
  end
  -- if this is slow fixme later
  return mvs[id] or getmvinfo(id, mvs.prev_mvs)
end

local metavariable_mt

metavariable_mt = {
  __index = {
    get_value = function(self)
      local canonical = self:get_canonical()
      local canonical_info = getmvinfo(canonical.id, self.typechecker_state.mvs)
      return canonical_info.bound_value or values.free(free.metavariable(canonical))
    end,
    get_canonical = function(self)
      local canonical_id = self.typechecker_state:get_canonical_id(self.id)

      if canonical_id ~= self.id then
        return setmetatable({
            id = canonical_id,
            typechecker_state = self.typechecker_state,
                            }, metavariable_mt):get_canonical()
      end

      return self
    end,
    -- this gets called to bind to any value that isn't another metavariable
    bind_value = function(self, value)
      -- FIXME: if value is a metavariable (free w/ metavariable) call bind_metavariable here?
      local canonical = self:get_canonical()
      local canonical_info = getmvinfo(canonical.id, self.typechecker_state.mvs)
      if canonical_info.bound_value and canonical_info.bound_value ~= value then
        -- unify the two values, throws lua error if can't
        value = canonical_info.bound_value:unify(value)
      end
      self.typechecker_state.mvs[canonical.id] = {
        bound_value = value,
      }
      return value
    end,
    bind_metavariable = function(self, other)
      if self == other then
        return
      end

      if getmetatable(other) ~= metavariable_mt then
        p(self, other, getmetatable(self), getmetatable(other))
        error("metavariable.bind should only be called with metavariable as arg")
      end

      if self.typechecker_state ~= other.typechecker_state then
        error("trying to mix metavariables from different typechecker_states")
      end

      if self.id == other.id then
        return
      end

      if self.id < other.id then
        return other:bind_metavariable(self)
      end

      local this = getmvinfo(self.id, self.typechecker_state.mvs)
      if this.bound_value then
        error("metavariable is already bound to a value")
      end

      self.typechecker_state.mvs[self.id] = {
        bound_mv_id = other.id,
      }
    end
  }
}
local metavariable_type = gen.declare_foreign(gen.metatable_equality(metavariable_mt))

local typechecker_state_mt
typechecker_state_mt = {
  __index = {
    metavariable = function(self) -- -> metavariable instance
      self.next_metavariable_id = self.next_metavariable_id + 1
      self.mvs[self.next_metavariable_id] = {}
      return setmetatable(
        {
          id = self.next_metavariable_id,
          typechecker_state = self,
        }, metavariable_mt)
    end,
    get_canonical_id = function(self, mv_id) -- -> number
      local mvinfo = getmvinfo(mv_id, self.mvs)
      if mvinfo.bound_mv_id then
        local final_id = self:get_canonical_id(mvinfo.bound_mv_id)
        if final_id ~= mvinfo.bound_mv_id then
          -- ok to mutate rather than setting in self.mvs here as collapsing chain is idempotent
          mvinfo.bound_mv_id = final_id
        end
        return final_id
      end
      return mv_id
    end,
  }
}

local function typechecker_state()
  return setmetatable({
      next_metavariable_id = 0,
      mvs = { prev_mvs = nil },
    }, typechecker_state_mt)
end

-- freeze and then commit or revert
-- like a transaction
local function speculate(f, ...)
  mvs = {
    prev_mvs = mvs,
  }
  local commit, result = f(...)
  if commit then
    -- commit
    for k, v in pairs(mvs) do
      if k ~= "prev_mvs" then
        prev_mvs[k] = mvs[k]
      end
    end
    mvs = mvs.prev_mvs
    return result
  else
    -- revert
    mvs = mvs.prev_mvs
    -- intentionally don't return result if set if not committing to prevent smuggling out of execution
    return nil
  end
end

local checkable_term = gen.declare_type()
local mechanism_term = gen.declare_type()
local mechanism_usage = gen.declare_type()
local inferrable_term = gen.declare_type()
local typed_term = gen.declare_type()
local free = gen.declare_type()
local value = gen.declare_type()
local neutral_value = gen.declare_type()

local new_env

local function new_store(val)
  local store = {val = val}
  if not types.is_duplicable(val.type) then
    store.kind = "useonce"
  else
    store.kind = "reusable"
  end
  return store
end

local runtime_context_mt

runtime_context_mt = {
  __index = {
    get = function(self, index)
      return self.bindings:get(index)
    end,
    append = function(self, value)
      local copy = { bindings = self.bindings:append(value) }
      return setmetatable(copy, runtime_context_mt)
    end
  }
}


local function runtime_context()
  local self = {}
  self.bindings = fibbuf()
  return setmetatable(self, runtime_context_mt)
end

local typechecking_context_mt

typechecking_context_mt = {
  __index = {
    get_name = function(self, index)
      return self.bindings:get(index).name
    end,
    get_type = function(self, index)
      return self.bindings:get(index).type
    end,
    get_runtime_context = function(self)
      return self.runtime_context
    end,
    append = function(self, name, type)
      local copy = {
        bindings = self.bindings:append({name = name, type = type}),
        runtime_context = self.runtime_context:append(value.neutral(neutral_value.free(free.placeholder(#self + 1)))),
      }
      return setmetatable(copy, typechecking_context_mt)
    end
  },
  __len = function(self)
    return self.bindings:len()
  end,
}

local function typechecking_context()
  local self = {}
  self.bindings = fibbuf()
  self.runtime_context = runtime_context()
  return setmetatable(self, typechecking_context_mt)
end

-- empty for now, just used to mark the table
local module_mt = {}

local environment_mt = {
  __index = {
    get = function(self, name)
      local present, binding = self.bindings:get(name)
      if not present then return false, "symbol \"" .. name .. "\" is not in scope" end
      if binding == nil then
        return false, "symbol \"" .. name .. "\" is marked as present but with no data; this indicates a bug in the environment or something violating encapsulation"
      end
      return true, binding
    end,
    bind_local = function(self, name, term)
      return new_env {
        locals = self.locals:put(name, term),
        nonlocals = self.nonlocals,
        carrier = self.carrier,
        perms = self.perms
      }
    end,
    gather_module = function(self)
      return self, setmetatable({bindings = self.locals}, module_mt)
    end,
    open_module = function(self, module)
      return new_env {
        locals = self.locals:extend(module.bindings),
        nonlocals = self.nonlocals,
        carrier = self.carrier,
        perms = self.perms
      }
    end,
    use_module = function(self, module)
      return new_env {
        locals = self.locals,
        nonlocals = self.nonlocals:extend(module.bindings),
        carrier = self.carrier,
        perms = self.perms
      }
    end,
    unlet_local = function(self, name)
      return new_env {
        locals = self.locals:remove(name),
        nonlocals = self.nonlocals,
        carrier = self.carrier,
        perms = self.perms
      }
    end,
    enter_block = function(self)
      return { shadowed = self }, new_env {
        locals = nil,
        nonlocals = self.nonlocals:extend(self.locals),
        carrier = self.carrier,
        perms = self.perms
      }
    end,
    exit_block = function(self, term, shadowed)
      for k, v in pairs(self.locals) do
        term:let(k, v)
      end
    end,
    child_scope = function(self)
      return new_env {
        locals = trie.empty,
        nonlocals = self.bindings,
        carrier = self.carrier,
        perms = self.perms
      }
    end,
    exit_child_scope = function(self, child)
      return new_env {
        locals = self.locals,
        nonlocals = self.nonlocals,
        carrier = child.carrier,
        perms = self.perms
      }
    end,
    get_carrier = function(self)
      if self.carrier == nil then
        return false, "The environment has no effect carrier, code in the environment must be pure"
      end
      if self.carrier.kind == "used" then
        return false, "The environment used to have an effect carrier but it was used; this environment shouldn't be used for anything and this message indicates a linearity-violating bug in an operative"
      end
      local val = self.carrier.val
      if self.carrier.kind == "useonce" then
        self.carrier.val = nil
        self.carrier.kind = "used"
      end
      return true, val
    end,
    provide_carrier = function(self, carrier)
      return new_env {
        locals = self.locals,
        nonlocals = self.nonlocals,
        carrier = new_store(carrier),
        perms = self.perms
      }
    end
  }
}

function new_env(opts)
  local self = {}
  self.locals = opts.locals or trie.empty
  self.nonlocals = opts.nonlocals or trie.empty
  self.bindings = self.nonlocals:extend(self.locals)
  self.carrier = opts.carrier or nil
  self.perms = opts.perms or {}
  self.typechecking_context = typechecking_context()
  return setmetatable(self, environment_mt)
end

local function dump_env(env)
  return "Environment"
    .. "\nlocals: " .. trie.dump_map(env.locals)
    .. "\nnonlocals: " .. trie.dump_map(env.nonlocals)
    .. "\ncarrier: " .. tostring(env.carrier)
end

local runtime_context_type = gen.declare_foreign(gen.metatable_equality(runtime_context_mt))
local typechecking_context_type = gen.declare_foreign(gen.metatable_equality(typechecking_context_mt))
local environment_type = gen.declare_foreign(gen.metatable_equality(environment_mt))
local prim_user_defined_id = gen.declare_foreign(function(val)
  return type(val) == "table" and type(val.name) == "string"
end)

-- checkable terms need a target type to typecheck against
checkable_term:define_enum("checkable", {
  {"mechanism", {"mechanism_term", mechanism_term}},
  {"lambda", {
    "param_name", gen.builtin_string,
    "body", checkable_term,
  }},
})
mechanism_term:define_enum("mechanism", {
  {"inferrable", {"inferrable_term", inferrable_term}},
  {"lambda", {
    "param_name", gen.builtin_string,
    "body", mechanism_term,
  }},
})
mechanism_usage:define_enum("mechanism_usage", {
  {"callable", {
    "arg_type", value,
    "next_usage", mechanism_usage,
  }},
  {"inferrable"},
})
-- inferrable terms can have their type inferred / don't need a target type
inferrable_term:define_enum("inferrable", {
  {"bound_variable", {"index", gen.builtin_number}},
  {"typed", {
    "type", value,
    "usage_counts", array(gen.builtin_number),
    "typed_term", typed_term,
  }},
  {"annotated_lambda", {
    "param_name", gen.builtin_string,
    "param_annotation", inferrable_term,
    "body", inferrable_term,
  }},
  {"qtype", {
    "quantity", inferrable_term,
    "type", inferrable_term,
  }},
  {"pi", {
    "param_type", inferrable_term,
    "param_info", inferrable_term,
    "result_type", inferrable_term,
    "result_info", inferrable_term,
  }},
  {"application", {
    "f", inferrable_term,
    "arg", inferrable_term,
  }},
  {"tuple_cons", {"elements", array(inferrable_term)}},
  {"tuple_elim", {
    "mechanism", mechanism_term,
    "subject", inferrable_term,
  }},
  {"let", {
    "var_name", gen.builtin_string,
    "var_expr", inferrable_term,
    "body", inferrable_term,
  }},
  {"operative_cons", {"handler", checkable_term}},
  {"level_type"},
  {"level0"},
  {"level_suc", {"previous_level", inferrable_term}},
  {"level_max", {
    "level_a", inferrable_term,
    "level_b", inferrable_term,
  }},
  {"star"},
  {"prop"},
  {"prim"},
  {"annotated", {
    "annotated_term", checkable_term,
    "annotated_type", inferrable_term,
  }},
  {"prim_tuple_cons", {"elements", array(inferrable_term)}}, -- prim
  {"prim_user_defined_type_cons", {
    "id", prim_user_defined_id, -- prim_user_defined_type
    "family_args", array(inferrable_term), -- prim
  }},
})
-- typed terms have been typechecked but do not store their type internally
typed_term:define_enum("typed", {
  {"bound_variable", {"index", gen.builtin_number}},
  {"literal", {"literal_value", value}},
  {"lambda", {"body", typed_term}},
  {"qtype", {
    "quantity", typed_term,
    "type", typed_term,
  }},
  {"pi", {
    "param_type", typed_term,
    "param_info", typed_term,
    "result_type", typed_term,
    "result_info", typed_term,
  }},
  {"application", {
    "f", typed_term,
    "arg", typed_term,
  }},
  {"level_type"},
  {"level0"},
  {"level_suc", {"previous_level", typed_term}},
  {"level_max", {
    "level_a", typed_term,
    "level_b", typed_term,
  }},
  {"star", {"level", gen.builtin_number}},
  {"prop", {"level", gen.builtin_number}},
  {"tuple_cons", {"elements", array(typed_term)}},
  --{"tuple_extend", {"base", typed_term, "fields", array(typed_term)}}, -- maybe?
  {"tuple_elim", {
    "mechanism", typed_term,
    "subject", typed_term,
  }},
  {"record_cons", {"fields", map(gen.builtin_string, typed_term)}},
  {"record_extend", {
    "base", typed_term,
    "fields", map(gen.builtin_string, typed_term),
  }},
  --TODO record elim
  {"data_cons", {
    "constructor", gen.builtin_string,
    "arg", typed_term,
  }},
  {"data_elim", {
    "mechanism", typed_term,
    "subject", typed_term,
  }},
  {"data_rec_elim", {
    "mechanism", typed_term,
    "subject", typed_term,
  }},
  {"object_cons", {"methods", map(gen.builtin_string, typed_term)}},
  {"object_corec_cons", {"methods", map(gen.builtin_string, typed_term)}},
  {"object_elim", {
    "mechanism", typed_term,
    "subject", typed_term,
  }},
  {"operative_cons"},
  {"prim_tuple_cons", {"elements", array(typed_term)}}, -- prim
  {"prim_user_defined_type_cons", {
    "id", prim_user_defined_id,
    "family_args", array(typed_term), -- prim
  }},
})

free:define_enum("free", {
  {"metavariable", {"metavariable", metavariable_type}},
  {"placeholder", {"index", gen.builtin_number}},
  -- TODO: axiom
})

-- erased - - - - never used at runtime
--              - can only be placed in other erased slots
--              - e.g. the type Array(u8, 42) has length information that is relevant for typechecking
--              -      but not for runtime. the constructor of Array(u8, 42) marks the 42 as erased,
--              -      and it's dropped after compile time.
-- linear - - - - used once during runtime
--              - e.g. world
-- unrestricted - used arbitrarily many times during runtime
local quantity = gen.declare_enum("quantity", {
  {"erased"},
  {"linear"},
  {"unrestricted"},
})
-- implicit arguments are filled in through unification
-- e.g. fn append(t : star(0), n : nat, xs : Array(t, n), val : t) -> Array(t, n+1)
--      t and n can be implicit, given the explicit argument xs, as they're filled in by unification
local visibility = gen.declare_enum("visibility", {
  {"explicit"},
  {"implicit"},
})
-- whether a function is effectful or pure
-- an effectful function must return a monad
-- calling an effectful function implicitly inserts a monad bind between the
-- function return and getting the result of the call
local purity = gen.declare_enum("purity", {
  {"effectful"},
  {"pure"},
})
local result_info = gen.declare_record("result_info", {"purity", purity})

-- values must always be constructed in their simplest form, that cannot be reduced further.
-- their format must enforce this invariant.
-- e.g. it must be impossible to construct "2 + 2"; it should be constructed in reduced form "4".
-- values can contain neutral values, which represent free variables and stuck operations.
-- stuck operations are those that are blocked from further evaluation by a neutral value.
-- therefore neutral values must always contain another neutral value or a free variable.
-- their format must enforce this invariant.
-- e.g. it's possible to construct the neutral value "x + 2"; "2" is not neutral, but "x" is.
-- values must all be finite in size and must not have loops.
-- i.e. destructuring values always (eventually) terminates.
value:define_enum("value", {
  -- erased, linear, unrestricted / none, one, many
  {"quantity_type"},
  {"quantity", {"quantity", quantity}},
  -- explicit, implicit,
  {"visibility_type"},
  {"visibility", {"visibility", visibility}},
  -- a type with a quantity
  {"qtype_type", {"level", gen.builtin_number}},
  {"qtype", {
    "quantity", value,
    "type", value,
  }},
  -- info about the parameter (is it implicit / what are the usage restrictions?)
  -- quantity/visibility should be restricted to free or (quantity/visibility) rather than any value
  {"param_info_type"},
  {"param_info", {"visibility", value}},
  -- whether or not a function is effectful /
  -- for a function returning a monad do i have to be called in an effectful context or am i pure
  {"result_info_type"},
  {"result_info", {"result_info", result_info}},
  {"pi", {
    "param_type", value, -- qtype
    "param_info", value, -- param_info
    "result_type", value, -- qtype
    "result_info", value, -- result_info
  }},
  -- closure is a type that contains a typed term corresponding to the body
  -- and a runtime context representng the bound context where the closure was created
  {"closure", {
    "code", typed_term,
    "capture", runtime_context_type,
  }},

  -- metaprogramming stuff
  -- TODO: add types of terms, and type indices
  {"syntax_value", {"syntax", metalang.constructed_syntax_type}},
  {"syntax_type"},
  {"matcher_value", {"matcher", metalang.matcher_type}},
  {"matcher_type", {"result_type", value}},
  {"reducer_value", {"reducer", metalang.reducer_type}},
  {"environment_value", {"environment", environment_type}},
  {"environment_type"},
  {"checkable_term", {"checkable_term", checkable_term}},
  {"inferrable_term", {"inferrable_term", inferrable_term}},
  {"inferrable_term_type"},
  {"typed_term", {"typed_term", typed_term}},
  --{"typechecker_monad_value", }, -- TODO
  {"typechecker_monad_type", {"wrapped_type", value}},
  {"name_type"},
  {"name", {"name", gen.builtin_string}},
  {"operative_value"},
  {"operative_type", {"handler", value}},


  -- ordinary data
  {"tuple_value", {"elements", array(value)}},
  {"tuple_type", {"decls", value}},
  {"data_value", {
    "constructor", gen.builtin_string,
    "arg", value,
  }},
  {"data_type", {"decls", value}},
  {"record_value", {"fields", map(gen.builtin_string, value)}},
  {"record_type", {"decls", value}},
  {"record_extend_stuck", {
    "base", neutral_value,
    "extension", map(gen.builtin_string, value),
  }},
  {"object_value", {"methods", map(gen.builtin_string, value)}},
  {"object_type", {"decls", value}},
  {"level_type"},
  {"number_type"},
  {"number", {"number", gen.builtin_number}},
  {"level", {"level", gen.builtin_number}},
  {"star", {"level", gen.builtin_number}},
  {"prop", {"level", gen.builtin_number}},
  {"neutral", {"neutral", neutral_value}},

  -- foreign data
  {"prim", {"primitive_value", gen.any_lua_type}},
  {"prim_type_type"},
  {"prim_number_type"},
  {"prim_bool_type"},
  {"prim_string_type"},
  {"prim_function_type", {
    "param_type", value, -- must be a prim_tuple_type
    -- primitive functions can only have explicit arguments
    "result_type", value, -- must be a prim_tuple_type
    -- primitive functions can only be pure for now
  }},
  {"prim_user_defined_type", {
    "id", prim_user_defined_id,
    "family_args", array(value),
  }},
  {"prim_nil_type"},
  --NOTE: prim_tuple is not considered a prim type because it's not a first class value in lua.
  {"prim_tuple_value", {"elements", array(gen.any_lua_type)}},
  {"prim_tuple_type", {"decls", value}}, -- just like an ordinary tuple type but can only hold prims

  -- type of key and value of key -> type of the value
  -- {"prim_table_type"},
})

neutral_value:define_enum("neutral_value", {
  -- fn(free_value) and table of functions eg free.metavariable(metavariable)
  -- value should be constructed w/ free.something()
  {"free", {"free", free}},
  {"application_stuck", {
    "f", neutral_value,
    "arg", value,
  }},
  {"data_elim_stuck", {
    "handler", value,
    "subject", neutral_value,
  }},
  {"data_rec_elim_stuck", {
    "handler", value,
    "subject", neutral_value,
  }},
  {"object_elim_stuck", {
    "method", value,
    "subject", neutral_value,
  }},
  {"record_elim_stuck", {
    "fields", value,
    "uncurried", value,
    "subject", neutral_value,
  }},
  {"tuple_elim_stuck", {
    "mechanism", value,
    "subject", neutral_value,
  }},
  {"prim_application_stuck", {
    "function", gen.any_lua_type,
    "arg", neutral_value,
  }},
  {"prim_tuple_stuck", {
    "leading", array(gen.any_lua_type),
    "stuck_element", neutral_value,
    "trailing", array(value), -- either primitive or neutral
  }},
})

neutral_value.free.metavariable = function(mv)
  return neutral_value.free(free.metavariable(mv))
end

for _, deriver in ipairs { derivers.as, derivers.pretty_print } do
  checkable_term:derive(deriver)
  mechanism_term:derive(deriver)
  mechanism_usage:derive(deriver)
  inferrable_term:derive(deriver)
  typed_term:derive(deriver)
  quantity:derive(deriver)
  visibility:derive(deriver)
  value:derive(deriver)
end

return {
  typechecker_state = typechecker_state, -- fn (constructor)
  checkable_term = checkable_term, -- {}
  mechanism_term = mechanism_term,
  mechanism_usage = mechanism_usage,
  inferrable_term = inferrable_term, -- {}
  typed_term = typed_term, -- {}
  free = free,
  quantity = quantity,
  visibility = visibility,
  purity = purity,
  result_info = result_info,
  value = value,
  neutral_value = neutral_value,

  new_env = new_env,
  dump_env = dump_env,
  new_store = new_store,
  runtime_context = runtime_context,
  typechecking_context = typechecking_context,
  runtime_context_type = runtime_context_type,
  typechecking_context_type = typechecking_context_type,
  environment_type = environment_type,
}
