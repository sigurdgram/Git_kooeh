extends Control
class_name UI_RequiredAmount_Frame

@export var _itemTextureRect: TextureRect
@export var _amountTxt: Label


func setup(texture: Texture2D, currentAmount: int, requiredAmount: int):
    _itemTextureRect.texture = texture

    if currentAmount - requiredAmount < 0:
        _amountTxt.add_theme_color_override("font_color", Color.DARK_RED)

    _amountTxt.text = "%s / %s" % [currentAmount, requiredAmount]
    pass

func setup_required_only(texture: Texture2D, requiredAmount: int):
    _itemTextureRect.texture = texture
    _amountTxt.text = "x %s" % requiredAmount
    pass
