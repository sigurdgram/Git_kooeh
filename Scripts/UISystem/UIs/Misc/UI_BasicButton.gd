@tool
extends Control
class_name UI_BasicButton

signal pressed()

@export var _button: Button
@export var _audio: AudioStream

@export var _fontSize: int:
    set(value):
        _fontSize = value
        if is_instance_valid(_button):
            _button.add_theme_font_size_override("font_size", _fontSize)
        pass

@export var text: String:
    set(value):
        text = value
        if is_instance_valid(_button):
            _button.text = text
        pass

@export var disabled: bool:
    set(value):
        disabled = value
        if is_instance_valid(_button):
            _button.disabled = disabled
        pass



func _ready():
    _fontSize = _button.get_theme_font_size("font_size", "Button_Basic")
    _button.pressed.connect(_on_pressed)
    pass

func _on_pressed():
    pressed.emit()
    AudioSystem.play_sfx(_audio)
    pass

func unfocus():
    _button.release_focus()
    pass

func _on_focus_entered():
    _button.grab_focus()
    pass

func get_button():
    return _button
