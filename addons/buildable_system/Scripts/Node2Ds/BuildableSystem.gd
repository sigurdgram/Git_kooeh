extends Node2D
class_name BuildableSystem







@export var _root2D: Node2D
@export var _gridData: BuildableGridData
@export var _layerHolder: Node2D

@export_category("Upgrade")
@export var upgradeBundle: UpgradeBundle

@export_category("Targeting")
@export var _cursor: PackedScene

@export_category("Interaction")
@export var _interactionMapping: Dictionary = {
    BuildableTypes.BuildMode_Build: null, 
    BuildableTypes.BuildMode_Delete: null, 
    BuildableTypes.BuildMode_Move: null
}

var _layers: Array[Node]
var _grid: AStarGrid2D
var _tileMapLayer: TileMapLayer
var _gridMesh: BuildableGridMesh
var _cursorInstance: BuildableCursor
var _physArea: RID
var isEditing: bool = false:
    set(v):
        if isEditing == v:
            return

        isEditing = v

        if isEditing:
            _gridMesh.show()
            onEnterEdit.emit()
        else:
            _gridMesh.hide()
            onExitEdit.emit()
        pass

var _auxillarySystems: Dictionary

var mode: StringName = BuildableTypes.BuildMode_None:
    set = set_build_mode

var selectedPreview: Node2D:
    set(v):
        if is_instance_valid(selectedPreview):
            selectedPreview.free()

        if is_instance_valid(v):
            _root2D.add_child(v)

        selectedPreview = v
        pass

signal onBuildModeChanged(buildMode: StringName)
signal onBuildableSelected(data: BuildableData)
signal onEnterEdit()
signal onExitEdit()




func set_build_mode(v: StringName) -> void :
    if mode == v:
        return

    if _interactionMapping.has(mode):
        _interactionMapping[mode].exit()

    mode = v

    if _interactionMapping.has(v):
        _interactionMapping[v].enter()

    onBuildModeChanged.emit(mode)
    pass

func get_upgrade_bundle() -> UpgradeBundle:
    return upgradeBundle

func get_grid() -> AStarGrid2D:
    return _grid

func get_root2D() -> Node2D:
    return _root2D

func get_buildable_layer(layer: BuildableTypes.EBuildableLayer) -> Node2D:
    return _layers[layer]

func get_tile_map_layer() -> TileMapLayer:
    return _tileMapLayer

func get_cursor() -> BuildableCursor:
    return _cursorInstance

func get_interaction_mapping() -> Dictionary:
    return _interactionMapping

func get_grid_data() -> BuildableGridData:
    return _gridData

func get_auxillary_system(systemName: StringName, node: Variant, createIfNull: bool) -> Variant:
    if not createIfNull:
        assert (_auxillarySystems.has(systemName))
        return

    var system: Node = null
    if _auxillarySystems.has(systemName) and is_instance_valid(_auxillarySystems[systemName]):
        system = _auxillarySystems[systemName]
    else:
        system = _auxillarySystems.get_or_add(systemName, node.new())
        add_child.call_deferred(system)
    return system

func build(config: Dictionary = {}) -> void :
    if not is_instance_valid(_root2D):
        push_error("Root2D in BuildableSystem is invalid, please ensure it is valid.")
        return

    if config.has(BuildableTypes.BuildConfig_GridData):
        _gridData = load(config[BuildableTypes.BuildConfig_GridData])
        if is_instance_valid(_gridMesh):
            _gridMesh.free()

    if config.has(BuildableTypes.BuildConfig_UpgradeBundle):
        upgradeBundle = load(config[BuildableTypes.BuildConfig_UpgradeBundle])

    _layers = _layerHolder.get_children()
    for i in _layers:
        for j in i.get_children():
            j.free()


    if not is_instance_valid(_tileMapLayer):
        _tileMapLayer = TileMapLayer.new()
        _root2D.add_child(_tileMapLayer)

    var tileSet: = TileSet.new()
    tileSet.tile_size = _gridData.cellSize
    match _gridData.cellShapeType:
        AStarGrid2D.CELL_SHAPE_SQUARE:
            tileSet.tile_shape = TileSet.TILE_SHAPE_SQUARE
        AStarGrid2D.CELL_SHAPE_ISOMETRIC_RIGHT:
            tileSet.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
            tileSet.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_RIGHT
        AStarGrid2D.CELL_SHAPE_ISOMETRIC_DOWN:
            tileSet.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
            tileSet.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN

    _tileMapLayer.tile_set = tileSet


    if not is_instance_valid(_grid):
        _grid = AStarGrid2D.new()
    _grid.cell_shape = _gridData.cellShapeType
    _grid.cell_size = _gridData.cellSize
    _grid.region = Rect2i(Vector2.ZERO, _gridData.gridSize)
    _grid.update()


    _gridMesh = BuildableGridMesh.new(_gridData, self)
    _gridMesh.hide()
    _layerHolder.add_child(_gridMesh)
    _layerHolder.move_child(_gridMesh, 1)


    if _physArea.is_valid():
        PhysicsServer2D.area_clear_shapes(_physArea)
        PhysicsServer2D.free_rid(_physArea)
    _generate_phys_area(_gridData.cellShape)
    PhysicsServer2D.area_set_monitorable(_physArea, true)
    PhysicsServer2D.area_set_collision_layer(_physArea, _gridData.collisionLayer)
    PhysicsServer2D.area_attach_object_instance_id(_physArea, 
        get_buildable_layer(BuildableTypes.EBuildableLayer.Terrain).get_instance_id())


    if not is_instance_valid(_cursorInstance):
        _cursorInstance = _cursor.instantiate()
        _cursorInstance.setup(self)
        _root2D.add_child(_cursorInstance)


    for i in _interactionMapping:
        if is_instance_valid(_interactionMapping[i]):
            _interactionMapping[i].setup(self)

    if config.has("Layers"):
        var allBuildables: Array[Buildable]

        var layers: Dictionary = config["Layers"]
        for l in layers:
            var itemArray: Array = layers[l]
            var holder: Node2D = _layerHolder.find_child(l, false)
            for i in itemArray:
                _recursive_build_tiles(i, allBuildables)

        rebuild_navigation(allBuildables)

    await get_tree().physics_frame
    propagate_notification(BuildableTypes.EBuildableNotification.RebuildSeats)
    pass

func generate_save_config_dict() -> Dictionary:
    var config: Dictionary = {
        BuildableTypes.BuildConfig_GridData: ResourceUID.id_to_text(ResourceLoader.get_resource_uid(_gridData.resource_path)), 
        BuildableTypes.BuildConfig_UpgradeBundle: ResourceUID.id_to_text(ResourceLoader.get_resource_uid(upgradeBundle.resource_path)), 
        "Layers": {}
    }

    var layers: Dictionary = config["Layers"]
    for i in _layerHolder.get_children():
        if not i.has_meta("IsLayer"):
            continue
        layers[i.name] = _recursive_search_buildable(i)

    return config

func rebuild_navigation(allBuildables: Array[Buildable]) -> void :
    var tiles: Dictionary = _gridMesh.generate_clean_navigation()

    for b in allBuildables:
        for i in b.get_blocked_nav():
            if _grid.is_in_boundsv(i):
                tiles[i] = 1
                _grid.set_point_solid(i)
    _gridMesh.visualize_nav(tiles)

func pathfind(fromGlobalPosition: Vector2, toGlobalPosition: Vector2) -> PackedVector2Array:
    var from: Vector2i = _tileMapLayer.local_to_map(fromGlobalPosition - global_position)
    var to: Vector2i = _tileMapLayer.local_to_map(toGlobalPosition - global_position)
    return pathfindi(from, to)

func pathfindi(from: Vector2i, to: Vector2i) -> PackedVector2Array:
    var neighbours: Array = [
        Vector2i(1, 0), 
        Vector2i(1, 1), 
        Vector2i(0, 1), 
        Vector2i(-1, 1), 
        Vector2i(-1, 0), 
        Vector2i(-1, -1), 
        Vector2i(0, -1)
        ]

    if not _grid.is_in_boundsv(from) or _grid.is_point_solid(from):
        var arr: Array = neighbours.map(func cost_estimate(v: Vector2i):
            var newV: Vector2i = from + v
            if not _grid.is_in_boundsv(newV):
                return 999

            return newV.distance_squared_to(to))

        from = from + neighbours[arr.find(arr.min())]

    if not _grid.is_in_boundsv(to) or _grid.is_point_solid(to):
        var arr: Array = neighbours.map(func cost_estimate(v: Vector2i):
            var newV: Vector2i = to + v
            if not _grid.is_in_boundsv(newV):
                return 999

            return from.distance_squared_to(newV))

        to = to + neighbours[arr.find(arr.min())]

    return _grid.get_point_path(from, to, true)

func get_point_global_positioni(position: Vector2i) -> Vector2:
    var tempPos: Vector2 = _grid.get_point_position(position)
    return _tileMapLayer.to_global(tempPos - global_position)



func _recursive_build_tiles(item: Dictionary, outAllBuildables: Array[Buildable]) -> Buildable:
    var data: BuildableData = AssetManager.load_asset(item[BuildableTypes.Meta_ID]).get_ref()
    var mapPos: Vector2i = str_to_var("Vector2i" + item[BuildableTypes.Meta_MapPos])
    var buildable: Buildable = BuildableBuild.force_build_tile(self, data, item, mapPos)
    outAllBuildables.push_back(buildable)

    if item.has(BuildableTypes.Meta_Slots):
        var slots: Dictionary = item[BuildableTypes.Meta_Slots]
        for s in slots:
            var s_: Dictionary = buildable.get_meta(BuildableTypes.Meta_Slots)
            var attachPoint: Node2D = buildable.get_node(s_[s])
            var child: Node2D = _recursive_build_tiles(slots[s], outAllBuildables)
            child.reparent(attachPoint)
            child.position = Vector2.ZERO
    return buildable

func _recursive_search_buildable(node: Node) -> Array[Dictionary]:
    var ret: Array[Dictionary]

    for i in node.get_children():
        if not i is Buildable:
            continue

        ret.append(i.to_dict())

        if i.get_child_count() > 0:
            ret.append_array(_recursive_search_buildable(i))
    return ret

func _generate_phys_area(areaShape: Shape2D) -> void :
    _physArea = PhysicsServer2D.area_create()
    PhysicsServer2D.area_set_space(_physArea, _root2D.get_world_2d().space)
    var index: int = 0
    var gridSize: Vector2i = _gridData.gridSize
    for i in gridSize.x:
        for j in gridSize.y:
            var pos = _grid.get_point_position(Vector2i(i, j))
            var t = Transform2D(0.0, pos)
            PhysicsServer2D.area_add_shape(_physArea, areaShape.get_rid(), _root2D.transform * t)
            index += 1
    pass

func _ready() -> void :
    build()
    pass

func _unhandled_input(event: InputEvent) -> void :
    if mode == BuildableTypes.BuildMode_None:
        return

    if is_instance_valid(_interactionMapping[mode]):
        _interactionMapping[mode].input(event)
    pass

func select_buildable(data: BuildableData) -> void :
    onBuildableSelected.emit(data)
    pass
