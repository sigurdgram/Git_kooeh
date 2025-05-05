extends Buildable_Base
class_name Buildable_Table

@export var foodPosition: Node2D
@export var seatScene: PackedScene

var _navMeshGen: NavMeshGenerator
var _assetsTileMap: TileMap
var _seatingSystem: SeatingSystem
var seat: Seat



func _ready():
    _navMeshGen = get_tree().get_first_node_in_group("NavMeshGen")
    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")
    _seatingSystem = GameInstance.gameWorld.seatingSystem
    if not is_in_group("Stamp"):
        _navMeshGen.onNavMeshBaked.connect(check_chairs)

func get_food_arrangement(amount: int, chairPos: Vector2) -> Array:
    assert (amount <= get_capacity())
    assert (amount >= 1)

    var pos = global_position
    var direction: Vector2 = (chairPos - pos).normalized().sign()
    var foodPos: int

    if direction == Vector2(1, 1):
        foodPos = 0
    elif direction == Vector2(-1, 1):
        foodPos = 1
    elif direction == Vector2(-1, -1):
        foodPos = 2
    elif direction == Vector2(1, -1):
        foodPos = 3

    var arrangement = foodPosition.get_child(foodPos)
    var array = []
    array.append(arrangement.get_child(0).global_position)
    return array


func get_capacity() -> int:
    return foodPosition.get_child_count()

func check_chairs():
    var tempPos = position
    for tile in _assetsTileMap.get_surrounding_cells(_assetsTileMap.local_to_map(tempPos)):
        if _assetsTileMap.get_cell_alternative_tile(0, tile) > 0:
            if GameplayVariables.placedResources[0].get(tile).category == BuildableData.Category.Chair:
                if seat == null:
                    seat = seatScene.instantiate()
                    _seatingSystem.add_child(seat)
                    seat.add_table(self)

                for chair in get_tree().get_nodes_in_group("Chair"):
                    chair.check_table()
        else:
            pass

    await get_tree().process_frame

    if not seat == null and seat.get_chairs().is_empty():
        seat.queue_free()
