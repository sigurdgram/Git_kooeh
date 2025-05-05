extends GutTest

func test_duplicate_ingredients_reduction():
    var allIngredients: Array = AssetManager.get_asset_ids_of_type(IngredientLibrary.AssetType)
    for i in 100:
        var ingredients: PackedStringArray = []
        ingredients.append(allIngredients.pick_random())
        var dupFound: bool = false
        var compare: Array = []
        for k in resolve_duplicate_ingredients(ingredients):
            if not compare.has(k):
                compare.push_back(k)
            else:
                dupFound = true

        assert_false(dupFound, "Duplicate Ingredients Reduction: Duplication found.")
    pass

func test_rarityX_randomization():
    for a in 100:
        var ingredients: Array = []
        var allIngredients: Array = AssetManager.get_asset_ids_of_type(IngredientLibrary.AssetType)

        for i in 3:
            ingredients.append(allIngredients.pick_random())

        var retVal: Array = []
        var rng: = RandomNumberGenerator.new()
        var requirements = _generate_requirement(rng.randi_range(0, 2))
        for r in requirements:
            var amount: int = requirements[r]
            match r:
                "Common":
                    retVal.append_array(_random_rarity_ingredient(KooehConstant.Rarity.Common, amount))
                "Uncommon":
                    retVal.append_array(_random_rarity_ingredient(KooehConstant.Rarity.Uncommon, amount))
                "CommonX":
                    retVal.append_array(_random_rarityX_ingredient(KooehConstant.Rarity.Common, amount, ingredients))
                "UncommonX":
                    retVal.append_array(_random_rarityX_ingredient(KooehConstant.Rarity.Uncommon, amount, ingredients))
                "X":
                    for i in ingredients:
                        for j in 10:
                            retVal.push_back(i)

        print("\n%s\n%s\n%s" % [requirements, ingredients.map(func get_name(x): return x), retVal.map(func get_name(x): return x)])
    pass

func _random_rarity_ingredient(rarity: KooehConstant.Rarity, amount: int) -> PackedStringArray:
    var retVal: PackedStringArray = []
    var category: Array = IngredientLibrary.get_ingredient_by_rarity(rarity)

    for i in amount:
        retVal.append(category.pick_random())

    return retVal

func _random_rarityX_ingredient(rarity: KooehConstant.Rarity, amount: int, 
    selectedIngredients: PackedStringArray) -> PackedStringArray:
    var retVal: PackedStringArray = []
    var dups: Array = resolve_duplicate_ingredients(selectedIngredients)
    if dups.is_empty():
        return _random_rarity_ingredient(rarity, amount)

    for i in amount:
        retVal.append(dups.pick_random())

    return retVal

func resolve_duplicate_ingredients(array: Array) -> Array:
    var compare: Array = []
    var retVal: Array = []
    for k in array:
        if not compare.has(k):
            retVal.push_back(k)
            compare.push_back(k)

    return retVal

func _generate_requirement(rating: int) -> Dictionary:
    var requirement: Dictionary
    var rng: = RandomNumberGenerator.new()
    match rating:
        0:
            if rng.randf() > 0.5:
                requirement = {"Common": 5}
            else:
                requirement = {"Common": 4, "CommonX": 1}
        1:
            if rng.randf() > 0.5:
                requirement = {"Common": 7, "Uncommon": 7}
            else:
                requirement = {"Common": 6, "Uncommon": 6, "CommonX": 1, "UncommonX": 1}
        2:
            requirement = {"X": 10}
        _:
            assert (false)
    return requirement
