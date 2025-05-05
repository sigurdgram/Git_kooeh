@tool
extends Control
class_name UI_Settings_Element_DropdownOption

signal item_selected(value: int)

@export var _label: Label
@export var _optionBTN: OptionButton
@export var _text: String:
    set(v):
        _text = v
        if is_instance_valid(_label):
            _label.text = _text
        pass

var disabled: bool:
    set(v):
        _optionBTN.disabled = v
        pass
    get:
        return _optionBTN.disabled

var selected: int:
    set(v):
        _optionBTN.selected = v
        pass
    get:
        return _optionBTN.selected


func _ready():
    _optionBTN.item_selected.connect(_on_item_selected)
    _optionBTN.get_popup().transparent_bg = true;
    pass

func add_item(label: String, id: int = -1):
    _optionBTN.add_item(label, id)
    pass

func _on_item_selected(value: int):
    item_selected.emit(value)
    pass

func select(value: int, force: bool = false):
    _optionBTN.select(value)

    if force:
        item_selected.emit(value)
    pass

func get_item_id(index: int) -> int:
    return _optionBTN.get_item_id(index)

func get_item_index(id: int) -> int:
    return _optionBTN.get_item_index(id)
