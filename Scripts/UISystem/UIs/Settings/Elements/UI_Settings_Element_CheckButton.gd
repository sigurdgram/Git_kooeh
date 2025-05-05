@tool
extends Button
class_name UI_Settings_Element_CheckButton

@export var _label: Label
@export var _checktextureRect: TextureRect

@export var _labelText: String:
    set(value):
        _labelText = value

        if is_instance_valid(_label):
            _label.text = _labelText
        pass

@export var _checkState: bool:
    set(value):
        _checkState = value
        if is_instance_valid(_label):
            update_check_texture()
            onCheckStateChanged.emit(_checkState)
        pass

var _checkedStyle: Texture2D
var _uncheckedStyle: Texture2D

signal onCheckStateChanged(pressed: bool)


func _ready():
    pressed.connect(_on_pressed)
    _checkedStyle = _checktextureRect.get_theme_icon("checked", "Entry_TextureRect_Check")
    _uncheckedStyle = _checktextureRect.get_theme_icon("unchecked", "Entry_TextureRect_Check")

    update_check_texture()
    pass

func _on_pressed():
    _checkState = not _checkState
    pass

func set_check_state_no_signal(state: bool):
    _checkState = state
    pass

func update_check_texture():
    _checktextureRect.texture = _checkedStyle if _checkState else _uncheckedStyle
    pass
