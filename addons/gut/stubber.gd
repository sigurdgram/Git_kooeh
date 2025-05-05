












var returns = {}
var _utils = load("res://addons/gut/utils.gd").get_instance()
var _lgr = _utils.get_logger()
var _strutils = _utils.Strutils.new()
var _class_db_name_hash = {}

func _init():
    _class_db_name_hash = _make_crazy_dynamic_over_engineered_class_db_hash()






func _make_crazy_dynamic_over_engineered_class_db_hash():
    var text = "var all_the_classes = {\n"
    for classname in ClassDB.get_class_list():
        if (ClassDB.can_instantiate(classname)):
            text += str("\"", classname, "\": ", classname, ", \n")
        else:
            text += str("# ", classname, "\n")
    text += "}"
    var inst = _utils.create_script_from_source(text).new()
    return inst.all_the_classes


func _find_matches(obj, method):
    var matches = null
    var last_not_null_parent = null




    if (returns.has(obj) and returns[obj].has(method)):
        matches = returns[obj][method]
    elif (_utils.is_instance(obj)):
        var parent = obj.get_script()
        var found = false
        while (parent != null and !found):
            found = returns.has(parent)

            if ( !found):
                last_not_null_parent = parent
                parent = parent.get_base_script()



        if ( !found):
            var base_type = last_not_null_parent.get_instance_base_type()
            if (_class_db_name_hash.has(base_type)):
                parent = _class_db_name_hash[base_type]
                found = returns.has(parent)

        if (found and returns[parent].has(method)):
            matches = returns[parent][method]

    return matches






func _find_stub(obj, method, parameters = null, find_overloads = false):
    var to_return = null
    var matches = _find_matches(obj, method)

    if (matches == null):
        return null

    var param_match = null
    var null_match = null
    var overload_match = null

    for i in range(matches.size()):
        var cur_stub = matches[i]
        if (cur_stub.parameters == parameters):
            param_match = cur_stub

        if (cur_stub.parameters == null and !cur_stub.is_param_override_only()):
            null_match = cur_stub

        if (cur_stub.has_param_override()):
            if (overload_match == null || overload_match.is_script_default):
                overload_match = cur_stub

    if (find_overloads and overload_match != null):
        to_return = overload_match

    elif (param_match != null):
        to_return = param_match



    elif (null_match != null):
        to_return = null_match

    return to_return







func add_stub(stub_params):
    stub_params._lgr = _lgr
    var key = stub_params.stub_target

    if ( !returns.has(key)):
        returns[key] = {}

    if ( !returns[key].has(stub_params.stub_method)):
        returns[key][stub_params.stub_method] = []

    returns[key][stub_params.stub_method].append(stub_params)

















func get_return(obj, method, parameters = null):
    var stub_info = _find_stub(obj, method, parameters)

    if (stub_info != null):
        return stub_info.return_val
    else:
        _lgr.info(str("Call to [", method, "] was not stubbed for the supplied parameters ", parameters, ".  Null was returned."))
        return null


func should_call_super(obj, method, parameters = null):
    if (_utils.non_super_methods.has(method)):
        return false

    var stub_info = _find_stub(obj, method, parameters)

    var is_partial = false
    if (typeof(obj) != TYPE_STRING):
        is_partial = obj.__gutdbl.is_partial
    var should = is_partial

    if (stub_info != null):
        should = stub_info.call_super
    elif ( !is_partial):



        _lgr.info("Unstubbed call to " + method + "::" + _strutils.type2str(obj))
        should = false

    return should


func get_parameter_count(obj, method):
    var to_return = null
    var stub_info = _find_stub(obj, method, null, true)

    if (stub_info != null and stub_info.has_param_override()):
        to_return = stub_info.parameter_count

    return to_return


func get_default_value(obj, method, p_index):
    var to_return = null
    var stub_info = _find_stub(obj, method, null, true)

    if (stub_info != null and 
        stub_info.parameter_defaults != null and 
        stub_info.parameter_defaults.size() > p_index):

        to_return = stub_info.parameter_defaults[p_index]

    return to_return


func clear():
    returns.clear()


func get_logger():
    return _lgr


func set_logger(logger):
    _lgr = logger


func to_s():
    var text = ""
    for thing in returns:
        text += str("-- ", thing, " --\n")
        for method in returns[thing]:
            text += str("	", method, "\n")
            for i in range(returns[thing][method].size()):
                text += "		" + returns[thing][method][i].to_s() + "\n"

    if (text == ""):
        text = "Stubber is empty";

    return text


func stub_defaults_from_meta(target, method_meta):
    var params = _utils.StubParams.new(target, method_meta)
    params.is_script_default = true
    add_stub(params)
