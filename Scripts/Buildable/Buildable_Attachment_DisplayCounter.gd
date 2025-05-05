extends Buildable
class_name Buildable_DisplayCounter1

@export var _foodPositions: Node2D
@export var _staticBody: StaticBody2D
@export var _audioPickup: AudioStream
@export var _interactableComp: InteractableComponent

var _interactionSystem: InteractionSystem
var _orderSystem: OrderSystem
var _posMap: Dictionary[StringName, Node]
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

func get_blocked_nav() -> PackedVector2Array:
    return super .get_blocked_nav() if _level > 0 else PackedVector2Array()

func get_pos_map() -> Dictionary[StringName, Node]:
    return _posMap

func _ready() -> void :
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem

    _interactableComp.onInteract.connect(onInteract)
    _interactableComp.onUninteract.connect(onUninteract)

    collision_layer = collision_layer | _interactableComp.interactFlag
    pass

func setup(buildableSystem: BuildableSystem, data: BuildableData, itemConfig: Dictionary, 
    isPreview: bool = false) -> void :

    super .setup(buildableSystem, data, itemConfig, isPreview)

    _level = itemConfig.get_or_add(BuildableTypes.Meta_Level, 0)
    if _buildableSystem.isEditing:
        on_enter_edit()
    else:
        on_exit_edit()

    if isPreview:
        return

    if is_instance_valid(GameInstance.gameWorld):
        _orderSystem = GameInstance.gameWorld.orderSystem

    pass

func can_interact(interactor: Node2D) -> bool:
    var ret: bool = not _interactionSystem.is_limited_interaction() or _interactionSystem.limited_interactables_contains(self)
    ret = ret and interactor.is_holding_food()

    return ret

func onInteract(interactor: Node2D) -> void :
    var holdFoods: Dictionary = interactor.release_food()
    for i in holdFoods:


        var slot: Node2D
        if _posMap.has(i):
            slot = _posMap[i]
        else:
            var untaggedChildren: Array[Node] = _foodPositions.get_children().filter(func(x: Node): return not x.has_meta("FoodType"))
            if untaggedChildren.is_empty():
                untaggedChildren = _foodPositions.get_children()
            slot = untaggedChildren.pick_random()
            slot.set_meta("FoodType", i)
            _posMap[i] = slot

        for j in holdFoods[i]:
            var food: = Food.new(i)
            slot.add_child(food)

    if is_instance_valid(_orderSystem):
        _orderSystem.check_fulfillable_order()
    AudioSystem.play_sfx(_audioPickup)
    onUninteract(interactor)
    pass

func get_displayed_food() -> Dictionary:
    var ret: Dictionary
    for i in _posMap:
        var count: int = _posMap[i].get_child_count()
        if count <= 0:
            continue

        ret[i] = count
    return ret

func onUninteract(_interactor: Node2D) -> void :
    pass

func get_fulfillable_orders(orderList: Dictionary) -> Array[int]:
    var fulfillableOrders: Array[int]
    var keys = orderList.keys()

    for i in _posMap:
        var amount: int = _posMap[i].get_child_count()

        var v: Array = orderList.values().map(
            func(value):
                return value.order[i] if value.order.has(i) else 0)

        for j in v.size():
            var value = v[j]
            if value <= 0 or amount == 0:
                continue

            var orderID: int = keys[j]
            var pending: int = amount - value
            if pending >= 0:
                fulfillableOrders.push_back(orderID)
    return fulfillableOrders

func get_upgrade_desc(level: int, template: RichTextLabel) -> Array[RichTextLabel]:
    var upgradeData: Array = _dataRef.get_ref().customData[BuildableTypes.BuildConfig_Upgrade][level + 1][BuildableTypes.Upgrade_Desc]
    var ret: Array[RichTextLabel]
    for i in upgradeData:
        if not i.has(BuildableTypes.Upgrade_Subject):
            continue

        var rtl: RichTextLabel = template.duplicate()
        rtl.visible = true

        match i[BuildableTypes.Upgrade_Subject]:
            "Display Counter":
                if i.has(BuildableTypes.Upgrade_Change):
                    rtl.text = "[color=WEB_GREEN]%+d[/color] %s" % [i[BuildableTypes.Upgrade_Change], i[BuildableTypes.Upgrade_Subject]]
        ret.push_back(rtl)
    return ret
