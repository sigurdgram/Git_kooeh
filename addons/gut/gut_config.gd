





var Gut = load("res://addons/gut/gut.gd")


var valid_fonts = ["AnonymousPro", "CourierPro", "LobsterTwo", "Default"]
var default_options = {
    background_color = Color(0.15, 0.15, 0.15, 1).to_html(), 
    config_file = "res://.gutconfig.json", 
    dirs = [], 
    disable_colors = false, 




    double_strategy = "SCRIPT_ONLY", 

    errors_do_not_cause_failure = false, 
    font_color = Color(0.8, 0.8, 0.8, 1).to_html(), 
    font_name = "CourierPrime", 
    font_size = 16, 
    hide_orphans = false, 
    ignore_pause = false, 
    include_subdirs = false, 
    inner_class = "", 
    junit_xml_file = "", 
    junit_xml_timestamp = false, 
    log_level = 1, 
    opacity = 100, 
    paint_after = 0.1, 
    post_run_script = "", 
    pre_run_script = "", 
    prefix = "test_", 
    selected = "", 
    should_exit = false, 
    should_exit_on_success = false, 
    should_maximize = false, 
    compact_mode = false, 
    show_help = false, 
    suffix = ".gd", 
    tests = [], 
    unit_test_name = "", 

    gut_on_top = true, 
}

var default_panel_options = {
    font_name = "CourierPrime", 
    font_size = 16, 
    output_font_name = "CourierPrime", 
    output_font_size = 30, 
    hide_result_tree = false, 
    hide_output_text = false, 
    hide_settings = false, 
    use_colors = true
}

var options = default_options.duplicate()
var json = JSON.new()


func _null_copy(h):
    var new_hash = {}
    for key in h:
        new_hash[key] = null
    return new_hash


func _load_options_from_config_file(file_path, into):

    if ( !FileAccess.file_exists(file_path)):
        if (file_path != "res://.gutconfig.json"):
            print("ERROR:  Config File \"", file_path, "\" does not exist.")
            return -1
        else:
            return 1

    var f = FileAccess.open(file_path, FileAccess.READ)
    if (f == null):
        var result = FileAccess.get_open_error()
        push_error(str("Could not load data ", file_path, " ", result))
        return result

    var json = f.get_as_text()
    f = null

    var test_json_conv = JSON.new()
    test_json_conv.parse(json)
    var results = test_json_conv.get_data()

    if (results == null):
        print("\n\n", "!! ERROR parsing file:  ", file_path)
        print("    at line ", results.error_line, ":")
        print("    ", results.error_string)
        return -1



    _load_dict_into(results, into)

    return 1

func _load_dict_into(source, dest):
    for key in dest:
        if (source.has(key)):
            if (source[key] != null):
                if (typeof(source[key]) == TYPE_DICTIONARY):
                    _load_dict_into(source[key], dest[key])
                else:
                    dest[key] = source[key]




func _apply_options(opts, gut):
    gut.include_subdirectories = opts.include_subdirs

    if (opts.inner_class != ""):
        gut.inner_class_name = opts.inner_class
    gut.log_level = opts.log_level
    gut.ignore_pause_before_teardown = opts.ignore_pause

    gut.select_script(opts.selected)

    for i in range(opts.dirs.size()):
        gut.add_directory(opts.dirs[i], opts.prefix, opts.suffix)

    for i in range(opts.tests.size()):
        gut.add_script(opts.tests[i])


    gut.double_strategy = GutUtils.get_enum_value(
        opts.double_strategy, GutUtils.DOUBLE_STRATEGY, 
        GutUtils.DOUBLE_STRATEGY.INCLUDE_NATIVE)

    gut.unit_test_name = opts.unit_test_name
    gut.pre_run_script = opts.pre_run_script
    gut.post_run_script = opts.post_run_script
    gut.color_output = !opts.disable_colors
    gut.show_orphans( !opts.hide_orphans)
    gut.junit_xml_file = opts.junit_xml_file
    gut.junit_xml_timestamp = opts.junit_xml_timestamp
    gut.paint_after = str(opts.paint_after).to_float()
    gut.treat_error_as_failure = !opts.errors_do_not_cause_failure

    return gut




func write_options(path):
    var content = json.stringify(options, " ")

    var f = FileAccess.open(path, FileAccess.WRITE)
    var result = FileAccess.get_open_error()
    if (f != null):
        f.store_string(content)
        f = null
    else:
        print("ERROR:  could not open file ", path, " ", result)
    return result


func load_options(path):
    return _load_options_from_config_file(path, options)


func load_panel_options(path):
    options["panel_options"] = default_panel_options.duplicate()
    return _load_options_from_config_file(path, options)


func load_options_no_defaults(path):
    options = _null_copy(default_options)
    return _load_options_from_config_file(path, options)


func apply_options(gut):
    _apply_options(options, gut)
