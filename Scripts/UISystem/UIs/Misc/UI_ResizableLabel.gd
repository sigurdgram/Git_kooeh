@tool
extends Label
class_name UI_ResizableLabel

var _usedFont: Font

@export var _maxFontSize: int


func _ready():
    _usedFont = get_theme_font("font")

    _update_font_size.call_deferred()
    pass

func _set(property: StringName, value: Variant) -> bool:
    match property:
        "text":
            text = value
            _update_font_size.call_deferred()

    return true

func _update_font_size():
    var stringSize = _usedFont.get_string_size(text, horizontal_alignment, -1, _maxFontSize)
    var parentRect: Rect2 = get_parent_control().get_rect()

    var ratio: Vector2 = stringSize / parentRect.size
    if ratio.x >= 1.0:
        var excess: float = 1.0 / ratio.x
        var correction: int = floori(_maxFontSize * excess)
        add_theme_font_size_override("font_size", correction)
        return

    add_theme_font_size_override("font_size", _maxFontSize)
    pass
