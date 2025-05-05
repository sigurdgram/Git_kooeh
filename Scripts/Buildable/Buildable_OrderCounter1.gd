extends Buildable
class_name Buildable_OrderCounter1

@export var queue: QueueSystem
@export var _interactableComp: InteractableComponent
@export var _staticBody: StaticBody2D

var _orderSystem: OrderSystem
var _interactionSystem: InteractionSystem
var _variant: BuildableVariant
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

func _ready():
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    _interactableComp.onInteract.connect(onInteract)
    _interactableComp.onUninteract.connect(onUninteract)

    if is_instance_valid(GameInstance.gameWorld):
        _orderSystem = GameInstance.gameWorld.orderSystem
        await get_tree().process_frame
        var queueStart: Vector2i = _variant.variantData["RPosQueueStart"]
        var m: TileMapLayer = _buildableSystem.get_tile_map_layer()
        var mapPos: Vector2i = str_to_var("Vector2i" + get_meta(BuildableTypes.Meta_Info)[BuildableTypes.Meta_MapPos])

        var v: Vector2 = m.to_global(m.map_to_local(mapPos + queueStart))
        queue.global_position = v

        for i in _variant.variantData["RPosQueuePoints"]:
            var pos: Vector2 = m.to_global(m.map_to_local(mapPos + queueStart + Vector2i(i)))
            queue.curve.add_point(pos)

        var spawnPointPosi: Vector2i = _variant.variantData[BuildableTypes.Meta_SpawnPoint]
        var spawnPointPos: Vector2 = m.to_global(m.map_to_local(mapPos + spawnPointPosi))
        _buildableSystem.set_meta(BuildableTypes.Meta_SpawnPoint, spawnPointPos)

    if _buildableSystem.isEditing:
        on_enter_edit()
    else:
        on_exit_edit()
    pass

func setup(buildableSystem: BuildableSystem, data: BuildableData, itemConfig: Dictionary, 
    isPreview: bool = false) -> void :

    super .setup(buildableSystem, data, itemConfig, isPreview)

    if isPreview:
        return

    _buildableSystem = buildableSystem
    var direction: BuildableTypes.EDirection = itemConfig[BuildableTypes.Meta_Direction]
    _variant = data.directionalVariants[direction]
    _level = itemConfig.get_or_add(BuildableTypes.Meta_Level, 0)
    pass

func can_interact(_interactor: Node2D) -> bool:
    var ret: int = not _interactionSystem.is_limited_interaction() or _interactionSystem.limited_interactables_contains(self)
    ret &= int( not _orderSystem.get_order_list().is_empty())

    var queueHead: QueueNode = queue.get_queue_head()
    if is_instance_valid(queueHead):
        var firstCustomer: Customer = queueHead.get_data() as Customer
        ret &= int(firstCustomer.is_order_fulfillable())
    return ret

func onInteract(interactor: Node2D) -> void :
    var queueHead: QueueNode = queue.get_queue_head()
    var customer: Customer = queueHead.get_data() as Customer
    customer.fulfill_order()
    _interactableComp.uninteract(interactor)
    pass

func onUninteract(_interactor: Node2D) -> void :
    pass

func get_blocked_nav() -> PackedVector2Array:
    return super .get_blocked_nav() if _level > 0 else PackedVector2Array()

func get_upgrade_desc(level: int, template: RichTextLabel) -> Array[RichTextLabel]:
    var upgradeData: Array = _dataRef.get_ref().customData[BuildableTypes.BuildConfig_Upgrade][level + 1][BuildableTypes.Upgrade_Desc]

    var ret: Array[RichTextLabel]
    for i in upgradeData:
        if not i.has(BuildableTypes.Upgrade_Subject):
            continue

        var rtl: RichTextLabel = template.duplicate()
        rtl.visible = true

        match i[BuildableTypes.Upgrade_Subject]:
            "Order Counter":
                if i.has(BuildableTypes.Upgrade_Change):
                    rtl.text = "[color=WEB_GREEN]%+d[/color] %s" % [i[BuildableTypes.Upgrade_Change], i[BuildableTypes.Upgrade_Subject]]
        ret.push_back(rtl)
    return ret
