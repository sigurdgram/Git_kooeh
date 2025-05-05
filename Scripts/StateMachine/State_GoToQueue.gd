extends State
class_name State_GoToQueue

var _targetLocation: Vector2
var _targetToleranceRadius: float = 10.0
var _pathToleranceRadius: float = 10.0
var _owningActor: CharacterBase
var _queue: QueueSystem



func enter():
    var orderCounter: Buildable_OrderCounter1 = get_tree().get_first_node_in_group("Buildable.OrderCounter")
    _queue = orderCounter.queue
    _targetLocation = _queue.global_position
    _owningActor = _owner as CharacterBase

    _owningActor.navigate_to(_targetLocation, _targetToleranceRadius, _pathToleranceRadius)
    pass

func exit():
    _queue.enter_queue(_owner)
    pass

func update(_delta: float):
    if _owningActor.is_navigation_finished():
        _runner.move_to(self, "State_WaitTillQueueHead")
    pass
