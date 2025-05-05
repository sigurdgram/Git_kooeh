extends Control
class_name UI_BuildableMove

@export var _moveIndicator: TextureRect
@export var _moveStateTexture: Array[Texture2D]

var _stamp: Buildable_Base
var _buildable: BuildableData
var _buildMenu: UI_BuildMenu
var _navMeshGen: Node2D
var _assetsTileMap: TileMap
var _highlightsTileMap: TileMap
var _camera2D: Camera2D
var _selectedBuildable: Buildable_Base
var _selectedBuildablePos: Vector2i
var _canPlace: bool
var _tileExtensions: Array[TileExtensions] = []



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
    var mousePos: Vector2i = _camera2D.get_global_mouse_position()
    var mouseTile: Vector2i = _assetsTileMap.local_to_map(mousePos)
    var mouseTilePos = _assetsTileMap.map_to_local(mouseTile)
    position = mouseTilePos

    if _is_buildable_selected():
        _check_occupied_tiles(_buildable.layer)

    _is_moveable()
    _hide_indicator_when_buildable_selected()
    _highlight_tiles()

    if Input.is_action_just_pressed("lmb"):
        if _is_moveable() and not _is_buildable_selected():
            for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
                if not GameplayVariables.placedBuildables[layer].is_empty():
                    if _assetsTileMap.get_cell_alternative_tile(layer, _assetsTileMap.local_to_map(position)) > 0:
                        _selectedBuildable = dict_to_inst(GameplayVariables.placedBuildables[layer].get(_assetsTileMap.local_to_map(position)))
                        _selectedBuildablePos = _assetsTileMap.local_to_map(position)
                    else:
                        continue

                    if _selectedBuildable == null:
                        continue

                    _stamp = GameplayVariables.placedResources[layer].get(_assetsTileMap.local_to_map(position)).buildableScene.instantiate()
                    _buildable = GameplayVariables.placedResources[layer].get(_assetsTileMap.local_to_map(position))
                    _stamp.tileExtensions = _buildable.tileExtensions

                    add_child(_stamp)
                    _stamp.add_to_group("Stamp")
                    _stamp.apply_scale(_selectedBuildable.startScale)



                    var tExtend: Array[TileExtensions] = []
                    if _selectedBuildable.startScale == Vector2(-1, 1):
                        tExtend = _buildable.flippedTileExtensions
                    else:
                        tExtend = _buildable.tileExtensions

                    _tileExtensions = tExtend

                    _selectedBuildable.get_sprite().modulate.a = 0.5
                    break
            accept_event()
        elif _is_buildable_selected() and _get_can_place():
            _delete_occupied_tiles()
            _place_buildable()

    if Input.is_action_just_pressed("rotate") and _is_buildable_selected() and _stamp.is_visible_in_tree():
        _rotate_buildable()

    if Input.is_action_just_pressed("rmb"):
        if _is_buildable_selected():
            _selectedBuildable.get_sprite().modulate.a = 1
            _cancel_move()
            accept_event()
        else:
            set_process(false)
            _highlightsTileMap.clear()
            self.queue_free()
    pass

func _hide_indicator_when_buildable_selected():
    _moveIndicator.visible = not _is_buildable_selected()
    pass

func _is_moveable() -> bool:
    for layer in range(_assetsTileMap.get_layers_count() - 1, -1, -1):
        var altTile = _assetsTileMap.get_cell_alternative_tile(layer, _assetsTileMap.local_to_map(position))
        var buildable = GameplayVariables.placedResources[layer].get(_assetsTileMap.local_to_map(position))

        if buildable == null:
            continue

        if altTile > 0 and is_instance_valid(buildable):
            _moveIndicator.texture = _moveStateTexture[0]
            return true

    _moveIndicator.texture = _moveStateTexture[1]
    return false

func _is_buildable_selected() -> bool:
    return is_instance_valid(_selectedBuildable)

func _cancel_move():
    _stamp.queue_free()
    _selectedBuildable = null
    _buildable = null
    pass

func _place_buildable():
    var tempPos = position
    _assetsTileMap.set_cell(_buildable.layer, _assetsTileMap.local_to_map(tempPos), 6, Vector2i(0, 0), _buildable.tileSetID)
    await get_tree().create_timer(0.01, false).timeout

    _assetsTileMap.get_child(-1).apply_scale(_stamp.scale)
    _assetsTileMap.get_child(-1).startScale = _stamp.scale
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

    _navMeshGen.bake_nav_mesh()
    _cancel_move()

func _rotate_buildable():
    _stamp.apply_scale(Vector2(-1, 1))
    if not _tileExtensions.is_empty():
        if _stamp.scale == Vector2(-1, 1):
            _tileExtensions = _buildable.flippedTileExtensions
        else:
            _tileExtensions = _buildable.tileExtensions

func _get_can_place() -> bool:
    return _canPlace

func _set_can_place(canPlace: bool):
    _canPlace = canPlace

func _check_occupied_tiles(layer: BuildableData.Layer):
    _stamp.get_sprite().material.set_shader_parameter("useCustomColor", true)
    _stamp.get_sprite().material.set_shader_parameter("enabled", true)

    var tExtend: Array[TileExtensions] = []
    if _selectedBuildable.startScale == Vector2(-1, 1):
        tExtend = _buildable.flippedTileExtensions
    else:
        tExtend = _buildable.tileExtensions

    var oriOccupiedTiles: Array[Vector2i] = [_selectedBuildablePos]
    if not tExtend.is_empty():
        var tilePos = _selectedBuildablePos
        for tile in tExtend:
            for n in range(tile.length):
                var dir: int = tile.direction
                var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                oriOccupiedTiles.append(extraTilePos)
                tilePos = extraTilePos

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
                _stamp.get_sprite().material.set_shader_parameter("customColor", Color.GREEN)
            else:
                _set_can_place(false)
                _stamp.get_sprite().material.set_shader_parameter("customColor", Color.RED)

                for oriTilePos in oriOccupiedTiles:
                    if tilePos == oriTilePos:
                        _set_can_place(true)
                        _stamp.get_sprite().material.set_shader_parameter("customColor", Color.GREEN)
                break
    elif layer == BuildableData.Layer.Tabletop:
        for tilePos in occupiedTiles:
            var tableTile = _assetsTileMap.get_cell_alternative_tile(0, tilePos)
            var altTile = _assetsTileMap.get_cell_alternative_tile(layer, tilePos)
            if altTile < 0 and tableTile > 0 and GameplayVariables.placedResources[layer - 1].get(tilePos).category == BuildableData.Category.Table:
                _set_can_place(true)
                _stamp.get_sprite().material.set_shader_parameter("customColor", Color.GREEN)
            else:
                _set_can_place(false)
                _stamp.get_sprite().material.set_shader_parameter("customColor", Color.RED)

                for oriTilePos in oriOccupiedTiles:
                    if tilePos == oriTilePos:
                        _set_can_place(true)
                        _stamp.get_sprite().material.set_shader_parameter("customColor", Color.GREEN)
                break

func _delete_occupied_tiles():
    var layer = _buildable.layer
    var tempPos = _selectedBuildablePos
    var tExtend: Array[TileExtensions] = []
    if _selectedBuildable.startScale == Vector2(-1, 1):
        tExtend = _buildable.flippedTileExtensions
    else:
        tExtend = _buildable.tileExtensions

    var occupiedTiles: Array[Vector2i] = [tempPos]
    if not tExtend.is_empty():
        for tile in tExtend:
            for n in range(tile.length):
                var dir: int = tile.direction
                var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tempPos, dir)
                occupiedTiles.append(extraTilePos)
                tempPos = extraTilePos

    for tile in occupiedTiles:
        _assetsTileMap.erase_cell(layer, tile)

    await get_tree().process_frame
    GameplayVariables.placedResources[layer].erase(_selectedBuildablePos)
    GameplayVariables.placedBuildables[layer].erase(_selectedBuildablePos)

func _highlight_tiles():

    for usedTile in _assetsTileMap.get_used_cells(0):
        _highlightsTileMap.set_cell(0, usedTile, 1, Vector2i(0, 0), 1)

    for highlights in _highlightsTileMap.get_used_cells(0):
        var _altTile = _assetsTileMap.get_cell_alternative_tile(0, highlights)
        if _altTile < 0:
            _highlightsTileMap.erase_cell(0, highlights)

    var tempPos = _selectedBuildablePos
    if _is_buildable_selected():

        var tExtend: Array[TileExtensions] = []
        if _selectedBuildable.startScale == Vector2(-1, 1):
            tExtend = _buildable.flippedTileExtensions
        else:
            tExtend = _buildable.tileExtensions


        var oriOccupiedTiles: Array[Vector2i] = [tempPos]
        if not tExtend.is_empty():
            for tile in tExtend:
                for n in range(tile.length):
                    var dir: int = tile.direction
                    var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tempPos, dir)
                    oriOccupiedTiles.append(extraTilePos)
                    tempPos = extraTilePos

        for oriTile in oriOccupiedTiles:
            _highlightsTileMap.erase_cell(0, oriTile)


        var occupiedTiles: Array[Vector2i] = [_assetsTileMap.local_to_map(position)]
        if not _tileExtensions.is_empty():
            var tilePos = _assetsTileMap.local_to_map(position)
            for tile in _tileExtensions:
                for n in range(tile.length):
                    var dir: int = tile.direction
                    var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                    occupiedTiles.append(extraTilePos)
                    tilePos = extraTilePos


        if _get_can_place():
            for tile in occupiedTiles:
                _highlightsTileMap.set_cell(0, tile, 1, Vector2i(0, 0), 2)
        else:
            for tile in occupiedTiles:
                _highlightsTileMap.set_cell(0, tile, 1, Vector2i(0, 0), 1)
