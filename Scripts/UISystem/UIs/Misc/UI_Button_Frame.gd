extends Button
class_name UI_Button_Frame

@export var _nameTxt: Label
@export var _textRect: TextureRect
@export var _selectedTxt: Label

var _itemWeakRef: WeakRef
var _onClick: Callable
var _hoverRotating: bool = false
var _isPressed: bool = false
var _isSelected: bool = false


func _ready():
    pressed.connect(_on_pressed)
    pass

func setup(ingredientID: String, onClick: Callable):
    _itemWeakRef = AssetManager.load_asset(ingredientID) if !ingredientID.is_empty() else weakref(null)
    _onClick = onClick

    var itemData: IngredientData = _itemWeakRef.get_ref()
    if not is_instance_valid(itemData):
        hide()
        return

    var texture: Texture = Utils.get_rarity_texture(itemData.rarity)

    set_button_texture(texture)
    _nameTxt.text = itemData.name
    _textRect.texture = itemData.texture

    show()
    pass

func _process(_delta):
    if (_hoverRotating and is_hovered()):
        rotation = 0.05
    else:
        rotation = 0

    if (_isPressed and button_pressed):
        modulate = Color(0.5, 0.5, 0.5)

    else:
        modulate = Color(1, 1, 1)

    if (_isSelected):
        scale = Vector2(0.9, 0.9)
        modulate = (Color(0.7, 0.7, 0.7))
    else:
        scale = Vector2(1, 1)



    pivot_offset = size / 2

func set_button_texture(texture: Texture):
    for state in ["normal", "hover", "pressed", "disabled", "focus"]:
        var stylebox: StyleBoxTexture = StyleBoxTexture.new()
        stylebox.texture = texture

        match state:
            "hover":
                _hoverRotating = true
            "pressed":
                _isPressed = true
            "disabled":
                stylebox.set_modulate(Color(0.1, 0.1, 0.1))
            "focus":
                stylebox.set_expand_margin_all(9.0)
                stylebox.set_modulate(Color(1.1, 1.1, 1.1))
            _:
                stylebox.set_modulate(Color(1, 1, 1))
                _hoverRotating = false
                _isPressed = false

        add_theme_stylebox_override(state, stylebox)
    pass

func _on_pressed():
    if not _itemWeakRef.get_ref():
        return

    _onClick.call(self, _itemWeakRef)
    pass

func select_ingredient():
    var baseStylebox: StyleBoxTexture = StyleBoxTexture.new()
    baseStylebox.texture = Utils.get_rarity_texture(_itemWeakRef.get_ref().rarity)

    for state in ["normal", "hover", "pressed", "disabled", "focus"]:
        var stylebox: StyleBoxTexture = baseStylebox.duplicate()
        stylebox.texture = Utils.get_rarity_texture(_itemWeakRef.get_ref().rarity)
        add_theme_stylebox_override(state, stylebox)

    _isSelected = true
    _selectedTxt.set_visible(true)
    var focusStylebox: StyleBoxTexture = baseStylebox.duplicate()
    focusStylebox.set_modulate(Color(1.5, 1.5, 1.5))
    focusStylebox.set_expand_margin_all(9.0)
    add_theme_stylebox_override("focus", focusStylebox)

    pass

func deselect_ingredient():
    set_button_texture(Utils.get_rarity_texture(_itemWeakRef.get_ref().rarity))
    scale = Vector2(1, 1)
    _isSelected = false
    _selectedTxt.set_visible(false)
    pass
