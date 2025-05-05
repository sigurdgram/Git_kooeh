extends State
class_name State_Eat

@export var _eatTime: float = 10.0

var _counter: float
var _seat: Buildable_Seat
var _selectedChair: Buildable_Attachment_Seat
var changeTextureAtFirst: bool = false
var changeTextureAtSecond: bool = false
var _spawnedFood: Array
var _assetLayer: Node2D:
    get():
        if not is_instance_valid(_assetLayer):
            _assetLayer = get_tree().get_first_node_in_group("BuildableLayer.Asset")

        return _assetLayer


func enter():
    var customer: Customer = _owner as Customer
    _blackboard["PreSeatLocation"] = customer.global_position
    _seat = _blackboard["Seat"]
    _selectedChair = _blackboard["Chair"]

    customer.stop_navigation()
    var sitPosition: Node2D = _selectedChair.get_sit_position()
    customer.reparent(sitPosition)
    customer.global_position = sitPosition.global_position
    customer.forwardVector = _selectedChair.global_position.direction_to(_seat.global_position)
    customer.bEat = true
    customer.eatingIn = true

    var foods: Dictionary = customer.release_food()
    var foodPos: Node2D = get_corresponding_table_slot()
    for i in foods:
        var food: = Food.new(i)
        _spawnedFood.push_back(food)
        foodPos.add_child(food)

    customer.update_animation()
    pass

func get_corresponding_table_slot() -> Node2D:
    var direction: BuildableTypes.EDirection = _seat.get_chair_direction(_selectedChair)
    var tableAttachmentSlots: Dictionary = _seat.get_meta(BuildableTypes.Meta_Slots)
    var slotPath: NodePath
    match direction:
        BuildableTypes.EDirection.NorthEast: slotPath = tableAttachmentSlots["Tabletop_NE"]
        BuildableTypes.EDirection.SouthEast: slotPath = tableAttachmentSlots["Tabletop_SE"]
        BuildableTypes.EDirection.NorthWest: slotPath = tableAttachmentSlots["Tabletop_NW"]
        BuildableTypes.EDirection.SouthWest: slotPath = tableAttachmentSlots["Tabletop_SW"]
        _: assert (false, "Missing Seat Attachment Slots for direction %s in %s" % [direction, _seat])

    return _seat.get_node(slotPath)

func exit():
    _owner.bEat = false

    for i in _spawnedFood:
        i.queue_free()

    var preSeatLocation: Vector2 = _blackboard["PreSeatLocation"]
    owner.reparent(_assetLayer)
    owner.global_position = preSeatLocation

    _selectedChair.occupied = false
    _spawnedFood.clear()
    _blackboard.erase("Seat")
    _blackboard.erase("Chair")
    _blackboard.erase("PreSeatLocation")
    pass

func progress_ratio() -> float:
    return min(_counter / _eatTime, 1.0)

func update(delta: float):
    _counter += delta
    var ratio = progress_ratio()

    for i in _spawnedFood:
        var food: = i as Food
        food.eat(ratio)

    if ratio >= 1.0:
        _runner.move_to(self, "State_Leave")
    pass
