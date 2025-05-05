extends Path2D
class_name QueueSystem

@export var spacing: float

var _queueHead: QueueNode = null
var _spaceState: PhysicsDirectSpaceState2D

signal onEnterQueue(queueNode: QueueNode)
signal onExitQueue(queueNode: QueueNode)



func insert_beginning(node: Node):
    if index_in_queue(node) > -1:
        return

    var newNode: = QueueNode.new(node, self)
    if _queueHead:
        newNode.prev = null
        newNode.next = _queueHead
        _queueHead.prev = newNode
        _queueHead = newNode
    else:
        newNode.next = null
        newNode.prev = null
        _queueHead = newNode



    add_child(newNode)
    update_queue_node_index()
    onEnterQueue.emit(newNode)
    pass

func insert_last(node: Node):
    if index_in_queue(node) > -1:
        return

    var newNode: = QueueNode.new(node, self)
    add_child(newNode)
    newNode.position = Vector2.ZERO

    var temp: QueueNode = null

    if is_instance_valid(_queueHead):
        temp = _queueHead
        while (is_instance_valid(temp.next)):
            temp = temp.next
        temp.next = newNode
        newNode.prev = temp
        newNode.next = null
    else:
        newNode.next = null
        newNode.prev = null
        _queueHead = newNode

    node.set_meta("QueueNode", newNode)


    update_queue_node_index()
    onEnterQueue.emit(newNode)
    pass

func insert_after(node: Node, location: int):
    if index_in_queue(node) > -1:
        return

    var newNode: = QueueNode.new(node, self)
    add_child(newNode)

    var temp = _queueHead

    for i in location:
        temp = temp.next
        if not is_instance_valid(temp):
            push_error("Location %s is out of bound" % i)
            return

    newNode.next = temp.next
    newNode.prev = temp
    var oldNext = temp.next
    temp.next = newNode
    if is_instance_valid(oldNext):
        oldNext.prev = newNode
        newNode.next = oldNext



    update_queue_node_index()
    onEnterQueue.emit(newNode)
    pass

func remove_beginning():
    var temp = _queueHead
    if not is_instance_valid(temp):
        push_error("List is empty")
        return

    if not is_instance_valid(temp.next):
        onExitQueue.emit(temp)
        temp.leave_queue()
        _queueHead = null
    else:
        onExitQueue.emit(temp)
        temp.leave_queue()
        _queueHead = _queueHead.next
        _queueHead.prev = null

    update_queue_node_index()
    pass

func remove_last():
    var temp = _queueHead
    if not is_instance_valid(temp):
        push_error("List is empty")
        return

    if not is_instance_valid(temp.next):
        onExitQueue.emit(temp)
        temp.leave_queue()
        _queueHead = null
        return

    while is_instance_valid(temp.next):
        temp = temp.next

    temp.prev.next = null
    onExitQueue.emit(temp)
    temp.leave_queue()
    update_queue_node_index()
    pass

func remove_at(location: int):
    var temp = _queueHead
    for i in location:
        temp = temp.next
        if not is_instance_valid(temp):
            push_error("Location %s is out of bound" % i)
            return

    var oldPrev = temp.prev
    var oldNext = temp.next

    if is_instance_valid(oldPrev):
        oldPrev.next = temp.next
        _queueHead = oldPrev

    if is_instance_valid(oldNext):
        oldNext.prev = oldPrev
        _queueHead = oldNext

    onExitQueue.emit(temp)
    temp.leave_queue()
    update_queue_node_index()
    pass

func index_in_queue(node: Node2D) -> int:
    var index: int = 0
    var temp: QueueNode = _queueHead
    while is_instance_valid(temp):
        if temp.get_data() == node:
            return index
        temp = temp.next
        index += 1
    return -1

func node_index_in_queue(node: Node2D) -> int:
    var index: int = 0
    var temp: QueueNode = _queueHead
    while is_instance_valid(temp):
        if temp.get_node_data() == node:
            return index
        temp = temp.next
        index += 1
    return -1

func _ready():
    _spaceState = get_world_2d().direct_space_state
    pass

func enter_queue(node: Node2D):
    insert_last(node)
    pass

func update_queue_node_index():
    var temp = _queueHead
    var index: int = 0
    if not is_instance_valid(temp):
        return

    if is_instance_valid(temp.next):
        while is_instance_valid(temp.next):
            temp = temp.next
            index += 1
            temp.index = index
    else:
        temp.index = index
    pass

func exit_queue(node: Node2D):
    var index: int = index_in_queue(node)
    if index < 0:
        return

    remove_at(index)
    pass

func raycast(t: Transform2D, excludes: Array[RID]) -> Array[Dictionary]:
    return Utils.PhysicsCast.circle_cast(_spaceState, t, spacing, excludes)

func get_queue_head() -> QueueNode:
    return _queueHead
