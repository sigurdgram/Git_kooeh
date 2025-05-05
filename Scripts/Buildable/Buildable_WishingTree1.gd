extends Buildable
class_name Buildable_WishingTree1

@export var _selectIngredientPrompt: PackedScene
@onready var _interactableComp: InteractableComponent = $"InteractableComponent"

var _wishingTreeUI: WeakRef
var _interactionSystem: InteractionSystem

signal onStartWish()


func get_wishing_tree_ui() -> WeakRef:
    return _wishingTreeUI

func _ready() -> void :
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    _interactableComp.onInteract.connect(func(_interactor: Node2D): onStartWish.emit())
    onStartWish.connect(start_wish, CONNECT_ONE_SHOT)
    pass

func can_interact(_interactor: Node2D):
    return ( not _interactionSystem.is_limited_interaction() or _interactionSystem.limited_interactables_contains(self)) and onStartWish.is_connected(start_wish)

func start_wish():
    var ui: = UITree.PushWidgetToLayer(_selectIngredientPrompt, UITree.layerGameUI) as UI_Phase1_WishingTree
    _wishingTreeUI = weakref(ui)
    ui.setup(self)
    pass

func random_wish_ingredients(rating: int, selectedIngredients: PackedStringArray) -> Dictionary:
    var rewards: Array = []
    var requirement: Dictionary = _generate_requirement(rating)
    for r in requirement:
        var amount: int = requirement[r]
        match r:
            "Common":
                rewards.append_array(_random_rarity_ingredient(KooehConstant.Rarity.Common, amount))
            "Uncommon":
                rewards.append_array(_random_rarity_ingredient(KooehConstant.Rarity.Uncommon, amount))
            "CommonX":
                rewards.append_array(_random_rarityX_ingredient(KooehConstant.Rarity.Common, amount, selectedIngredients))
            "UncommonX":
                rewards.append_array(_random_rarityX_ingredient(KooehConstant.Rarity.Uncommon, amount, selectedIngredients))
            "X":
                for i in selectedIngredients:
                    for j in 10:
                        rewards.push_back(i)

    var rewardDict = rewards.reduce(func dictionarize(accum, element):
        if accum.has(element):
            accum[element] += 1
        else:
            accum[element] = 1
        return accum
    , Dictionary())

    InventorySystem.bulk_add_ingredient_count(rewardDict)
    return rewardDict

func _random_rarity_ingredient(rarity: KooehConstant.Rarity, amount: int) -> PackedStringArray:
    var retVal: PackedStringArray = []
    var category: Array = IngredientLibrary.get_ingredient_by_rarity(rarity)

    for i in amount:
        var data: String = category.pick_random()
        retVal.append(data)

    return retVal

func _random_rarityX_ingredient(rarity: KooehConstant.Rarity, amount: int, 
    selectedIngredients: PackedStringArray) -> PackedStringArray:
    var retVal: PackedStringArray = []
    var dups = resolve_duplicate_ingredients(selectedIngredients)
    if dups.is_empty():
        return _random_rarity_ingredient(rarity, amount)

    for i in amount:
        retVal.append(dups.pick_random())

    return retVal

func resolve_duplicate_ingredients(array: Array) -> Array:
    var compare: Array = []
    var retVal: Array = []
    for k in array:
        if compare.has(k):
            retVal.push_back(k)
        else:
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
