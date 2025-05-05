extends Buildable_Base
class_name Buildable_CookingStation

@export var _cookedFoodMaxInventory: int = 10
@export var _cookedFoodPlacementPolygon: TriangulatablePolygon
@export var _radialProgressBar: TextureProgressBar
@export var _cookMenuUI: PackedScene
@export var _audioPickup: AudioStream
@onready var animation = $AnimationPlayer

var _cookTimer: WeakRef
var _cookedFood: String
var _isCooking: bool = false


func get_cook_timer() -> WeakRef:
    await animation.animation_finished
    return _cookTimer

func _ready():
    super ._ready()
    _radialProgressBar.hide()
    animation.play("Stove_Idle")
    pass

func _process(_delta):
    if not _cookTimer or not _cookTimer.get_ref():
        _radialProgressBar.hide()
        return

    _radialProgressBar.value = _cookTimer.get_ref().progress_ratio() * 100
    pass

func can_interact(_interactor: Node2D):
    if not interactionSystem.is_limited_interaction() or interactionSystem.limited_interactables_contains(self):
        if _interactor.is_holding_food() or _isCooking:
            uninteract(_interactor)
            _canInteract = false
        else:
            _canInteract = true
    else:
        _canInteract = false

    return _canInteract

func interact(_interactor: Node2D):






    pass

func take_food(_interactor: Node2D):
    for food in _cookedFoodPlacementPolygon.get_children():
        food.queue_free()

    animation.play("Stove_Idle")
    AudioSystem.play_sfx(_audioPickup)
    var character: = _interactor as PlayerCharacter
    var amount: int = AssetManager.load_asset(_cookedFood).get_ref().batchCookAmount

    if character.hold_food({_cookedFood: amount}):
        _cookedFood = ""
    pass

func cook(foodWeakRef: WeakRef):
    _isCooking = true
    animation.play("Stove_Start")
    await animation.animation_finished

    animation.play("Stove_Mid")
    var cookSystem: CookSystem = GameInstance.gameWorld.cookSystem
    _cookTimer = cookSystem.cook(foodWeakRef)
    var timer: = _cookTimer.get_ref() as CookTimer
    timer.onCookTimeUp.connect(_spawn_food.bind(foodWeakRef.get_ref().resource_name))
    _radialProgressBar.show()

    pass

func _spawn_food(foodID: String):
    _isCooking = false
    _cookedFood = foodID

    var cookedFood: FoodData = AssetManager.load_asset(foodID).get_ref()
    var batchCookAmount: int = min(cookedFood.batchCookAmount, _cookedFoodMaxInventory)

    for i in batchCookAmount:
        var spawnedFood: = Food.new(foodID)
        _cookedFoodPlacementPolygon.add_child(spawnedFood)
        var point: Vector2 = _cookedFoodPlacementPolygon.get_random_point()
        spawnedFood.position = point
    pass
    animation.play("Stove_End")
    await animation.animation_finished
    animation.play("Stove_Collect")

func get_rect() -> Rect2:
    return _sprite.get_rect()
