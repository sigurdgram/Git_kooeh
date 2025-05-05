extends UI_Widget
class_name UI_FlyInText

@export var _affectedControl: Control
@export var _description: Label



func _ready():
    _affectedControl.position.y = -100

    var tween: Tween = create_tween()
    tween.tween_property(_affectedControl, "position:y", 50, 0.5).set_trans(Tween.TRANS_SPRING)
    tween.tween_property(_affectedControl, "position:y", -100, 0.5).set_trans(Tween.TRANS_LINEAR).set_delay(3.0)
    tween.tween_callback(queue_free)
    pass

func set_text(text: String):
    _description.text = text
    pass
