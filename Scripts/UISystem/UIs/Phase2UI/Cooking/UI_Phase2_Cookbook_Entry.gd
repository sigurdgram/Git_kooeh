extends Button
class_name UI_Phase2_Cookbook_Entry

@export var _btnFood: Button
@export var _itemImg: TextureRect
@export var _itemTxt: Label

var _foodWeakRef: WeakRef

func setup(data: WeakRef, onClickFood: Callable):
    _foodWeakRef = data

    var foodData: FoodData = data.get_ref()
    _itemImg.texture = foodData.sprite
    _itemTxt.text = foodData.name

    var c = onClickFood.bind(data)
    _btnFood.pressed.connect(c)

    GameplayVariables.onRecipeLearned.connect(_on_recipe_learned)
    _btnFood.visible = FoodLibrary.is_food_unlocked(foodData.resource_name)
    _btnFood.disabled = not FoodLibrary.is_food_learned(foodData.resource_name)
    pass

func get_button() -> Button:
    return _btnFood

func get_food_data() -> FoodData:
    return _foodWeakRef.get_ref()

func _on_recipe_learned(_foodId: String):
    _btnFood.disabled = not FoodLibrary.is_food_learned(_foodWeakRef.get_ref().resource_name)
    pass
