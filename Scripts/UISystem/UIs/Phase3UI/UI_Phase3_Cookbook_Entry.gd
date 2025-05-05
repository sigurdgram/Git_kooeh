extends Button
class_name UI_Phase3_Cookbook_Entry

@export var _btnFood: Button
@export var _itemImg: TextureRect
@export var _itemTxt: Label
@export var _checkMarkTextRect: TextureRect

var _foodData: WeakRef



func setup(data: WeakRef, onClickFood: Callable):
    _foodData = data

    var foodData: FoodData = data.get_ref()
    _itemImg.texture = foodData.sprite
    _itemTxt.text = foodData.name

    var c = onClickFood.bind(_foodData)
    _btnFood.pressed.connect(c)
    GameplayVariables.onRecipeLearned.connect(_on_recipe_learned)
    _checkMarkTextRect.visible = FoodLibrary.is_food_learned(foodData.resource_name)

    _btnFood.disabled = not FoodLibrary.is_food_unlocked(foodData.resource_name)
    GameplayVariables.onRecipeUnlocked.connect(_on_recipe_unlocked)
    pass

func set_active(state: bool):
    disabled = not state
    focus_mode = Control.FOCUS_NONE if not state else Control.FOCUS_ALL
    pass

func get_food_data() -> FoodData:
    return _foodData.get_ref()

func get_button() -> Button:
    return _btnFood

func _on_recipe_learned(_foodId: String):
    _checkMarkTextRect.visible = FoodLibrary.is_food_learned(_foodData.get_ref().resource_name)
    pass

func _on_recipe_unlocked(_foodId: String):
    _btnFood.disabled = not FoodLibrary.is_food_unlocked(_foodData.get_ref().resource_name)
    pass
