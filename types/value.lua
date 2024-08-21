-- THIS FILE AUTOGENERATED BY terms-gen-meta.lua
---@meta "value.lua"

---@class (exact) value: EnumValue
value = {}

---@return boolean
function value:is_visibility_type() end
---@return nil
function value:unwrap_visibility_type() end
---@return boolean
function value:as_visibility_type() end
---@return boolean
function value:is_visibility() end
---@return visibility
function value:unwrap_visibility() end
---@return boolean, visibility
function value:as_visibility() end
---@return boolean
function value:is_param_info_type() end
---@return nil
function value:unwrap_param_info_type() end
---@return boolean
function value:as_param_info_type() end
---@return boolean
function value:is_param_info() end
---@return value
function value:unwrap_param_info() end
---@return boolean, value
function value:as_param_info() end
---@return boolean
function value:is_result_info_type() end
---@return nil
function value:unwrap_result_info_type() end
---@return boolean
function value:as_result_info_type() end
---@return boolean
function value:is_result_info() end
---@return result_info
function value:unwrap_result_info() end
---@return boolean, result_info
function value:as_result_info() end
---@return boolean
function value:is_pi() end
---@return value, value, value, value
function value:unwrap_pi() end
---@return boolean, value, value, value, value
function value:as_pi() end
---@return boolean
function value:is_closure() end
---@return string, typed, RuntimeContext
function value:unwrap_closure() end
---@return boolean, string, typed, RuntimeContext
function value:as_closure() end
---@return boolean
function value:is_range() end
---@return ArrayValue, ArrayValue, value
function value:unwrap_range() end
---@return boolean, ArrayValue, ArrayValue, value
function value:as_range() end
---@return boolean
function value:is_name_type() end
---@return nil
function value:unwrap_name_type() end
---@return boolean
function value:as_name_type() end
---@return boolean
function value:is_name() end
---@return string
function value:unwrap_name() end
---@return boolean, string
function value:as_name() end
---@return boolean
function value:is_operative_value() end
---@return value
function value:unwrap_operative_value() end
---@return boolean, value
function value:as_operative_value() end
---@return boolean
function value:is_operative_type() end
---@return value, value
function value:unwrap_operative_type() end
---@return boolean, value, value
function value:as_operative_type() end
---@return boolean
function value:is_tuple_value() end
---@return ArrayValue
function value:unwrap_tuple_value() end
---@return boolean, ArrayValue
function value:as_tuple_value() end
---@return boolean
function value:is_tuple_type() end
---@return value
function value:unwrap_tuple_type() end
---@return boolean, value
function value:as_tuple_type() end
---@return boolean
function value:is_tuple_desc_type() end
---@return value
function value:unwrap_tuple_desc_type() end
---@return boolean, value
function value:as_tuple_desc_type() end
---@return boolean
function value:is_enum_value() end
---@return string, value
function value:unwrap_enum_value() end
---@return boolean, string, value
function value:as_enum_value() end
---@return boolean
function value:is_enum_type() end
---@return value
function value:unwrap_enum_type() end
---@return boolean, value
function value:as_enum_type() end
---@return boolean
function value:is_enum_desc_type() end
---@return value
function value:unwrap_enum_desc_type() end
---@return boolean, value
function value:as_enum_desc_type() end
---@return boolean
function value:is_record_value() end
---@return MapValue
function value:unwrap_record_value() end
---@return boolean, MapValue
function value:as_record_value() end
---@return boolean
function value:is_record_type() end
---@return value
function value:unwrap_record_type() end
---@return boolean, value
function value:as_record_type() end
---@return boolean
function value:is_record_desc_type() end
---@return value
function value:unwrap_record_desc_type() end
---@return boolean, value
function value:as_record_desc_type() end
---@return boolean
function value:is_record_extend_stuck() end
---@return neutral_value, MapValue
function value:unwrap_record_extend_stuck() end
---@return boolean, neutral_value, MapValue
function value:as_record_extend_stuck() end
---@return boolean
function value:is_object_value() end
---@return MapValue, RuntimeContext
function value:unwrap_object_value() end
---@return boolean, MapValue, RuntimeContext
function value:as_object_value() end
---@return boolean
function value:is_object_type() end
---@return value
function value:unwrap_object_type() end
---@return boolean, value
function value:as_object_type() end
---@return boolean
function value:is_level_type() end
---@return nil
function value:unwrap_level_type() end
---@return boolean
function value:as_level_type() end
---@return boolean
function value:is_number_type() end
---@return nil
function value:unwrap_number_type() end
---@return boolean
function value:as_number_type() end
---@return boolean
function value:is_number() end
---@return number
function value:unwrap_number() end
---@return boolean, number
function value:as_number() end
---@return boolean
function value:is_level() end
---@return number
function value:unwrap_level() end
---@return boolean, number
function value:as_level() end
---@return boolean
function value:is_star() end
---@return number
function value:unwrap_star() end
---@return boolean, number
function value:as_star() end
---@return boolean
function value:is_prop() end
---@return number
function value:unwrap_prop() end
---@return boolean, number
function value:as_prop() end
---@return boolean
function value:is_neutral() end
---@return neutral_value
function value:unwrap_neutral() end
---@return boolean, neutral_value
function value:as_neutral() end
---@return boolean
function value:is_host_value() end
---@return any
function value:unwrap_host_value() end
---@return boolean, any
function value:as_host_value() end
---@return boolean
function value:is_host_type_type() end
---@return nil
function value:unwrap_host_type_type() end
---@return boolean
function value:as_host_type_type() end
---@return boolean
function value:is_host_number_type() end
---@return nil
function value:unwrap_host_number_type() end
---@return boolean
function value:as_host_number_type() end
---@return boolean
function value:is_host_bool_type() end
---@return nil
function value:unwrap_host_bool_type() end
---@return boolean
function value:as_host_bool_type() end
---@return boolean
function value:is_host_string_type() end
---@return nil
function value:unwrap_host_string_type() end
---@return boolean
function value:as_host_string_type() end
---@return boolean
function value:is_host_function_type() end
---@return value, value, value
function value:unwrap_host_function_type() end
---@return boolean, value, value, value
function value:as_host_function_type() end
---@return boolean
function value:is_host_wrapped_type() end
---@return value
function value:unwrap_host_wrapped_type() end
---@return boolean, value
function value:as_host_wrapped_type() end
---@return boolean
function value:is_host_unstrict_wrapped_type() end
---@return value
function value:unwrap_host_unstrict_wrapped_type() end
---@return boolean, value
function value:as_host_unstrict_wrapped_type() end
---@return boolean
function value:is_host_user_defined_type() end
---@return { name: string }, ArrayValue
function value:unwrap_host_user_defined_type() end
---@return boolean, { name: string }, ArrayValue
function value:as_host_user_defined_type() end
---@return boolean
function value:is_host_nil_type() end
---@return nil
function value:unwrap_host_nil_type() end
---@return boolean
function value:as_host_nil_type() end
---@return boolean
function value:is_host_tuple_value() end
---@return ArrayValue
function value:unwrap_host_tuple_value() end
---@return boolean, ArrayValue
function value:as_host_tuple_value() end
---@return boolean
function value:is_host_tuple_type() end
---@return value
function value:unwrap_host_tuple_type() end
---@return boolean, value
function value:as_host_tuple_type() end
---@return boolean
function value:is_singleton() end
---@return value, value
function value:unwrap_singleton() end
---@return boolean, value, value
function value:as_singleton() end
---@return boolean
function value:is_program_end() end
---@return value
function value:unwrap_program_end() end
---@return boolean, value
function value:as_program_end() end
---@return boolean
function value:is_program_cont() end
---@return table, value, continuation
function value:unwrap_program_cont() end
---@return boolean, table, value, continuation
function value:as_program_cont() end
---@return boolean
function value:is_effect_empty() end
---@return nil
function value:unwrap_effect_empty() end
---@return boolean
function value:as_effect_empty() end
---@return boolean
function value:is_effect_elem() end
---@return effect_id
function value:unwrap_effect_elem() end
---@return boolean, effect_id
function value:as_effect_elem() end
---@return boolean
function value:is_effect_type() end
---@return nil
function value:unwrap_effect_type() end
---@return boolean
function value:as_effect_type() end
---@return boolean
function value:is_effect_row() end
---@return SetValue, value
function value:unwrap_effect_row() end
---@return boolean, SetValue, value
function value:as_effect_row() end
---@return boolean
function value:is_effect_row_type() end
---@return nil
function value:unwrap_effect_row_type() end
---@return boolean
function value:as_effect_row_type() end
---@return boolean
function value:is_program_type() end
---@return value, value
function value:unwrap_program_type() end
---@return boolean, value, value
function value:as_program_type() end
---@return boolean
function value:is_srel_type() end
---@return value
function value:unwrap_srel_type() end
---@return boolean, value
function value:as_srel_type() end
---@return boolean
function value:is_variance_type() end
---@return value
function value:unwrap_variance_type() end
---@return boolean, value
function value:as_variance_type() end
---@return boolean
function value:is_intersection_type() end
---@return value, value
function value:unwrap_intersection_type() end
---@return boolean, value, value
function value:as_intersection_type() end
---@return boolean
function value:is_union_type() end
---@return value, value
function value:unwrap_union_type() end
---@return boolean, value, value
function value:as_union_type() end

---@class (exact) valueType: EnumType
---@field define_enum fun(self: valueType, name: string, variants: Variants): valueType
---@field visibility_type value
---@field visibility fun(visibility: visibility): value
---@field param_info_type value
---@field param_info fun(visibility: value): value
---@field result_info_type value
---@field result_info fun(result_info: result_info): value
---@field pi fun(param_type: value, param_info: value, result_type: value, result_info: value): value
---@field closure fun(param_name: string, code: typed, capture: RuntimeContext): value
---@field range fun(lower_bounds: ArrayValue, upper_bounds: ArrayValue, relation: value): value
---@field name_type value
---@field name fun(name: string): value
---@field operative_value fun(userdata: value): value
---@field operative_type fun(handler: value, userdata_type: value): value
---@field tuple_value fun(elements: ArrayValue): value
---@field tuple_type fun(desc: value): value
---@field tuple_desc_type fun(universe: value): value
---@field enum_value fun(constructor: string, arg: value): value
---@field enum_type fun(desc: value): value
---@field enum_desc_type fun(universe: value): value
---@field record_value fun(fields: MapValue): value
---@field record_type fun(desc: value): value
---@field record_desc_type fun(universe: value): value
---@field record_extend_stuck fun(base: neutral_value, extension: MapValue): value
---@field object_value fun(methods: MapValue, capture: RuntimeContext): value
---@field object_type fun(desc: value): value
---@field level_type value
---@field number_type value
---@field number fun(number: number): value
---@field level fun(level: number): value
---@field star fun(level: number): value
---@field prop fun(level: number): value
---@field neutral fun(neutral: neutral_value): value
---@field host_value fun(host_value: any): value
---@field host_type_type value
---@field host_number_type value
---@field host_bool_type value
---@field host_string_type value
---@field host_function_type fun(param_type: value, result_type: value, result_info: value): value
---@field host_wrapped_type fun(type: value): value
---@field host_unstrict_wrapped_type fun(type: value): value
---@field host_user_defined_type fun(id: { name: string }, family_args: ArrayValue): value
---@field host_nil_type value
---@field host_tuple_value fun(elements: ArrayValue): value
---@field host_tuple_type fun(desc: value): value
---@field singleton fun(supertype: value, value: value): value
---@field program_end fun(result: value): value
---@field program_cont fun(action: table, argument: value, continuation: continuation): value
---@field effect_empty value
---@field effect_elem fun(tag: effect_id): value
---@field effect_type value
---@field effect_row fun(components: SetValue, rest: value): value
---@field effect_row_type value
---@field program_type fun(effect_sig: value, base_type: value): value
---@field srel_type fun(target_type: value): value
---@field variance_type fun(target_type: value): value
---@field intersection_type fun(left: value, right: value): value
---@field union_type fun(left: value, right: value): value
return {}
