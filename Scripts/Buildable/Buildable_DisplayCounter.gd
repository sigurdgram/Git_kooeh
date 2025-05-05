extends Buildable_Base
class_name Buildable_DisplayCounter

@export var _foodPositions: Node2D
@export var _audioPickup: AudioStream

var _posMap: Dictionary = {}
var _serveSystem: ServeSystem
var slotAmount: Dictionary = {}
var foods: Dictionary


func _ready():
    super ._ready()
    _build_posMap()
    call_deferred("_setup")
    pass

func _setup():
    _serveSystem = GameInstance.gameWorld.serveSystem

    pass

func _build_posMap():
    for i in _foodPositions.get_children():
        _posMap[i] = null
    pass

func can_interact(_interactor: Node2D):
    if not interactionSystem.is_limited_interaction() or interactionSystem.limited_interactables_contains(self):
        if _interactor.is_holding_food():
            _canInteract = true
        else:
            uninteract(_interactor)
            _canInteract = false
    else:
        _canInteract = false

    return _canInteract

func interact(_interactor: Node2D):

    foods = _interactor.release_food()

    AudioSystem.play_sfx(_audioPickup)
    super .interact(_interactor)
    _on_cooked_foods_updated(foods)
    pass

func _on_cooked_foods_updated(cookedFoods: Dictionary):

    var slots: Array = _posMap.values()

    for i in foods:
        if slots.has(i):
            slotAmount[i] += 1
            continue
        else:
            slotAmount[i] = 1

        var emptySlot: Node2D = slots.filter(func select_empty(x): return x == null).pick_random()
        var key = _posMap.find_key(emptySlot)
        _posMap[key] = i

        var food: = Food.new(i)
        key.add_child(food)
        slots.erase(i)









    pass
