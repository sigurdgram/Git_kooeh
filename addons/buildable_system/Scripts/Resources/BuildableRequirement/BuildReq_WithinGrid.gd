extends BuildableRequirement
class_name BuildReq_WithinGrid

@export var _scanLocations: Array[Vector2]

func init(buildableSystem: BuildableSystem, data: BuildableData) -> void :
    var preview: Node2D = buildableSystem.selectedPreview
    if not is_instance_valid(preview):
        return

    var cursorInstance: BuildableCursor = buildableSystem.get_cursor()
    var tileMapLayer: TileMapLayer = buildableSystem.get_tile_map_layer()
    var grid: AStarGrid2D = buildableSystem.get_grid()
    var gridData: BuildableGridData = buildableSystem.get_grid_data()

    for i in _scanLocations:
        var shapeCast: ShapeCast2D = ShapeCast2D.new()
        shapeCast.shape = cursorInstance.shape
        shapeCast.target_position = Vector2.ZERO
        shapeCast.collide_with_areas = true
        shapeCast.collide_with_bodies = false
        shapeCast.collision_mask = gridData.collisionLayer | data.collisionLayer
        var pos: Vector2 = tileMapLayer.map_to_local(i + Vector2.UP)
        preview.add_child(shapeCast)
        shapeCast.position = pos
    pass

func is_pass(buildableSystem: BuildableSystem, data: BuildableData) -> String:
    var cursorInstance: BuildableCursor = buildableSystem.get_cursor()
    var preview: Node2D = buildableSystem.selectedPreview
    var tileMapLayer: TileMapLayer = buildableSystem.get_tile_map_layer()
    var grid: AStarGrid2D = buildableSystem.get_grid()

    var hits: Dictionary
    for i in preview.get_children():
        if not i is ShapeCast2D:
            continue

        i.force_shapecast_update()
        for j in i.collision_result:
            var collisionLayer: int = PhysicsServer2D.area_get_collision_layer(j.rid)
            if hits.has(collisionLayer):
                hits[collisionLayer] += 1
            else:
                hits[collisionLayer] = 1

    var terrain: int = buildableSystem.get_grid_data().collisionLayer
    if hits.has(terrain) and hits.keys().size() == 1 and hits.values()[0] == _scanLocations.size():
        return ""

    return "Not in GridMap"

func get_affected_locations() -> Array[Vector2]:
    return _scanLocations

func get_check_time() -> BuildableTypes.ECheckTime:
    return BuildableTypes.ECheckTime.OnTargetPosChanged
