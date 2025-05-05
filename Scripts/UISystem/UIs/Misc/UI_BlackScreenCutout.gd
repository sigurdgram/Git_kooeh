extends UI_Widget
class_name UI_BlackScreenCutout

@export var _cutout: Control

var _mat: Material
var _items: Array[CanvasItem]
var _moveTween: Tween

func _ready():
    _mat = _cutout.material






    pass

func _process(delta: float) -> void :
    if _items.is_empty():
        return

    var viewportSize: Vector2 = get_viewport_rect().size
    var rect: Rect2
    for i in _items.size():
        if not is_instance_valid(_items[i]):
            _items.remove_at(i)
            continue

        if i == 0:
            rect = _get_transform_and_size(_items[i])
        else:
            rect.merge(_get_transform_and_size(_items[i]))
        pass

    _mat.set_shader_parameter("size", rect.size / viewportSize * 0.5)
    _mat.set_shader_parameter("position", rect.position / viewportSize)
    pass

func update_mask(maskRect: Rect2):
    var viewportSize: Vector2 = get_viewport_rect().size
    _mat.set_shader_parameter("size", maskRect.size / viewportSize * 0.5)
    _mat.set_shader_parameter("position", maskRect.position / viewportSize)
    pass

func _get_transform_and_size(item: CanvasItem) -> Rect2:
    var rect: Rect2
    if item is Sprite2D:
        rect = item.get_rect()
        var t: Transform2D = item.get_global_transform_with_canvas()
        rect.size *= t.get_scale()
        rect.position = (t.origin - rect.size * 0.5) + (item.offset * t.get_scale())
    elif item is Control:
        rect = item.get_rect()
        var t: Transform2D = item.get_global_transform_with_canvas()
        rect.position = t.origin
    else:
        assert (false, "Not suppose to hit here")

    return rect

func emphasize(items: Array[CanvasItem], duration: float = 0) -> void :
    set_process(false)
    _items = items

    if duration <= 0.0:
        if is_instance_valid(_moveTween) and _moveTween.is_valid():
            _moveTween.kill()
        set_process(true)
    else:
        var viewportSize: Vector2 = get_viewport_rect().size
        var rect: Rect2
        for i in _items.size():
            if i == 0:
                rect = _get_transform_and_size(_items[i])
            else:
                rect.merge(_get_transform_and_size(_items[i]))

        _moveTween = create_tween()
        _moveTween.tween_property(_mat, "shader_parameter/size", rect.size / viewportSize * 0.5, duration)
        _moveTween.parallel().tween_property(_mat, "shader_parameter/position", rect.position, duration)
        _moveTween.tween_callback(func(): set_process(true))
    pass

func get_cutout_material() -> Material:
    return _mat
