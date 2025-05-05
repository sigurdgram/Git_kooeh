class_name GutHookScript






var JunitXmlExport = load("res://addons/gut/junit_xml_export.gd")




var gut = null


var _exit_code = null

var _should_abort = false



func run():
    gut.logger.error("Run method not overloaded.  Create a 'run()' method in your hook script to run your code.")





func set_exit_code(code):
    _exit_code = code

func get_exit_code():
    return _exit_code



func abort():
    _should_abort = true

func should_abort():
    return _should_abort
