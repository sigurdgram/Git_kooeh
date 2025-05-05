@tool
extends Button
class_name UI_Settings_Element_Slider

signal valueChanged(value: float)

@export var _label: Label
@export var _hSlider: HSlider
@export var _text: String:
    set(v):
        _text = v
        if is_instance_valid(_label):
            _label.text = _text
        pass

@export var _minValue: float = 0:
    set(v):
        _minValue = v
        if is_instance_valid(_hSlider):
            _hSlider.min_value = _minValue
        pass

@export var _maxValue: float = 100:
    set(v):
        _maxValue = v
        if is_instance_valid(_hSlider):
            _hSlider.max_value = _maxValue
        pass

@export var value: float = 50:
    set(v):
        value = v
        if is_instance_valid(_hSlider):
            _hSlider.value = value
        pass

@export var step: float = 1.0:
    set(v):
        step = v
        if is_instance_valid(_hSlider):
            _hSlider.step = step
        pass

@export var editable: bool = true:
    set(v):
        editable = v
        if is_instance_valid(editable):
            _hSlider.editable = editable
        pass



func _ready():
    editable = _hSlider.editable
    _hSlider.value_changed.connect(_on_slider_value_changed)
    pass

func _gui_input(event: InputEvent):
    if !get_viewport().gui_get_focus_owner() == self:
        return

    if event.is_action_pressed("ui_left", true):
        _hSlider.value -= step
        accept_event()
    elif event.is_action_pressed("ui_right", true):
        _hSlider.value += step
        accept_event()
    pass

func set_value_no_signal(v: float):
    _hSlider.set_value_no_signal(v)
    pass

func _on_slider_value_changed(v: float):
    valueChanged.emit(v)
    pass
