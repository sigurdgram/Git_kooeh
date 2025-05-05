extends Button
class_name UI_Buy_Frame

@export var _rarityPanelCont: PanelContainer
@export var _itemNameTxt: Label
@export var _itemTextRect: TextureRect
@export var _costTxt: Label
@export var _amountTxt: Label

var _itemDataWeakRef: WeakRef



func setup(itemData: WeakRef, onClick: Callable):
    _itemDataWeakRef = itemData

    var item: IngredientData = _itemDataWeakRef.get_ref()
    _itemNameTxt.text = item.name
    _itemTextRect.texture = item.texture
    _costTxt.text = str(item.bundlePrice)
    _amountTxt.text = "x%s" % str(item.bundlePurchaseAmount)

    var color: Color = Utils.get_rarity_color(item.rarity)
    var styleBox: StyleBoxFlat = _rarityPanelCont.get_theme_stylebox("panel") as StyleBoxFlat
    styleBox.border_color = color

    pressed.connect(onClick)
    pass
