extends Node

var _ingredientInventory: Dictionary
signal onIngredientInventoryUpdated(ingredientID: String, count: int)


func _init():
    for ingredient in AssetManager.get_asset_ids_of_type(IngredientLibrary.AssetType):
        _ingredientInventory[ingredient] = 0

func get_ingredient_inventory() -> Dictionary:
    return _ingredientInventory

func find_ingredient_by_name(ingredientName: String) -> IngredientData:
    for ingredient in _ingredientInventory:
        if ingredient.name == ingredientName:
            return ingredient
    return null

func find_ingredient_by_index(index: int) -> IngredientData:
    var num: int = 0
    for ingredient in _ingredientInventory:
        if num == index:
            return ingredient
        num += 1
    return null

func get_ingredient_count(ingredientName: String) -> int:
    return _ingredientInventory.get(ingredientName, -1)

func set_ingredient_count(ingredientId: String, value: int):
    if _ingredientInventory[ingredientId] == value:
        return

    _ingredientInventory[ingredientId] = value
    onIngredientInventoryUpdated.emit(ingredientId, value)
    pass

func bulk_add_ingredient_count(data: Dictionary):
    for i in data:
        var amount: int = data[i]
        _ingredientInventory[i] += amount
        onIngredientInventoryUpdated.emit(i, _ingredientInventory[i])
    pass
