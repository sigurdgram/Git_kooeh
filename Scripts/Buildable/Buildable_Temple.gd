extends Buildable_Base
class_name Buildable_Temple

@export var _ingredientsToPickup: Dictionary
@export var _collectionUI: PackedScene
@export var _purchaseUI: PackedScene
@export var _ingredientBag: Sprite2D
@export var _audioPickup: AudioStream

var isInTutorial: bool = false


func _ready():
    super ._ready()
    isInTutorial = is_instance_valid(get_tree().get_first_node_in_group("tutorial_prologue"))
    _canInteract = true
    pass

func can_interact(_interactor: Node2D):
    if ( not interactionSystem.is_limited_interaction() or interactionSystem.limited_interactables_contains(self)) and _canInteract:
        return true
    else:
        return false

func _set_canInteract(value: Variant):
    super ._set_canInteract(value)
    if is_instance_valid(_ingredientBag):
        _ingredientBag.visible = value
    pass

func interact(_interactor: Node2D):
    var ingredients: Dictionary = _ingredientsToPickup if isInTutorial else _gather_ingredients(20)
    InventorySystem.bulk_add_ingredient_count(ingredients)
    AudioSystem.play_sfx(_audioPickup)
    InputManager.set_game_input_enabled(false)
    var collectionUI = UITree.PushWidgetToLayer(_collectionUI, UITree.layerGameUI) as UI_Phase1_Temple_Gather
    collectionUI.setup(ingredients)
    collectionUI.onDeactivated.connect(_reenable_game_input)

    super .interact(_interactor)
    _canInteract = false
    pass

func _gather_ingredients(spawnAmount: int) -> Dictionary:
    uninteract(PlayerCharacter.player)
    var retVal: Dictionary = {}
    var unlockedFood: Array[WeakRef] = AssetManager.load_assets_of_type(FoodLibrary.AssetType)

    for i in spawnAmount:
        var randFood: FoodData = unlockedFood[randi() % unlockedFood.size()].get_ref()
        var ingredients: Dictionary = randFood.ingredients

        for j in ingredients:
            if retVal.has(j):
                retVal[j] += ingredients[j]
            else:
                retVal[j] = ingredients[j]

    for i in retVal:
        var amount: int = InventorySystem.get_ingredient_count(i)
        InventorySystem.set_ingredient_count(i, amount + retVal[i])





    return retVal








func _reenable_game_input():
    InputManager.set_game_input_enabled(true)
    pass
