extends State
class_name State_Leave

var _entrance: Node2D


func enter():
    if _owner.eatingIn == false:
        _owner.foodLeave = true

    if _owner.notServed == true:
        _owner.foodLeave = false

    _entrance = get_tree().get_first_node_in_group("Buildable.Entrance")
    var customer: Customer = _owner as Customer
    customer.navigate_to(_entrance.global_position)
    customer.navigation_finished.connect(_destroy)
    pass

func _destroy():
    _owner.queue_free()
    pass
