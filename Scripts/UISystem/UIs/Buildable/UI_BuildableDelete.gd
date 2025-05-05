extends Control
class_name UI_BuildableDelete

@export var _deleteIndicator: TextureRect
@export var _deleteStateTexture: Array[Texture2D]

var _buildMenu: UI_BuildMenu
var _navMeshGen: Node2D
var _assetsTileMap: TileMap
var _highlightsTileMap: TileMap
var _camera2D: Camera2D



func _ready():
    _camera2D = GameInstance.gameViewport.get_camera_2d()
    _navMeshGen = get_tree().get_first_node_in_group("NavMeshGen")
    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")
    _highlightsTileMap = get_tree().get_first_node_in_group("TileMapHighlights")
    pass

func setup_buildable(menu: UI_BuildMenu):
    _buildMenu = menu
    pass

func _process(_delta):
    _hide_indicator_when_mouse_out_of_bound()
    var mousePos: Vector2i = _camera2D.get_global_mouse_position()
    var mouseTile: Vector2i = _assetsTileMap.local_to_map(mousePos)
    var mouseTilePos = _assetsTileMap.map_to_local(mouseTile)
    position = mouseTilePos

    if not UI_BuildMenu.is_mouse_in_playing_field():
        return

    for usedTile in _assetsTileMap.get_used_cells(0):
        _highlightsTileMap.set_cell(0, usedTile, 1, Vector2i(0, 0), 2)

    for highlights in _highlightsTileMap.get_used_cells(0):
        var _altTile = _assetsTileMap.get_cell_alternative_tile(0, highlights)
        if _altTile < 0:
            _highlightsTileMap.erase_cell(0, highlights)

    _is_deletable()

    if Input.is_action_just_pressed("lmb") and _is_deletable():
        _delete_occupied_tiles()
    else:
        pass

    if Input.is_action_just_pressed("rmb"):
        set_process(false)
        _highlightsTileMap.clear()
        self.queue_free()
    pass

func _hide_indicator_when_mouse_out_of_bound():
    if _deleteIndicator.is_visible_in_tree() != UI_BuildMenu.is_mouse_in_playing_field():
        _deleteIndicator.visible = UI_BuildMenu.is_mouse_in_playing_field()
    pass

func _is_deletable() -> bool:
    for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
        var altTile = _assetsTileMap.get_cell_alternative_tile(layer, _assetsTileMap.local_to_map(position))
        var buildable = GameplayVariables.placedResources[layer].get(_assetsTileMap.local_to_map(position))

        if buildable == null:
            continue

        if altTile > 0 and is_instance_valid(buildable):
            _deleteIndicator.texture = _deleteStateTexture[0]
            return true

    _deleteIndicator.texture = _deleteStateTexture[1]
    return false

func _delete_occupied_tiles():
    for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
        if GameplayVariables.placedResources[layer].is_empty():
            continue

        var tempPos = position
        var buildable = GameplayVariables.placedBuildables[layer].get(_assetsTileMap.local_to_map(tempPos))
        if buildable == null:
            continue

        var tExtend: Array[TileExtensions] = []
        if dict_to_inst(buildable).startScale == Vector2(-1, 1):
            tExtend = GameplayVariables.placedResources[layer].get(_assetsTileMap.local_to_map(tempPos)).flippedTileExtensions
        else:
            tExtend = GameplayVariables.placedResources[layer].get(_assetsTileMap.local_to_map(tempPos)).tileExtensions

        var occupiedTiles: Array[Vector2i] = [_assetsTileMap.local_to_map(tempPos)]
        if not tExtend.is_empty():
            var tilePos = _assetsTileMap.local_to_map(tempPos)
            for tile in tExtend:
                for n in range(tile.length):
                    var dir: int = tile.direction
                    var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                    occupiedTiles.append(extraTilePos)
                    tilePos = extraTilePos

        for tile in occupiedTiles:
            _assetsTileMap.erase_cell(layer, tile)

        GameplayVariables.add_money(GameplayVariables.placedResources[layer][_assetsTileMap.local_to_map(tempPos)].price)
        GameplayVariables.placedResources[layer].erase(_assetsTileMap.local_to_map(tempPos))
        GameplayVariables.placedBuildables[layer].erase(_assetsTileMap.local_to_map(tempPos))
        _rebake_mesh()
        break

func _rebake_mesh():
    await get_tree().create_timer(0.02, false).timeout
    _navMeshGen.bake_nav_mesh()
