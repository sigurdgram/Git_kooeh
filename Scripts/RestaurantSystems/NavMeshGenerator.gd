extends Node2D
class_name NavMeshGenerator

var _navPolygon: NavigationPolygon
var _navMap: RID
var _navSourceGeomData: NavigationMeshSourceGeometryData2D
var _navRegion: NavigationRegion2D

var _assetsTileMap: TileMap
var _floorTileMap: TileMap
var _terrainTileMap: TileMap
var _beamsTileMap: TileMap

@export_group("Debug")
@export var _isDebug: bool

signal onNavMeshBaked()










func _ready() -> void :
    _navSourceGeomData = NavigationMeshSourceGeometryData2D.new()
    _navPolygon = NavigationPolygon.new()
    _navMap = get_world_2d().get_navigation_map()

    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")
    _floorTileMap = get_tree().get_first_node_in_group("TileMapFloor")
    _terrainTileMap = get_tree().get_first_node_in_group("TileMapTerrain")
    _beamsTileMap = get_tree().get_first_node_in_group("TileMapBeams")
    _setup_dictionaries()

    await get_tree().process_frame

    _navRegion = NavigationRegion2D.new()
    add_sibling(_navRegion)
    _navRegion.navigation_polygon = _navPolygon

    if _isDebug:
        _navRegion = NavigationRegion2D.new()
        add_sibling(_navRegion)
        _navRegion.navigation_polygon = _navPolygon
        _navRegion.set_navigation_map(_navMap)

    await get_tree().process_frame
    _check_placed_buildables()

func _setup_dictionaries():
    if GameplayVariables.placedResources.is_empty():
        for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
            var resourceDict: Dictionary = {}
            GameplayVariables.placedResources.append(resourceDict)

    if GameplayVariables.placedBuildables.is_empty():
        for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
            var buildableDict: Dictionary = {}
            GameplayVariables.placedBuildables.append(buildableDict)

    if GameplayVariables.shopTerrain.is_empty():
        for layer in range(_terrainTileMap.get_layers_count() - 1, -1, -1):
            var terrainDict: Dictionary = {}
            GameplayVariables.shopTerrain.append(terrainDict)

    if GameplayVariables.shopFloor.is_empty():
        for layer in range(_floorTileMap.get_layers_count() - 1, -1, -1):
            var floorDict: Dictionary = {}
            GameplayVariables.shopFloor.append(floorDict)

    if GameplayVariables.shopBeams.is_empty():
        for layer in range(_beamsTileMap.get_layers_count() - 1, -1, -1):
            var beamsDict: Dictionary = {}
            GameplayVariables.shopBeams.append(beamsDict)
    pass

func _extract_nav_polygon() -> NavigationMeshSourceGeometryData2D:
    var navSourceGeom: = NavigationMeshSourceGeometryData2D.new()

    for cell: Vector2i in _terrainTileMap.get_used_cells(0):
        var tileData: TileData = _terrainTileMap.get_cell_tile_data(0, cell)
        var pos: Vector2 = _terrainTileMap.map_to_local(cell)
        var navPoly: NavigationPolygon = tileData.get_navigation_polygon(0)
        if !navPoly:
            continue
        var verts: PackedVector2Array = []
        for i in navPoly.get_vertices():
            verts.append(i + pos)
        navSourceGeom.add_traversable_outline(verts)

    for child in get_tree().get_nodes_in_group("Buildable"):
        if child.is_in_group("Stamp"):
            continue

        var pos: Vector2 = child._areaNavigation.get_child(0).get_global_position()
        var scle: Vector2 = child.scale
        if child._areaNavigation.get_child(0).get_polygon().is_empty():
            continue

        var verts: PackedVector2Array = []
        for i in child._areaNavigation.get_child(0).get_polygon():
            verts.append(i * scle + pos)
        navSourceGeom.add_obstruction_outline(verts)
    return navSourceGeom

func bake_nav_mesh():
    _navSourceGeomData = _extract_nav_polygon()
    NavigationServer2D.bake_from_source_geometry_data(_navPolygon, _navSourceGeomData, _reset_nav_polygon)
    onNavMeshBaked.emit()
    pass

func _reset_nav_polygon():
    _navRegion.navigation_polygon = _navPolygon
    pass

func _is_point_in_map(target_point: Vector2) -> bool:
    var closest_point: = NavigationServer2D.map_get_closest_point(_navMap, target_point)
    var delta: = closest_point - target_point
    if abs(delta) < Vector2.ONE:
        return true
    else:
        return false

func _check_placed_buildables():




    if CampaignSystem.get_event_status(KooehConstant.Prologue) == KooehConstant.CampaignStatus.SUCCESS and GameplayVariables.hasCustomized:
        GameplayVariables.load_restaurant_layout()
        _place_customized_buildables()
        return

    await get_tree().process_frame
    var assetTypes = AssetManager.load_assets_of_type("BuildableData")
    for child in get_tree().get_nodes_in_group("Buildable"):
        var pos = _assetsTileMap.local_to_map(child.get_global_position())
        for asset in assetTypes:
            if asset.get_ref().buildableScene.resource_path == child.scene_file_path:
                var layer = asset.get_ref().layer
                child.startScale = child.scale
                GameplayVariables.placedResources[layer][pos] = asset.get_ref()
                GameplayVariables.placedBuildables[layer][pos] = inst_to_dict(child)
                break

    for layer in _terrainTileMap.get_layers_count():
        for cell in _terrainTileMap.get_used_cells(layer):
            GameplayVariables.shopTerrain[layer][cell] = _terrainTileMap.get_cell_source_id(layer, cell)

    for layer in _floorTileMap.get_layers_count():
        for cell in _floorTileMap.get_used_cells(layer):
            GameplayVariables.shopFloor[layer][cell] = _floorTileMap.get_cell_source_id(layer, cell)

    for layer in _beamsTileMap.get_layers_count():
        for cell in _beamsTileMap.get_used_cells(layer):
            GameplayVariables.shopBeams[layer][cell] = _beamsTileMap.get_cell_source_id(layer, cell)

    await get_tree().process_frame
    GameplayVariables.save_restaurant_layout()
    bake_nav_mesh()
    pass

func _place_customized_buildables():
    _assetsTileMap.clear()
    _setup_dictionaries()
    for layer in _assetsTileMap.get_layers_count():
        if not GameplayVariables.placedResources[layer].is_empty():
            var dict = GameplayVariables.placedResources[layer]
            for pos in dict:
                _assetsTileMap.set_cell(layer, pos, 6, Vector2i(0, 0), dict.get(pos).tileSetID)
                await get_tree().process_frame
                _assetsTileMap.get_child(-1).apply_scale(GameplayVariables.placedBuildables[layer].get(pos).startScale)

                var occupiedTiles: Array[Vector2i] = []
                var tExtend: Array[TileExtensions] = []
                if _assetsTileMap.get_child(-1).scale == Vector2(-1, 1):
                    tExtend = dict.get(pos).flippedTileExtensions
                else:
                    tExtend = dict.get(pos).tileExtensions

                if not tExtend.is_empty():
                    var tilePos = pos
                    for tile in tExtend:
                        for n in range(tile.length):
                            var dir: int = tile.direction
                            var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                            occupiedTiles.append(extraTilePos)
                            tilePos = extraTilePos

                for tile in occupiedTiles:
                    _assetsTileMap.set_cell(layer, tile, 6, Vector2i(0, 0), 0)

    _terrainTileMap.clear()
    for layer in _terrainTileMap.get_layers_count():
        if not GameplayVariables.shopTerrain[layer].is_empty():
            var dict = GameplayVariables.shopTerrain[layer]
            for pos in dict:
                _terrainTileMap.set_cell(layer, pos, GameplayVariables.shopTerrain[layer].get(pos), Vector2i.ZERO)

    _floorTileMap.clear()
    for layer in _floorTileMap.get_layers_count():
        if not GameplayVariables.shopFloor[layer].is_empty():
            var dict = GameplayVariables.shopFloor[layer]
            for pos in dict:
                _floorTileMap.set_cell(layer, pos, GameplayVariables.shopFloor[layer].get(pos), Vector2i.ZERO)

    _beamsTileMap.clear()
    for layer in _beamsTileMap.get_layers_count():
        if not GameplayVariables.shopBeams[layer].is_empty():
            var dict = GameplayVariables.shopBeams[layer]
            for pos in dict:
                _beamsTileMap.set_cell(layer, pos, GameplayVariables.shopBeams[layer].get(pos), Vector2i.ZERO)

    GameplayVariables.placedBuildables.clear()
    _setup_dictionaries()

    var assetTypes = AssetManager.load_assets_of_type("BuildableData")
    for child in get_tree().get_nodes_in_group("Buildable"):
        var pos = _assetsTileMap.local_to_map(child.get_global_position())
        for asset in assetTypes:
            if asset.get_ref().buildableScene.resource_path == child.scene_file_path:
                var layer = asset.get_ref().layer
                child.startScale = child.scale
                GameplayVariables.placedBuildables[layer][pos] = inst_to_dict(child)
                break

    await get_tree().process_frame
    await get_tree().process_frame
    bake_nav_mesh()
    pass
