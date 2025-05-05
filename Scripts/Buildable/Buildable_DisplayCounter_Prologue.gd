extends Buildable_Base
class_name Buildable_DisplayCounter_Prologue

@export var _collectionUI: PackedScene
@export var _ingredientsToPickup: Dictionary
@export var _ingredientGroup: Node2D
@export var _audioPickup: AudioStream

var isInTutorial: bool = false


func _ready():
    super ._ready()
    var tutorial = get_tree().get_first_node_in_group("tutorial_prologue")
    isInTutorial = is_instance_valid(tutorial)
    pass

func can_interact(_interactor: Node2D):
    if ( not interactionSystem.is_limited_interaction() or interactionSystem.limited_interactables_contains(self)) and _canInteract:
        return true
    else:
        return false

func interact(_interactor: Node2D):
    if isInTutorial:
        InventorySystem.bulk_add_ingredient_count(_ingredientsToPickup)
    else:
        InventorySystem.bulk_add_ingredient_count(_generate_items_to_pickup(20))

    _ingredientGroup.hide()
    AudioSystem.play_sfx(_audioPickup)
    super .interact(_interactor)
    _canInteract = false
    pass

func _generate_items_to_pickup(spawnAmount: int) -> Dictionary:
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

    InputManager.set_game_input_enabled(false)
    var collectionUI = UITree.PushWidgetToLayer(_collectionUI, UITree.layerGameUI) as UI_Phase1_Temple_Gather
    collectionUI.setup(retVal)
    collectionUI.onDeactivated.connect(_reenable_game_input)
    return retVal

func _reenable_game_input():
    InputManager.set_game_input_enabled(true)
    pass
