extends Node
class_name ServeSystem

var _cookedFoods: Dictionary
var _cookSystem: CookSystem
var _orderSystem: OrderSystem
var _displayCounters: Array[Node]

signal onCookedFoodsUpdated(cookedFoods: Dictionary)

func _ready():
    call_deferred("_setup")
    pass

func get_cooked_foods():
    return _cookedFoods

func get_serve_stations() -> Array[Node]:
    return _displayCounters

func _setup():
    _orderSystem = GameInstance.gameWorld.orderSystem
    _cookSystem = GameInstance.gameWorld.cookSystem
    _displayCounters = get_tree().get_nodes_in_group("Buildable.DisplayCounter")

    _orderSystem.broadcastOrderFulfilled.connect(_on_order_fulfilled)
    pass

func _on_order_fulfilled(_orderID: int, order: OrderData):
    var o: Dictionary = order.order.duplicate()
    var price: float = 0.0

    for i in o:
        var amount: int = o[i]
        price += AssetManager.load_asset(i).get_ref().price * amount

    for i in _displayCounters:
        var posMap: Dictionary[StringName, Node] = i.get_pos_map()
        for food in o:
            if not posMap.has(food) or o[food] == 0:
                continue

            var node: Node = posMap[food]
            var amount: int = o[food]
            var j: int = min(amount, node.get_child_count())

            for n in j:
                node.get_child(n).queue_free()
                o[food] -= 1

    GameplayVariables.add_money(price)
    onCookedFoodsUpdated.emit(_cookedFoods)
    pass
