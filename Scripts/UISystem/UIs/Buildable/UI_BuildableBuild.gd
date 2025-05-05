extends Control
class_name UI_BuildableBuild

var _buildMenu: UI_BuildMenu
var _navMeshGen: Node2D
var _assetsTileMap: TileMap
var _highlightsTileMap: TileMap
var _buildable: BuildableData
var _stamp: Buildable_Base
var _camera2D: Camera2D
var _canPlace: bool
var _tileExtensions: Array[TileExtensions] = []



func _ready():
    _camera2D = GameInstance.gameViewport.get_camera_2d()
    _navMeshGen = get_tree().get_first_node_in_group("NavMeshGen")
    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")
    _highlightsTileMap = get_tree().get_first_node_in_group("TileMapHighlights")
    pass

func setup_buildable(buildable: BuildableData, menu: UI_BuildMenu):
    _buildMenu = menu
    _buildable = buildable
    _tileExtensions = _buildable.tileExtensions
    _stamp = buildable.buildableScene.instantiate()
    _stamp.tileExtensions = _buildable.tileExtensions
    add_child(_stamp)
    _stamp.add_to_group("Stamp")
    pass

func _exit_tree():
    _buildMenu.moneyWarning.visible = false
    pass

func _hide_stamp_when_mouse_out_of_bound():
    if is_visible_in_tree() != UI_BuildMenu.is_mouse_in_playing_field():
        visible = UI_BuildMenu.is_mouse_in_playing_field()
    pass

func _process(_delta):
    _hide_stamp_when_mouse_out_of_bound()

    var mousePos: Vector2i = _camera2D.get_global_mouse_position()
    var mouseTile: Vector2i = _assetsTileMap.local_to_map(mousePos)
    var mouseTilePos = _assetsTileMap.map_to_local(mouseTile)
    position = mouseTilePos

    _check_occupied_tiles(_buildable.layer)
    _highlight_tiles()

    if Input.is_action_just_pressed("lmb") and _stamp.is_visible_in_tree():
        if _get_can_place() and _get_enough_money():
            _place_buildable()
        else:
            pass

    if Input.is_action_just_pressed("rotate") and _stamp.is_visible_in_tree():
        _rotate_buildable()

    if Input.is_action_just_pressed("rmb"):
        _buildMenu.moneyWarning.visible = false
        set_process(false)
        _highlightsTileMap.clear()
        self.queue_free()
    pass

func _place_buildable():
    var tempPos = position
    _assetsTileMap.set_cell(_buildable.layer, _assetsTileMap.local_to_map(tempPos), 6, Vector2i(0, 0), _buildable.tileSetID)
    await get_tree().create_timer(0.01, false).timeout

    _assetsTileMap.get_child(-1).apply_scale(_stamp.scale)
    _assetsTileMap.get_child(-1).startScale = _stamp.scale

    for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
        if _buildable.layer >= GameplayVariables.placedResources.size():
            var resourceDict: Dictionary = {_assetsTileMap.local_to_map(tempPos): _buildable}
            var buildableDict: Dictionary = {_assetsTileMap.local_to_map(tempPos): inst_to_dict(_assetsTileMap.get_child(-1))}
            GameplayVariables.placedResources.append(resourceDict)
            GameplayVariables.placedBuildables.append(buildableDict)
        else:
            GameplayVariables.placedResources[_buildable.layer][_assetsTileMap.local_to_map(tempPos)] = _buildable
            GameplayVariables.placedBuildables[_buildable.layer][_assetsTileMap.local_to_map(tempPos)] = inst_to_dict(_assetsTileMap.get_child(-1))

    var occupiedTiles: Array[Vector2i] = []
    if not _tileExtensions.is_empty():
        var tilePos = _assetsTileMap.local_to_map(position)
        for tile in _tileExtensions:
            for n in range(tile.length):
                var dir: int = tile.direction
                var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                occupiedTiles.append(extraTilePos)
                tilePos = extraTilePos

    for tile in occupiedTiles:
        _assetsTileMap.set_cell(_buildable.layer, tile, 6, Vector2i(0, 0), 0)

    GameplayVariables.add_money( - _buildable.price)
    _navMeshGen.bake_nav_mesh()

func _rotate_buildable():
    _stamp.apply_scale(Vector2(-1, 1))
    if not _tileExtensions.is_empty():
        if _stamp.scale == Vector2(-1, 1):
            _tileExtensions = _buildable.flippedTileExtensions
        else:
            _tileExtensions = _buildable.tileExtensions
    pass

func _check_occupied_tiles(layer: BuildableData.Layer):
    _stamp.get_sprite().material.set_shader_parameter("useCustomColor", true)
    _stamp.get_sprite().material.set_shader_parameter("enabled", true)

    var occupiedTiles: Array[Vector2i] = [_assetsTileMap.local_to_map(position)]
    if not _tileExtensions.is_empty():
        var tilePos = _assetsTileMap.local_to_map(position)
        for tile in _tileExtensions:
            for n in range(tile.length):
                var dir: int = tile.direction
                var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                occupiedTiles.append(extraTilePos)
                tilePos = extraTilePos

    if layer == BuildableData.Layer.Floor:
        for tilePos in occupiedTiles:
            var altTile = _assetsTileMap.get_cell_alternative_tile(layer, tilePos)
            if altTile < 0 and _navMeshGen._is_point_in_map(_assetsTileMap.map_to_local(tilePos)):
                _set_can_place(true)
            else:
                _set_can_place(false)
                break
    elif layer == BuildableData.Layer.Tabletop:
        for tilePos in occupiedTiles:
            var tableTile = _assetsTileMap.get_cell_alternative_tile(0, tilePos)
            var altTile = _assetsTileMap.get_cell_alternative_tile(layer, tilePos)
            if altTile < 0 and tableTile > 0 and GameplayVariables.placedResources[layer - 1].get(tilePos).category == BuildableData.Category.Table:
                _set_can_place(true)
            else:
                _set_can_place(false)
                break

func _highlight_tiles():
    var occupiedTiles: Array[Vector2i] = [_assetsTileMap.local_to_map(position)]
    if not _tileExtensions.is_empty():
        var tilePos = _assetsTileMap.local_to_map(position)
        for tile in _tileExtensions:
            for n in range(tile.length):
                var dir: int = tile.direction
                var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                occupiedTiles.append(extraTilePos)
                tilePos = extraTilePos

    for usedTile in _assetsTileMap.get_used_cells(0):
        _highlightsTileMap.set_cell(0, usedTile, 1, Vector2i(0, 0), 1)

    for highlights in _highlightsTileMap.get_used_cells(0):
        var _altTile = _assetsTileMap.get_cell_alternative_tile(0, highlights)
        if _altTile < 0:
            _highlightsTileMap.erase_cell(0, highlights)

    for tile in occupiedTiles:
        if _get_can_place() and _get_enough_money():
            _highlightsTileMap.set_cell(0, tile, 1, Vector2i(0, 0), 2)
            _stamp.get_sprite().material.set_shader_parameter("customColor", Color.GREEN)
        else:
            if _get_enough_money():
                _buildMenu.moneyWarning.visible = false
            else:
                _buildMenu.moneyWarning.visible = true

            _highlightsTileMap.set_cell(0, tile, 1, Vector2i(0, 0), 1)
            _stamp.get_sprite().material.set_shader_parameter("customColor", Color.RED)

func _get_can_place() -> bool:
    return _canPlace

func _set_can_place(canPlace: bool):
    _canPlace = canPlace

func _get_enough_money() -> bool:
    if EconomySystem.get_currency() >= _buildable.price:
        return true
    else:
        return false
