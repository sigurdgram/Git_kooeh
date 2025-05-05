extends UI_Widget
class_name UI_Journal

@export var animation: AnimationPlayer
@export var _journalEntry: PackedScene
@export var _requiredAmountFrame: PackedScene
@export var _closeBtn: Button
@export var _journalEntriesVBOX: VBoxContainer
@export var _starTexture1: TextureRect
@export var _starTexture2: TextureRect
@export var _starTexture3: TextureRect
@export var star_texture: Texture

@export_group("RightPage")
@export var _rightPage: Control
@export var _selectedFoodText: Label
@export var _selectedFoodDescription: Label
@export var _selectedFoodDate: Label
@export var _selectedFoodTextureRect: TextureRect
@export var _requiredIngredients: HFlowContainer
@export var _selectedFoodPrice: Label

var _currentFocus: UI_Journal_Entry
var _isInteractionDisabled: bool:
    set(value):
        _isInteractionDisabled = value


func _ready():
    _closeBtn.pressed.connect(_on_back)
    _closeBtn.mouse_filter = Control.MOUSE_FILTER_STOP

    animation.animation_finished.connect(
        func enable_interaction(_animName):
            _isInteractionDisabled = false, CONNECT_ONE_SHOT)
    animation.play("Journal_Popup")
    populate_journal()
    _isInteractionDisabled = true
    pass

func _input(event: InputEvent):
    if _isInteractionDisabled:
        accept_event()

    if event.is_action_pressed("ui_cancel"):
        _on_back()
        accept_event()
    pass

func populate_journal():
    var allFoods = AssetManager.load_assets_of_type(FoodLibrary.AssetType)

    for food in allFoods:
        var entry: = _journalEntry.instantiate() as UI_Journal_Entry
        entry.setup(food, _on_click_food.bind(food))
        _journalEntriesVBOX.add_child(entry)

        if _currentFocus == null:
            _currentFocus = entry

    _selectedFoodText.text = "Select a Food"
    _selectedFoodDescription.text = ""
    _selectedFoodTextureRect.texture = null

    if _currentFocus != null:
        _currentFocus.focus()
    pass

func _on_click_food(foodWeakRef: WeakRef):
    _rightPage.show()
    _update_right_page(foodWeakRef)
    _populate_ratings(foodWeakRef)
    _populate_ingredients(foodWeakRef)
    pass

func _on_back():
    _isInteractionDisabled = true
    GameInstance.settingsManager.save_config()
    animation.animation_finished.connect(
        func destroy(_animName):
            release_focus()
            UITree.PopWidgetFromLayer(self, get_owning_layer_name())
            , CONNECT_ONE_SHOT)
    animation.play_backwards("Journal_Popup")
    pass

func _on_animation_finished(anim_name):
    if anim_name == "Journal_Popup":
        emit_signal("closed")
        queue_free()
    pass

func _update_right_page(foodWeakRef: WeakRef):
    var foodData: FoodData = foodWeakRef.get_ref()
    var dateText = str(GameplayVariables.get_learned_date(foodData.resource_name))
    _selectedFoodText.text = foodData.name
    _selectedFoodDescription.text = "%s" % foodData.description
    _selectedFoodTextureRect.texture = foodData.sprite
    _selectedFoodDate.text = "Learned On: %s" % dateText
    _selectedFoodPrice.text = "%s" % foodData.price
    pass

func _populate_ratings(foodWeakRef: WeakRef):
    var selectedFood: FoodData = foodWeakRef.get_ref()
    var totalStar = int(GameplayVariables.get_learned_rate(selectedFood.resource_name))

    var stars = [_starTexture1, _starTexture2, _starTexture3]
    for i in range(3):
        if i < totalStar:
            stars[i].texture = star_texture
            stars[i].visible = true
        else:
            stars[i].visible = false
    pass

func _populate_ingredients(foodWeakRef: WeakRef):
    for i in _requiredIngredients.get_children():
        i.queue_free()

    var selectedFood: FoodData = foodWeakRef.get_ref()
    var neededIngredients: Dictionary = selectedFood.ingredients


    for ingredient in neededIngredients:
        var ingredientData: IngredientData = AssetManager.load_asset(ingredient).get_ref()
        var neededAmount: int = neededIngredients[ingredient]


        var frame: = _requiredAmountFrame.instantiate() as UI_RequiredAmount_Frame
        frame.setup_required_only(ingredientData.texture, neededAmount)
        frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        _requiredIngredients.add_child(frame)
    pass
