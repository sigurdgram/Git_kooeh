extends CharacterBase
class_name Customer

@export var _stateMachine: StateMachineRunner
@export var _orderPanel: Control
@export var _orderBTN: Button
@export var _orderContainer: VBoxContainer

var _onDestroyCallback: Callable
var _customerData: CustomerData
var _orderPopupMaterial: Material
var _orderID: int = -1
var bEat: bool
var eatingIn: bool
var foodLeave: bool
var notServed: bool


func _ready():
    eatingIn = false
    super ._ready()
    _orderPopupMaterial = _orderPanel.material
    _orderPanel.hide()

    var orderSystem: OrderSystem = GameInstance.gameWorld.orderSystem
    orderSystem.broadcastOrderFulfilled.connect(_on_order_fulfilled)
    orderSystem.broadcastOrderCancelled.connect(_on_order_cancelled)
    orderSystem.onOrdersUpdated.connect(_on_orders_updated)
    _orderPanel.self_modulate = Color.DIM_GRAY
    pass

func _notification(what):
    if what != NOTIFICATION_PREDELETE:
        return

    if not _onDestroyCallback.is_null():
        _onDestroyCallback.call()
    pass

func setup(onDestroyCallback: Callable, customerData: CustomerData):
    _onDestroyCallback = onDestroyCallback
    _customerData = customerData
    _stateMachine.start()
    pass

func _on_orders_updated(fulfilledOrders: Array[int]):
    _orderBTN.disabled = not fulfilledOrders.has(_orderID)
    _orderPanel.self_modulate = Color.DIM_GRAY if _orderBTN.disabled else Color.WHITE
    pass

func _on_order_cancelled(orderID: int):
    if orderID == _orderID:
        _orderBTN.disabled = false
        _orderPanel.hide()
    pass

func _on_order_fulfilled(orderID: int, _order: OrderData):
    if orderID == _orderID:
        _orderBTN.disabled = false
        _orderPanel.hide()
    pass

func request_order(order: Dictionary) -> int:
    var orderSys: OrderSystem = GameInstance.gameWorld.orderSystem
    for entry in order:
        for i in order[entry]:
            var orderTexture: = TextureRect.new()
            var food: FoodData = AssetManager.load_asset(entry).get_ref()
            orderTexture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            orderTexture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            orderTexture.custom_minimum_size = Vector2.ONE * 100.0
            orderTexture.texture = food.sprite
            _orderContainer.add_child(orderTexture)

    _orderPanel.show()
    _orderID = orderSys.submit_order(order, _customerData)
    return _orderID

func fulfill_order():
    var orderSystem: OrderSystem = GameInstance.gameWorld.orderSystem
    orderSystem.fulfill_order(_orderID)
    pass

func get_customer_data() -> CustomerData:
    return _customerData

func get_blackboard() -> Dictionary:
    return _stateMachine.get_blackboard()

func is_order_fulfillable() -> bool:
    return not _orderBTN.disabled

func update_animation():
    if bEat:
        _animTree.set("parameters/Stationary/Eat/blend_position", forwardVector)
    pass
