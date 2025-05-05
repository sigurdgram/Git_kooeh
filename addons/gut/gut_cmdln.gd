






































extends SceneTree

var Optparse = load("res://addons/gut/optparse.gd")
var Gut = load("res://addons/gut/gut.gd")
var GutRunner = load("res://addons/gut/gui/GutRunner.tscn")

var json = JSON.new()












class OptionResolver:
    var base_opts = {}
    var cmd_opts = {}
    var config_opts = {}


    func get_value(key):
        return _nvl(cmd_opts[key], _nvl(config_opts[key], base_opts[key]))

    func set_base_opts(opts):
        base_opts = opts
        cmd_opts = _null_copy(opts)
        config_opts = _null_copy(opts)


    func _null_copy(h):
        var new_hash = {}
        for key in h:
            new_hash[key] = null
        return new_hash

    func _nvl(a, b):
        if (a == null):
            return b
        else:
            return a
    func _string_it(h):
        var to_return = ""
        for key in h:
            to_return += str("(", key, ":", _nvl(h[key], "NULL"), ")")
        return to_return

    func to_s():
        return str("base:\n", _string_it(base_opts), "\n", \
"config:\n", _string_it(config_opts), "\n", \
"cmd:\n", _string_it(cmd_opts), "\n", \
"resolved:\n", _string_it(get_resolved_values()))

    func get_resolved_values():
        var to_return = {}
        for key in base_opts:
            to_return[key] = get_value(key)
        return to_return

    func to_s_verbose():
        var to_return = ""
        var resolved = get_resolved_values()
        for key in base_opts:
            to_return += str(key, "\n")
            to_return += str("  default: ", _nvl(base_opts[key], "NULL"), "\n")
            to_return += str("  config:  ", _nvl(config_opts[key], " --"), "\n")
            to_return += str("  cmd:     ", _nvl(cmd_opts[key], " --"), "\n")
            to_return += str("  final:   ", _nvl(resolved[key], "NULL"), "\n")

        return to_return





var _utils = load("res://addons/gut/utils.gd").get_instance()
var _gut_config = load("res://addons/gut/gut_config.gd").new()

var _tester = null

var _final_opts = []


func setup_options(options, font_names):
    var opts = Optparse.new()
    opts.set_banner(
"\nThe GUT CLI\n-----------\nThe default behavior for GUT is to load options from a res://.gutconfig.json if\nit exists.  Any options specified on the command line will take precedence over\noptions specified in the gutconfig file.  You can specify a different gutconfig\nfile with the -gconfig option.\n\nTo generate a .gutconfig.json file you can use -gprint_gutconfig_sample\nTo see the effective values of a CLI command and a gutconfig use -gpo\n\nAny option that requires a value will take the form of \"-g<name>=<value>\".\nThere cannot be any spaces between the option, the \"=\", or ' + 'inside a\nspecified value or godot will think you are trying to run a scene.\n"\
\
\
\
\
\
\
\
\
\
\
\
\
\
)

    opts.add("-gselect", "", ("All scripts that contain the specified string in their filename will be ran"))
    opts.add("-ginner_class", "", "Only run inner classes that contain the specified string int their name.")
    opts.add("-gunit_test_name", "", ("Any test that contains the specified text will be run, all others will be skipped."))


    opts.add("-ginclude_subdirs", false, "Include subdirectories of -gdir.")
    opts.add("-gdir", options.dirs, "Comma delimited list of directories to add tests from.")
    opts.add("-gtest", [], "Comma delimited list of full paths to test scripts to run.")
    opts.add("-gprefix", options.prefix, "Prefix used to find tests when specifying -gdir.  Default \"[default]\".")
    opts.add("-gsuffix", options.suffix, "Test script suffix, including .gd extension.  Default \"[default]\".")
    opts.add("-gconfig", "res://.gutconfig.json", "A config file that contains configuration information.  Default is res://.gutconfig.json")
    opts.add("-gpre_run_script", "", "pre-run hook script path")
    opts.add("-gpost_run_script", "", "post-run hook script path")
    opts.add("-gerrors_do_not_cause_failure", false, "When an internal GUT error occurs tests will fail.  With this option set, that does not happen.")
    opts.add("-gdouble_strategy", "SCRIPT_ONLY", "Default strategy to use when doubling.  Valid values are [INCLUDE_NATIVE, SCRIPT_ONLY].  Default \"[default]\"")


    opts.add("-gpaint_after", options.paint_after, "Delay before GUT will add a 1 frame pause to paint the screen/GUI.  default [default]")


    opts.add("-glog", options.log_level, "Log level.  Default [default]")
    opts.add("-ghide_orphans", false, "Display orphan counts for tests and scripts.  Default \"[default]\".")
    opts.add("-gmaximize", false, "Maximizes test runner window to fit the viewport.")
    opts.add("-gcompact_mode", false, "The runner will be in compact mode.  This overrides -gmaximize.")
    opts.add("-gopacity", options.opacity, "Set opacity of test runner window. Use range 0 - 100. 0 = transparent, 100 = opaque.")
    opts.add("-gdisable_colors", false, "Disable command line colors.")
    opts.add("-gfont_name", options.font_name, str("Valid values are:  ", font_names, ".  Default \"[default]\""))
    opts.add("-gfont_size", options.font_size, "Font size, default \"[default]\"")
    opts.add("-gbackground_color", options.background_color, "Background color as an html color, default \"[default]\"")
    opts.add("-gfont_color", options.font_color, "Font color as an html color, default \"[default]\"")


    opts.add("-gexit", false, "Exit after running tests.  If not specified you have to manually close the window.")
    opts.add("-gexit_on_success", false, "Only exit if all tests pass.")
    opts.add("-gignore_pause", false, "Ignores any calls to gut.pause_before_teardown.")


    opts.add("-gh", false, "Print this help.  You did this to see this, so you probably understand.")
    opts.add("-gpo", false, "Print option values from all sources and the value used.")
    opts.add("-gprint_gutconfig_sample", false, "Print out json that can be used to make a gutconfig file.")


    opts.add("-gjunit_xml_file", options.junit_xml_file, "Export results of run to this file in the Junit XML format.")
    opts.add("-gjunit_xml_timestamp", options.junit_xml_timestamp, "Include a timestamp in the -gjunit_xml_file, default [default]")

    return opts




func extract_command_line_options(from, to):
    to.config_file = from.get_value("-gconfig")
    to.dirs = from.get_value("-gdir")
    to.disable_colors = from.get_value("-gdisable_colors")
    to.double_strategy = from.get_value("-gdouble_strategy")
    to.ignore_pause = from.get_value("-gignore_pause")
    to.include_subdirs = from.get_value("-ginclude_subdirs")
    to.inner_class = from.get_value("-ginner_class")
    to.log_level = from.get_value("-glog")
    to.opacity = from.get_value("-gopacity")
    to.post_run_script = from.get_value("-gpost_run_script")
    to.pre_run_script = from.get_value("-gpre_run_script")
    to.prefix = from.get_value("-gprefix")
    to.selected = from.get_value("-gselect")
    to.should_exit = from.get_value("-gexit")
    to.should_exit_on_success = from.get_value("-gexit_on_success")
    to.should_maximize = from.get_value("-gmaximize")
    to.compact_mode = from.get_value("-gcompact_mode")
    to.hide_orphans = from.get_value("-ghide_orphans")
    to.suffix = from.get_value("-gsuffix")
    to.errors_do_not_cause_failure = from.get_value("-gerrors_do_not_cause_failure")
    to.tests = from.get_value("-gtest")
    to.unit_test_name = from.get_value("-gunit_test_name")

    to.font_size = from.get_value("-gfont_size")
    to.font_name = from.get_value("-gfont_name")
    to.background_color = from.get_value("-gbackground_color")
    to.font_color = from.get_value("-gfont_color")
    to.paint_after = from.get_value("-gpaint_after")

    to.junit_xml_file = from.get_value("-gjunit_xml_file")
    to.junit_xml_timestamp = from.get_value("-gjunit_xml_timestamp")



func _print_gutconfigs(values):
    var header = "Here is a sample of a full .gutconfig.json file.\nYou do not need to specify all values in your own file.  The values supplied in\nthis sample are what would be used if you ran gut w/o the -gprint_gutconfig_sample\noption (option priority:  command-line, .gutconfig, default)."



    print("\n", header.replace("\n", " "), "\n\n")
    var resolved = values


    resolved.erase("config_file")
    resolved.erase("show_help")

    print("Here's a config with all the properties set based off of your current command and config.")
    print(json.stringify(resolved, "  "))

    for key in resolved:
        resolved[key] = null

    print("\n\nAnd here's an empty config for you fill in what you want.")
    print(json.stringify(resolved, " "))



func _run_gut():
    var opt_resolver = OptionResolver.new()
    opt_resolver.set_base_opts(_gut_config.default_options)

    print("\n\n", " ---  Gut  ---")
    var o = setup_options(_gut_config.default_options, _gut_config.valid_fonts)

    var all_options_valid = o.parse()
    extract_command_line_options(o, opt_resolver.cmd_opts)

    var load_result = _gut_config.load_options_no_defaults(
        opt_resolver.get_value("config_file"))


    if ( !all_options_valid or load_result == -1):
        quit(1)
    else:
        opt_resolver.config_opts = _gut_config.options

        if (o.get_value("-gh")):
            print(_utils.get_version_text())
            o.print_help()
            quit()
        elif (o.get_value("-gpo")):
            print("All command line options and where they are specified.  " + 
                "The \"final\" value shows which value will actually be used " + 
                "based on order of precedence (default < .gutconfig < cmd line)." + "\n")
            print(opt_resolver.to_s_verbose())
            quit()
        elif (o.get_value("-gprint_gutconfig_sample")):
            _print_gutconfigs(opt_resolver.get_resolved_values())
            quit()
        else:
            _final_opts = opt_resolver.get_resolved_values();
            _gut_config.options = _final_opts

            var runner = GutRunner.instantiate()

            runner.set_cmdln_mode(true)
            runner.set_gut_config(_gut_config)

            get_root().add_child(runner)
            _tester = runner.get_gut()
            _tester.connect("end_run", Callable(self, "_on_tests_finished").bind(_final_opts.should_exit, _final_opts.should_exit_on_success))

            runner.run_tests()



func _on_tests_finished(should_exit, should_exit_on_success):
    if (_final_opts.dirs.size() == 0):
        if (_tester.get_summary().get_totals().scripts == 0):
            var lgr = _tester.logger
            lgr.error("No directories configured.  Add directories with options or a .gutconfig.json file.  Use the -gh option for more information.")

    var exit_code = 0
    if (_tester.get_fail_count()):
        exit_code = 1


    var post_inst = _tester.get_post_run_script_instance()
    if (post_inst != null and post_inst.get_exit_code() != null):
        exit_code = post_inst.get_exit_code()

    if (should_exit or (should_exit_on_success and _tester.get_fail_count() == 0)):
        quit(exit_code)
    else:
        print("Tests finished, exit manually")





func _init():
    if ( !_utils.is_version_ok()):
        print("\n\n", _utils.get_version_text())
        push_error(_utils.get_bad_version_text())
        quit(1)
    else:
        _run_gut()
