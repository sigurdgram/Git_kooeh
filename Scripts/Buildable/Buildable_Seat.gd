extends Buildable
class_name Buildable_Seat

@export var _chairs: Dictionary[int, Node]
@export var _interactableComp: InteractableComponent
@export var _staticBody: StaticBody2D

var _buildableVariant: BuildableVariant
var _interactionSystem: InteractionSystem
var _activatedChairs: PackedInt32Array
var _level: int = 0:
    set(v):
        _level = v
        match _level:
            0:
                _sprite.visible = false
                _sprite.modulate = Color(Color.SLATE_GRAY, 0.5)
                _staticBody.set_process(Node.PROCESS_MODE_DISABLED)
                for i in _chairs:
                    _chairs[i].set_activate(false)
            _:
                _sprite.visible = true
                _sprite.modulate = Color.WHITE
                collision_layer = collision_layer | _interactableComp.interactFlag
                _staticBody.set_process_mode(Node.PROCESS_MODE_INHERIT)
                _info[BuildableTypes.Meta_Level] = _level

                _activatedChairs = _buildableVariant.variantData["Upgrade"][_level]
                for i in _activatedChairs:
                    _chairs[i].set_activate(true)
        pass

func _init() -> void :
    add_to_group("Buildable.Seat")
    pass

func upgrade() -> void :
    _level += 1
    pass

func get_level() -> int:
    return _level

func on_enter_edit() -> void :
    if _level == 0:
        _sprite.visible = true

    for i in _chairs:
        if not _activatedChairs.has(i):
            _chairs[i].set_preview(true)
    pass

func on_exit_edit() -> void :
    if _level == 0:
        _sprite.visible = false
    for i in _chairs:
        if not _activatedChairs.has(i):
            _chairs[i].set_preview(false)
    pass

func get_blocked_nav() -> PackedVector2Array:
    if _level == 0:
        return PackedVector2Array()

    var ret: PackedVector2Array = super .get_blocked_nav()
    var mapPos: Vector2i = str_to_var("Vector2i" + get_meta(BuildableTypes.Meta_Info)[BuildableTypes.Meta_MapPos])

    for i in _chairs:
        if _chairs[i].process_mode == Node.PROCESS_MODE_DISABLED:
            continue

        match i:
            1: ret.push_back(mapPos + Vector2i(1, 0))
            3: ret.push_back(mapPos + Vector2i(0, 1))
            5: ret.push_back(mapPos + Vector2i(-1, 0))
            7: ret.push_back(mapPos + Vector2i(0, -1))
    return ret

func _ready() -> void :
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    pass

func setup(buildableSystem: BuildableSystem, data: BuildableData, itemConfig: Dictionary, isPreview: bool = false) -> void :
    super .setup(buildableSystem, data, itemConfig, isPreview)

    _buildableSystem = buildableSystem
    var direction: BuildableTypes.EDirection = itemConfig[BuildableTypes.Meta_Direction]
    _buildableVariant = data.directionalVariants[direction]

    _level = 0
    _level = itemConfig.get_or_add(BuildableTypes.Meta_Level, 0)

    if _buildableSystem.isEditing:
        on_enter_edit()
    else:
        on_exit_edit()
    pass

func can_interact(interactor: Node2D) -> bool:
    var ret: bool = not _interactionSystem.is_limited_interaction() or _interactionSystem.limited_interactables_contains(self)
    return ret

func get_available_chair() -> Buildable_Attachment_Seat:
    var shuffledChairs: Array = Array(_activatedChairs)
    shuffledChairs.shuffle()

    for i in shuffledChairs:
        var activatedChair: Buildable_Attachment_Seat = _chairs[i]
        if not activatedChair.occupied:
            return activatedChair
    return null

func get_chair_direction(chair: Buildable_Attachment_Seat) -> int:
    for i in _chairs:
        if _chairs[i] == chair:
            return i
    return -1

func is_full() -> bool:
    return not is_instance_valid(get_available_chair())

func get_upgrade_desc(level: int, template: RichTextLabel) -> Array[RichTextLabel]:
    var upgradeData: Array = _dataRef.get_ref().customData[BuildableTypes.BuildConfig_Upgrade][level + 1][BuildableTypes.Upgrade_Desc]

    var ret: Array[RichTextLabel]
    for i in upgradeData:
        if not i.has(BuildableTypes.Upgrade_Subject):
            continue

        var rtl: RichTextLabel = template.duplicate()
        rtl.visible = true

        match i[BuildableTypes.Upgrade_Subject]:
            "Seat":
                if i.has(BuildableTypes.Upgrade_Change):
                    var activatedChairs: int = _activatedChairs.size()
                    if activatedChairs > 0:
                        rtl.text = "%s ⇒ [color=WEB_GREEN]%s[/color]    %s" % [activatedChairs, activatedChairs + i[BuildableTypes.Upgrade_Change], i[BuildableTypes.Upgrade_Subject]]
                    else:
                        rtl.text = "[color=WEB_GREEN]%+d[/color] %s" % [i[BuildableTypes.Upgrade_Change], i[BuildableTypes.Upgrade_Subject]]
        ret.push_back(rtl)
    return ret
