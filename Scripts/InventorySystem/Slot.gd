extends PanelContainer
class_name Slot

signal slotClicked(_itemData: IngredientData, button: int)

@export var _colorRect: ColorRect
@export var _textureRect: TextureRect
@export var _labelQuantity: Label
@export var _labelName: Label

var _itemData: IngredientData



func set_slot_data(itemData: Resource, quantity: int) -> void :
    _itemData = itemData
    _textureRect.texture = itemData.texture
    _labelName.text = itemData.name

    tooltip_text = "%s\n%s" % [itemData.name, itemData.description]

    if itemData.rarity == KooehConstant.Rarity.Common:
        _colorRect.color = Color(0.4, 0.4, 0.4, 1)
    elif itemData.rarity == KooehConstant.Rarity.Uncommon:
        _colorRect.color = Color(1, 1, 1, 1)
    elif itemData.rarity == KooehConstant.Rarity.Rare:
        _colorRect.color = Color(0.5, 1, 0, 1)

    if quantity > 1:
        _labelQuantity.text = "x%s" % quantity
        _labelQuantity.show()
    else:
        _labelQuantity.hide()

func _on_gui_input(event: InputEvent) -> void :
    if event.is_action_pressed("lmb"):
        slotClicked.emit(_itemData, event.button_index)

func get_item_data() -> IngredientData:
    return _itemData
