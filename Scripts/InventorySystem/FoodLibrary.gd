class_name FoodLibrary

const KopiO: String = "FoodData.KopiO"
const KuihLapis: String = "FoodData.KuihLapis"
const OndehOndeh: String = "FoodData.OndehOndeh"
const PineappleTart: String = "FoodData.PineappleTart"
const SirapLimau: String = "FoodData.SirapLimau"
const TehTarik: String = "FoodData.TehTarik"
const KuihBahulu: String = "FoodData.KuihBahulu"
const PatPoh: String = "FoodData.PatPoh"
const Vadai: String = "FoodData.Vadai"
const KuihSaguMerah: String = "FoodData.KuihSaguMerah"
const AmbraJuice: String = "FoodData.AmbraJuice"

const AssetType: String = "FoodData"



static func is_food_learned(assetId: String):
    return GameplayVariables.get_learned_recipes().has(assetId)

static func is_food_unlocked(assetId: String):
    return GameplayVariables.get_unlocked_recipes().has(assetId)

static func get_unlocked_food() -> PackedStringArray:
    var unlockedFood: Array = []
    var unlockedRecipes: Array = GameplayVariables.get_unlocked_recipes()
    for i in AssetManager.get_asset_ids_of_type(AssetType):
        if unlockedRecipes.has(i):
            unlockedFood.push_back(i)
    return unlockedFood

static func get_learned_food() -> PackedStringArray:
    var learnedFood: PackedStringArray = []
    var learnedRecipes: PackedStringArray = GameplayVariables.get_learned_recipes()
    for i in AssetManager.get_asset_ids_of_type(AssetType):
        if learnedRecipes.has(i):
            learnedFood.push_back(i)
    return learnedFood
