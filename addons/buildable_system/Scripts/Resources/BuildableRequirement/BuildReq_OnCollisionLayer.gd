extends BuildableRequirement
class_name BuildReq_OnCollisionLayer

@export_flags_2d_physics var collisionLayer: int
var _shapeQuery: PhysicsShapeQueryParameters2D
var _space: PhysicsDirectSpaceState2D

func init(buildableSystem: BuildableSystem, data: BuildableData) -> void :
    super .init(buildableSystem, data)
    var cursorInstance: BuildableCursor = buildableSystem.get_cursor()
    _space = cursorInstance.get_world_2d().direct_space_state

    _shapeQuery = PhysicsShapeQueryParameters2D.new()
    _shapeQuery.collide_with_areas = true
    _shapeQuery.collision_mask = collisionLayer
    _shapeQuery.shape_rid = cursorInstance.shape
    pass

func get_check_time() -> BuildableTypes.ECheckTime:
    return BuildableTypes.ECheckTime.OnTargetPosChanged

func is_pass(buildableSystem: BuildableSystem, data: BuildableData) -> String:
    var cursorInstance: BuildableCursor = buildableSystem.get_cursor()
    var preview: Node2D = buildableSystem.selectedPreview

    var hits: int = 0
    var scanCount: int = 0
    for i in preview.get_children():
        if not i is ShapeCast2D:
            continue
        scanCount += 1
        _shapeQuery.transform = i.global_transform
        var result: Array[Dictionary] = _space.intersect_shape(_shapeQuery)
        for j in result:
            hits += 1

    if hits == scanCount:
        return ""
    return "Not on layer %s" % collisionLayer
