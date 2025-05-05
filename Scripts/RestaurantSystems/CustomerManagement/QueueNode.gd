extends PathFollow2D
class_name QueueNode

var prev: QueueNode = null
var next: QueueNode = null
var _n: Node
var _qNode: QueueNode
var _agent: NavigationAgent2D
var _queueSystem: QueueSystem
var index: int = -1
var _queuePath: PackedVector2Array
var _assetLayer: Node2D:
    get():
        if not is_instance_valid(_assetLayer):
            _assetLayer = get_tree().get_first_node_in_group("BuildableLayer.Asset")

        return _assetLayer

signal onStoppedInQueue_OneOff()
var _isFaceOrderCounter: bool = false


func _init(node: Node, queueSystem: QueueSystem):
    y_sort_enabled = true
    rotates = false
    loop = false
    _n = node
    _queueSystem = queueSystem
    _agent = _n.navigationAgent
    _qNode = self
    pass

func _ready():
    var curve: Curve2D = _queueSystem.curve
    var pointCount: int = curve.point_count
    for i in pointCount:
        var p: Vector2 = curve.get_point_position(i)
        _queuePath.append(p)

    _queuePath = NavigationServer2D.simplify_path(_queuePath, 1)

    _n.navigation_finished.connect(_nav_complete)
    var point: Vector2 = _queuePath[0]
    _n.navigate_to(point)
    pass

func _nav_complete():
    if _queuePath.is_empty():
        return

    _queuePath.remove_at(0)

    if _queuePath.is_empty():
        return

    var point: Vector2 = _queuePath[0]
    _n.navigate_to(point)
    pass

func get_owning_queue() -> QueueSystem:
    return _queueSystem

func get_data():
    return _n

func get_node_data():
    return _qNode

func get_index_in_queue():

    return _queueSystem.index_in_queue(self)

func get_node_index_in_queue():

    return _queueSystem.node_index_in_queue(self)

func _is_path_end_reached() -> bool:
    return _n.is_navigation_finished()

func _physics_process(_delta):
    if not is_instance_valid(_n):
        return

    if not is_instance_valid(prev):
        if _is_path_end_reached():
            if not _isFaceOrderCounter:
                face_order_counter()
                _isFaceOrderCounter = true

            onStoppedInQueue_OneOff.emit()
        else:
            _n.set_pause(false)
        return

    var prevLoc: Vector2 = prev.get_data().global_position
    var nLoc: Vector2 = _n.global_position
    var distance: float = prevLoc.distance_to(nLoc)

    var customerSize: float = _n._customerData.customerSize
    if distance > customerSize:
        _n.set_pause(false)
    else:
        _n.set_pause(true)
    pass

func face_order_counter():
    var orderCounter = get_tree().get_first_node_in_group("Buildable.OrderCounter")
    var targetPosition: Vector2 = orderCounter.global_position
    var owningPosition: Vector2 = _n.global_position

    var dir: Vector2 = (targetPosition - owningPosition).normalized()
    _n.sprite.flip_h = dir.x > 0
    _n.velocity = Vector2.ZERO
    pass

func leave_queue():
    _n.remove_meta("QueueNode")
    queue_free()
pass
