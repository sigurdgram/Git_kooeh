extends Sprite2D
class_name Food

var _foodWeakRef: WeakRef
var _eatState: int = 0
var _eatInterval: float
var _hasStartedEating: bool = false


func _init(foodID: String):
    _foodWeakRef = AssetManager.load_asset(foodID)
    self.scale = Vector2(0.5, 0.5)
    var foodData: FoodData = _foodWeakRef.get_ref()
    _eatInterval = 1.0 / foodData.eatingSprites.size()
    texture = foodData.platelessSprite
    pass

func get_food_data() -> FoodData:
    return _foodWeakRef.get_ref()

func eat(progress: float):
    var foodData: FoodData = _foodWeakRef.get_ref()
    if not _hasStartedEating and progress > 0:
        _hasStartedEating = true
        texture = foodData.eatingSprites[0]

    var progressi = floori(progress / _eatInterval)
    if progressi == _eatState:
        return

    progressi = clampi(progressi, 0, foodData.eatingSprites.size() - 1)
    _eatState = progressi
    texture = foodData.eatingSprites[_eatState]
    pass
