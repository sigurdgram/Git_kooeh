extends Buildable
class_name Buildable_Temple1

@export var _ingredientsToPickup: Dictionary
@export var _collectionUI: PackedScene
@export var _ingredientBag: Sprite2D
@export var _audioPickup: AudioStream

@onready var _interactableComp: InteractableComponent = $InteractableComponent

var isInTutorial: bool = false
var _interactionSystem: InteractionSystem

func _ready() -> void :
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    isInTutorial = is_instance_valid(get_tree().get_first_node_in_group("tutorial_prologue"))
    _interactableComp.onInteract.connect(onInteract)
    pass

func can_interact(_interactor: Node2D):
    var ret: bool = not _interactionSystem.is_limited_interaction() or _interactionSystem.limited_interactables_contains(self)
    ret = ret and _ingredientBag.visible
    return ret

func onInteract(_interactor: Node2D) -> void :
    var ingredients: Dictionary = _ingredientsToPickup if isInTutorial else _gather_ingredients(50)
    InventorySystem.bulk_add_ingredient_count(ingredients)
    AudioSystem.play_sfx(_audioPickup)
    InputManager.set_game_input_enabled(false)
    var collectionUI = UITree.PushWidgetToLayer(_collectionUI, UITree.layerGameUI) as UI_Phase1_Temple_Gather
    collectionUI.setup(ingredients)
    collectionUI.onDeactivated.connect(_reenable_game_input)
    _ingredientBag.visible = false
    pass

func _gather_ingredients(spawnAmount: int) -> Dictionary:
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

func onUninteract(_interactor: Node2D) -> void :
    pass
