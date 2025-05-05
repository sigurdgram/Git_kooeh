class_name IngredientLibrary

const AssetType: String = "IngredientData"
const BlackTeaLeaves: String = "IngredientData.BlackTeaLeaves"
const Butter: String = "IngredientData.Butter"
const CasterSugar: String = "IngredientData.CasterSugar"
const CoconutMilk: String = "IngredientData.CoconutMilk"
const CoffeePowder: String = "IngredientData.CoffeePowder"
const CondensedMilk: String = "IngredientData.CondensedMilk"
const Egg: String = "IngredientData.Egg"
const GlutinousRice: String = "IngredientData.GlutinousRice"
const GlutinousRiceFlour: String = "IngredientData.GlutinousRiceFlour"
const GratedCoconut: String = "IngredientData.GratedCoconut"
const IcingSugar: String = "IngredientData.IcingSugar"
const Lime: String = "IngredientData.Lime"
const Oil: String = "IngredientData.Oil"
const PalmSugar: String = "IngredientData.PalmSugar"
const Pandan: String = "IngredientData.Pandan"
const PineappleJam: String = "IngredientData.PineappleJam"
const PlainFlour: String = "IngredientData.PlainFlour"
const RoseSyrup: String = "IngredientData.RoseSyrup"
const Salt: String = "IngredientData.Salt"
const Sugar: String = "IngredientData.Sugar"
const Water: String = "IngredientData.Water"
const DhalBean: String = "IngredientData.DhalBean"
const Onion: String = "IngredientData.Onion"
const CurryPowder: String = "IngredientData.CurryPowder"
const Chili: String = "IngredientData.Chili"
const ChineseHerbs: String = "IngredientData.ChineseHerbs"
const Ambarella: String = "IngredientData.Ambarella"



static func get_all_ingredients() -> Array[WeakRef]:
    return AssetManager.load_assets_of_type(AssetType)

static func get_ingredient_by_rarity(rarity: KooehConstant.Rarity) -> PackedStringArray:
    var sameRarityIngredient: PackedStringArray = []
    for i in get_all_ingredients():
        var ingredient: IngredientData = i.get_ref()
        if rarity == ingredient.rarity:
            sameRarityIngredient.append(ingredient.resource_name)
    return sameRarityIngredient
