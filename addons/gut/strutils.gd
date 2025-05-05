class_name GutStringUtils

var _utils = load("res://addons/gut/utils.gd").get_instance()



var types = {}

func _init_types_dictionary():
    types[TYPE_NIL] = "TYPE_NIL"
    types[TYPE_BOOL] = "Bool"
    types[TYPE_INT] = "Int"
    types[TYPE_FLOAT] = "Float/Real"
    types[TYPE_STRING] = "String"
    types[TYPE_VECTOR2] = "Vector2"
    types[TYPE_RECT2] = "Rect2"
    types[TYPE_VECTOR3] = "Vector3"

    types[TYPE_PLANE] = "Plane"
    types[TYPE_QUATERNION] = "QUAT"
    types[TYPE_AABB] = "AABB"

    types[TYPE_TRANSFORM3D] = "Transform3D"
    types[TYPE_COLOR] = "Color"

    types[TYPE_NODE_PATH] = "Node Path3D"
    types[TYPE_RID] = "RID"
    types[TYPE_OBJECT] = "TYPE_OBJECT"

    types[TYPE_DICTIONARY] = "Dictionary"
    types[TYPE_ARRAY] = "Array"
    types[TYPE_PACKED_BYTE_ARRAY] = "TYPE_PACKED_BYTE_ARRAY"
    types[TYPE_PACKED_INT32_ARRAY] = "TYPE_PACKED_INT32_ARRAY"
    types[TYPE_PACKED_FLOAT32_ARRAY] = "TYPE_PACKED_FLOAT32_ARRAY"
    types[TYPE_PACKED_STRING_ARRAY] = "TYPE_PACKED_STRING_ARRAY"
    types[TYPE_PACKED_VECTOR2_ARRAY] = "TYPE_PACKED_VECTOR2_ARRAY"
    types[TYPE_PACKED_VECTOR3_ARRAY] = "TYPE_PACKED_VECTOR3_ARRAY"
    types[TYPE_PACKED_COLOR_ARRAY] = "TYPE_PACKED_COLOR_ARRAY"
    types[TYPE_MAX] = "TYPE_MAX"
    types[TYPE_STRING_NAME] = "TYPE_STRING_NAME"


var _str_ignore_types = [
    TYPE_INT, TYPE_FLOAT, TYPE_STRING, 
    TYPE_NIL, TYPE_BOOL
]

func _init():
    _init_types_dictionary()



func _get_filename(path):
    return path.split("/")[-1]





func _get_obj_filename(thing):
    var filename = null

    if (thing == null or 
        _utils.is_native_class(thing) or 
        !is_instance_valid(thing) or 
        str(thing) == "<Object#null>" or 
        typeof(thing) != TYPE_OBJECT or 
        _utils.is_double(thing)):
        return

    if (thing.get_script() == null):
        if (thing is PackedScene):
            filename = _get_filename(thing.resource_path)
        else:


            pass
    elif ( !_utils.is_native_class(thing)):
        var dict = inst_to_dict(thing)
        filename = _get_filename(dict["@path"])
        if (str(dict["@subpath"]) != ""):
            filename += str("/", dict["@subpath"])

    return filename





func type2str(thing):
    var filename = _get_obj_filename(thing)
    var str_thing = str(thing)

    if (thing == null):





        str_thing = str(null)
    elif (typeof(thing) == TYPE_FLOAT):
        if ( !"." in str_thing):
            str_thing += ".0"
    elif (typeof(thing) == TYPE_STRING):
        str_thing = str("\"", thing, "\"")
    elif (typeof(thing) in _str_ignore_types):



        pass
    elif (typeof(thing) == TYPE_OBJECT):
        if (_utils.is_native_class(thing)):
            str_thing = _utils.get_native_class_name(thing)
        elif (_utils.is_double(thing)):
            var double_path = _get_filename(thing.__gutdbl.thepath)
            if (thing.__gutdbl.subpath != ""):
                double_path += str("/", thing.__gutdbl.subpath)
            elif (thing.__gutdbl.from_singleton != ""):
                double_path = thing.__gutdbl.from_singleton + " Singleton"

            var double_type = "double"
            if (thing.__gutdbl.is_partial):
                double_type = "partial-double"

            str_thing += str("(", double_type, " of ", double_path, ")")

            filename = null
    elif (types.has(typeof(thing))):
        if ( !str_thing.begins_with("(")):
            str_thing = "(" + str_thing + ")"
        str_thing = str(types[typeof(thing)], str_thing)

    if (filename != null):
        str_thing += str("(", filename, ")")
    return str_thing






func truncate_string(src, max_size):
    var to_return = src
    if (src.length() > max_size - 10 and max_size != -1):
        to_return = str(src.substr(0, max_size - 10), "...", src.substr(src.length() - 10, src.length()))
    return to_return


func _get_indent_text(times, pad):
    var to_return = ""
    for i in range(times):
        to_return += pad

    return to_return

func indent_text(text, times, pad):
    if (times == 0):
        return text

    var to_return = text
    var ending_newline = ""

    if (text.ends_with("\n")):
        ending_newline = "\n"
        to_return = to_return.left(to_return.length() - 1)

    var padding = _get_indent_text(times, pad)
    to_return = to_return.replace("\n", "\n" + padding)
    to_return += ending_newline

    return padding + to_return
