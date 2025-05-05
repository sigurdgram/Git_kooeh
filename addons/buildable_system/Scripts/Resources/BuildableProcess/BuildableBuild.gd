extends BuildableProcess
class_name BuildableBuild

var _validVariants: Dictionary
var _currentVariant: BuildableVariant
var _currentDirection: BuildableTypes.EDirection:
    set(v):
        _currentDirection = v
        _currentVariant = _validVariants[_currentDirection]
        pass
var _data: BuildableData:
    set(v):
        if _data == v:
            return
        _data = v
        _validVariants = v.get_valid_variants()
        _currentDirection = v.defaultDirection
        pass
var _selectedPreview: Node2D
var _targetPosRequirements: Array[BuildableRequirement]

func get_process_name() -> String:
    return "Build"

func get_selected_preview() -> Node2D:
    return _selectedPreview

func enter() -> void :
    print("enter Build")

    if not _buildableSystem.onBuildableSelected.is_connected(_on_buildable_selected):
        _buildableSystem.onBuildableSelected.connect(_on_buildable_selected)

    if not _buildableSystem.get_cursor().onTargetPosChanged.is_connected(_on_target_position_changed):
        _buildableSystem.get_cursor().onTargetPosChanged.connect(_on_target_position_changed)
    pass

func input(event: InputEvent) -> void :
    if not is_instance_valid(_data):
        return

    if event.is_action_pressed("lmb"):
        build_tile(_buildableSystem, _data, _currentDirection)
        _buildableSystem.get_viewport().set_input_as_handled()
    elif event.is_action_pressed("buildable_rotate"):
        _scroll(1)
        _refresh_selected_preview()
    pass

func exit() -> void :
    print("exit Build")

    if _buildableSystem.onBuildableSelected.is_connected(_on_buildable_selected):
        _buildableSystem.onBuildableSelected.disconnect(_on_buildable_selected)

    if _buildableSystem.get_cursor().onTargetPosChanged.is_connected(_on_target_position_changed):
        _buildableSystem.get_cursor().onTargetPosChanged.disconnect(_on_target_position_changed)

    if is_instance_valid(_selectedPreview):
        _selectedPreview.queue_free()
    pass

static func build_tile(system: BuildableSystem, data: BuildableData, direction: BuildableTypes.EDirection) -> void :
    var tileMapLayer: TileMapLayer = system.get_tile_map_layer()
    var layer: Node2D = system.get_buildable_layer(data.layer2)
    var cursorInstance: BuildableCursor = system.get_cursor()
    cursorInstance.force_shapecast_update()

    var variant: BuildableVariant = data.directionalVariants[direction]
    var attachmentReqs: Array = variant.buildReqs.filter(
        func(req: BuildableRequirement):
            return is_instance_of(req, BuildReq_AttachOnSlot))

    if not _validate_requirements(system, variant.buildReqs, data):
        return

    var pos: Vector2
    var mapPos: Vector2i
    var attachPoint: Node2D
    var tile: Buildable = variant.buildable.instantiate()
    if not attachmentReqs.is_empty():
        attachPoint = attachmentReqs[0].get_attachment_point()
        pos = attachPoint.global_position
    else:
        pos = cursorInstance.global_position
    mapPos = tileMapLayer.local_to_map(tileMapLayer.to_local(pos))

    tile.name = "%s %s:%s" % [data.displayName, mapPos.x, mapPos.y]
    var info: Dictionary = {
        BuildableTypes.Meta_Direction: direction, 
        BuildableTypes.Meta_ID: data.id, 
        BuildableTypes.Meta_MapPos: var_to_str(mapPos).lstrip("Vector2i")
    }
    tile.setup(system, data, info)

    if is_instance_valid(attachPoint):
        attachPoint.add_child(tile)
    else:
        layer.add_child(tile)
        tile.position = system.get_grid().get_point_position(Vector2(mapPos.x, mapPos.y))
    pass

static func force_build_tile(system: BuildableSystem, data: BuildableData, 
    itemConfig: Dictionary, mapPos: Vector2i) -> Buildable:

    var tileMapLayer: TileMapLayer = system.get_tile_map_layer()
    var layer: Node2D = system.get_buildable_layer(data.layer2)
    var direction: BuildableTypes.EDirection = itemConfig[BuildableTypes.Meta_Direction]
    var variant: BuildableVariant = data.directionalVariants[direction]
    var attachmentReqs: Array = variant.buildReqs.filter(
        func(req: BuildableRequirement):
            return is_instance_of(req, BuildReq_AttachOnSlot))

    var attachPoint: Node2D
    var tile: Buildable = variant.buildable.instantiate()
    if not attachmentReqs.is_empty():
        attachPoint = attachmentReqs[0].get_attachment_point()

    tile.name = "%s %s:%s" % [data.displayName, mapPos.x, mapPos.y]
    tile.setup(system, data, itemConfig)

    if is_instance_valid(attachPoint):
        attachPoint.add_child(tile)
    else:
        layer.add_child(tile)
        var mapPosv2: = Vector2(mapPos.x, mapPos.y)
        if system.get_grid().is_in_boundsv(mapPosv2):
            tile.position = system.get_grid().get_point_position(mapPosv2)
    return tile

static func _validate_requirements(system: BuildableSystem, reqs: Array[BuildableRequirement], 
    data: BuildableData) -> bool:

    var ret: Array[String]
    for r in reqs:
        var log: String = r.is_pass(system, data)
        if not log.is_empty():
            ret.push_back(log)

    return true if ret.is_empty() else false

func _on_buildable_selected(data: BuildableData) -> void :
    _data = data

    if is_instance_valid(_selectedPreview):
        _selectedPreview.free()

    _refresh_selected_preview()
    pass

func _refresh_selected_preview() -> void :
    if not _currentVariant.buildReqs.is_empty():
        _targetPosRequirements = _currentVariant.buildReqs.filter(
            func(req: BuildableRequirement):
                return req.get_check_time() == BuildableTypes.ECheckTime.OnTargetPosChanged)
    else:
        _targetPosRequirements.clear()

    _selectedPreview = _currentVariant.buildable.instantiate() as Buildable
    _selectedPreview.setup(_buildableSystem, _data, {BuildableTypes.Meta_Direction: _currentDirection}, true)
    _buildableSystem.selectedPreview = _selectedPreview
    _selectedPreview.global_position = _buildableSystem.get_cursor().global_position

    var attachmentReqs: Array = _targetPosRequirements.filter(
        func(req: BuildableRequirement):
            return is_instance_of(req, BuildReq_AttachOnSlot))

    if not attachmentReqs.is_empty() and is_instance_valid(attachmentReqs[0].get_attachment_point()):
        _selectedPreview.global_position = attachmentReqs[0].get_attachment_point().global_position


    for i in _targetPosRequirements:
        i.init(_buildableSystem, _data)

    var passed: bool = _validate_target_pos_changed_requirements()
    var rgb: Color = Color.WHITE if passed else Color.RED
    _selectedPreview.modulate = Color(rgb, 0.5)
    pass

func _on_target_position_changed(position: Vector2) -> void :
    if not is_instance_valid(_selectedPreview):
        return

    var attachmentReqs: Array = _targetPosRequirements.filter(
        func(req: BuildableRequirement):
            return is_instance_of(req, BuildReq_AttachOnSlot))

    _selectedPreview.global_position = position

    var passed: bool = _validate_target_pos_changed_requirements()
    if not attachmentReqs.is_empty() and is_instance_valid(attachmentReqs[0].get_attachment_point()):
        _selectedPreview.global_position = attachmentReqs[0].get_attachment_point().global_position

    var rgb: Color = Color.WHITE if passed else Color.RED
    _selectedPreview.modulate = Color(rgb, 0.5)
    pass

func _validate_target_pos_changed_requirements() -> bool:
    var errors: Array[String]
    _targetPosRequirements.reduce(
        func(failAccum: Array[String], req: BuildableRequirement):
            var log: String = req.is_pass(_buildableSystem, _data)

            if not log.is_empty():
                failAccum.push_back(log)

            return failAccum, errors)

    return errors.is_empty()

func _scroll(modifier: int) -> void :
    var keys: Array = _validVariants.keys()
    var currentIndex: int = keys.find(_currentDirection)
    var d: int = (currentIndex + modifier) % (_validVariants.size())

    if d == currentIndex:
        return

    _currentDirection = keys[d]
    pass
