extends UI_Widget
class_name UI_Phase1_Temple_Purchase

@export var _itemGrid: Container
@export var _labelPrice: Label
@export var _btnBuy: UI_BasicButton
@export var _btnBack: Button
@export var _slot: PackedScene
@export var _audioLeft: AudioStream
@export var _audioRight: AudioStream

@export_group("Details Panel")
@export var _detailsFoodName: Label
@export var _detailsFoodTextRect: TextureRect
@export var _detailsFoodDesc: Label
@export var _relatedRecipesTree: Tree

@export_group("Purchase Details")
@export var _purchaseAmountTxt: Label
@export var _amountSelectorLeft: Button
@export var _amountSelectorRight: Button

var _availableMoney: float
var _purchaseAmount: int:
    set(value):
        _purchaseAmount = clamp(value, 1, 9999)
        _purchaseAmountTxt.text = str(_purchaseAmount)

var _selectedIngredient: WeakRef


func _ready():
    _btnBack.pressed.connect(_on_back)
    _btnBuy.pressed.connect(_on_buy)
    _update_available_money(EconomySystem.get_currency(), 0)
    GameplayVariables.onEconomyUpdate.connect(_update_available_money)
    _purchaseAmount = 1
    _amountSelectorLeft.pressed.connect(_on_amount_selector_left)
    _amountSelectorRight.pressed.connect(_on_amount_selector_right)

    var root: TreeItem = _relatedRecipesTree.create_item()
    root.set_text(0, "Used in:")

    _populate_item_grid()
    pass

func _populate_item_grid() -> void :
    for child in _itemGrid.get_children():
        child.queue_free()

    var firstIngredient: WeakRef = null
    for ingredient in IngredientLibrary.get_all_ingredients():
        if firstIngredient == null:
            firstIngredient = ingredient
        var slotNode = _slot.instantiate() as UI_Buy_Frame
        slotNode.setup(ingredient, _on_slot_clicked.bind(ingredient))
        _itemGrid.add_child(slotNode)

    _on_slot_clicked(firstIngredient)
    pass

func _update_details_panel(ingredientWeakRef: WeakRef):
    var ingredientData: IngredientData = ingredientWeakRef.get_ref()
    var ingredientID: String = ingredientData.resource_name
    _detailsFoodName.text = ingredientData.name
    _detailsFoodTextRect.texture = ingredientData.texture
    _detailsFoodDesc.text = ingredientData.description

    var root: TreeItem = _relatedRecipesTree.get_root()
    for i in root.get_children():
        i.free()

    for food in AssetManager.load_assets_of_type(FoodLibrary.AssetType):
        var foodData: FoodData = food.get_ref()
        if not foodData.ingredients.has(ingredientID):
            continue
        var entry: TreeItem = _relatedRecipesTree.create_item(root)
        entry.set_text(0, foodData.name)
    pass

func _on_slot_clicked(ingredientData: WeakRef):
    _selectedIngredient = ingredientData
    _update_details_panel(_selectedIngredient)
    _update_price()
    pass

func _on_back():
    UITree.PopWidgetFromLayer(self, UITree.layerGameUI)
    pass

func _on_buy():
    var ingredient: IngredientData = _selectedIngredient.get_ref()
    var ingredientAmount = InventorySystem.get_ingredient_count(ingredient.resource_name)
    var bundleAmount: int = ingredient.bundlePurchaseAmount * _purchaseAmount
    InventorySystem.set_ingredient_count(ingredient.resource_name, ingredientAmount + bundleAmount)
    GameplayVariables.add_money( - ingredient.bundlePrice * _purchaseAmount)
    pass

func _update_price():
    if is_instance_valid(_selectedIngredient) and _selectedIngredient.get_ref():
        var data: IngredientData = _selectedIngredient.get_ref()
        var totalPrice: float = data.bundlePrice * _purchaseAmount
        _labelPrice.text = str(totalPrice)
        _btnBuy.disabled = _availableMoney < totalPrice
    else:
        _btnBuy.disabled = true
        _labelPrice.text = ""
    pass

func _on_amount_selector_left():
    AudioSystem.play_sfx(_audioLeft)
    _purchaseAmount -= 1
    _update_price()
    pass

func _on_amount_selector_right():
    AudioSystem.play_sfx(_audioRight)
    _purchaseAmount += 1
    _update_price()
    pass

func _update_available_money(money: float, _delta: float):
    _availableMoney = money
    _update_price()
    pass
