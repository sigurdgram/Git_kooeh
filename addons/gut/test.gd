class_name GutTest





































extends Node


var _utils = load("res://addons/gut/utils.gd").get_instance()
var _compare = _utils.Comparator.new()





var gut = null

var _disable_strict_datatype_checks = false


var _fail_pass_text = []

const EDITOR_PROPERTY = PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT
const VARIABLE_PROPERTY = PROPERTY_USAGE_SCRIPT_VARIABLE


var _summary = {
    asserts = 0, 
    passed = 0, 
    failed = 0, 
    tests = 0, 
    pending = 0
}


var _signal_watcher = load("res://addons/gut/signal_watcher.gd").new()


var DOUBLE_STRATEGY = GutUtils.DOUBLE_STRATEGY

var _lgr = _utils.get_logger()
var _strutils = _utils.Strutils.new()


var ParameterFactory = _utils.ParameterFactory
var CompareResult = _utils.CompareResult
var InputFactory = _utils.InputFactory
var InputSender = _utils.InputSender

func _init():
    pass


func _str(thing):
    return _strutils.type2str(thing)




func _fail(text):
    _summary.asserts += 1
    _summary.failed += 1
    _fail_pass_text.append("failed:  " + text)
    if (gut):
        _lgr.failed(gut.get_call_count_text() + text)
        gut._fail(text)





func _pass(text):
    _summary.asserts += 1
    _summary.passed += 1
    _fail_pass_text.append("passed:  " + text)
    if (gut):
        _lgr.passed(text)
        gut._pass(text)






func _do_datatypes_match__fail_if_not(got, expected, text):
    var did_pass = true

    if ( !_disable_strict_datatype_checks):
        var got_type = typeof(got)
        var expect_type = typeof(expected)
        if (got_type != expect_type and got != null and expected != null):


            if ([2, 3].has(got_type) and [2, 3].has(expect_type)):
                _lgr.warn(str("Warn:  Float/Int comparison.  Got ", _strutils.types[got_type], 
                    " but expected ", _strutils.types[expect_type]))
            elif ([TYPE_STRING, TYPE_STRING_NAME].has(got_type) and [TYPE_STRING, TYPE_STRING_NAME].has(expect_type)):
                pass
            else:
                _fail("Cannot compare " + _strutils.types[got_type] + "[" + _str(got) + "] to " + \
_strutils.types[expect_type] + "[" + _str(expected) + "].  " + text)
                did_pass = false

    return did_pass





func _get_desc_of_calls_to_instance(inst):
    var BULLET = "  * "
    var calls = gut.get_spy().get_call_list_as_string(inst)

    calls = BULLET + calls.replace("\n", "\n" + BULLET)

    calls = calls.substr(0, calls.length() - BULLET.length() - 1)
    return "Calls made on " + str(inst) + "\n" + calls




func _fail_if_does_not_have_signal(object, signal_name):
    var did_fail = false
    if ( !_signal_watcher.does_object_have_signal(object, signal_name)):
        _fail(str("Object ", object, " does not have the signal [", signal_name, "]"))
        did_fail = true
    return did_fail




func _fail_if_not_watching(object):
    var did_fail = false
    if ( !_signal_watcher.is_watching_object(object)):
        _fail(str("Cannot make signal assertions because the object ", object, \
" is not being watched.  Call watch_signals(some_object) to be able to make assertions about signals."))
        did_fail = true
    return did_fail





func _get_fail_msg_including_emitted_signals(text, object):
    return str(text, " (Signals emitted: ", _signal_watcher.get_signals_emitted(object), ")")





func _fail_if_parameters_not_array(parameters):
    var invalid = parameters != null and typeof(parameters) != TYPE_ARRAY
    if (invalid):
        _lgr.error("The \"parameters\" parameter must be an array of expected parameter values.")
        _fail("Cannot compare paramter values because an array was not passed.")
    return invalid


func _create_obj_from_type(type):
    var obj = null
    if type.is_class("PackedScene"):
        obj = type.instantiate()
        add_child(obj)
    else:
        obj = type.new()
    return obj







func before_all():
    pass


func before_each():
    pass


func after_all():
    pass


func after_each():
    pass





func get_logger():
    return _lgr

func set_logger(logger):
    _lgr = logger









func assert_eq(got, expected, text = ""):

    if (_do_datatypes_match__fail_if_not(got, expected, text)):
        var disp = "[" + _str(got) + "] expected to equal [" + _str(expected) + "]:  " + text
        var result = null

        result = _compare.simple(got, expected)

        if (typeof(got) in [TYPE_ARRAY, TYPE_DICTIONARY]):
            disp = str(result.summary, "  ", text)
            _lgr.info("Array/Dictionary compared by value.  Use assert_same to compare references.  Use assert_eq_deep to see diff when failing.")

        if (result.are_equal):
            _pass(disp)
        else:
            _fail(disp)





func assert_ne(got, not_expected, text = ""):
    if (_do_datatypes_match__fail_if_not(got, not_expected, text)):
        var disp = "[" + _str(got) + "] expected to not equal [" + _str(not_expected) + "]:  " + text
        var result = null

        result = _compare.simple(got, not_expected)

        if (typeof(got) in [TYPE_ARRAY, TYPE_DICTIONARY]):
            disp = str(result.summary, "  ", text)
            _lgr.info("Array/Dictionary compared by value.  Use assert_not_same to compare references.  Use assert_ne_deep to see diff.")

        if (result.are_equal):
            _fail(disp)
        else:
            _pass(disp)





func assert_almost_eq(got, expected, error_interval, text = ""):
    var disp = "[" + _str(got) + "] expected to equal [" + _str(expected) + "] +/- [" + str(error_interval) + "]:  " + text
    if (_do_datatypes_match__fail_if_not(got, expected, text) and _do_datatypes_match__fail_if_not(got, error_interval, text)):
        if not _is_almost_eq(got, expected, error_interval):
            _fail(disp)
        else:
            _pass(disp)




func assert_almost_ne(got, not_expected, error_interval, text = ""):
    var disp = "[" + _str(got) + "] expected to not equal [" + _str(not_expected) + "] +/- [" + str(error_interval) + "]:  " + text
    if (_do_datatypes_match__fail_if_not(got, not_expected, text) and _do_datatypes_match__fail_if_not(got, error_interval, text)):
        if _is_almost_eq(got, not_expected, error_interval):
            _fail(disp)
        else:
            _pass(disp)





func _is_almost_eq(got, expected, error_interval) -> bool:
    var result = false
    if typeof(got) == TYPE_VECTOR2:
        if got.x >= (expected.x - error_interval.x) and got.x <= (expected.x + error_interval.x):
            if got.y >= (expected.y - error_interval.y) and got.y <= (expected.y + error_interval.y):
                result = true
    elif typeof(got) == TYPE_VECTOR3:
        if got.x >= (expected.x - error_interval.x) and got.x <= (expected.x + error_interval.x):
            if got.y >= (expected.y - error_interval.y) and got.y <= (expected.y + error_interval.y):
                if got.z >= (expected.z - error_interval.z) and got.z <= (expected.z + error_interval.z):
                    result = true
    elif (got >= (expected - error_interval) and got <= (expected + error_interval)):
        result = true
    return (result)




func assert_gt(got, expected, text = ""):
    var disp = "[" + _str(got) + "] expected to be > than [" + _str(expected) + "]:  " + text
    if (_do_datatypes_match__fail_if_not(got, expected, text)):
        if (got > expected):
            _pass(disp)
        else:
            _fail(disp)




func assert_lt(got, expected, text = ""):
    var disp = "[" + _str(got) + "] expected to be < than [" + _str(expected) + "]:  " + text
    if (_do_datatypes_match__fail_if_not(got, expected, text)):
        if (got < expected):
            _pass(disp)
        else:
            _fail(disp)




func assert_true(got, text = ""):
    if (typeof(got) == TYPE_BOOL):
        if (got):
            _pass(text)
        else:
            _fail(text)
    else:
        var msg = str("Cannot convert ", _strutils.type2str(got), " to boolean")
        _fail(msg)




func assert_false(got, text = ""):
    if (typeof(got) == TYPE_BOOL):
        if (got):
            _fail(text)
        else:
            _pass(text)
    else:
        var msg = str("Cannot convert ", _strutils.type2str(got), " to boolean")
        _fail(msg)




func assert_between(got, expect_low, expect_high, text = ""):
    var disp = "[" + _str(got) + "] expected to be between [" + _str(expect_low) + "] and [" + str(expect_high) + "]:  " + text

    if (_do_datatypes_match__fail_if_not(got, expect_low, text) and _do_datatypes_match__fail_if_not(got, expect_high, text)):
        if (expect_low > expect_high):
            disp = "INVALID range.  [" + str(expect_low) + "] is not less than [" + str(expect_high) + "]"
            _fail(disp)
        else:
            if (got < expect_low or got > expect_high):
                _fail(disp)
            else:
                _pass(disp)




func assert_not_between(got, expect_low, expect_high, text = ""):
    var disp = "[" + _str(got) + "] expected not to be between [" + _str(expect_low) + "] and [" + str(expect_high) + "]:  " + text

    if (_do_datatypes_match__fail_if_not(got, expect_low, text) and _do_datatypes_match__fail_if_not(got, expect_high, text)):
        if (expect_low > expect_high):
            disp = "INVALID range.  [" + str(expect_low) + "] is not less than [" + str(expect_high) + "]"
            _fail(disp)
        else:
            if (got > expect_low and got < expect_high):
                _fail(disp)
            else:
                _pass(disp)





func assert_has(obj, element, text = ""):
    var disp = str("Expected [", _str(obj), "] to contain value:  [", _str(element), "]:  ", text)
    if (obj.has(element)):
        _pass(disp)
    else:
        _fail(disp)



func assert_does_not_have(obj, element, text = ""):
    var disp = str("Expected [", _str(obj), "] to NOT contain value:  [", _str(element), "]:  ", text)
    if (obj.has(element)):
        _fail(disp)
    else:
        _pass(disp)




func assert_file_exists(file_path):
    var disp = "expected [" + file_path + "] to exist."
    if (FileAccess.file_exists(file_path)):
        _pass(disp)
    else:
        _fail(disp)




func assert_file_does_not_exist(file_path):
    var disp = "expected [" + file_path + "] to NOT exist"
    if ( !FileAccess.file_exists(file_path)):
        _pass(disp)
    else:
        _fail(disp)




func assert_file_empty(file_path):
    var disp = "expected [" + file_path + "] to be empty"
    if (FileAccess.file_exists(file_path) and gut.is_file_empty(file_path)):
        _pass(disp)
    else:
        _fail(disp)




func assert_file_not_empty(file_path):
    var disp = "expected [" + file_path + "] to contain data"
    if ( !gut.is_file_empty(file_path)):
        _pass(disp)
    else:
        _fail(disp)




func assert_has_method(obj, method, text = ""):
    var disp = _str(obj) + " should have method: " + method
    if (text != ""):
        disp = _str(obj) + " " + text
    assert_true(obj.has_method(method), disp)









func assert_accessors(obj, property, default, set_to):
    var fail_count = _summary.failed
    var get_func = "get_" + property
    var set_func = "set_" + property

    if (obj.has_method("is_" + property)):
        get_func = "is_" + property

    assert_has_method(obj, get_func, "should have getter starting with get_ or is_")
    assert_has_method(obj, set_func)

    if (_summary.failed > fail_count):
        return
    assert_eq(obj.call(get_func), default, "It should have the expected default value.")
    obj.call(set_func, set_to)
    assert_eq(obj.call(get_func), set_to, "The set value should have been returned.")










func _find_object_property(obj, property_name, property_usage = null):
    var result = null
    var found = false
    var properties = obj.get_property_list()

    while !found and !properties.is_empty():
        var property = properties.pop_back()
        if property["name"] == property_name:
            if property_usage == null or property["usage"] == property_usage:
                result = property
                found = true
    return result




func assert_exports(obj, property_name, type):
    var disp = "expected %s to have editor property [%s]" % [_str(obj), property_name]
    var property = _find_object_property(obj, property_name, EDITOR_PROPERTY)
    if property != null:
        disp += " of type [%s]. Got type [%s]." % [_strutils.types[type], _strutils.types[property["type"]]]
        if property["type"] == type:
            _pass(disp)
        else:
            _fail(disp)
    else:
        _fail(disp)








func _can_make_signal_assertions(object, signal_name):
    return !(_fail_if_not_watching(object) or _fail_if_does_not_have_signal(object, signal_name))





func _is_connected(signaler_obj, connect_to_obj, signal_name, method_name = ""):
    if (method_name != ""):
        return signaler_obj.is_connected(signal_name, Callable(connect_to_obj, method_name))
    else:
        var connections = signaler_obj.get_signal_connection_list(signal_name)
        for conn in connections:
            if (conn["signal"].get_name() == signal_name and conn["callable"].get_object() == connect_to_obj):
                return true
        return false




func watch_signals(object):
    _signal_watcher.watch_signals(object)







func assert_connected(signaler_obj, connect_to_obj, signal_name, method_name = ""):
    pass
    var method_disp = ""
    if (method_name != ""):
        method_disp = str(" using method: [", method_name, "] ")
    var disp = str("Expected object ", _str(signaler_obj), \
" to be connected to signal: [", signal_name, "] on ", \
_str(connect_to_obj), method_disp)
    if (_is_connected(signaler_obj, connect_to_obj, signal_name, method_name)):
        _pass(disp)
    else:
        _fail(disp)







func assert_not_connected(signaler_obj, connect_to_obj, signal_name, method_name = ""):
    var method_disp = ""
    if (method_name != ""):
        method_disp = str(" using method: [", method_name, "] ")
    var disp = str("Expected object ", _str(signaler_obj), \
" to not be connected to signal: [", signal_name, "] on ", \
_str(connect_to_obj), method_disp)
    if (_is_connected(signaler_obj, connect_to_obj, signal_name, method_name)):
        _fail(disp)
    else:
        _pass(disp)







func assert_signal_emitted(object, signal_name, text = ""):
    var disp = str("Expected object ", _str(object), " to have emitted signal [", signal_name, "]:  ", text)
    if (_can_make_signal_assertions(object, signal_name)):
        if (_signal_watcher.did_emit(object, signal_name)):
            _pass(disp)
        else:
            _fail(_get_fail_msg_including_emitted_signals(disp, object))







func assert_signal_not_emitted(object, signal_name, text = ""):
    var disp = str("Expected object ", _str(object), " to NOT emit signal [", signal_name, "]:  ", text)
    if (_can_make_signal_assertions(object, signal_name)):
        if (_signal_watcher.did_emit(object, signal_name)):
            _fail(disp)
        else:
            _pass(disp)










func assert_signal_emitted_with_parameters(object, signal_name, parameters, index = -1):
    if (typeof(parameters) != TYPE_ARRAY):
        _lgr.error("The expected parameters must be wrapped in an array, you passed:  " + _str(parameters))
        _fail("Bad Parameters")
        return

    var disp = str("Expected object ", _str(object), " to emit signal [", signal_name, "] with parameters ", parameters, ", got ")
    if (_can_make_signal_assertions(object, signal_name)):
        if (_signal_watcher.did_emit(object, signal_name)):
            var parms_got = _signal_watcher.get_signal_parameters(object, signal_name, index)
            var diff_result = _compare.deep(parameters, parms_got)
            if (diff_result.are_equal):
                _pass(str(disp, parms_got))
            else:
                _fail(str("Expected object ", _str(object), " to emit signal [", signal_name, "] with parameters ", diff_result.summarize()))
        else:
            var text = str("Object ", object, " did not emit signal [", signal_name, "]")
            _fail(_get_fail_msg_including_emitted_signals(text, object))







func assert_signal_emit_count(object, signal_name, times, text = ""):
    if (_can_make_signal_assertions(object, signal_name)):
        var count = _signal_watcher.get_emit_count(object, signal_name)
        var disp = str("Expected the signal [", signal_name, "] emit count of [", count, "] to equal [", times, "]: ", text)
        if (count == times):
            _pass(disp)
        else:
            _fail(_get_fail_msg_including_emitted_signals(disp, object))




func assert_has_signal(object, signal_name, text = ""):
    var disp = str("Expected object ", _str(object), " to have signal [", signal_name, "]:  ", text)
    if (_signal_watcher.does_object_have_signal(object, signal_name)):
        _pass(disp)
    else:
        _fail(disp)






func get_signal_emit_count(object, signal_name):
    return _signal_watcher.get_emit_count(object, signal_name)








func get_signal_parameters(object, signal_name, index = -1):
    return _signal_watcher.get_signal_parameters(object, signal_name, index)










func get_call_parameters(object, method_name, index = -1):
    var to_return = null
    if (_utils.is_double(object)):
        to_return = gut.get_spy().get_call_parameters(object, method_name, index)
    else:
        _lgr.error("You must pass a doulbed object to get_call_parameters.")

    return to_return




func get_call_count(object, method_name, parameters = null):
    return gut.get_spy().call_count(object, method_name, parameters)





func assert_is(object, a_class, text = ""):
    var disp = ""
    var NATIVE_CLASS = "GDScriptNativeClass"
    var GDSCRIPT_CLASS = "GDScript"
    var bad_param_2 = "Parameter 2 must be a Class (like Node2D or Label).  You passed "

    if (typeof(object) != TYPE_OBJECT):
        _fail(str("Parameter 1 must be an instance of an object.  You passed:  ", _str(object)))
    elif (typeof(a_class) != TYPE_OBJECT):
        _fail(str(bad_param_2, _str(a_class)))
    else:
        var a_str = _str(a_class)
        disp = str("Expected [", _str(object), "] to extend [", a_str, "]: ", text)
        if ( !_utils.is_native_class(a_class) and !_utils.is_gdscript(a_class)):
            _fail(str(bad_param_2, a_str))
        else:
            if (is_instance_of(object, a_class)):
                _pass(disp)
            else:
                _fail(disp)

func _get_typeof_string(the_type):
    var to_return = ""
    if (_strutils.types.has(the_type)):
        to_return += str(the_type, "(", _strutils.types[the_type], ")")
    else:
        to_return += str(the_type)
    return to_return



func assert_typeof(object, type, text = ""):
    var disp = str("Expected [typeof(", object, ") = ")
    disp += _get_typeof_string(typeof(object))
    disp += "] to equal ["
    disp += _get_typeof_string(type) + "]"
    disp += ".  " + text
    if (typeof(object) == type):
        _pass(disp)
    else:
        _fail(disp)



func assert_not_typeof(object, type, text = ""):
    var disp = str("Expected [typeof(", object, ") = ")
    disp += _get_typeof_string(typeof(object))
    disp += "] to not equal ["
    disp += _get_typeof_string(type) + "]"
    disp += ".  " + text
    if (typeof(object) != type):
        _pass(disp)
    else:
        _fail(disp)





func assert_string_contains(text, search, match_case = true):
    var empty_search = "Expected text and search strings to be non-empty. You passed '%s' and '%s'."
    var disp = "Expected '%s' to contain '%s', match_case=%s" % [text, search, match_case]
    if (text == "" or search == ""):
        _fail(empty_search % [text, search])
    elif (match_case):
        if (text.find(search) == -1):
            _fail(disp)
        else:
            _pass(disp)
    else:
        if (text.to_lower().find(search.to_lower()) == -1):
            _fail(disp)
        else:
            _pass(disp)





func assert_string_starts_with(text, search, match_case = true):
    var empty_search = "Expected text and search strings to be non-empty. You passed '%s' and '%s'."
    var disp = "Expected '%s' to start with '%s', match_case=%s" % [text, search, match_case]
    if (text == "" or search == ""):
        _fail(empty_search % [text, search])
    elif (match_case):
        if (text.find(search) == 0):
            _pass(disp)
        else:
            _fail(disp)
    else:
        if (text.to_lower().find(search.to_lower()) == 0):
            _pass(disp)
        else:
            _fail(disp)






func assert_string_ends_with(text, search, match_case = true):
    var empty_search = "Expected text and search strings to be non-empty. You passed '%s' and '%s'."
    var disp = "Expected '%s' to end with '%s', match_case=%s" % [text, search, match_case]
    var required_index = len(text) - len(search)
    if (text == "" or search == ""):
        _fail(empty_search % [text, search])
    elif (match_case):
        if (text.find(search) == required_index):
            _pass(disp)
        else:
            _fail(disp)
    else:
        if (text.to_lower().find(search.to_lower()) == required_index):
            _pass(disp)
        else:
            _fail(disp)








func assert_called(inst, method_name, parameters = null):
    var disp = str("Expected [", method_name, "] to have been called on ", _str(inst))

    if (_fail_if_parameters_not_array(parameters)):
        return

    if ( !_utils.is_double(inst)):
        _fail("You must pass a doubled instance to assert_called.  Check the wiki for info on using double.")
    else:
        if (gut.get_spy().was_called(inst, method_name, parameters)):
            _pass(disp)
        else:
            if (parameters != null):
                disp += str(" with parameters ", parameters)
            _fail(str(disp, "\n", _get_desc_of_calls_to_instance(inst)))






func assert_not_called(inst, method_name, parameters = null):
    var disp = str("Expected [", method_name, "] to NOT have been called on ", _str(inst))

    if (_fail_if_parameters_not_array(parameters)):
        return

    if ( !_utils.is_double(inst)):
        _fail("You must pass a doubled instance to assert_not_called.  Check the wiki for info on using double.")
    else:
        if (gut.get_spy().was_called(inst, method_name, parameters)):
            if (parameters != null):
                disp += str(" with parameters ", parameters)
            _fail(str(disp, "\n", _get_desc_of_calls_to_instance(inst)))
        else:
            _pass(disp)






func assert_call_count(inst, method_name, expected_count, parameters = null):
    var count = gut.get_spy().call_count(inst, method_name, parameters)

    if (_fail_if_parameters_not_array(parameters)):
        return

    var param_text = ""
    if (parameters):
        param_text = " with parameters " + str(parameters)
    var disp = "Expected [%s] on %s to be called [%s] times%s.  It was called [%s] times."
    disp = disp % [method_name, _str(inst), expected_count, param_text, count]

    if ( !_utils.is_double(inst)):
        _fail("You must pass a doubled instance to assert_call_count.  Check the wiki for info on using double.")
    else:
        if (count == expected_count):
            _pass(disp)
        else:
            _fail(str(disp, "\n", _get_desc_of_calls_to_instance(inst)))




func assert_null(got, text = ""):
    var disp = str("Expected [", _str(got), "] to be NULL:  ", text)
    if (got == null):
        _pass(disp)
    else:
        _fail(disp)




func assert_not_null(got, text = ""):
    var disp = str("Expected [", _str(got), "] to be anything but NULL:  ", text)
    if (got == null):
        _fail(disp)
    else:
        _pass(disp)





func assert_freed(obj, title = "something"):
    var disp = title
    if (is_instance_valid(obj)):
        disp = _strutils.type2str(obj) + title
    assert_true( not is_instance_valid(obj), "Expected [%s] to be freed" % disp)




func assert_not_freed(obj, title):
    var disp = title
    if (is_instance_valid(obj)):
        disp = _strutils.type2str(obj) + title
    assert_true(is_instance_valid(obj), "Expected [%s] to not be freed" % disp)






func assert_no_new_orphans(text = ""):
    var count = gut.get_orphan_counter().get_counter("test")
    var msg = ""
    if (text != ""):
        msg = ":  " + text



    if (count > 0):
        _fail(str("Expected no orphans, but found ", count, msg))
    else:
        _pass("No new orphans found." + msg)






func _validate_singleton_name(singleton_name):
    var is_valid = true
    if (typeof(singleton_name) != TYPE_STRING):
        _lgr.error("double_singleton requires a Godot singleton name, you passed " + _str(singleton_name))
        is_valid = false



    elif ( !ClassDB.class_exists(singleton_name) and !ClassDB.class_exists("_" + singleton_name)):
        var txt = str("The singleton [", singleton_name, "] could not be found.  ", 
                    "Check the GlobalScope page for a list of singletons.")
        _lgr.error(txt)
        is_valid = false
    return is_valid




func assert_setget(
    instance, name_property, 
    const_or_setter = null, getter = "__not_set__"):
    _lgr.deprecated("assert_setget")
    _fail("assert_setget has been removed.  Use assert_property, assert_set_property, assert_readonly_property instead.")






func assert_set_property(obj, property_name, new_value, expected_value):
    pending("this hasn't been implemented yet")






func assert_readonly_property(obj, property_name, new_value, expected_value):
    pending("this hasn't been implemented yet")






func _warn_for_public_accessors(obj, property_name):
    var public_accessors = []
    var accessor_names = [
        str("get_", property_name), 
        str("is_", property_name), 
        str("set_", property_name)
    ]

    for acc in accessor_names:
        if (obj.has_method(acc)):
            public_accessors.append(acc)

    if (public_accessors.size() > 0):
        _lgr.warn(str("Public accessors ", public_accessors, " found for property ", property_name))







func assert_property_with_backing_variable(obj, property_name, default_value, new_value, backed_by_name = null):
    var setter_name = str("@", property_name, "_setter")
    var getter_name = str("@", property_name, "_getter")
    var backing_name = GutUtils.nvl(backed_by_name, str("_", property_name))
    var pre_fail_count = get_fail_count()

    var props = obj.get_property_list()
    var found = false
    var idx = 0
    while (idx < props.size() and !found):
        found = props[idx].name == backing_name
        idx += 1

    assert_true(found, str(obj, " has ", backing_name, " variable."))
    assert_true(obj.has_method(setter_name), str("There should be a setter for ", property_name))
    assert_true(obj.has_method(getter_name), str("There should be a getter for ", property_name))

    if (pre_fail_count == get_fail_count()):
        var call_setter = Callable(obj, setter_name)
        var call_getter = Callable(obj, getter_name)

        assert_eq(obj.get(backing_name), default_value, str("Variable ", backing_name, " has default value."))
        assert_eq(call_getter.call(), default_value, "Getter returns default value.")
        call_setter.call(new_value)
        assert_eq(call_getter.call(), new_value, "Getter returns value from Setter.")
        assert_eq(obj.get(backing_name), new_value, str("Variable ", backing_name, " was set"))

    _warn_for_public_accessors(obj, property_name)







func assert_property(obj, property_name, default_value, new_value) -> void :
    var free_me = null
    var resource = null
    var pre_fail_count = get_fail_count()

    var setter_name = str("@", property_name, "_setter")
    var getter_name = str("@", property_name, "_getter")

    if (typeof(obj) != TYPE_OBJECT):
        _fail(str(_str(obj), " is not an object"))
        return

    assert_has_method(obj, setter_name)
    assert_has_method(obj, getter_name)

    if (pre_fail_count == get_fail_count()):
        var call_setter = Callable(obj, setter_name)
        var call_getter = Callable(obj, getter_name)

        assert_eq(call_getter.call(), default_value, "Default value")
        call_setter.call(new_value)
        assert_eq(call_getter.call(), new_value, "Getter gets Setter value")

    _warn_for_public_accessors(obj, property_name)





func pending(text = ""):
    _summary.pending += 1
    if (gut):
        _lgr.pending(text)
        gut._pending(text)






func wait_seconds(time, msg = ""):
    var to_return = gut.set_wait_time(time, msg)
    return to_return

func yield_for(time, msg = ""):
    _lgr.deprecated("yield_for", "wait_seconds")
    var to_return = gut.set_wait_time(time, msg)
    return to_return





func wait_for_signal(sig, max_wait, msg = ""):
    watch_signals(sig.get_object())
    var to_return = gut.set_wait_for_signal_or_time(sig.get_object(), sig.get_name(), max_wait, msg)
    return to_return


func yield_to(obj, signal_name, max_wait, msg = ""):
    _lgr.deprecated("yield_to", "wait_for_signal")
    watch_signals(obj)
    var to_return = gut.set_wait_for_signal_or_time(obj, signal_name, max_wait, msg)
    return to_return





func wait_frames(frames, msg = ""):
    if (frames <= 0):
        var text = str("yeild_frames:  frames must be > 0, you passed  ", frames, ".  0 frames waited.")
        _lgr.error(text)
        frames = 1

    var to_return = gut.set_wait_frames(frames, msg)
    return to_return


func yield_frames(frames, msg = ""):
    _lgr.deprecated("yield_frames", "wait_frames")
    var to_return = wait_frames(frames, msg)
    return to_return

func get_summary():
    return _summary

func get_fail_count():
    return _summary.failed

func get_pass_count():
    return _summary.passed

func get_pending_count():
    return _summary.pending

func get_assert_count():
    return _summary.asserts

func clear_signal_watcher():
    _signal_watcher.clear()

func get_double_strategy():
    return gut.get_doubler().get_strategy()

func set_double_strategy(double_strategy):
    gut.get_doubler().set_strategy(double_strategy)

func pause_before_teardown():
    gut.pause_before_teardown()




func get_summary_text():
    var to_return = get_script().get_path() + "\n"
    to_return += str("  ", _summary.passed, " of ", _summary.asserts, " passed.")
    if (_summary.pending > 0):
        to_return += str("\n  ", _summary.pending, " pending")
    if (_summary.failed > 0):
        to_return += str("\n  ", _summary.failed, " failed.")
    return to_return









func _smart_double(thing, double_strat, partial):
    var override_strat = GutUtils.nvl(double_strat, gut.get_doubler().get_strategy())
    var to_return = null

    if (thing is PackedScene):
        if (partial):
            to_return = gut.get_doubler().partial_double_scene(thing, override_strat)
        else:
            to_return = gut.get_doubler().double_scene(thing, override_strat)

    elif (_utils.is_native_class(thing)):
        if (partial):
            to_return = gut.get_doubler().partial_double_gdnative(thing)
        else:
            to_return = gut.get_doubler().double_gdnative(thing)

    elif (thing is GDScript):
        if (partial):
            to_return = gut.get_doubler().partial_double(thing, override_strat)
        else:
            to_return = gut.get_doubler().double(thing, override_strat)

    return to_return






func _are_double_parameters_valid(thing, p2, p3):
    var bad_msg = ""
    if (p3 != null or typeof(p2) == TYPE_STRING):
        bad_msg += "Doubling using a subpath is not supported.  Call register_inner_class and then pass the Inner Class to double().\n"

    if (typeof(thing) == TYPE_STRING):
        bad_msg += "Doubling using the path to a script or scene is no longer supported.  Load the script or scene and pass that to double instead.\n"

    if (_utils.is_instance(thing)):
        bad_msg += "double requires a script, you passed an instance:  " + _str(thing)

    if (bad_msg != ""):
        _lgr.error(bad_msg)

    return bad_msg == ""




func double(thing, double_strat = null, not_used_anymore = null):
    if ( !_are_double_parameters_valid(thing, double_strat, not_used_anymore)):
        return null

    return _smart_double(thing, double_strat, false)



func partial_double(thing, double_strat = null, not_used_anymore = null):
    if ( !_are_double_parameters_valid(thing, double_strat, not_used_anymore)):
        return null

    return _smart_double(thing, double_strat, true)




func double_singleton(singleton_name):
    return null








func partial_double_singleton(singleton_name):
    return null








func double_scene(path, strategy = null):
    _lgr.deprecated("test.double_scene has been removed.", "double")
    return null







func double_script(path, strategy = null):
    _lgr.deprecated("test.double_script has been removed.", "double")
    return null







func double_inner(path, subpath, strategy = null):
    _lgr.deprecated("double_inner should not be used.  Use register_inner_classes and double instead.", "double")
    return null

    var override_strat = GutUtils.nvl(strategy, gut.get_doubler().get_strategy())
    return gut.get_doubler().double_inner(path, subpath, override_strat)






func ignore_method_when_doubling(thing, method_name):
    if (typeof(thing) == TYPE_STRING):
        _lgr.error("ignore_method_when_doubling no longer supports paths to scripts or scenes.  Load them and pass them instead.")
        return

    var r = thing
    if (thing is PackedScene):
        r = GutUtils.get_scene_script_object(thing)

    gut.get_doubler().add_ignored_method(r, method_name)












func stub(thing, p2, p3 = null):
    if (_utils.is_instance(thing) and !_utils.is_double(thing)):
        _lgr.error(str("You cannot use stub on ", _str(thing), " because it is not a double."))
        return _utils.StubParams.new()

    var method_name = p2
    var subpath = null
    if (p3 != null):
        subpath = p2
        method_name = p3

    var sp = _utils.StubParams.new(thing, method_name, subpath)
    gut.get_stubber().add_stub(sp)
    return sp




func simulate(obj, times, delta, check_is_processing: bool = false):
    gut.simulate(obj, times, delta, check_is_processing)










func replace_node(base_node, path_or_node, with_this):
    var path = path_or_node

    if (typeof(path_or_node) != TYPE_STRING):




        path = base_node.get_path_to(path_or_node)
        if (path.get_name_count() == 0):
            _lgr.error("You passed an object that base_node does not have.  Cannot replace node.")
            return

    if ( !base_node.has_node(path)):
        _lgr.error(str("Could not find node at path [", path, "]"))
        return

    var to_replace = base_node.get_node(path)
    var parent = to_replace.get_parent()
    var replace_name = to_replace.get_name()

    parent.remove_child(to_replace)
    parent.add_child(with_this)
    with_this.set_name(replace_name)
    with_this.set_owner(parent)

    var groups = to_replace.get_groups()
    for i in range(groups.size()):
        with_this.add_to_group(groups[i])

    to_replace.queue_free()







func use_parameters(params):
    var ph = gut.parameter_handler
    if (ph == null):
        ph = _utils.ParameterHandler.new(params)
        gut.parameter_handler = ph




    var output = str("- params[", ph.get_call_count(), "]", "(", ph.get_current_parameters(), ")")
    gut.p(output, gut.LOG_LEVEL_TEST_AND_FAILURES)

    return ph.next_parameters()






func autofree(thing):
    gut.get_autofree().add_free(thing)
    return thing






func autoqfree(thing):
    gut.get_autofree().add_queue_free(thing)
    return thing




func add_child_autofree(node, legible_unique_name = false):
    gut.get_autofree().add_free(node)


    super .add_child(node, legible_unique_name)
    return node




func add_child_autoqfree(node, legible_unique_name = false):
    gut.get_autofree().add_queue_free(node)


    super .add_child(node, legible_unique_name)
    return node




func is_passing():
    if (gut.get_current_test_object() != null and 
        !["before_all", "after_all"].has(gut.get_current_test_object().name)):
        return gut.get_current_test_object().is_passing() and \
gut.get_current_test_object().assert_count > 0
    else:
        _lgr.error("No current test object found.  is_passing must be called inside a test.")
        return null




func is_failing():
    if (gut.get_current_test_object() != null and 
        !["before_all", "after_all"].has(gut.get_current_test_object().name)):

        return gut.get_current_test_object().is_failing()
    else:
        _lgr.error("No current test object found.  is_failing must be called inside a test.")
        return null





func pass_test(text):
    _pass(text)




func fail_test(text):
    _fail(text)





func compare_deep(v1, v2, max_differences = null):
    var result = _compare.deep(v1, v2)
    if (max_differences != null):
        result.max_differences = max_differences
    return result




func compare_shallow(v1, v2, max_differences = null):
    _fail("compare_shallow has been removed.  Use compare_deep or just compare using == instead.")
    _lgr.error("compare_shallow has been removed.  Use compare_deep or just compare using == instead.")
    return null





func assert_eq_deep(v1, v2):
    var result = compare_deep(v1, v2)
    if (result.are_equal):
        _pass(result.get_short_summary())
    else:
        _fail(result.summary)




func assert_ne_deep(v1, v2):
    var result = compare_deep(v1, v2)
    if ( !result.are_equal):
        _pass(result.get_short_summary())
    else:
        _fail(result.get_short_summary())




func assert_eq_shallow(v1, v2):
    _fail("assert_eq_shallow has been removed.  Use assert_eq/assert_same/assert_eq_deep")




func assert_ne_shallow(v1, v2):
    _fail("assert_eq_shallow has been removed.  Use assert_eq/assert_same/assert_eq_deep")





func assert_same(v1, v2, text = ""):
    var disp = "[" + _str(v1) + "] expected to be same as  [" + _str(v2) + "]:  " + text
    if (is_same(v1, v2)):
        _pass(disp)
    else:
        _fail(disp)

func assert_not_same(v1, v2, text = ""):
    var disp = "[" + _str(v1) + "] expected to not be same as  [" + _str(v2) + "]:  " + text
    if (is_same(v1, v2)):
        _fail(disp)
    else:
        _pass(disp)











func skip_if_godot_version_lt(expected):
    var should_skip = !_utils.is_godot_version_gte(expected)
    if (should_skip):
        _pass(str("Skipping ", _utils.godot_version(), " is less than ", expected))
    return should_skip












func skip_if_godot_version_ne(expected):
    var should_skip = !_utils.is_godot_version(expected)
    if (should_skip):
        _pass(str("Skipping ", _utils.godot_version(), " is not ", expected))
    return should_skip






func register_inner_classes(base_script):
    gut.get_doubler().inner_class_registry.register(base_script)
