extends Camera2D
class_name PlayerCamera

var followTarget: Node2D:
    set(value):
        if followTarget == value:
            return

        followTarget = value
        set_physics_process(is_instance_valid(followTarget))



func _ready():
    set_process(is_instance_valid(followTarget))
    pass

func _process(_delta):
    position = followTarget.position
