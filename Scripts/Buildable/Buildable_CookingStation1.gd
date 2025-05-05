extends Buildable
class_name Buildable_CookingStation1

@export var _cookedFoodMaxInventory: int = 10
@export var _cookedFoodPlacementPolygon: TriangulatablePolygon
@export var _radialProgressBar: TextureProgressBar
@export var _cookMenuUI: PackedScene
@export var _audioPickup: AudioStream
@export var animation: AnimationPlayer

var _cookTimer: WeakRef
var _cookedFood: String
var _isCooking: bool = false
var _level: int = 0:
    set(v):
        _level = v
        match _level:
            0:
                _sprite.visible = false
                _sprite.modulate = Color(Color.SLATE_GRAY, 0.5)
                _staticBody.set_process_mode(Node.PROCESS_MODE_DISABLED)
            1:
                _sprite.visible = true
                _sprite.modulate = Color.WHITE
                collision_layer = collision_layer | _interactableComp.interactFlag
                _staticBody.set_process_mode(Node.PROCESS_MODE_INHERIT)
                _info[BuildableTypes.Meta_Level] = 1
        pass


@export var _interactableComp: InteractableComponent
@export var _staticBody: StaticBody2D

var _interactionSystem: InteractionSystem

func upgrade() -> void :
    _level += 1
    pass

func get_level() -> int:
    return _level

func on_enter_edit() -> void :
    if _level == 0:
        _sprite.visible = true
    pass

func on_exit_edit() -> void :
    if _level == 0:
        _sprite.visible = false
    pass

func get_cook_timer() -> WeakRef:
    await animation.animation_finished
    return _cookTimer

func get_blocked_nav() -> PackedVector2Array:
    return super .get_blocked_nav() if _level > 0 else PackedVector2Array()

func setup(buildableSystem: BuildableSystem, data: BuildableData, info: Dictionary, isPreview: bool = false) -> void :
    super .setup(buildableSystem, data, info, isPreview)
    if isPreview:
        return

    _level = 0
    _level = info.get_or_add(BuildableTypes.Meta_Level, 0)
    pass

func _ready() -> void :
    _radialProgressBar.hide()
    animation.play("Stove_Idle")
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem

    _interactableComp.onInteract.connect(onInteract)
    _interactableComp.onUninteract.connect(onUninteract)

    if _buildableSystem.isEditing:
        on_enter_edit()
    else:
        on_exit_edit()
    pass

func _process(_delta):
    if not _cookTimer or not _cookTimer.get_ref():
        _radialProgressBar.hide()
        return

    _radialProgressBar.value = _cookTimer.get_ref().progress_ratio() * 100
    pass

func can_interact(interactor: Node2D) -> bool:
    var ret: bool = false
    if not _interactionSystem.is_limited_interaction() or _interactionSystem.limited_interactables_contains(self):
        if interactor.is_holding_food() or _isCooking:
            ret = false
        else:
            ret = true
    else:
        ret = false
    return ret

func onInteract(interactor: Node2D) -> void :
    if _cookedFoodPlacementPolygon.get_child_count() < 1:
        var cookMenu: = UITree.PushWidgetToLayer(_cookMenuUI, UITree.layerGame) as UI_Phase2_Cookbook
        cookMenu.cookingStation = self
    else:
        take_food(interactor)

    _interactableComp.uninteract(interactor)
    pass

func onUninteract(_interactor: Node2D) -> void :
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

    animation.play("Stove_End")
    await animation.animation_finished
    animation.play("Stove_Collect")
    pass

func get_rect() -> Rect2:
    return $Sprite2D.get_rect()

func get_upgrade_desc(level: int, template: RichTextLabel) -> Array[RichTextLabel]:
    var upgradeData: Array = _dataRef.get_ref().customData[BuildableTypes.BuildConfig_Upgrade][level + 1][BuildableTypes.Upgrade_Desc]
    var ret: Array[RichTextLabel]
    for i in upgradeData:
        if not i.has(BuildableTypes.Upgrade_Subject):
            continue

        var rtl: RichTextLabel = template.duplicate()
        rtl.visible = true

        match i[BuildableTypes.Upgrade_Subject]:
            "Stove":
                if i.has(BuildableTypes.Upgrade_Change):
                    rtl.text = "[color=WEB_GREEN]%+d[/color] %s" % [i[BuildableTypes.Upgrade_Change], i[BuildableTypes.Upgrade_Subject]]
        ret.push_back(rtl)
    return ret
