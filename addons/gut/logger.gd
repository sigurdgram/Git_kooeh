






























var types = {
    debug = "debug", 
    deprecated = "deprecated", 
    error = "error", 
    failed = "failed", 
    info = "info", 
    normal = "normal", 
    orphan = "orphan", 
    passed = "passed", 
    pending = "pending", 
    risky = "risky", 
    warn = "warn", 
}

var fmts = {
    red = "red", 
    yellow = "yellow", 
    green = "green", 

    bold = "bold", 
    underline = "underline", 

    none = null
}

var _type_data = {
    types.debug: {disp = "DEBUG", enabled = true, fmt = fmts.none}, 
    types.deprecated: {disp = "DEPRECATED", enabled = true, fmt = fmts.none}, 
    types.error: {disp = "ERROR", enabled = true, fmt = fmts.red}, 
    types.failed: {disp = "Failed", enabled = true, fmt = fmts.red}, 
    types.info: {disp = "INFO", enabled = true, fmt = fmts.bold}, 
    types.normal: {disp = "NORMAL", enabled = true, fmt = fmts.none}, 
    types.orphan: {disp = "Orphans", enabled = true, fmt = fmts.yellow}, 
    types.passed: {disp = "Passed", enabled = true, fmt = fmts.green}, 
    types.pending: {disp = "Pending", enabled = true, fmt = fmts.yellow}, 
    types.risky: {disp = "Risky", enabled = true, fmt = fmts.yellow}, 
    types.warn: {disp = "WARNING", enabled = true, fmt = fmts.yellow}, 
}

var _logs = {
    types.warn: [], 
    types.error: [], 
    types.info: [], 
    types.debug: [], 
    types.deprecated: [], 
}

var _printers = {
    terminal = null, 
    gui = null, 
    console = null
}

var _gut = null
var _utils = null
var _indent_level = 0
var _min_indent_level = 0
var _indent_string = "    "
var _skip_test_name_for_testing = false
var _less_test_names = false
var _yield_calls = 0
var _last_yield_text = ""


func _init():
    _utils = load("res://addons/gut/utils.gd").get_instance()
    _printers.terminal = _utils.Printers.TerminalPrinter.new()
    _printers.console = _utils.Printers.ConsolePrinter.new()



    _printers.console.set_disabled(true)

func get_indent_text():
    var pad = ""
    for i in range(_indent_level):
        pad += _indent_string

    return pad

func _indent_text(text):
    var to_return = text
    var ending_newline = ""

    if (text.ends_with("\n")):
        ending_newline = "\n"
        to_return = to_return.left(to_return.length() - 1)

    var pad = get_indent_text()
    to_return = to_return.replace("\n", "\n" + pad)
    to_return += ending_newline

    return pad + to_return

func _should_print_to_printer(key_name):
    return _printers[key_name] != null and !_printers[key_name].get_disabled()

func _print_test_name():
    if (_gut == null):
        return

    var cur_test = _gut.get_current_test_object()
    if (cur_test == null):
        return false

    if ( !cur_test.has_printed_name):
        var param_text = ""
        if (cur_test.arg_count > 0):


            param_text = "<parameterized>"
        _output(str("* ", cur_test.name, param_text, "\n"))
        cur_test.has_printed_name = true

func _output(text, fmt = null):
    for key in _printers:
        if (_should_print_to_printer(key)):
            var info = ""
            _printers[key].send(info + text, fmt)

func _log(text, fmt = fmts.none):
    _print_test_name()
    var indented = _indent_text(text)
    _output(indented, fmt)




func get_warnings():
    return get_log_entries(types.warn)

func get_errors():
    return get_log_entries(types.error)

func get_infos():
    return get_log_entries(types.info)

func get_debugs():
    return get_log_entries(types.debug)

func get_deprecated():
    return get_log_entries(types.deprecated)

func get_count(log_type = null):
    var count = 0
    if (log_type == null):
        for key in _logs:
            count += _logs[key].size()
    else:
        count = _logs[log_type].size()
    return count

func get_log_entries(log_type):
    return _logs[log_type]




func _output_type(type, text):
    var td = _type_data[type]
    if ( !td.enabled):
        return

    _print_test_name()
    if (type != types.normal):
        if (_logs.has(type)):
            _logs[type].append(text)

        var start = str("[", td.disp, "]")
        if (text != null and text != ""):
            start += ":  "
        else:
            start += " "
        var indented_start = _indent_text(start)
        var indented_end = _indent_text(text)
        indented_end = indented_end.lstrip(_indent_string)
        _output(indented_start, td.fmt)
        _output(indented_end + "\n")


func debug(text):
    _output_type(types.debug, text)


func deprecated(text, alt_method = null):
    var msg = text
    if (alt_method):
        msg = str("The method ", text, " is deprecated, use ", alt_method, " instead.")
    return _output_type(types.deprecated, msg)

func error(text):
    _output_type(types.error, text)
    if (_gut != null):
        _gut._fail_for_error(text)

func failed(text):
    _output_type(types.failed, text)

func info(text):
    _output_type(types.info, text)

func orphan(text):
    _output_type(types.orphan, text)

func passed(text):
    _output_type(types.passed, text)

func pending(text):
    _output_type(types.pending, text)

func risky(text):
    _output_type(types.risky, text)

func warn(text):
    _output_type(types.warn, text)

func log(text = "", fmt = fmts.none):
    end_yield()
    if (text == ""):
        _output("\n")
    else:
        _log(text + "\n", fmt)
    return null

func lograw(text, fmt = fmts.none):
    return _output(text, fmt)



func log_test_name():


    if ( !_less_test_names):
        _print_test_name()




func get_gut():
    return _gut

func set_gut(gut):
    _gut = gut
    if (_gut == null):
        _printers.gui = null
    else:
        if (_printers.gui == null):
            _printers.gui = _utils.Printers.GutGuiPrinter.new()


func get_indent_level():
    return _indent_level

func set_indent_level(indent_level):
    _indent_level = max(_min_indent_level, indent_level)

func get_indent_string():
    return _indent_string

func set_indent_string(indent_string):
    _indent_string = indent_string

func clear():
    for key in _logs:
        _logs[key].clear()

func inc_indent():
    _indent_level += 1

func dec_indent():
    _indent_level = max(_min_indent_level, _indent_level - 1)

func is_type_enabled(type):
    return _type_data[type].enabled

func set_type_enabled(type, is_enabled):
    _type_data[type].enabled = is_enabled

func get_less_test_names():
    return _less_test_names

func set_less_test_names(less_test_names):
    _less_test_names = less_test_names

func disable_printer(name, is_disabled):
    _printers[name].set_disabled(is_disabled)

func is_printer_disabled(name):
    return _printers[name].get_disabled()

func disable_formatting(is_disabled):
    for key in _printers:
        _printers[key].set_format_enabled( !is_disabled)

func disable_all_printers(is_disabled):
    for p in _printers:
        disable_printer(p, is_disabled)

func get_printer(printer_key):
    return _printers[printer_key]

func _yield_text_terminal(text):
    var printer = _printers["terminal"]
    if (_yield_calls != 0):
        printer.clear_line()
        printer.back(_last_yield_text.length())
    printer.send(text, fmts.yellow)

func _end_yield_terminal():
    var printer = _printers["terminal"]
    printer.clear_line()
    printer.back(_last_yield_text.length())

func _yield_text_gui(text):
    pass




func _end_yield_gui():
    pass





func yield_msg(text):
    if (_type_data.warn.enabled):
        self.log(text, fmts.yellow)


func yield_text(text):
    _yield_text_terminal(text)
    _yield_text_gui(text)
    _last_yield_text = text
    _yield_calls += 1


func end_yield():
    if (_yield_calls == 0):
        return
    _end_yield_terminal()
    _end_yield_gui()
    _yield_calls = 0
    _last_yield_text = ""

func get_gui_bbcode():
    return _printers.gui.get_bbcode()
