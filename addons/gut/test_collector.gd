






var CollectedScript = load("res://addons/gut/collected_script.gd")
var CollectedTest = load("res://addons/gut/collected_test.gd")

var _test_prefix = "test_"
var _test_class_prefix = "Test"
var _utils = load("res://addons/gut/utils.gd").get_instance()
var _lgr = _utils.get_logger()



var scripts = []


func _does_inherit_from_test(thing):
    var base_script = thing.get_base_script()
    var to_return = false
    if (base_script != null):
        var base_path = base_script.get_path()
        if (base_path == "res://addons/gut/test.gd"):
            to_return = true
        else:
            to_return = _does_inherit_from_test(base_script)
    return to_return


func _populate_tests(test_script):
    var script = test_script.load_script()
    if (script == null):
        print("  !!! ", test_script.path, " could not be loaded")
        return false

    test_script.is_loaded = true
    var methods = script.get_script_method_list()
    for i in range(methods.size()):
        var name = methods[i]["name"]
        if (name.begins_with(_test_prefix)):
            var t = CollectedTest.new()
            t.name = name
            t.arg_count = methods[i]["args"].size()
            test_script.tests.append(t)


func _get_inner_test_class_names(loaded):
    var inner_classes = []
    var const_map = loaded.get_script_constant_map()
    for key in const_map:
        var thing = const_map[key]
        if (_utils.is_gdscript(thing)):
            if (key.begins_with(_test_class_prefix)):
                if (_does_inherit_from_test(thing)):
                    inner_classes.append(key)
                else:
                    _lgr.warn(str("Ignoring Inner Class ", key, 
                        " because it does not extend GutTest"))






    return inner_classes


func _parse_script(test_script):
    var inner_classes = []
    var scripts_found = []

    var loaded = load(test_script.path)
    if (_does_inherit_from_test(loaded)):
        _populate_tests(test_script)
        scripts_found.append(test_script.path)
        inner_classes = _get_inner_test_class_names(loaded)
    else:
        return []

    for i in range(inner_classes.size()):
        var loaded_inner = loaded.get(inner_classes[i])
        if (_does_inherit_from_test(loaded_inner)):
            var ts = CollectedScript.new(_utils, _lgr)
            ts.path = test_script.path
            ts.inner_class_name = inner_classes[i]
            _populate_tests(ts)
            scripts.append(ts)
            scripts_found.append(test_script.path + "[" + inner_classes[i] + "]")

    return scripts_found





func add_script(path):

    if (has_script(path)):
        return []


    if ( !FileAccess.file_exists(path)):
        _lgr.error("Could not find script:  " + path)
        return

    var ts = CollectedScript.new(_utils, _lgr)
    ts.path = path





    scripts.append(ts)
    var parse_results = _parse_script(ts)

    if (parse_results.find(path) == -1):
        _lgr.warn(str("Ignoring script ", path, " because it does not extend GutTest"))
        scripts.remove_at(scripts.find(ts))

    return parse_results


func clear():
    scripts.clear()


func has_script(path):
    var found = false
    var idx = 0
    while (idx < scripts.size() and !found):
        if (scripts[idx].get_full_name() == path):
            found = true
        else:
            idx += 1
    return found


func export_tests(path):
    var success = true
    var f = ConfigFile.new()
    for i in range(scripts.size()):
        scripts[i].export_to(f, str("CollectedScript-", i))
    var result = f.save(path)
    if (result != OK):
        _lgr.error(str("Could not save exported tests to [", path, "].  Error code:  ", result))
        success = false
    return success


func import_tests(path):
    var success = false
    var f = ConfigFile.new()
    var result = f.load(path)
    if (result != OK):
        _lgr.error(str("Could not load exported tests from [", path, "].  Error code:  ", result))
    else:
        var sections = f.get_sections()
        for key in sections:
            var ts = CollectedScript.new(_utils, _lgr)
            ts.import_from(f, key)
            _populate_tests(ts)
            scripts.append(ts)
        success = true
    return success


func get_script_named(name):
    return _utils.search_array(scripts, "get_filename_and_inner", name)


func get_test_named(script_name, test_name):
    var s = get_script_named(script_name)
    if (s != null):
        return s.get_test_named(test_name)
    else:
        return null


func to_s():
    var to_return = ""
    for i in range(scripts.size()):
        to_return += scripts[i].to_s() + "\n"
    return to_return




func get_logger():
    return _lgr


func set_logger(logger):
    _lgr = logger


func get_test_prefix():
    return _test_prefix


func set_test_prefix(test_prefix):
    _test_prefix = test_prefix


func get_test_class_prefix():
    return _test_class_prefix


func set_test_class_prefix(test_class_prefix):
    _test_class_prefix = test_class_prefix


func get_scripts():
    return scripts


func get_ran_test_count():
    var count = 0
    for s in scripts:
        count += s.get_ran_test_count()
    return count


func get_ran_script_count():
    var count = 0
    for s in scripts:
        if (s.was_run):
            count += 1
    return count

func get_test_count():
    var count = 0
    for s in scripts:
        count += s.tests.size()
    return count


func get_assert_count():
    var count = 0
    for s in scripts:
        count += s.get_assert_count()
    return count


func get_pass_count():
    var count = 0
    for s in scripts:
        count += s.get_pass_count()
    return count


func get_fail_count():
    var count = 0
    for s in scripts:
        count += s.get_fail_count()
    return count


func get_pending_count():
    var count = 0
    for s in scripts:
        count += s.get_pending_count()
    return count
