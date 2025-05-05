@tool
extends CollisionPolygon2D
class_name TriangulatablePolygon

@warning_ignore("unused_private_class_variable")
@export var _generate: bool:
    set(_value):
        _generate_triangulation_data()
        pass

@export var _triangulationData: PackedFloat32Array
@export var _triangles: PackedInt32Array

func _generate_triangulation_data():
    if not Engine.is_editor_hint():
        return

    _triangles = Geometry2D.triangulate_polygon(polygon)
    @warning_ignore("integer_division")
    var triangle_count: int = _triangles.size() / 3
    assert (triangle_count > 0)
    _triangulationData.resize(triangle_count)
    _triangulationData[-1] = 0
    for i in range(triangle_count):
        var a: Vector2 = polygon[_triangles[3 * i + 0]]
        var b: Vector2 = polygon[_triangles[3 * i + 1]]
        var c: Vector2 = polygon[_triangles[3 * i + 2]]
        _triangulationData[i] = _triangulationData[i - 1] + _triangle_area(a, b, c)

    notify_property_list_changed()
    pass

func _triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
    return 0.5 * abs((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))

func _random_triangle_point(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
    return a + sqrt(randf()) * ( - a + b + randf() * (c - b))

func get_random_point() -> Vector2:
    var totalArea: float = _triangulationData[-1]
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    var chosenTriangleIndex: int = _triangulationData.bsearch(rng.randf() * totalArea)
    var a: Vector2 = polygon[_triangles[3 * chosenTriangleIndex + 0]]
    var b: Vector2 = polygon[_triangles[3 * chosenTriangleIndex + 1]]
    var c: Vector2 = polygon[_triangles[3 * chosenTriangleIndex + 2]]
    return _random_triangle_point(a, b, c)
