extends Control
class_name UI_OrderBubble

@export var _itemImg: TextureRect

var _foodData: FoodData



func setup_order_food(foodData: FoodData):
    _foodData = foodData
    _itemImg.texture = _foodData.sprite
    pass
