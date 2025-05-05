@tool
extends Panel

var _yesCallback: Callable
var _noCallback: Callable



func _init():
    hide()
    pass

func setup(description: String, yesCallback: Callable, noCallback: Callable):
    % TXT_Description.text = description

    _yesCallback = yesCallback
    _noCallback = noCallback
    show()
    pass

func _on_btn_yes_pressed():
    if _yesCallback.is_valid():
        _yesCallback.call()
    hide()
    pass

func _on_btn_close_pressed():
    if _noCallback.is_valid():
        _noCallback.call()
    hide()
    pass
