extends Buildable_Base
class_name Buildable_Chair

@export var sitPosition: Node2D
@export var _navTargetTolerance: CollisionShape2D
@export var rayCast: RayCast2D

var _navMeshGen: Node2D
var _assetsTileMap: TileMap
var _seatingSystem: SeatingSystem
var _isTableAssigned: bool = false
var _assignedTable: Buildable_Table

var _isOccupied: bool = false



func _ready():
    super ._ready()
    _navMeshGen = get_tree().get_first_node_in_group("NavMeshGen")
    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")
    _seatingSystem = GameInstance.gameWorld.seatingSystem

    if not is_in_group("Stamp"):
        _navMeshGen.onNavMeshBaked.connect(check_table)

func _process(delta):
    if get_table_assigned() and is_instance_valid(_assignedTable):
        rayCast.target_position = (_assignedTable.position - position) * 0.15 * scale
    else:
        rayCast.target_position = Vector2.ZERO

func get_navigation_target_tolerance() -> float:
    return _navTargetTolerance.shape.get_rect().size.x

func check_table():
    if get_table_assigned() and not is_instance_valid(_assignedTable):
        set_table_assigned(false)

    var tempPos = position
    for tile in _assetsTileMap.get_surrounding_cells(_assetsTileMap.local_to_map(tempPos)):
        if not GameplayVariables.placedResources[0].get(tile) == null and GameplayVariables.placedResources[0].get(tile).category == BuildableData.Category.Table:
            if not get_table_assigned():
                for table in get_tree().get_nodes_in_group("Table"):
                    if _assetsTileMap.local_to_map(table.global_position) == tile:
                        _assignedTable = table

                if not _assignedTable == null and is_instance_valid(_assignedTable.seat):
                    _assignedTable.seat.add_chair(self)
                    set_table_assigned(true)
                return
            else:
                return

    _assignedTable = null
    set_table_assigned(false)

func set_table_assigned(assigned: bool):
    _isTableAssigned = assigned
    pass

func get_table_assigned() -> bool:
    return _isTableAssigned

func set_is_occupied(state: bool):
    _isOccupied = state
    pass

func get_is_occupied() -> bool:
    return _isOccupied
