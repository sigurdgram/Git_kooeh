extends Control
class_name UI_Item_Frame

@export var _rarityPanelCont: PanelContainer
@export var _nameTxt: Label
@export var _textRect: TextureRect
@export var _amountTxt: Label

var _itemWeakRef: WeakRef


func setup(itemID: String, quantity: int):
    _itemWeakRef = AssetManager.load_asset(itemID)

    var itemData: IngredientData = _itemWeakRef.get_ref()
    _nameTxt.text = itemData.name
    _textRect.texture = itemData.texture
    _amountTxt.text = "x%s" % str(quantity)

    var texture: Texture = Utils.get_rarity_texture(itemData.rarity)
    var styleBoxTexture: StyleBoxTexture = StyleBoxTexture.new()
    styleBoxTexture.texture = texture
    _rarityPanelCont.add_theme_stylebox_override("panel", styleBoxTexture)
    pass
