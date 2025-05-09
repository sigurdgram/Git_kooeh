extends "res://addons/gut/gut_to_move.gd"













const LOG_LEVEL_FAIL_ONLY = 0
const LOG_LEVEL_TEST_AND_FAILURES = 1
const LOG_LEVEL_ALL_ASSERTS = 2
const WAITING_MESSAGE = "/# waiting #/"
const PAUSE_MESSAGE = "/# Pausing.  Press continue button...#/"
const COMPLETED = "completed"




signal start_pause_before_teardown
signal end_pause_before_teardown

signal start_run
signal end_run
signal start_script(test_script_obj)
signal end_script
signal start_test(test_name)
signal end_test









var _inner_class_name = ""

var inner_class_name = _inner_class_name:
    get: return _inner_class_name
    set(val): _inner_class_name = val

var _ignore_pause_before_teardown = false


var ignore_pause_before_teardown = _ignore_pause_before_teardown:
    get: return _ignore_pause_before_teardown
    set(val): _ignore_pause_before_teardown = val


var _temp_directory = "user://gut_temp_directory"

var temp_directory = _temp_directory:
    get: return _temp_directory
    set(val): _temp_directory = val


var _log_level = 1

var log_level = _log_level:
    get: return _log_level
    set(val): _set_log_level(val)




var _disable_strict_datatype_checks = false
var disable_strict_datatype_checks = false:
    get: return _disable_strict_datatype_checks
    set(val): _disable_strict_datatype_checks = val

var _export_path = ""


var export_path = "":
    get: return _export_path
    set(val): _export_path = val

var _include_subdirectories = false


var include_subdirectories = _include_subdirectories:
    get: return _include_subdirectories
    set(val): _include_subdirectories = val


var _double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY

var double_strategy = _double_strategy:
    get: return _double_strategy
    set(val):
        if (GutUtils.DOUBLE_STRATEGY.values().has(val)):
            _double_strategy = val
            _doubler.set_strategy(double_strategy)
        else:
            _lgr.error(str("gut.gd:  invalid double_strategy ", val))

var _pre_run_script = ""


var pre_run_script = _pre_run_script:
    get: return _pre_run_script
    set(val): _pre_run_script = val

var _post_run_script = ""


var post_run_script = _post_run_script:
    get: return _post_run_script
    set(val): _post_run_script = val

var _color_output = false

var color_output = false:
    get: return _color_output
    set(val):
        _color_output = val
        _lgr.disable_formatting( !_color_output)

var _junit_xml_file = ""


var junit_xml_file = "":
    get: return _junit_xml_file
    set(val): _junit_xml_file = val

var _junit_xml_timestamp = false


var junit_xml_timestamp = false:
    get: return _junit_xml_timestamp
    set(val): _junit_xml_timestamp = val




var paint_after = 0.1:
    get: return paint_after
    set(val): paint_after = val

var _unit_test_name = ""

var unit_test_name = _unit_test_name:
    get: return _unit_test_name
    set(val): _unit_test_name = val

var _parameter_handler = null



var parameter_handler = _parameter_handler:
    get: return _parameter_handler
    set(val):
        _parameter_handler = val
        _parameter_handler.set_logger(_lgr)

var _lgr = _utils.get_logger()


var logger = _lgr:
    get: return _lgr
    set(val):
        _lgr = val
        _lgr.set_gut(self)

var _add_children_to = self




var add_children_to = self:
    get: return _add_children_to
    set(val): _add_children_to = val


var _treat_error_as_failure = true
var treat_error_as_failure = _treat_error_as_failure:
    get: return _treat_error_as_failure
    set(val): _treat_error_as_failure = val




var _test_collector = _utils.TestCollector.new()
func get_test_collector():
    return _test_collector


func get_version():
    return _utils.version

var _orphan_counter = _utils.OrphanCounter.new()
func get_orphan_counter():
    return _orphan_counter

var _autofree = _utils.AutoFree.new()
func get_autofree():
    return _autofree

var _stubber = _utils.Stubber.new()
func get_stubber():
    return _stubber

var _doubler = _utils.Doubler.new()
func get_doubler():
    return _doubler

var _spy = _utils.Spy.new()
func get_spy():
    return _spy

var _is_running = false
func is_running():
    return _is_running





var _should_print_versions = true
var _should_print_summary = true

var _test_prefix = "test_"
var _file_prefix = "test_"
var _inner_class_prefix = "Test"

var _select_script = ""
var _last_paint_time = 0.0
var _strutils = _utils.Strutils.new()



var _pre_run_script_instance = null
var _post_run_script_instance = null

var _script_name = null


var _test_script_objects = []

var _waiting = false
var _done = false


var _start_time = 0.0


var _current_test = null
var _pause_before_teardown = false


var _awaiter = _utils.Awaiter.new()







var _cancel_import = false



var _auto_queue_free_delay = 0.1



func _init():



    _lgr.set_gut(self)

    _doubler.set_stubber(_stubber)
    _doubler.set_spy(_spy)
    _doubler.set_gut(self)


    _doubler.set_logger(_lgr)
    _spy.set_logger(_lgr)
    _stubber.set_logger(_lgr)
    _test_collector.set_logger(_lgr)






func _ready():
    if ( !_utils.is_version_ok()):
        _print_versions()
        push_error(_utils.get_bad_version_text())
        print("Error:  ", _utils.get_bad_version_text())
        get_tree().quit()
        return

    if (_should_print_versions):
        _lgr.info(str("using [", OS.get_user_data_dir(), "] for temporary output."))

    add_child(_awaiter)

    if (_select_script != null):
        select_script(_select_script)

    _print_versions()




func _notification(what):
    if (what == NOTIFICATION_PREDELETE):
        for test_script in _test_script_objects:
            if (is_instance_valid(test_script)):
                test_script.free()

        _test_script_objects = []
        if (is_instance_valid(_awaiter)):
            _awaiter.free()


func _print_versions(send_all = true):
    if ( !_should_print_versions):
        return

    var info = _utils.get_version_text()

    if (send_all):
        p(info)
    else:
        _lgr.get_printer("gui").send(info + "\n")














func _set_log_level(level):
    _log_level = max(level, 0)


    _lgr.set_less_test_names(level == 0)

    _lgr.set_type_enabled(_lgr.types.normal, true)
    _lgr.set_type_enabled(_lgr.types.error, true)
    _lgr.set_type_enabled(_lgr.types.pending, true)


    _lgr.set_type_enabled(_lgr.types.warn, level > 0)
    _lgr.set_type_enabled(_lgr.types.deprecated, level > 0)


    _lgr.set_type_enabled(_lgr.types.passed, level > 1)
    _lgr.set_type_enabled(_lgr.types.info, level > 1)
    _lgr.set_type_enabled(_lgr.types.debug, level > 1)






func end_teardown_pause():
    _pause_before_teardown = false
    _waiting = false
    end_pause_before_teardown.emit()






func _log_test_children_warning(test_script):
    if ( !_lgr.is_type_enabled(_lgr.types.orphan)):
        return

    var kids = test_script.get_children()
    if (kids.size() > 0):
        var msg = ""
        if (_log_level == 2):
            msg = "Test script still has children when all tests finisehd.\n"
            for i in range(kids.size()):
                msg += str("  ", _strutils.type2str(kids[i]), "\n")
            msg += "You can use autofree, autoqfree, add_child_autofree, or add_child_autoqfree to automatically free objects."
        else:
            msg = str("Test script has ", kids.size(), " unfreed children.  Increase log level for more details.")


        _lgr.warn(msg)


func _log_end_run():
    if (_should_print_summary):
        var summary = _utils.Summary.new(self)
        summary.log_end_run()


func _validate_hook_script(path):
    var result = {
        valid = true, 
        instance = null
    }


    if (path == ""):
        return result

    if (FileAccess.file_exists(path)):
        var inst = load(path).new()
        if (inst and inst is GutHookScript):
            result.instance = inst
            result.valid = true
        else:
            result.valid = false
            _lgr.error("The hook script [" + path + "] does not extend GutHookScript")
    else:
        result.valid = false
        _lgr.error("The hook script [" + path + "] does not exist.")

    return result






func _run_hook_script(inst):
    if (inst != null):
        inst.gut = self
        inst.run()
    return inst




func _init_run():
    var valid = true
    _test_collector.set_test_class_prefix(_inner_class_prefix)
    _test_script_objects = []
    _current_test = null
    _is_running = true

    var pre_hook_result = _validate_hook_script(_pre_run_script)
    _pre_run_script_instance = pre_hook_result.instance
    var post_hook_result = _validate_hook_script(_post_run_script)
    _post_run_script_instance = post_hook_result.instance

    valid = pre_hook_result.valid and post_hook_result.valid

    return valid





func _end_run():
    _log_end_run()
    _is_running = false

    _run_hook_script(_post_run_script_instance)
    _export_results()
    end_run.emit()





func _export_results():
    if (_junit_xml_file != ""):
        _export_junit_xml()



func _export_junit_xml():
    var exporter = _utils.JunitXmlExport.new()
    var output_file = _junit_xml_file

    if (_junit_xml_timestamp):
        var ext = "." + output_file.get_extension()
        output_file = output_file.replace(ext, str("_", Time.get_unix_time_from_system(), ext))

    var f_result = exporter.write_file(self, output_file)
    if (f_result == OK):
        p(str("Results saved to ", output_file))





func _print_script_heading(coll_script):
    if (_does_class_name_match(_inner_class_name, coll_script.inner_class_name)):
        _lgr.log(str("\n\n", coll_script.get_full_name()), _lgr.fmts.underline)





func _does_class_name_match(the_class_name, script_class_name):
    return (the_class_name == null or the_class_name == "") or \
(script_class_name != null and str(script_class_name).findn(the_class_name) != -1)




func _setup_script(test_script):
    test_script.gut = self
    test_script.set_logger(_lgr)
    _add_children_to.add_child(test_script)
    _test_script_objects.append(test_script)





func _wait_for_continue_button():
    p(PAUSE_MESSAGE, 0)
    _waiting = true
    return self




func _get_indexes_matching_script_name(name):
    var indexes = []
    for i in range(_test_collector.scripts.size()):
        if (_test_collector.scripts[i].get_filename().find(name) != -1):
            indexes.append(i)
    return indexes




func _get_indexes_matching_path(path):
    var indexes = []
    for i in range(_test_collector.scripts.size()):
        if (_test_collector.scripts[i].path == path):
            indexes.append(i)
    return indexes





func _run_parameterized_test(test_script, test_name):
    await _run_test(test_script, test_name)

    if (_current_test.assert_count == 0 and !_current_test.pending):
        _lgr.risky("Test did not assert")

    if (_parameter_handler == null):
        _lgr.error(str("Parameterized test ", _current_test.name, " did not call use_parameters for the default value of the parameter."))
        _fail(str("Parameterized test ", _current_test.name, " did not call use_parameters for the default value of the parameter."))
    else:
        while ( !_parameter_handler.is_done()):
            var cur_assert_count = _current_test.assert_count
            await _run_test(test_script, test_name)
            if (_current_test.assert_count == cur_assert_count and !_current_test.pending):
                _lgr.risky("Test did not assert")

    _parameter_handler = null





func _run_test(script_inst, test_name):
    _lgr.log_test_name()
    _lgr.set_indent_level(1)
    _orphan_counter.add_counter("test")
    var script_result = null

    await script_inst.before_each()

    start_test.emit(test_name)

    await script_inst.call(test_name)



    if (_pause_before_teardown and !_ignore_pause_before_teardown):
        start_pause_before_teardown.emit()
        await _wait_for_continue_button().end_pause_before_teardown

    script_inst.clear_signal_watcher()


    await script_inst.after_each()




    var aqf_count = _autofree.get_queue_free_count()
    _autofree.free_all()
    if (aqf_count > 0):
        await get_tree().create_timer(_auto_queue_free_delay).timeout

    if (_log_level > 0):
        _orphan_counter.print_orphans("test", _lgr)

    _doubler.get_ignored_methods().clear()








func _call_before_all(test_script, collected_script):
    var before_all_test_obj = _utils.CollectedTest.new()
    before_all_test_obj.has_printed_name = false
    before_all_test_obj.name = "before_all"

    collected_script.setup_teardown_tests.append(before_all_test_obj)
    _current_test = before_all_test_obj

    _lgr.inc_indent()
    await test_script.before_all()


    before_all_test_obj.was_run = before_all_test_obj.did_something()

    _lgr.dec_indent()

    _current_test = null








func _call_after_all(test_script, collected_script):
    var after_all_test_obj = _utils.CollectedTest.new()
    after_all_test_obj.has_printed_name = false
    after_all_test_obj.name = "after_all"

    collected_script.setup_teardown_tests.append(after_all_test_obj)
    _current_test = after_all_test_obj

    _lgr.inc_indent()
    await test_script.after_all()


    after_all_test_obj.was_run = after_all_test_obj.did_something()
    _lgr.dec_indent()

    _current_test = null





func _test_the_scripts(indexes = []):
    _orphan_counter.add_counter("total")

    _print_versions(false)
    var is_valid = _init_run()
    if ( !is_valid):
        _lgr.error("Something went wrong and the run was aborted.")
        return

    _run_hook_script(_pre_run_script_instance)
    if (_pre_run_script_instance != null and _pre_run_script_instance.should_abort()):
        _lgr.error("pre-run abort")
        end_run.emit()
        return

    start_run.emit()
    _start_time = Time.get_ticks_msec()
    _last_paint_time = _start_time

    var indexes_to_run = []
    if (indexes.size() == 0):
        for i in range(_test_collector.scripts.size()):
            indexes_to_run.append(i)
    else:
        indexes_to_run = indexes



    for test_indexes in range(indexes_to_run.size()):
        var coll_script = _test_collector.scripts[indexes_to_run[test_indexes]]
        _orphan_counter.add_counter("script")

        if (coll_script.tests.size() > 0):
            _lgr.set_indent_level(0)
            _print_script_heading(coll_script)

        if ( !coll_script.is_loaded):
            break

        start_script.emit(coll_script)

        var test_script = coll_script.get_new()




        var skip_script = test_script.get("skip_script")
        if (skip_script != null):
            var msg = str("- [Script skipped]:  ", skip_script)
            _lgr.inc_indent()
            _lgr.log(msg, _lgr.fmts.yellow)
            _lgr.dec_indent()
            coll_script.skip_reason = skip_script
            coll_script.was_skipped = true
            continue


        var script_result = null
        _setup_script(test_script)
        _doubler.set_strategy(_double_strategy)






        if ( !_does_class_name_match(_inner_class_name, coll_script.inner_class_name)):
            coll_script.tests = []
        else:
            coll_script.was_run = true
            await _call_before_all(test_script, coll_script)


        var skip_suffix = "_skip__"
        coll_script.mark_tests_to_skip_with_suffix(skip_suffix)
        for i in range(coll_script.tests.size()):
            _stubber.clear()
            _spy.clear()
            _current_test = coll_script.tests[i]
            script_result = null



            if (_current_test.should_skip):
                continue


            if ((_unit_test_name != "" and _current_test.name.find(_unit_test_name) > -1) or 
                (_unit_test_name == "")):

                if (_current_test.arg_count > 1):
                    _lgr.error(str("Parameterized test ", _current_test.name, 
                        " has too many parameters:  ", _current_test.arg_count, "."))
                elif (_current_test.arg_count == 1):
                    _current_test.was_run = true
                    script_result = await _run_parameterized_test(test_script, _current_test.name)
                else:
                    _current_test.was_run = true
                    script_result = await _run_test(test_script, _current_test.name)

                if ( !_current_test.did_something()):
                    _lgr.risky(str(_current_test.name, " did not assert"))

                _current_test.has_printed_name = false
                end_test.emit()



                if (paint_after > 0.0):
                    var now = Time.get_ticks_msec()
                    var time_since = (now - _last_paint_time) / 1000.0
                    if (time_since > paint_after):
                        _last_paint_time = now
                        await get_tree().process_frame

        _current_test = null
        _lgr.dec_indent()
        _orphan_counter.print_orphans("script", _lgr)

        if (_does_class_name_match(_inner_class_name, coll_script.inner_class_name)):
            await _call_after_all(test_script, coll_script)

        _log_test_children_warning(test_script)




        _add_children_to.remove_child(test_script)

        _lgr.set_indent_level(0)
        if (test_script.get_assert_count() > 0):
            var script_sum = str(coll_script.get_passing_test_count(), "/", coll_script.get_ran_test_count(), " passed.")
            _lgr.log(script_sum, _lgr.fmts.bold)

        end_script.emit()


    _lgr.set_indent_level(0)
    _end_run()




func _pass(text = ""):
    if (_current_test):
        _current_test.add_pass(text)






func get_call_count_text():
    var to_return = ""
    if (_parameter_handler != null):




        to_return = str("params[", _parameter_handler.get_call_count() - 1, "] ")
    return to_return




func _fail(text = ""):
    if (_current_test != null):
        var line_number = _extract_line_number(_current_test)
        var line_text = "  at line " + str(line_number)
        p(line_text, LOG_LEVEL_FAIL_ONLY)

        line_text = "\n    " + line_text
        var call_count_text = get_call_count_text()
        _current_test.line_number = line_number
        _current_test.add_fail(call_count_text + text + line_text)







func _fail_for_error(err_text):
    if (_current_test != null and treat_error_as_failure):
        _fail(err_text)




func _pending(text = ""):
    if (_current_test):
        _current_test.add_pending(text)





func _extract_line_number(current_test):
    var line_number = -1

    var stackTrace = get_stack()
    if (stackTrace != null):
        for index in stackTrace.size():
            var line = stackTrace[index]
            var function = line.get("function")
            if function == current_test.name:
                line_number = line.get("line")
    return line_number






func _get_files(path, prefix, suffix):
    var files = []
    var directories = []

    if (path == "res://addons/gut"):
        return [];

    var d = DirAccess.open(path)

    d.list_dir_begin()




    var fs_item = d.get_next()
    var full_path = ""
    while (fs_item != ""):
        full_path = path.path_join(fs_item)


        if (d.file_exists(full_path)):
            if (fs_item.begins_with(prefix) and fs_item.ends_with(suffix)):
                files.append(full_path)
        elif (include_subdirectories and d.dir_exists(full_path)):
            directories.append(full_path)

        fs_item = d.get_next()
    d.list_dir_end()

    for dir in range(directories.size()):
        var dir_files = _get_files(directories[dir], prefix, suffix)
        for i in range(dir_files.size()):
            files.append(dir_files[i])

    files.sort()
    return files







func get_elapsed_time():
    var to_return = 0.0
    if (_start_time != 0.0):
        to_return = Time.get_ticks_msec() - _start_time
    to_return = to_return / 1000.0

    return to_return










func p(text, level = 0):
    var str_text = str(text)

    if (level <= GutUtils.nvl(_log_level, 0)):
        _lgr.log(str_text)










func test_scripts(run_rest = false):
    if (_script_name != null and _script_name != ""):
        var indexes = _get_indexes_matching_script_name(_script_name)
        if (indexes == []):
            _lgr.error(str(
                "Could not find script matching '", _script_name, "'.\n", 
                "Check your directory settings and Script Prefix/Suffix settings."))
        else:
            _test_the_scripts(indexes)
    else:
        _test_the_scripts([])


func run_tests(run_rest = false):
    test_scripts(run_rest)





func test_script(script):
    _test_collector.set_test_class_prefix(_inner_class_prefix)
    _test_collector.clear()
    _test_collector.add_script(script)
    _test_the_scripts()





func add_script(script):
    if ( !Engine.is_editor_hint()):
        _test_collector.set_test_class_prefix(_inner_class_prefix)
        _test_collector.add_script(script)







func add_directory(path, prefix = _file_prefix, suffix = ".gd"):



    if (path == "" or path == null):
        return

    var dir = DirAccess.open(path)
    if (dir == null):
        _lgr.error(str("The path [", path, "] does not exist."))


    else:
        var files = _get_files(path, prefix, suffix)
        for i in range(files.size()):
            if (_script_name == null or _script_name == "" or \
(_script_name != null and files[i].findn(_script_name) != -1)):
                add_script(files[i])










func select_script(script_name):
    _script_name = script_name
    _select_script = script_name




func export_tests(path = _export_path):
    if (path == null):
        _lgr.error("You must pass a path or set the export_path before calling export_tests")
    else:
        var result = _test_collector.export_tests(path)
        if (result):
            _lgr.info(_test_collector.to_s())
            _lgr.info("Exported to " + path)




func import_tests(path = _export_path):
    if ( !_utils.file_exists(path)):
        _lgr.error(str("Cannot import tests:  the path [", path, "] does not exist."))
    else:
        _test_collector.clear()
        var result = _test_collector.import_tests(path)
        if (result):
            _lgr.info("\n" + _test_collector.to_s())
            _lgr.info("Imported from " + path)




func import_tests_if_none_found():
    if ( !_cancel_import and _test_collector.scripts.size() == 0):
        import_tests()




func export_if_tests_found():
    if (_test_collector.scripts.size() > 0):
        export_tests()










func maximize():
    _lgr.deprecated("gut.maximize")





func clear_text():
    _lgr.deprecated("gut.clear_text")





func get_test_count():
    return _test_collector.get_ran_test_count()




func get_assert_count():
    return _test_collector.get_assert_count()




func get_pass_count():
    return _test_collector.get_pass_count()




func get_fail_count():
    return _test_collector.get_fail_count()




func get_pending_count():
    return _test_collector.get_pending_count()






func pause_before_teardown():
    _pause_before_teardown = true;






func set_wait_time(time, text = ""):
    _awaiter.wait_for(time)
    _lgr.yield_msg(str("-- Awaiting ", time, " second(s) -- ", text))
    return _awaiter.timeout





func set_wait_frames(frames, text = ""):
    _awaiter.wait_frames(frames)
    _lgr.yield_msg(str("-- Awaiting ", frames, " frame(s) -- ", text))
    return _awaiter.timeout





func set_wait_for_signal_or_time(obj, signal_name, max_wait, text = ""):
    _awaiter.wait_for_signal(Signal(obj, signal_name), max_wait)
    _lgr.yield_msg(str("-- Awaiting signal \"", signal_name, "\" or for ", max_wait, " second(s) -- ", text))
    return _awaiter.timeout





func get_current_script_object():
    var to_return = null
    if (_test_script_objects.size() > 0):
        to_return = _test_script_objects[-1]
    return to_return




func get_current_test_object():
    return _current_test




func get_summary():
    return _utils.Summary.new(self)



func get_pre_run_script_instance():
    return _pre_run_script_instance



func get_post_run_script_instance():
    return _post_run_script_instance



func show_orphans(should):
    _lgr.set_type_enabled(_lgr.types.orphan, should)


func get_logger():
    return _lgr
