extends UI_Widget
class_name UI_BuildMenu

signal onCategoryChange(categoryBitMask)

@export var _hboxBuildable: HBoxContainer
@export var _btnCategoryAll: Button

@export var _btnCategoryTable: Button
@export var _btnCategoryChair: Button
@export var _btnBuildable: PackedScene
@export var _btnMove: Button
@export var _btnDelete: Button
@export var _btnBack: Button
@export var _btnExpand: Button

@export var _buildableBuild: PackedScene
@export var _buildableMove: PackedScene
@export var _buildableDelete: PackedScene
@export var _buildableUpgrade: PackedScene
@export var _restrictionsList: UI_BuildableRestrictions

@export var moneyWarning: TextureRect

var _assetsTileMap: TileMap
var _floorTileMap: TileMap
var _terrainTileMap: TileMap
var _beamsTileMap: TileMap
var _navMeshGenerator: NavMeshGenerator
var categoryBitMask: BuildableData.Category
var _buildableOpControl: Control
static  var _mousePositionValid: bool = false

var shopExpansionCoords: Dictionary = {
    1: [Vector2i(-1, -3), Vector2i(0, -2)], 
    2: [Vector2i(0, -3), Vector2i(0, -4)], 
    3: [Vector2i(-2, -3), Vector2i(-1, -4), Vector2i(-1, -5)], 
    }

var shopExpansionPrices: Dictionary = {
    1: 1500, 
    2: 5000, 
    3: 20000, 
    }

static func is_mouse_in_playing_field() -> bool:
    return _mousePositionValid

func _ready():
    _navMeshGenerator = get_tree().get_first_node_in_group("NavMeshGen")
    _navMeshGenerator.onNavMeshBaked.connect(_check_layout_viability)
    await get_tree().create_timer(0.1, false).timeout
    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")
    _floorTileMap = get_tree().get_first_node_in_group("TileMapFloor")
    _terrainTileMap = get_tree().get_first_node_in_group("TileMapTerrain")
    _beamsTileMap = get_tree().get_first_node_in_group("TileMapBeams")

    _btnCategoryAll.toggled.connect(_on_toggle_all)

    _btnCategoryTable.toggled.connect(_on_toggle_table)
    _btnCategoryChair.toggled.connect(_on_toggle_chair)
    _btnMove.pressed.connect(_on_move_button_pressed)
    _btnDelete.pressed.connect(_on_delete_button_pressed)
    _btnBack.pressed.connect(_on_back_button_pressed)

    _btnExpand.pressed.connect(_on_expand_button_pressed)
    _btnExpand.text = "Expand Shop\nNext Level: " + str(GameplayVariables.get_restaurant_level() + 1) + "\nPrice: " + str(shopExpansionPrices.get(GameplayVariables.get_restaurant_level()))
    _check_expand_price()

    _spawn_buttons()
    pass

func _spawn_buttons():
    var newPaths: Array = []
    for assetID in AssetManager.get_asset_ids_of_type("BuildableData"):
        newPaths.append(AssetManager.get_asset_path(assetID))

    var sortedArray: Array = newPaths.duplicate()
    sortedArray.sort()

    while _hboxBuildable.get_child_count() > 0:
        var child = _hboxBuildable.get_child(0)
        _hboxBuildable.remove_child(child)
        child.queue_free()

    for path in sortedArray:
        var buildableButton: UI_BuildableButton = _btnBuildable.instantiate() as UI_BuildableButton
        buildableButton.setup(path, _init_buildable_build)
        onCategoryChange.connect(buildableButton.on_category_change)
        _hboxBuildable.add_child(buildableButton)

func _init_buildable_build(buildable: Resource):
    if is_instance_valid(_buildableOpControl):
        _buildableOpControl.queue_free()
    _buildableOpControl = _buildableBuild.instantiate()
    _buildableOpControl.setup_buildable(buildable, self)
    _assetsTileMap.add_child(_buildableOpControl)
    pass

func _on_move_button_pressed():
    if is_instance_valid(_buildableOpControl):
        _buildableOpControl.queue_free()
    _buildableOpControl = _buildableMove.instantiate()
    _buildableOpControl.setup_buildable(self)
    _assetsTileMap.add_child(_buildableOpControl)
    pass

func _on_delete_button_pressed():
    if is_instance_valid(_buildableOpControl):
        _buildableOpControl.queue_free()
    _buildableOpControl = _buildableDelete.instantiate()
    _buildableOpControl.setup_buildable(self)
    _assetsTileMap.add_child(_buildableOpControl)
    pass

func _on_upgrade_button_pressed():
    if is_instance_valid(_buildableOpControl):
        _buildableOpControl.queue_free()
    _buildableOpControl = _buildableUpgrade.instantiate()
    _assetsTileMap.add_child(_buildableOpControl)
    pass

func _on_back_button_pressed():
    if await _check_layout_viability():
        GameplayVariables.save_layout_load_scene("res://Scenes/Levels/Submission_1_Scene.tscn")
        queue_free()
        pass

func _on_expand_button_pressed():
    var level = GameplayVariables.get_restaurant_level()
    var price = shopExpansionPrices.get(level)
    if level <= shopExpansionCoords.size() and EconomySystem.get_currency() >= price:
        _expand_layout(shopExpansionCoords.get(level))
        GameplayVariables.add_money( - price)
        GameplayVariables.add_restaurant_level()
        level += 1

        if GameplayVariables.get_restaurant_level() == 4:
            _btnExpand.text = "Expand Shop\nAlready Max Level!"
        else:
            _btnExpand.text = "Expand Shop\nNext Level: " + str(level + 1) + "\nPrice: " + str(shopExpansionPrices.get(level))

        _check_expand_price()
        _update_terrain_dicts()
    pass

func _on_mouse_entered():
    _mousePositionValid = false

func _on_mouse_exited():
    _mousePositionValid = true

func _on_toggle_all(pressed: bool):
    if pressed:
        _btnCategoryChair.button_pressed = false
        _btnCategoryTable.button_pressed = false


    var val: BuildableData.Category = BuildableData.Category.All if pressed else 0
    categoryBitMask = Utils.toggle_flag(0, val)
    onCategoryChange.emit(categoryBitMask)
    pass

func _on_toggle_work_station(pressed: bool):
    if pressed:
        _btnCategoryAll.button_pressed = false




    onCategoryChange.emit(categoryBitMask)
    pass

func _on_toggle_table(pressed: bool):
    if pressed:
        _btnCategoryAll.button_pressed = false
        categoryBitMask = Utils.set_flag(categoryBitMask, BuildableData.Category.Table)
    else:
        categoryBitMask = Utils.unset_flag(categoryBitMask, BuildableData.Category.Table)

    onCategoryChange.emit(categoryBitMask)
    pass

func _on_toggle_chair(pressed: bool):
    if pressed:
        _btnCategoryAll.button_pressed = false
        categoryBitMask = Utils.set_flag(categoryBitMask, BuildableData.Category.Chair)
    else:
        categoryBitMask = Utils.unset_flag(categoryBitMask, BuildableData.Category.Chair)

    onCategoryChange.emit(categoryBitMask)
    pass

func _check_layout_viability() -> bool:
    await get_tree().create_timer(0.1, false).timeout
    var resList: Array[String] = []
    var valid: bool = true

    var assetTypes = AssetManager.load_assets_of_type("BuildableData")
    for asset in assetTypes:
        if not asset.get_ref().check_restrictions():
            valid = false
            resList.append_array(asset.get_ref().get_restrictions_list())

    _restrictionsList.clear_list()
    for r in resList:
        _restrictionsList.add_restriction(r)
    return valid

func _expand_layout(rootCells: Array):
    _floorTileMap.clear_layer(1)
    for cell in rootCells:
        _terrainTileMap.erase_cell(1, cell)
        _terrainTileMap.erase_cell(2, cell)
        _terrainTileMap.set_cell(0, cell, 4, Vector2i.ZERO)

        var topLeft = _terrainTileMap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE)
        var topRight = _terrainTileMap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE)
        var topCorner = _beamsTileMap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_CORNER)

        if _terrainTileMap.get_cell_tile_data(0, topLeft) == null:
            _terrainTileMap.set_cell(1, topLeft, 5, Vector2i.ZERO)

        if _terrainTileMap.get_cell_tile_data(0, topRight) == null:
            _terrainTileMap.set_cell(2, topRight, 7, Vector2i.ZERO)

        _beamsTileMap.set_cell(0, topLeft, 0, Vector2i.ZERO)
        _beamsTileMap.set_cell(0, topRight, 1, Vector2i.ZERO)
        _beamsTileMap.set_cell(0, topCorner, 2, Vector2i.ZERO)

    _navMeshGenerator.bake_nav_mesh()
    pass

func _check_expand_price():
    var level = GameplayVariables.get_restaurant_level()
    if level < 4 and EconomySystem.get_currency() >= shopExpansionPrices.get(level):
        _btnExpand.disabled = false
    else:
        _btnExpand.disabled = true

func _update_terrain_dicts():
    GameplayVariables.shopTerrain.clear()
    if GameplayVariables.shopTerrain.is_empty():
        for layer in _terrainTileMap.get_layers_count():
            var terrainDict: Dictionary = {}
            GameplayVariables.shopTerrain.append(terrainDict)

    for layer in _terrainTileMap.get_layers_count():
        for cell in _terrainTileMap.get_used_cells(layer):
            GameplayVariables.shopTerrain[layer][cell] = _terrainTileMap.get_cell_source_id(layer, cell)

    GameplayVariables.shopFloor.clear()
    if GameplayVariables.shopFloor.is_empty():
        for layer in _floorTileMap.get_layers_count():
            var floorDict: Dictionary = {}
            GameplayVariables.shopFloor.append(floorDict)

    for layer in _floorTileMap.get_layers_count():
        for cell in _floorTileMap.get_used_cells(layer):
            GameplayVariables.shopFloor[layer][cell] = _floorTileMap.get_cell_source_id(layer, cell)

    GameplayVariables.shopBeams.clear()
    if GameplayVariables.shopBeams.is_empty():
        for layer in _beamsTileMap.get_layers_count():
            var beamsDict: Dictionary = {}
            GameplayVariables.shopBeams.append(beamsDict)

    for layer in _beamsTileMap.get_layers_count():
        for cell in _beamsTileMap.get_used_cells(layer):
            GameplayVariables.shopBeams[layer][cell] = _beamsTileMap.get_cell_source_id(layer, cell)
    pass
