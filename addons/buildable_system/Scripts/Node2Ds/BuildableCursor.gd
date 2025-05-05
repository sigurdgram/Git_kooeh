extends ShapeCast2D
class_name BuildableCursor

var _buildableSystem: BuildableSystem
var _tileMapLayer: TileMapLayer
var _selectedBuildable: BuildableData
var _targetPosRequirements: Array[BuildableRequirement]

signal onTargetPosChanged(location: Vector2)

func _init() -> void :
    collide_with_areas = true
    collide_with_bodies = false
    target_position = Vector2.ZERO
    pass

func setup(buildableSystem: BuildableSystem) -> void :
    _buildableSystem = buildableSystem
    _tileMapLayer = _buildableSystem.get_tile_map_layer()

    collision_mask = 0
    for i in BuildableTypes.EBuildableMask.values():
        collision_mask |= i
    pass

func _process(delta: float) -> void :
    var loc: Vector2i = _tileMapLayer.local_to_map(_tileMapLayer.get_local_mouse_position())
    var newLoc: Vector2 = _tileMapLayer.to_global(_tileMapLayer.map_to_local(loc))

    if newLoc == global_position:
        return

    global_position = newLoc
    onTargetPosChanged.emit(global_position)
    pass
