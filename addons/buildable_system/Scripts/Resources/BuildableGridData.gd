extends Resource
class_name BuildableGridData

@export var texture: Texture2D
@export var layer: BuildableTypes.EBuildableLayer = BuildableTypes.EBuildableLayer.Terrain
@export var mesh: Mesh
@export_flags_2d_physics var collisionLayer: int
@export var cellShape: Shape2D
@export var cellShapeType: AStarGrid2D.CellShape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_RIGHT
@export var cellSize: Vector2i
@export var gridSize: Vector2i
