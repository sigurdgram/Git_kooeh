extends BuildableProcess
class_name BuildableDelete

var _cacheMask: int
var _selectedItem: Node2D:
    set(v):
        if v == _selectedItem:
            return

        if is_instance_valid(_selectedItem):
            _selectedItem.modulate = Color.WHITE

        _selectedItem = v

        if is_instance_valid(_selectedItem):
            _selectedItem.modulate = Color(Color.GRAY, 0.5)
        pass

func enter() -> void :
    print("enter Delete")
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    var terrainLayer = _buildableSystem.get_grid_data().collisionLayer
    _cacheMask = cursorInstance.collision_mask
    cursorInstance.collision_mask = 4294967295 & ~ terrainLayer
    pass

func exit() -> void :
    print("exit Delete")
    _selectedItem = null
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    cursorInstance.collision_mask = _cacheMask
    pass

func input(event: InputEvent) -> void :
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            _select_item_to_delete()
    elif event is InputEventKey:
        if event.keycode == KEY_X and event.is_pressed() and is_instance_valid(_selectedItem):
            delete(_selectedItem)
    pass

func _select_item_to_delete() -> void :
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    cursorInstance.force_shapecast_update()

    var arr = cursorInstance.collision_result
    if not arr.is_empty():
        arr.sort_custom(func(i, j):
            return i["collider"].priority > j["collider"].priority)
        _selectedItem = arr[0].collider
    pass

static func delete(node: Node2D) -> void :
    if not is_instance_valid(node):
        return

    node.free()
    pass
