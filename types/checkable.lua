-- THIS FILE AUTOGENERATED BY terms-gen-meta.lua
---@meta "checkable.lua"

---@class (exact) checkable: EnumValue
checkable = {}

---@return boolean
function checkable:is_inferrable() end
---@return inferrable
function checkable:unwrap_inferrable() end
---@return boolean, inferrable
function checkable:as_inferrable() end
---@return boolean
function checkable:is_tuple_cons() end
---@return ArrayValue
function checkable:unwrap_tuple_cons() end
---@return boolean, ArrayValue
function checkable:as_tuple_cons() end
---@return boolean
function checkable:is_prim_tuple_cons() end
---@return ArrayValue
function checkable:unwrap_prim_tuple_cons() end
---@return boolean, ArrayValue
function checkable:as_prim_tuple_cons() end
---@return boolean
function checkable:is_lambda() end
---@return string, checkable
function checkable:unwrap_lambda() end
---@return boolean, string, checkable
function checkable:as_lambda() end

---@class (exact) checkableType: EnumType
---@field define_enum fun(self: checkableType, name: string, variants: Variants): checkableType
---@field inferrable fun(inferrable_term: inferrable): checkable
---@field tuple_cons fun(elements: ArrayValue): checkable
---@field prim_tuple_cons fun(elements: ArrayValue): checkable
---@field lambda fun(param_name: string, body: checkable): checkable
return {}
