extends Node
class_name CookTimer

var _totalCookTime: float
var _counter: float = 0
var _cookSystem: CookSystem
var _foodWeakRef: WeakRef

signal onCookTimeUp()


func _init(cookSystem: CookSystem, foodWeakRef: WeakRef):
    _cookSystem = cookSystem
    _foodWeakRef = foodWeakRef

    var foodData: FoodData = _foodWeakRef.get_ref()
    var ingredients: Dictionary = foodData.ingredients
    _totalCookTime = foodData.cookTime

    for ingredient in ingredients:
        var currentCount: int = InventorySystem.get_ingredient_count(ingredient)
        var neededAmount: int = ingredients[ingredient]
        InventorySystem.set_ingredient_count(ingredient, currentCount - neededAmount)
    pass

func progress_ratio() -> float:
    return _counter / _totalCookTime

func _process(delta):
    _counter += delta
    var ratio: float = progress_ratio()

    if ratio >= 1.0:
        onCookTimeUp.emit()
        queue_free()
    pass
