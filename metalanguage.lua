local function issymbol(handler)
  return {
    kind = "Symbol",
    handler = handler,
  }
end

local function ispair(handler)
  return {
    kind = "Pair",
    handler = handler
  }
end

local function isnil(handler)
  return {
    kind = "Nil",
    handler = handler
  }
end

local function isvalue(handler)
  return {
    kind = "Value",
    handler = handler
  }
end


local function reducible(handler, name, func, userdata)
  local reducible = {
    kind = "Reducible",
    name = name,
    handler = handler,
    reducible = func,
  }

  for k, v in pairs(userdata) do
    reducible[k] = v
  end

  return reducible
end

local env_mt
env_mt = {
  __add = function(self, other)
    local res = {}
    for k, v in pairs(self.dict) do
      res[k] = v
    end
    for k, v in pairs(other.dict) do
      if res[k] ~= nil then
        error("names in environments being merged must be disjoint, but both environments have " .. k)
      end
      res[k] = v
    end
    return setmetatable({dict = res}, env_mt)
  end,
  __index = {
    get = function(self, name)
      return self.dict[name]
    end,
    without = function(self, name)
      local res = {}
      for k, v in pairs(self.dict) do
        if k ~= name then
          res[k] = v
        end
      end
      return setmetatable({dict = res}, env_mt)
    end
  },
  __tostring = function(self)
    local message = "env{"
    local fields = {}
    for k, v in pairs(self.dict) do
      fields[#fields + 1] = tostring(k) .. " = " .. tostring(v)
    end
    message = message .. table.concat(fields, ", ") .. "}"
    return message
  end
}

local function newenv(dict)
  return setmetatable({dict = dict}, env_mt)
end

local function symbolenvhandler(env, name)
  --print("symbolenvhandler(", name, env, ")")
  local res = env:get(name)
  if res ~= nil then
    return true, res
  else
    return false, "environment does not contain a binding for " .. name
  end
end

local function symbolexacthandler(expected, name)
  if name == expected then
    return true
  else
    return false, "symbol is expected to be exactly " .. expected .. " but was instead " .. name
  end
end

local function accept_handler(data, ...)
  return true, ...
end
local function failure_handler(data, exception)
  return false, exception
end

local function SymbolInEnvironment(syntax, matcher)
  --print("in symbol in environment reducer", matcher.kind, matcher[1], matcher)
  return syntax:match(
    {
      issymbol(symbolenvhandler)
    },
    failure_handler,
    matcher.environment
  )
end

local function SymbolExact(syntax, matcher)
  return syntax:match(
    {
      issymbol(symbolexacthandler)
    },
    failure_handler,
    matcher.symbol
  )
end


local function symbol_in_environment(handler, env)
  return reducible(handler, "symbol in env", SymbolInEnvironment, { environment = env })
end

local function symbol_exact(handler, symbol)
  return reducible(handler, "symbol exact", SymbolExact, { symbol = symbol })
end

local syntax_error_mt = {
  __tostring = function(self)
    local message = "Syntax error at anchor " .. (self.anchor or "<unknown position>") .. " must be acceptable for one of:\n"
    local options = {}
    for k, v in ipairs(self.matchers) do
        if v.kind == "Reducible" then
          options[k] = v.kind .. ": " .. v.name
        else
          options[k] = v.kind
        end
    end
    message = message .. table.concat(options, ", ")
    message = message .. "\nbut was rejected"
    if self.cause then
      message = message .. " because:\n" .. tostring(self.cause)
    end
    return message
  end
}

local function syntax_error(matchers, anchor, cause)
  return setmetatable(
    {
      matchers = matchers,
      anchor = anchor,
      cause = cause
    },
    syntax_error_mt
  )
end

local constructed_syntax_mt = {
  __index = {
    match = function(self, matchers, unmatched, extra)
      if matchers.kind then print(debug.traceback()) end
      local lasterr = nil
      for _, matcher in ipairs(matchers) do
        if self.accepters[matcher.kind] then
          -- print("accepting primitive handler on kind", matcher.kind)
          return self.accepters[matcher.kind](self, matcher, extra)
        elseif matcher.kind == "Reducible" then
          -- print("trying syntax reduction on kind", matcher.kind)
          local res = {matcher.reducible(self, matcher)}
          if res[1] then
            --print("accepted syntax reduction")
            if not matcher.handler then
              print("missing handler for ", matcher.kind, debug.traceback())
            end
            return matcher.handler(extra, unpack(res, 2))
          end
          --print("rejected syntax reduction")
          lasterr = res[2]
        end
        --print("rejected syntax kind", matcher.kind)
      end
      return unmatched(extra, syntax_error(matchers, self.anchor, lasterr))
    end
  }
}
local function cons_syntax(accepters, ...)
  return setmetatable({accepters = accepters, ...}, constructed_syntax_mt)
end

local pair_accepters = {
  Pair = function(self, matcher, extra)
    return matcher.handler(extra, self[1], self[2])
  end
}

local function pair(a, b)
  return cons_syntax(pair_accepters, a, b)
end

local symbol_accepters = {
  Symbol = function(self, matcher, extra)
    return matcher.handler(extra, self[1])
  end
}

local function symbol(name)
  return cons_syntax(symbol_accepters, name)
end

local value_accepters = {
  Value = function(self, matcher, extra)
    return matcher.handler(extra, self[1])
  end
}

local function value(val)
  return cons_syntax(value_accepters, val)
end

local nil_accepters = {
  Nil = function(self, matcher, extra)
    return matcher.handler(extra)
  end
}

local nilval = cons_syntax(nil_accepters)

local function list(a, ...)
  if a == nil then return nilval end
  return pair(a, list(...))
end

local eval

local vau_mt = {
  __index = {
    apply = function(self, ops, env)
      local bodyenv = self.params:argmatch(ops) + self.envparam:argmatch(env)
      local bodycode = self.body
      local expr
      local res
      while bodycode ~= unit do
        expr, bodycode = bodycode[1], bodycode[2]
        res, bodyenv = eval(expr, bodyenv)
      end
      return {kind = "value", res}
    end

  }
}


local function list_match_pair_handler(rule, a, b)
  --print("list pair handler", a, b, rule)
  local ok, val = a:match({rule}, failure_handler, nil)
  return ok, val, b
end


local function ListMatch(syntax, matcher)
  local args = {}
  local ok, err, val, tail = true, nil, true, nil
  for i, rule in ipairs(matcher.rules) do
    ok, val, tail =
      syntax:match(
        {
          ispair(list_match_pair_handler)
        },
        failure_handler,
        rule
      )
    --print("list match rule", ok, val, tail)
    if not ok then return false, val end
    args[#args + 1] = val
    syntax = tail
  end
  ok, err =
    syntax:match(
      {
        isnil(accept_handler)
      },
      failure_handler,
      nil
    )
  if not ok then return false, err end
  return true, unpack(args)
end

local function listmatch(handler, ...)
  return reducible(handler, "list", ListMatch, { rules = {...} })
end

return {
  newenv = newenv,
  accept_handler = accept_handler,
  failure_handler = failure_handler,
  ispair = ispair,
  issymbol = issymbol,
  isvalue = isvalue,
  value = value,
  listmatch = listmatch,
  reducible = reducible,
  isnil = isnil,
  nilval = nilval,
  symbol_exact = symbol_exact,
  pair = pair,
  list = list,
  symbol = symbol,
  symbol_in_environment = symbol_in_environment,
}
