







var CollectedTest = load("res://addons/gut/collected_test.gd")

var _utils = null
var _lgr = null


var tests = []


var setup_teardown_tests = []
var inner_class_name: StringName
var path: String





var is_loaded = false




var was_skipped = false
var skip_reason = ""
var was_run = false


var name = "":
    get: return path
    set(val): pass


func _init(utils = null, logger = null):
    _utils = utils
    _lgr = logger


func get_new():
    return load_script().new()


func load_script():
    var to_return = load(path)

    if (inner_class_name != null and inner_class_name != ""):





        to_return = to_return.get(inner_class_name)

    return to_return


func get_filename_and_inner():
    var to_return = get_filename()
    if (inner_class_name != ""):
        to_return += "." + String(inner_class_name)
    return to_return



func get_full_name():
    var to_return = path
    if (inner_class_name != ""):
        to_return += "." + String(inner_class_name)
    return to_return


func get_filename():
    return path.get_file()


func has_inner_class():
    return inner_class_name != ""





func export_to(config_file, section):
    config_file.set_value(section, "path", path)
    config_file.set_value(section, "inner_class", inner_class_name)
    var names = []
    for i in range(tests.size()):
        names.append(tests[i].name)
    config_file.set_value(section, "tests", names)


func _remap_path(source_path):
    var to_return = source_path
    if ( !_utils.file_exists(source_path)):
        _lgr.debug("Checking for remap for:  " + source_path)
        var remap_path = source_path.get_basename() + ".gd.remap"
        if (_utils.file_exists(remap_path)):
            var cf = ConfigFile.new()
            cf.load(remap_path)
            to_return = cf.get_value("remap", "path")
        else:
            _lgr.warn("Could not find remap file " + remap_path)
    return to_return


func import_from(config_file, section):
    path = config_file.get_value(section, "path")
    path = _remap_path(path)



    var inner_name = config_file.get_value(section, "inner_class", "Placeholder")
    if (inner_name != "Placeholder"):
        inner_class_name = inner_name
    else:
        inner_class_name = StringName("")


func get_test_named(name):
    return _utils.search_array(tests, "name", name)


func mark_tests_to_skip_with_suffix(suffix):
    for single_test in tests:
        single_test.should_skip = single_test.name.ends_with(suffix)


func get_ran_test_count():
    var count = 0
    for t in tests:
        if (t.was_run):
            count += 1
    return count


func get_assert_count():
    var count = 0
    for t in tests:
        count += t.pass_texts.size()
        count += t.fail_texts.size()
    for t in setup_teardown_tests:
        count += t.pass_texts.size()
        count += t.fail_texts.size()
    return count


func get_pass_count():
    var count = 0
    for t in tests:
        count += t.pass_texts.size()
    for t in setup_teardown_tests:
        count += t.pass_texts.size()
    return count


func get_fail_count():
    var count = 0
    for t in tests:
        count += t.fail_texts.size()
    for t in setup_teardown_tests:
        count += t.fail_texts.size()
    return count


func get_pending_count():
    var count = 0
    for t in tests:
        count += t.pending_texts.size()
    return count


func get_passing_test_count():
    var count = 0
    for t in tests:
        if (t.is_passing()):
            count += 1
    return count


func get_failing_test_count():
    var count = 0
    for t in tests:
        if (t.is_failing()):
            count += 1
    return count


func get_risky_count():
    var count = 0
    if (was_skipped):
        count = 1
    else:
        for t in tests:
            if (t.is_risky()):
                count += 1
    return count


func to_s():
    var to_return = path
    if (inner_class_name != null):
        to_return += str(".", inner_class_name)
    to_return += "\n"
    for i in range(tests.size()):
        to_return += str("  ", tests[i].to_s())
    return to_return
