extends Control
class_name UI_Customer_Popup

@export var _panelCont: PanelContainer
@export var _button: Button
@export var _vBox: VBoxContainer



func _ready():
    _button.button_down.connect(_on_button_down)
    _button.button_up.connect(_on_button_up)

    if _button.disabled:
        _button.self_modulate = Color.DIM_GRAY
    else:
        _button.self_modulate = Color.WHITE
    pass

func _on_button_down():
    _panelCont.self_modulate = Color.DIM_GRAY
    pass

func _on_button_up():
    _panelCont.self_modulate = Color.WHITE
    pass
