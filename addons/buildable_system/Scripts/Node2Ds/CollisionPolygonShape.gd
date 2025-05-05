@tool
extends CollisionPolygon2D
class_name CollisionPolygonShape2D

@export var shape: ConvexPolygonShape2D:
    set(value):
        shape = value
        polygon = shape.points if is_instance_valid(shape) else PackedVector2Array()
        notify_property_list_changed()
        pass
