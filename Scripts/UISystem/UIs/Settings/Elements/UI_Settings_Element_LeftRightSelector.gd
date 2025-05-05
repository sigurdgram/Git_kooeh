@tool
extends OptionButton
class_name UI_Settings_Element_LeftRightSelector

@export var _leftBtn: Button
@export var _rightBtn: Button
@export var _label: Label
@export var _item: Label
@export var _wrapAround: bool = false
@export var _name: String:
    set(value):
        _name = value
        if is_instance_valid(_label):
            _label.text = value
        pass



func _set(property, value):
    if property == "selected":
        if item_count <= 0:
            _item.text = ""
            return

        update_item_text(value)
    elif property == "disabled":
        _leftBtn.disabled = value
        _rightBtn.disabled = value
    pass

func _ready():
    if selected == -1 && item_count > 0:
        update_item_text(0)

    _leftBtn.pressed.connect(_on_press_left)
    _rightBtn.pressed.connect(_on_press_right)
    pass

func update_item_text(value: int):
    selected = value % item_count if _wrapAround else clamp(value, 0, item_count - 1)
    select(selected)
    var output: String = get_item_text(selected)
    _item.text = output

    item_selected.emit(selected)
    pass

func force_set_text(string: String):
    _item.text = string
    pass

func _gui_input(event: InputEvent):
    if !get_viewport().gui_get_focus_owner() == self:
        return

    if event.is_action_pressed("ui_left"):
        _on_press_left()
        accept_event()
    elif event.is_action_pressed("ui_right"):
        _on_press_right()
        accept_event()
    pass

func _on_press_left():
    update_item_text(selected - 1)
    pass

func _on_press_right():
    update_item_text(selected + 1)
    pass

func _on_item_selected(index: int):
    selected = index % item_count if _wrapAround else clamp(index, 0, item_count - 1)
    var output: String = get_item_text(selected)
    _item.text = output
    pass
