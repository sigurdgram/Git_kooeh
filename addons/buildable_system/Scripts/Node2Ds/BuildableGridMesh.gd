extends MultiMeshInstance2D
class_name BuildableGridMesh

var _buildableSystem: BuildableSystem
var _gridSize: Vector2i

func _init(gridData: BuildableGridData, buildableSystem: BuildableSystem) -> void :
    texture_filter = TEXTURE_FILTER_NEAREST
    _buildableSystem = buildableSystem

    var cellSize: Vector2i = gridData.cellSize
    _gridSize = gridData.gridSize

    multimesh = MultiMesh.new()
    multimesh.use_colors = true
    multimesh.mesh = gridData.mesh
    multimesh.instance_count = _gridSize.x * _gridSize.y
    texture = gridData.texture

    var grid: AStarGrid2D = buildableSystem.get_grid()
    for i in _gridSize.x:
        for j in _gridSize.y:
            var index: int = _gridSize.x * i + j
            multimesh.set_instance_transform_2d(index, Transform2D(0, grid.get_point_position(Vector2i(i, j))))
            multimesh.set_instance_color(index, Color.WHITE)
    pass

func generate_clean_navigation() -> Dictionary:
    var ret: Dictionary
    for i in _gridSize.x:
        for j in _gridSize.y:
            var index: int = _gridSize.x * i + j
            ret[Vector2(i, j)] = 0
    return ret

func visualize_nav(navDict: Dictionary) -> void :
    for point in navDict:
        var status: int = navDict[point]
        var index: int = _gridSize.x * point.x + point.y

        var color = Color.RED if status == 1 else Color.WHITE
        multimesh.set_instance_color(index, color)
    pass
