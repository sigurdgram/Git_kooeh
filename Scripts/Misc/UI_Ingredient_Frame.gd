extends Control
class_name UI_Ingredient_Frame

@export var _textRect: TextureRect

var _itemWeakRef: WeakRef


func setup(ingredientID: String):
    _itemWeakRef = AssetManager.load_asset(ingredientID) if !ingredientID.is_empty() else weakref(null)

    var itemData: IngredientData = _itemWeakRef.get_ref()
    if not is_instance_valid(itemData):
        hide()
        return

    _textRect.texture = itemData.texture

    show()
    pass
