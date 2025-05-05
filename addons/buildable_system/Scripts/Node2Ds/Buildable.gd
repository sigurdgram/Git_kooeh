extends Area2D
class_name Buildable

@export var _clickablePolygon: CollisionPolygon2D
@export var _sprite: Sprite2D

var _dataRef: WeakRef
var _info: Dictionary
var _buildableSystem: BuildableSystem
var _isPreview: bool

func setup(buildableSystem: BuildableSystem, data: BuildableData, info: Dictionary, isPreview: bool = false) -> void :
    _buildableSystem = buildableSystem
    _dataRef = weakref(data)
    collision_layer = data.collisionLayer
    priority = data.collisionPriority
    _info = info
    _isPreview = isPreview

    if isPreview:
        _clickablePolygon.disabled = true
        modulate = Color(Color.WHITE, 0.5)
        z_index = 1
        return

    z_index = 0
    set_meta(BuildableTypes.Meta_Info, info)
    pass

func get_buildable_data() -> WeakRef:
    return _dataRef

func get_buildable_variant() -> BuildableVariant:
    return _dataRef.get_ref().directionalVariant[get_direction()]

func get_is_preview() -> bool:
    return _isPreview

func get_direction() -> BuildableTypes.EDirection:
    return _info[BuildableTypes.Meta_Direction]

func get_sprite() -> Sprite2D:
    return _sprite

func get_buildable_system() -> BuildableSystem:
    return _buildableSystem

func get_blocked_nav() -> PackedVector2Array:
    var blockedNav: PackedVector2Array
    var mapPos: Vector2i = str_to_var("Vector2i" + get_meta(BuildableTypes.Meta_Info)[BuildableTypes.Meta_MapPos])
    for i in _dataRef.get_ref().directionalVariants[get_direction()].blockedNav:
        blockedNav.push_back(mapPos + Vector2i(i))
    return blockedNav

func to_dict() -> Dictionary:
    var meta: Dictionary = get_meta(BuildableTypes.Meta_Info).duplicate()
    if has_meta(BuildableTypes.Meta_Slots):
        var slots: Dictionary = meta.get_or_add(BuildableTypes.Meta_Slots, {})
        var attachmentsSlots: Dictionary = get_meta(BuildableTypes.Meta_Slots)
        for i in attachmentsSlots:
            for j in get_node(attachmentsSlots[i]).get_children():
                slots.get_or_add(i, j.to_dict())
    return meta

func can_interact(_interactor: Node2D) -> bool:
    return true
