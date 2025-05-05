extends BuildableRequirement
class_name BuildReq_AttachOnSlot

@export_flags_2d_physics var targetCollisionLayer: int
@export var slotName: String

var _shapeQuery: PhysicsShapeQueryParameters2D
var _space: PhysicsDirectSpaceState2D
var _attachmentPoint: Node2D

func init(buildableSystem: BuildableSystem, data: BuildableData) -> void :
    super .init(buildableSystem, data)
    var cursorInstance: BuildableCursor = buildableSystem.get_cursor()
    _space = cursorInstance.get_world_2d().direct_space_state

    _shapeQuery = PhysicsShapeQueryParameters2D.new()
    _shapeQuery.collide_with_areas = true
    _shapeQuery.collision_mask = targetCollisionLayer
    _shapeQuery.shape_rid = cursorInstance.shape
    pass

func get_check_time() -> BuildableTypes.ECheckTime:
    return BuildableTypes.ECheckTime.OnTargetPosChanged

func get_attachment_point() -> Node2D:
    return _attachmentPoint

func is_pass(buildableSystem: BuildableSystem, data: BuildableData) -> String:
    var cursorInstance: BuildableCursor = buildableSystem.get_cursor()
    var preview: Node2D = buildableSystem.selectedPreview
    _shapeQuery.transform = cursorInstance.global_transform
    var result: Array[Dictionary] = _space.intersect_shape(_shapeQuery)

    if result.is_empty():
        _attachmentPoint = null
        return "No object to attach to"

    for i in result:
        var collider: Node2D = i["collider"]
        if not collider.has_meta(BuildableTypes.Meta_Slots):
            continue

        var slots: Dictionary = collider.get_meta(BuildableTypes.Meta_Slots)
        if slots.has(slotName):
            _attachmentPoint = collider.get_node(slots[slotName])
            if _attachmentPoint.get_child_count() > 0:
                return "Slot '%s' is occupied"
            return ""

    _attachmentPoint = null
    return "Slot '%s' does not exist" % slotName
