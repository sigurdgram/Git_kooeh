extends UI_Widget
class_name UI_Phase2_Cookbook

@export var _cookBookEntry: PackedScene
@export var _requiredAmountFrame: PackedScene
@export var _cookBookEntriesVBox: VBoxContainer
@export var _cookBtn: UI_BasicButton

@export_group("RightPage")
@export var _rightPage: Control
@export var _selectedFoodText: Label
@export var _selectedFoodDescription: Label
@export var _selectedFoodTextureRect: TextureRect
@export var _selectedFoodDifficulty: RichTextLabel
@export var _selectedFoodCookingTime: Label
@export var _selectedFoodCookAmount: Label
@export var _selectedFoodPrice: Label
@export var _requiredIngredientsHFlow: HFlowContainer

var _selectedFood: WeakRef
var cookingStation: Buildable_CookingStation1



func get_cookbook_entries() -> Array[Node]:
    return _cookBookEntriesVBox.get_children()

func get_right_page() -> Control:
    return _rightPage

func get_cook_button() -> UI_BasicButton:
    return _cookBtn

func _enter_tree():
    InputManager.set_game_input_enabled(false)
    pass

func _exit_tree():
    if DialogueSystem.get_dialogue_is_playing():
        return
    InputManager.set_game_input_enabled(true)
    pass

func _ready():
    _cookBtn.pressed.connect(_on_cook)
    _rightPage.hide()
    _populate_cookbook_entries()
    pass

func _process(_delta):
    if DialogueSystem.get_dialogue_is_playing():
        _on_back()

func _populate_cookbook_entries():
    var allFoods = AssetManager.load_assets_of_type(FoodLibrary.AssetType)
    var currentFocus: Control = null
    for food in allFoods:
        var entry: = _cookBookEntry.instantiate() as UI_Phase2_Cookbook_Entry
        entry.setup(food, _on_click_food)
        _cookBookEntriesVBox.add_child(entry)

        if not is_instance_valid(currentFocus) and not entry.disabled:
            currentFocus = entry

    if currentFocus != null:
        currentFocus.grab_focus()
    pass

func _on_click_food(foodWeakRef: WeakRef):
    _selectedFood = foodWeakRef
    _rightPage.show()
    _update_right_page(foodWeakRef)
    pass

func _update_right_page(foodWeakRef: WeakRef):
    var foodData: FoodData = foodWeakRef.get_ref()

    _selectedFoodText.text = foodData.name
    _selectedFoodDescription.text = foodData.description
    _selectedFoodTextureRect.texture = foodData.sprite

    var difficultyText: String = ""
    var pattern: String = "[color=%s]%s[/color]"
    match foodData.difficulty:
        KooehConstant.Difficulty.Easy: difficultyText = pattern % [Color.DARK_GREEN.to_html(), "Easy"]
        KooehConstant.Difficulty.Normal: difficultyText = pattern % [Color.ORANGE_RED.to_html(), "Normal"]
        KooehConstant.Difficulty.Hard: difficultyText = pattern % [Color.FIREBRICK.to_html(), "Hard"]

    _selectedFoodDifficulty.text = difficultyText
    _selectedFoodCookingTime.text = "%ss" % foodData.cookTime
    _selectedFoodCookAmount.text = str(foodData.batchCookAmount)
    _selectedFoodPrice.text = "RM %s" % foodData.price
    _populate_required_ingredients()
    pass

func _populate_required_ingredients():
    for i in _requiredIngredientsHFlow.get_children():
        i.queue_free()

    var canCook: int = 1
    var neededIngredients: Dictionary = _selectedFood.get_ref().ingredients
    for ingredient in neededIngredients:
        var neededAmount: int = neededIngredients[ingredient]
        var currentAmount: int = InventorySystem.get_ingredient_count(ingredient)

        canCook &= int(currentAmount >= neededAmount)

        var frame: = _requiredAmountFrame.instantiate() as UI_RequiredAmount_Frame
        var texture: Texture2D = AssetManager.load_asset(ingredient).get_ref().texture
        frame.setup(texture, currentAmount, neededAmount)
        _requiredIngredientsHFlow.add_child(frame)
    _cookBtn.disabled = canCook == 0
    pass

func _on_cook():
    cookingStation.cook(_selectedFood)
    _on_back()
    pass

func _on_back():
    UITree.PopWidgetFromLayer(self, _parentLayer.name)
    pass

func _unhandled_input(_event):
    accept_event()
    pass

func _input(event):
    if event.is_action_pressed("ui_cancel") and not is_instance_valid(GameInstance.gameWorld.tutorial.get_ref()):
        _on_back()
        accept_event()
    pass
