extends UI_Button_Frame
class_name UI_Toggle_Frame

@export var _checkBox: CheckBox



func _on_pressed():
    var newState: bool = !_checkBox.button_pressed
    _onClick.call(_itemWeakRef, _checkBox, newState)
    pass
