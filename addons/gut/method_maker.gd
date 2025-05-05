class CallParameters:
    var p_name = null
    var default = null

    func _init(n, d):
        p_name = n
        default = d





















var _utils = load("res://addons/gut/utils.gd").get_instance()
var _lgr = _utils.get_logger()
const PARAM_PREFIX = "p_"










































var _supported_defaults = []

func _init():
    for _i in range(TYPE_MAX):
        _supported_defaults.append(null)


    _supported_defaults[TYPE_NIL] = ""
    _supported_defaults[TYPE_BOOL] = ""
    _supported_defaults[TYPE_INT] = ""
    _supported_defaults[TYPE_FLOAT] = ""
    _supported_defaults[TYPE_OBJECT] = ""
    _supported_defaults[TYPE_ARRAY] = ""
    _supported_defaults[TYPE_STRING] = ""
    _supported_defaults[TYPE_STRING_NAME] = ""
    _supported_defaults[TYPE_DICTIONARY] = ""
    _supported_defaults[TYPE_PACKED_VECTOR2_ARRAY] = ""
    _supported_defaults[TYPE_RID] = ""


    _supported_defaults[TYPE_VECTOR2] = "Vector2"
    _supported_defaults[TYPE_VECTOR2I] = "Vector2i"
    _supported_defaults[TYPE_RECT2] = "Rect2"
    _supported_defaults[TYPE_RECT2I] = "Rect2i"
    _supported_defaults[TYPE_VECTOR3] = "Vector3"
    _supported_defaults[TYPE_COLOR] = "Color"
    _supported_defaults[TYPE_TRANSFORM2D] = "Transform2D"
    _supported_defaults[TYPE_TRANSFORM3D] = "Transform3D"
    _supported_defaults[TYPE_PACKED_INT32_ARRAY] = "PackedInt32Array"
    _supported_defaults[TYPE_PACKED_FLOAT32_ARRAY] = "PackedFloat32Array"
    _supported_defaults[TYPE_PACKED_STRING_ARRAY] = "PackedStringArray"




var _func_text = _utils.get_file_as_text("res://addons/gut/double_templates/function_template.txt")
var _init_text = _utils.get_file_as_text("res://addons/gut/double_templates/init_template.txt")

func _is_supported_default(type_flag):
    return type_flag >= 0 and type_flag < _supported_defaults.size() and _supported_defaults[type_flag] != null


func _make_stub_default(method, index):
    return str("__gutdbl.default_val(\"", method, "\",", index, ")")

func _make_arg_array(method_meta, override_size):
    var to_return = []

    var has_unsupported_defaults = false
    var dflt_start = method_meta.args.size() - method_meta.default_args.size()

    for i in range(method_meta.args.size()):
        var pname = method_meta.args[i].name
        var dflt_text = _make_stub_default(method_meta.name, i)
        to_return.append(CallParameters.new(PARAM_PREFIX + pname, dflt_text))


    if (override_size != null):
        for i in range(method_meta.args.size(), override_size):
            var pname = str(PARAM_PREFIX, "arg", i)
            var dflt_text = _make_stub_default(method_meta.name, i)
            to_return.append(CallParameters.new(pname, dflt_text))

    return [has_unsupported_defaults, to_return];








func _get_arg_text(arg_array):
    var text = ""

    for i in range(arg_array.size()):
        text += str(arg_array[i].p_name, "=", arg_array[i].default)
        if (i != arg_array.size() - 1):
            text += ", "

    return text



func _get_super_call_text(method_name, args, super_name = ""):
    var params = ""
    for i in range(args.size()):
        params += args[i].p_name
        if (i != args.size() - 1):
            params += ", "

    return str(super_name, "await super(", params, ")")


func _get_spy_call_parameters_text(args):
    var called_with = "null"

    if (args.size() > 0):
        called_with = "["
        for i in range(args.size()):
            called_with += args[i].p_name
            if (i < args.size() - 1):
                called_with += ", "
        called_with += "]"

    return called_with






func _get_init_text(meta, args, method_params, param_array):
    var text = null

    var decleration = str("func ", meta.name, "(", method_params, ")")
    var super_params = ""
    if (args.size() > 0):
        for i in range(args.size()):
            super_params += args[i].p_name
            if (i != args.size() - 1):
                super_params += ", "


    text = _init_text.format({
        "func_decleration": decleration, 
        "super_params": super_params, 
        "param_array": param_array, 
        "method_name": meta.name
    })

    return text








func get_function_text(meta, path = null, override_size = null, super_name = ""):
    var method_params = ""
    var text = null
    var result = _make_arg_array(meta, override_size)
    var has_unsupported = result[0]
    var args = result[1]

    var param_array = _get_spy_call_parameters_text(args)
    if (has_unsupported):



        method_params = null
    else:
        method_params = _get_arg_text(args);

    if (param_array == "null"):
        param_array = "[]"

    if (method_params != null):
        if (meta.name == "_init"):
            text = _get_init_text(meta, args, method_params, param_array)
        else:
            var decleration = str("func ", meta.name, "(", method_params, "):")

            text = _func_text.format({
                "func_decleration": decleration, 
                "method_name": meta.name, 
                "param_array": param_array, 
                "super_call": _get_super_call_text(meta.name, args, super_name)
            })

    return text




func get_logger():
    return _lgr

func set_logger(logger):
    _lgr = logger
