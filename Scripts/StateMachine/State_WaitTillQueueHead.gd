extends State
class_name State_WaitTillQueueHead

var _owningQueueNode: QueueNode
var _canPlaceOrder: bool = false


func enter():
    _owningQueueNode = _owner.get_meta("QueueNode") as QueueNode
    assert (_owningQueueNode)
    _owningQueueNode.onStoppedInQueue_OneOff.connect(_on_stopped_in_queue_one_off)
    pass

func update(_delta: float):
    if _canPlaceOrder && _owningQueueNode.get_node_index_in_queue() == 0:
        _runner.move_to(self, "State_Order")
    pass

func _on_stopped_in_queue_one_off():
    _canPlaceOrder = true
    pass
