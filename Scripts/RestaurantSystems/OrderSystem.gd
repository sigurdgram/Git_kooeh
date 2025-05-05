extends Node
class_name OrderSystem

static  var uniqueOrderID: int = 0
var _orderList: Dictionary = {}

signal broadcastOrderFulfilled(orderID: int, order: OrderData)
signal broadcastOrderCancelled(orderID: int)
signal onOrdersUpdated(fulfilledOrders: Array[int])

func get_order_list() -> Dictionary:
    return _orderList

func check_fulfillable_order() -> void :
    var fulfillableOrders: Array[int] = []
    var serveSystem: ServeSystem = GameInstance.gameWorld.serveSystem

    for i in serveSystem.get_serve_stations():
        fulfillableOrders = i.get_fulfillable_orders(_orderList)

    if not fulfillableOrders.is_empty():
        onOrdersUpdated.emit(fulfillableOrders)
    pass

func submit_order(order: Dictionary, orderFiler: CustomerData) -> int:
    var id: int = uniqueOrderID
    _orderList[uniqueOrderID] = OrderData.new(order, orderFiler)
    check_fulfillable_order.call_deferred()
    uniqueOrderID += 1
    return id

func fulfill_order(orderID: int):
    assert (_orderList.has(orderID))
    var order = _orderList[orderID]
    GameplayVariables.add_served_customer(order.orderFiller.identifier)

    _orderList.erase(orderID)
    broadcastOrderFulfilled.emit(orderID, order)
    pass

func cancel_order(orderID: int):
    assert (_orderList.has(orderID))
    _orderList.erase(orderID)
    broadcastOrderCancelled.emit(orderID)
    pass
