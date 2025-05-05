extends Control
class_name QTEBar_Drag_Knob

@export var _textureKnob: TextureButton

var _curve: Curve2D



func get_knob() -> TextureButton:
    return _textureKnob

func setup(curve: Curve2D, onButtonDown: Callable, onButtonUp: Callable, trackWidth: float):
    _curve = curve
    _textureKnob.custom_minimum_size = Vector2(trackWidth, trackWidth)

    if not _textureKnob.button_down.is_connected(onButtonDown):
        _textureKnob.button_down.connect(onButtonDown)

    if not _textureKnob.button_up.is_connected(onButtonUp):
        _textureKnob.button_up.connect(onButtonUp)
    position = curve.sample_baked()
    pass
