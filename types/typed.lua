-- THIS FILE AUTOGENERATED BY terms-gen-meta.lua
---@meta "typed.lua"
---@class (exact) typed
---@field kind string
typed = {}
---@return boolean
function typed:is_bound_variable() end
---@return number
function typed:unwrap_bound_variable() end
---@return boolean
function typed:is_literal() end
---@return value
function typed:unwrap_literal() end
---@return boolean
function typed:is_lambda() end
---@return string, typed
function typed:unwrap_lambda() end
---@return boolean
function typed:is_pi() end
---@return typed, typed, typed, typed
function typed:unwrap_pi() end
---@return boolean
function typed:is_application() end
---@return typed, typed
function typed:unwrap_application() end
---@return boolean
function typed:is_let() end
---@return string, typed, typed
function typed:unwrap_let() end
---@return boolean
function typed:is_level_type() end
---@return boolean
function typed:is_level0() end
---@return boolean
function typed:is_level_suc() end
---@return typed
function typed:unwrap_level_suc() end
---@return boolean
function typed:is_level_max() end
---@return typed, typed
function typed:unwrap_level_max() end
---@return boolean
function typed:is_star() end
---@return number
function typed:unwrap_star() end
---@return boolean
function typed:is_prop() end
---@return number
function typed:unwrap_prop() end
---@return boolean
function typed:is_tuple_cons() end
---@return any
function typed:unwrap_tuple_cons() end
---@return boolean
function typed:is_tuple_elim() end
---@return any, typed, number, typed
function typed:unwrap_tuple_elim() end
---@return boolean
function typed:is_tuple_element_access() end
---@return typed, number
function typed:unwrap_tuple_element_access() end
---@return boolean
function typed:is_tuple_type() end
---@return typed
function typed:unwrap_tuple_type() end
---@return boolean
function typed:is_record_cons() end
---@return any
function typed:unwrap_record_cons() end
---@return boolean
function typed:is_record_extend() end
---@return typed, any
function typed:unwrap_record_extend() end
---@return boolean
function typed:is_record_elim() end
---@return typed, any, typed
function typed:unwrap_record_elim() end
---@return boolean
function typed:is_enum_cons() end
---@return string, typed
function typed:unwrap_enum_cons() end
---@return boolean
function typed:is_enum_elim() end
---@return typed, typed
function typed:unwrap_enum_elim() end
---@return boolean
function typed:is_enum_rec_elim() end
---@return typed, typed
function typed:unwrap_enum_rec_elim() end
---@return boolean
function typed:is_object_cons() end
---@return any
function typed:unwrap_object_cons() end
---@return boolean
function typed:is_object_corec_cons() end
---@return any
function typed:unwrap_object_corec_cons() end
---@return boolean
function typed:is_object_elim() end
---@return typed, typed
function typed:unwrap_object_elim() end
---@return boolean
function typed:is_operative_cons() end
---@return typed
function typed:unwrap_operative_cons() end
---@return boolean
function typed:is_operative_type_cons() end
---@return typed, typed
function typed:unwrap_operative_type_cons() end
---@return boolean
function typed:is_prim_tuple_cons() end
---@return any
function typed:unwrap_prim_tuple_cons() end
---@return boolean
function typed:is_prim_user_defined_type_cons() end
---@return any, any
function typed:unwrap_prim_user_defined_type_cons() end
---@return boolean
function typed:is_prim_tuple_type() end
---@return typed
function typed:unwrap_prim_tuple_type() end
---@return boolean
function typed:is_prim_function_type() end
---@return typed, typed
function typed:unwrap_prim_function_type() end
---@return boolean
function typed:is_prim_wrapped_type() end
---@return typed
function typed:unwrap_prim_wrapped_type() end
---@return boolean
function typed:is_prim_unstrict_wrapped_type() end
---@return typed
function typed:unwrap_prim_unstrict_wrapped_type() end
---@return boolean
function typed:is_prim_wrap() end
---@return typed
function typed:unwrap_prim_wrap() end
---@return boolean
function typed:is_prim_unwrap() end
---@return typed
function typed:unwrap_prim_unwrap() end
---@return boolean
function typed:is_prim_unstrict_wrap() end
---@return typed
function typed:unwrap_prim_unstrict_wrap() end
---@return boolean
function typed:is_prim_unstrict_unwrap() end
---@return typed
function typed:unwrap_prim_unstrict_unwrap() end
---@return boolean
function typed:is_prim_user_defined_type() end
---@return any, any
function typed:unwrap_prim_user_defined_type() end
---@return boolean
function typed:is_prim_if() end
---@return typed, typed, typed
function typed:unwrap_prim_if() end
---@return boolean
function typed:is_prim_intrinsic() end
---@return typed, any
function typed:unwrap_prim_intrinsic() end
---@class (exact) typedType:Type
---@field bound_variable fun(index:number): typed
---@field literal fun(literal_value:value): typed
---@field lambda fun(param_name:string, body:typed): typed
---@field pi fun(param_type:typed, param_info:typed, result_type:typed, result_info:typed): typed
---@field application fun(f:typed, arg:typed): typed
---@field let fun(name:string, expr:typed, body:typed): typed
---@field level_type typed
---@field level0 typed
---@field level_suc fun(previous_level:typed): typed
---@field level_max fun(level_a:typed, level_b:typed): typed
---@field star fun(level:number): typed
---@field prop fun(level:number): typed
---@field tuple_cons fun(elements:any): typed
---@field tuple_elim fun(names:any, subject:typed, length:number, body:typed): typed
---@field tuple_element_access fun(subject:typed, index:number): typed
---@field tuple_type fun(definition:typed): typed
---@field record_cons fun(fields:any): typed
---@field record_extend fun(base:typed, fields:any): typed
---@field record_elim fun(subject:typed, field_names:any, body:typed): typed
---@field enum_cons fun(constructor:string, arg:typed): typed
---@field enum_elim fun(subject:typed, mechanism:typed): typed
---@field enum_rec_elim fun(subject:typed, mechanism:typed): typed
---@field object_cons fun(methods:any): typed
---@field object_corec_cons fun(methods:any): typed
---@field object_elim fun(subject:typed, mechanism:typed): typed
---@field operative_cons fun(userdata:typed): typed
---@field operative_type_cons fun(handler:typed, userdata_type:typed): typed
---@field prim_tuple_cons fun(elements:any): typed
---@field prim_user_defined_type_cons fun(id:any, family_args:any): typed
---@field prim_tuple_type fun(decls:typed): typed
---@field prim_function_type fun(param_type:typed, result_type:typed): typed
---@field prim_wrapped_type fun(type:typed): typed
---@field prim_unstrict_wrapped_type fun(type:typed): typed
---@field prim_wrap fun(content:typed): typed
---@field prim_unwrap fun(container:typed): typed
---@field prim_unstrict_wrap fun(content:typed): typed
---@field prim_unstrict_unwrap fun(container:typed): typed
---@field prim_user_defined_type fun(id:any, family_args:any): typed
---@field prim_if fun(subject:typed, consequent:typed, alternate:typed): typed
---@field prim_intrinsic fun(source:typed, anchor:any): typed
return {}
