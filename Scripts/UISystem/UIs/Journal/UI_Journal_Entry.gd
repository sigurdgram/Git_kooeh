extends Button
class_name UI_Journal_Entry

@export var _btnFood: Button
@export var _itemImg: TextureRect
@export var _itemTxt: Label



func setup(foodWeakRef: WeakRef, onClickFood: Callable):
    var foodData: FoodData = foodWeakRef.get_ref()
    _itemImg.texture = foodData.sprite

    _btnFood.pressed.connect(onClickFood)
    _btnFood.disabled = true

    if (FoodLibrary.is_food_unlocked(foodData.resource_name)):
        _on_recipe_unlocked(foodData.name)

    if (FoodLibrary.is_food_learned(foodData.resource_name)):
        _on_recipe_learned(foodData.resource_name)
    pass

func _on_recipe_unlocked(_foodName: String):
    _itemTxt.text = _foodName
    pass

func _on_recipe_learned(_foodName: String):
    _btnFood.disabled = not FoodLibrary.is_food_learned(_foodName)
    pass

func focus():
    _btnFood.grab_focus()
    pass
