extends Node

@export var _phase3Cookbook: PackedScene
@export var phase3CookSystem: Phase3CookSystem

var cookbook: UI_Phase3_Cookbook


func _ready():
    GameInstance.gameWorld = self
    GameInstance.gameWorld.phase3CookSystem = phase3CookSystem

    var data: PackedStringArray = AssetManager.get_asset_ids_of_type("FoodData")
    for i in data:
        GameplayVariables.add_unlocked_recipe(i)

    cookbook = UITree.PushWidgetToLayer(_phase3Cookbook, UITree.layerGameUI)
    cookbook.disregardIngredients = true
    phase3CookSystem.onCookSequenceCompleted.connect(destroy, CONNECT_ONE_SHOT)
    pass

func destroy(cookedFood: WeakRef, successRate: float):
    phase3CookSystem.get_cookingUI().get_ref().queue_free()
    cookbook.queue_free()
    queue_free()
    pass
