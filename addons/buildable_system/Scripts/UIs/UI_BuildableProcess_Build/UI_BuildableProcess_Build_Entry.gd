extends Button
class_name UI_BuildableProcess_Build_Entry

@export var _itemNameTxt: Label
@export var _itemTextRect: TextureRect
@export var _costTxt: Label

var _itemDataWeakRef: WeakRef



func setup(itemData: WeakRef, onClick: Callable):
    _itemDataWeakRef = itemData

    var item: BuildableData = _itemDataWeakRef.get_ref()
    _itemNameTxt.text = item.displayName
    _itemTextRect.texture = item.texture
    _costTxt.text = str(item.price)

    pressed.connect(onClick)
    pass
