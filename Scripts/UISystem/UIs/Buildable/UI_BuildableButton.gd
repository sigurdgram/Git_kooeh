extends VBoxContainer
class_name UI_BuildableButton

@export var _path: String
@export var _textureRect: TextureRect
@export var _btnFurniture: Button
@export var _furniturePrice: Label

var _buildable: BuildableData
var _onClick: Callable



func _ready():
    _buildable = load(_path)
    await get_tree().process_frame
    _textureRect.texture = _buildable.texture
    _btnFurniture.text = _buildable.name
    _btnFurniture.button_down.connect(_on_building_button_pressed)
    _furniturePrice.text = str(_buildable.price)

func on_category_change(categoryBitMask: BuildableData.Category):
    visible = Utils.is_flag_enabled(categoryBitMask, _buildable.category)
    pass

func setup(newPath: String, onClick: Callable):
    _onClick = onClick
    _path = newPath
    pass

func _on_building_button_pressed():
    _onClick.call(_buildable)
    pass
