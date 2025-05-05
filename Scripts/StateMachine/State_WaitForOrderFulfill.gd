extends State
class_name State_WaitForOrderFulfill

const DineInChance: String = "DineInChance"
var _orderID: int
var patience: float
var _orderSystem: OrderSystem

func enter():
    _orderSystem = GameInstance.gameWorld.orderSystem
    _orderID = _blackboard["OrderID"]


    if not _blackboard.has(DineInChance):
        _blackboard[DineInChance] = 0.5

    _orderSystem.broadcastOrderFulfilled.connect(_on_order_fulfilled)
    _orderSystem.broadcastOrderCancelled.connect(_on_order_cancelled)

    var owningCustomer: = _owner as Customer
    patience = owningCustomer.get_customer_data().patience
    pass

func exit():
    _orderSystem.broadcastOrderFulfilled.disconnect(_on_order_fulfilled)
    _orderSystem.broadcastOrderCancelled.disconnect(_on_order_cancelled)
    var qNode = _owner.get_meta("QueueNode") as QueueNode
    var queueSystem: QueueSystem = qNode.get_owning_queue()
    queueSystem.exit_queue(_owner)
    pass

func _on_order_fulfilled(orderID: int, order: OrderData):
    _owner.notServed = false

    if _orderID != orderID:
        return

    var rng: = RandomNumberGenerator.new()
    var random: float = rng.randf()

    _owner.hold_food(order.order)

    var dineInChance: float = _blackboard[DineInChance]
    var dest: String = "State_Leave" if random > dineInChance else "State_FindSeatAndSit"
    _runner.move_to(self, dest)
    pass

func _on_order_cancelled(orderID: int):
    if _orderID == orderID:
        _owner.notServed = true
        _runner.move_to(self, "State_Leave")
    pass

func update(delta: float):
    if patience <= -1.0:
        return

    patience -= delta

    if patience <= 0.0:
        _orderSystem.cancel_order(_orderID)
