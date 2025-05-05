extends UI_Widget
class_name UI_Phase3_Cookbook

@export var _cookBookEntry: PackedScene
@export var _requiredAmountFrame: PackedScene
@export var _cookBookEntriesVBox: VBoxContainer
@export var _cookBtn: UI_BasicButton
@export var _animPlayer: AnimationPlayer
@export var _cookbookAudio: AudioStream

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

var _phase3CookSystem: Phase3CookSystem
var _selectedFood: WeakRef
var _blockInput: bool
var _currentFocus: Control


var disregardIngredients: bool = false


func _ready():
    _blockInput = true
    _cookBtn.pressed.connect(_on_cook)
    _rightPage.hide()
    _populate_cookbook_entries()
    _animPlayer.play("Anim_In")
    InputManager.set_game_input_enabled(false)
    _cookBtn.focus_entered.connect(_on_focus_entered_element.bind(_cookBtn))
    AudioSystem.play_music(_cookbookAudio, AudioSystem.AudioPlayMode.SOLO)
    pass

func _unhandled_input(_event):
    accept_event()
    pass

func _input(_event):
    if _blockInput:
        accept_event()
    elif _event.is_action_pressed("ui_cancel") and not is_instance_valid(GameInstance.gameWorld.tutorial.get_ref()):
        on_back()
        accept_event()
    pass

func unblock_input():
    _blockInput = false
    pass

func _populate_cookbook_entries():
    var allFoods = AssetManager.load_asset_of_ids(GameplayVariables.get_unlocked_recipes())
    for food in allFoods:
        var foodId: String = food.get_ref().resource_name
        if not FoodLibrary.is_food_unlocked(foodId):
            continue
        var entry: = _cookBookEntry.instantiate() as UI_Phase3_Cookbook_Entry
        entry.setup(food, _on_click_food)
        entry.focus_mode = Control.FOCUS_ALL
        entry.focus_entered.connect(_on_focus_entered_element.bind(entry))
        _cookBookEntriesVBox.add_child(entry)
        if not is_instance_valid(_currentFocus) and FoodLibrary.is_food_unlocked(foodId) and not entry.disabled:
            _currentFocus = entry

    if is_instance_valid(_currentFocus):
        _currentFocus.grab_focus()
    pass

func get_cookbook_entries() -> Array[Node]:
    return _cookBookEntriesVBox.get_children()

func get_right_page() -> Control:
    return _rightPage

func get_cook_button() -> UI_BasicButton:
    return _cookBtn

func get_anim_player() -> AnimationPlayer:
    return _animPlayer

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
    _selectedFoodPrice.text = "%s" % foodData.price
    _populate_required_ingredients()

    pass

func _is_enough_ingredients(foodData: FoodData) -> bool:
    var canCook: int = 1
    var neededIngredients = foodData.ingredients
    for i in neededIngredients:
        var neededAmount: int = neededIngredients[i]
        var availableAmount: int = InventorySystem.get_ingredient_count(i)
        canCook &= int(availableAmount >= neededAmount)
    return canCook

func _populate_required_ingredients():
    for i in _requiredIngredientsHFlow.get_children():
        i.queue_free()

    var selectedFood: FoodData = _selectedFood.get_ref()

    var canCook: int = 1
    var neededIngredients: Dictionary = selectedFood.ingredients
    for ingredient in neededIngredients:
        var ingredientData: IngredientData = AssetManager.load_asset(ingredient).get_ref()
        var neededAmount: int = neededIngredients[ingredient]
        var currentAmount: int = InventorySystem.get_ingredient_count(ingredient)
        canCook &= int(currentAmount >= neededAmount)
        var frame: = _requiredAmountFrame.instantiate() as UI_RequiredAmount_Frame
        frame.setup(ingredientData.texture, currentAmount, neededAmount)
        frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        _requiredIngredientsHFlow.add_child(frame)

        if disregardIngredients:
            continue

        _cookBtn.disabled = !canCook
    pass

func _on_cook():
    var viewport: Viewport = get_viewport()
    _currentFocus = viewport.gui_get_focus_owner()
    var p3CookSystem: Phase3CookSystem = GameInstance.gameWorld.phase3CookSystem
    p3CookSystem.setup(_selectedFood)
    viewport.gui_release_focus()
    p3CookSystem.start_cook()
    pass

func on_back():
    _blockInput = true
    _animPlayer.animation_finished.connect(func pop(_animationName):
        UITree.PopWidgetFromLayer(self, _parentLayer.name)
        , CONNECT_ONE_SHOT)

    _animPlayer.play_backwards("Anim_In")
    pass

func select_food(foodWeakRef: WeakRef):
    _selectedFood = foodWeakRef
    pass

func _on_focus_entered_element(control: Control):
    _currentFocus = control
    pass
