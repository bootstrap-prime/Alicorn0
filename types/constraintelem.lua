-- THIS FILE AUTOGENERATED BY terms-gen-meta.lua
---@meta "types.constraintelem"

---@class (exact) constraintelem: EnumValue
constraintelem = {}

---@return boolean
function constraintelem:is_sliced_constrain() end
---@return SubtypeRelation, typed, TypecheckingContext, any
function constraintelem:unwrap_sliced_constrain() end
---@return boolean, SubtypeRelation, typed, TypecheckingContext, any
function constraintelem:as_sliced_constrain() end
---@return boolean
function constraintelem:is_constrain_sliced() end
---@return typed, TypecheckingContext, SubtypeRelation, any
function constraintelem:unwrap_constrain_sliced() end
---@return boolean, typed, TypecheckingContext, SubtypeRelation, any
function constraintelem:as_constrain_sliced() end
---@return boolean
function constraintelem:is_sliced_leftcall() end
---@return typed, SubtypeRelation, typed, TypecheckingContext, any
function constraintelem:unwrap_sliced_leftcall() end
---@return boolean, typed, SubtypeRelation, typed, TypecheckingContext, any
function constraintelem:as_sliced_leftcall() end
---@return boolean
function constraintelem:is_leftcall_sliced() end
---@return typed, TypecheckingContext, typed, SubtypeRelation, any
function constraintelem:unwrap_leftcall_sliced() end
---@return boolean, typed, TypecheckingContext, typed, SubtypeRelation, any
function constraintelem:as_leftcall_sliced() end
---@return boolean
function constraintelem:is_sliced_rightcall() end
---@return SubtypeRelation, typed, TypecheckingContext, typed, any
function constraintelem:unwrap_sliced_rightcall() end
---@return boolean, SubtypeRelation, typed, TypecheckingContext, typed, any
function constraintelem:as_sliced_rightcall() end
---@return boolean
function constraintelem:is_rightcall_sliced() end
---@return typed, TypecheckingContext, SubtypeRelation, typed, any
function constraintelem:unwrap_rightcall_sliced() end
---@return boolean, typed, TypecheckingContext, SubtypeRelation, typed, any
function constraintelem:as_rightcall_sliced() end

---@class (exact) constraintelemType: EnumType
---@field define_enum fun(self: constraintelemType, name: string, variants: Variants): constraintelemType
---@field sliced_constrain fun(rel: SubtypeRelation, right: typed, rightctx: TypecheckingContext, cause: any): constraintelem
---@field constrain_sliced fun(left: typed, leftctx: TypecheckingContext, rel: SubtypeRelation, cause: any): constraintelem
---@field sliced_leftcall fun(arg: typed, rel: SubtypeRelation, right: typed, rightctx: TypecheckingContext, cause: any): constraintelem
---@field leftcall_sliced fun(left: typed, leftctx: TypecheckingContext, arg: typed, rel: SubtypeRelation, cause: any): constraintelem
---@field sliced_rightcall fun(rel: SubtypeRelation, right: typed, rightctx: TypecheckingContext, arg: typed, cause: any): constraintelem
---@field rightcall_sliced fun(left: typed, leftctx: TypecheckingContext, rel: SubtypeRelation, arg: typed, cause: any): constraintelem
return {}
