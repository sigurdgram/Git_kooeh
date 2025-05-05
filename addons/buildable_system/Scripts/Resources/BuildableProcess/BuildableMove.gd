extends BuildableProcess
class_name BuildableMove

var _selectedItem: Buildable:
    set = _set_selected_item

var _selectedPreview: Buildable
var _validVariants: Dictionary
var _currentVariant: BuildableVariant
var _selectedData: BuildableData:
    set(v):
        if _selectedData == v:
            return

        _selectedData = v

        if is_instance_valid(v):
            _validVariants = v.get_valid_variants()
        else:
            _validVariants.clear()
        pass
var _currentDirection: BuildableTypes.EDirection:
    set(v):
        _currentDirection = v
        _currentVariant = _validVariants[_currentDirection]
        pass
var _targetPosRequirements: Array[BuildableRequirement]

func enter() -> void :
    print("enter Move")
    _buildableSystem.get_cursor().onTargetPosChanged.connect(_on_target_position_changed)

    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    var terrainLayer = _buildableSystem.get_grid_data().collisionLayer
    cursorInstance.collision_mask = 4294967295 & ~ (terrainLayer | 1)
    pass

func input(event: InputEvent) -> void :
    if event.is_action_pressed("lmb"):
        if not is_instance_valid(_selectedItem):
            _select_item_to_move()
        else:
            _move_item()
        _buildableSystem.get_viewport().set_input_as_handled()
    elif event.is_action_pressed("rmb"):
        _selectedItem = null
        _buildableSystem.get_viewport().set_input_as_handled()
    elif event.is_action_pressed("buildable_rotate"):
        var keys: Array = _validVariants.keys()
        var currentIndex: int = keys.find(_currentDirection)
        var d: int = (currentIndex + 1) % _validVariants.size()

        if d == currentIndex:
            return

        _currentDirection = keys[d]
        _refresh_selected_preview()
        _buildableSystem.get_viewport().set_input_as_handled()
    pass

func exit() -> void :
    print("exit Move")
    _selectedData = null
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    cursorInstance.onTargetPosChanged.disconnect(_on_target_position_changed)
    cursorInstance.clear_exceptions()

    if is_instance_valid(_selectedPreview):
        _selectedPreview.queue_free()
    pass

func _select_item_to_move() -> void :
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    cursorInstance.force_shapecast_update()
    var arr: Array = cursorInstance.collision_result
    arr.sort_custom(func(i, j):
        return i["collider"].priority > j["collider"].priority)

    if not arr.is_empty():
        _selectedItem = arr[0].collider
    pass

func _move_item() -> void :
    if not _validate_requirements():
        return

    BuildableDelete.delete(_selectedItem)
    BuildableBuild.build_tile(_buildableSystem, _selectedData, _currentDirection)
    _selectedItem = null
    pass

func _validate_requirements() -> bool:
    var ret: Array[String]
    for r in _currentVariant.buildReqs:
        var log: String = r.is_pass(_buildableSystem, _selectedData)
        if not log.is_empty():
            ret.push_back(log)
    return true if ret.is_empty() else false

func _set_selected_item(v: Buildable) -> void :
    if not is_instance_valid(_buildableSystem):
        return

    _selectedItem = v
    _setup_selected_preview()
    pass

func _setup_selected_preview() -> void :
    if is_instance_valid(_selectedPreview):
        _selectedPreview.free()

    if not is_instance_valid(_selectedItem):
        _selectedData = null
        _targetPosRequirements.clear()
        return

    _selectedData = _selectedItem.get_buildable_data().get_ref()
    var meta: Dictionary = _selectedItem.get_meta(BuildableTypes.Meta_Info)
    _currentDirection = meta[BuildableTypes.Meta_Direction]

    _refresh_selected_preview()

    for i in _selectedPreview.get_children():
        if i is ShapeCast2D:
            i.add_exception(_selectedItem)
    pass

func _refresh_selected_preview() -> void :
    _targetPosRequirements = _currentVariant.buildReqs.filter(
        func(req: BuildableRequirement):
            return req.get_check_time() == BuildableTypes.ECheckTime.OnTargetPosChanged)

    _selectedPreview = _currentVariant.buildable.instantiate() as Buildable
    _selectedPreview.setup(_buildableSystem, _selectedData, {BuildableTypes.Meta_Direction: _currentDirection}, true)
    _buildableSystem.selectedPreview = _selectedPreview
    _selectedPreview.global_position = _buildableSystem.get_cursor().global_position

    var attachmentReqs: Array = _targetPosRequirements.filter(
        func(req: BuildableRequirement):
            return is_instance_of(req, BuildReq_AttachOnSlot))
    if not attachmentReqs.is_empty() and is_instance_valid(attachmentReqs[0].get_attachment_point()):
        _selectedPreview.global_position = attachmentReqs[0].get_attachment_point()

    for i in _targetPosRequirements:
        i.init(_buildableSystem, _selectedData)
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
        _selectedPreview.global_position = attachmentReqs[0].get_attachment_point()

    var rgb: Color = Color.WHITE if passed else Color.RED
    _selectedPreview.modulate = Color(rgb, 0.5)
    pass

func _validate_target_pos_changed_requirements() -> bool:
    if _selectedData == null:
        return false

    var errors: Array[String]
    _targetPosRequirements.reduce(
        func(failAccum: Array[String], req: BuildableRequirement):
            var log: String = req.is_pass(_buildableSystem, _selectedData)

            if not log.is_empty():
                failAccum.push_back(log)

            return failAccum, errors)

    return errors.is_empty()
