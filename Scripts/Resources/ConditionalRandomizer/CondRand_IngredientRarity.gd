extends ConditionalRandomizer
class_name CondRand_IngredientRarity

@export var rarity: KooehConstant.Rarity
@export_range(0.0, 1.0) var probability: float



func rand():
    var rng: = RandomNumberGenerator.new()
    var r: float = rng.randf()

    if r >= probability:
        var ingredients: Array = IngredientLibrary.get_ingredient_by_rarity(rarity)
        return ingredients.pick_random()

    return null
