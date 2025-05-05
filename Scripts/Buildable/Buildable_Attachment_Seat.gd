extends StaticBody2D
class_name Buildable_Attachment_Seat

@export var _sprite: Sprite2D
@export var _collisionPolygon: CollisionPolygon2D
@export var _sitPosition: Node2D

var occupied: bool = false

func set_activate(activate: bool) -> void :
    _sprite.visible = activate
    _collisionPolygon.visible = activate
    _collisionPolygon.disabled = not activate
    _sprite.modulate = Color.WHITE if activate else Color(Color.SLATE_GRAY, 0.5)
    process_mode = Node.PROCESS_MODE_INHERIT if activate else Node.PROCESS_MODE_DISABLED
    pass

func set_preview(isPreview: bool) -> void :
    _sprite.visible = isPreview
    _sprite.modulate = Color(Color.SLATE_GRAY, 0.5) if isPreview else Color.WHITE
    pass

func get_sit_position() -> Node2D:
    return _sitPosition
