extends UI_Widget
class_name UI_Phase3_CookingUI

@export var _descriptionTxt: Label
@export var _QTEBarContainer: Control
@export var _timeTxt: Label
@export var _timeHBox: HBoxContainer
@export var _potFoodArea: Control
@export var _potAspectRect: AspectRatioContainer
@export var _qteHintText: AdvancedRichTextLabel
@export var _audioFireCrackling: AudioStream
@export var _audioFireShake: AudioStream

@export_group("FoodInfo")
@export var _foodNameTxt: Label
@export var _foodImgTextRect: TextureRect
@export var _foodTypeTxt: Label
@export var _foodPriceTxt: Label
@export var _foodDifficultyTxt: RichTextLabel
@export var _foodCookingTimeTxt: Label

@export_group("Ingredients")
@export var _requiredAmountFrame: PackedScene
@export var _ingredientVBox: VBoxContainer

var _phase3CookSystem: Phase3CookSystem
var _isInterrupted: bool
var _foodData: WeakRef
var _qteHint: String



func get_is_interrupted() -> bool:
    return _isInterrupted

func setup(foodWeakRef: WeakRef, phase3CookSystem: Phase3CookSystem):
    _foodData = foodWeakRef
    _phase3CookSystem = phase3CookSystem
    _phase3CookSystem.onCookSequenceStarted.connect(_on_cook_sequence_started)
    _phase3CookSystem.onEnterCookQTE.connect(_on_enter_cook_qte)
    _phase3CookSystem.onExitCookQTE.connect(_on_exit_cook_qte)
    _potFoodArea.child_entered_tree.connect(_on_food_entered)
    _update_food_info()
    pass

func _update_food_info():
    var foodData: FoodData = _foodData.get_ref()
    _foodNameTxt.text = foodData.name
    _foodImgTextRect.texture = foodData.sprite

    match foodData.type:
        KooehConstant.FoodType.DRINK: _foodTypeTxt.text = "Drink"
        KooehConstant.FoodType.FOOD: _foodTypeTxt.text = "Food"

    _foodPriceTxt.text = "%s" % foodData.price

    var t: String = ""
    match foodData.difficulty:
        KooehConstant.Difficulty.Easy: t = "[color=%s]%s[/color]" % [Color.DARK_GREEN.to_html(), "Easy"]
        KooehConstant.Difficulty.Normal: t = "[color=%s]%s[/color]" % [Color.ORANGE.to_html(), "Normal"]
        KooehConstant.Difficulty.Hard: t = "[color=%s]%s[/color]" % [Color.RED.to_html(), "Hard"]

    _foodDifficultyTxt.text = t
    _foodCookingTimeTxt.text = "%ss" % foodData.cookTime
    pass

func _update_ingredients():
    for i in _ingredientVBox.get_children():
        i.queue_free()

    var ingredients: Dictionary = _foodData.get_ref().ingredients
    for i in ingredients:
        var ingredient: IngredientData = AssetManager.load_asset(i).get_ref()
        var amount: int = ingredients[i]

        var frame: = _requiredAmountFrame.instantiate() as UI_RequiredAmount_Frame
        frame.setup_required_only(ingredient.texture, amount)
        _ingredientVBox.add_child(frame)
        _ingredientVBox.move_child(frame, 0)
    pass

func _unhandled_input(_event):
    accept_event()
    pass

func _input(event):
    if event.is_action_pressed("act_interact"):
        _phase3CookSystem.interact()
    elif event.is_action_pressed("ui_cancel"):
        _on_press_close()
    pass

func _on_press_close():
    _isInterrupted = true
    _phase3CookSystem.stop()
    UITree.PopWidgetFromLayer(self, _parentLayer.name)
    pass

func _on_cook_sequence_started():
    _descriptionTxt.show()

    var player = AudioSystem.play_sfx(_audioFireCrackling)
    _phase3CookSystem.onCookSequenceCompleted.connect(
        func stop_fire_crackling(_cookedFoodWeakRef: WeakRef, _successRate: float):
            player.finished.emit(), CONNECT_ONE_SHOT)
    _update_ingredients()
    pass

func _on_enter_cook_qte(cookInstruction: CookInstruction, qteBar: Control):
    _descriptionTxt.text = cookInstruction.description
    _qteHint = cookInstruction.qteData.qteHint
    _qteHintText.text = _qteHint

    _QTEBarContainer.add_child(qteBar)

    if cookInstruction.qteTimeLimit > 0.0:
        if not _phase3CookSystem.onSessionTimeLimitUpdated.is_connected(_update_time_limit):
            _phase3CookSystem.onSessionTimeLimitUpdated.connect(_update_time_limit)
        _update_time_limit(cookInstruction.qteTimeLimit)
        _timeHBox.show()
    else:
        if _phase3CookSystem.onSessionTimeLimitUpdated.is_connected(_update_time_limit):
            _phase3CookSystem.onSessionTimeLimitUpdated.disconnect(_update_time_limit)
        _timeHBox.hide()
    pass

func _update_time_limit(time: float):
    _timeTxt.text = str(max(int(time), 0))
    pass

func _on_exit_cook_qte(_interrupted: bool):
    if _QTEBarContainer.get_child_count() > 0:
        var c = _QTEBarContainer.get_child(0)
        _QTEBarContainer.remove_child(c)
        c.queue_free()
    pass

func _remove_top_ingredient():
    if _ingredientVBox.get_child_count() == 0:
        return

    var entry = _ingredientVBox.get_child(0)
    var tweener: Tween = create_tween()

    tweener.tween_property(entry, "custom_minimum_size", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_EXPO)
    tweener.parallel().tween_property(entry, "modulate", Color.TRANSPARENT, 0.1).set_trans(Tween.TRANS_EXPO)

    tweener.tween_callback(func delete_entry():
        if is_instance_valid(entry):
            _ingredientVBox.remove_child(entry)
            entry.queue_free())
    pass

func _spawn_flyout_object():
    var entry: = _ingredientVBox.get_child(0) as UI_RequiredAmount_Frame
    var flyout: = TextureRect.new()
    flyout.texture = entry._itemTextureRect.texture
    add_child(flyout)
    flyout.global_position = entry.global_position
    flyout.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    flyout.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    flyout.set_anchors_preset(Control.PRESET_CENTER)

    _ingredientVBox.remove_child(entry)
    entry.queue_free()

    var targetSize: Vector2 = Vector2.ONE * 200.0
    flyout.pivot_offset = targetSize * 0.5
    var randomPos: Vector2 = _random_pot_food_position() - flyout.pivot_offset
    var tweener: Tween = create_tween()
    tweener.tween_property(flyout, "global_position", randomPos, 0.5).set_trans(Tween.TRANS_CIRC)
    tweener.parallel().tween_property(flyout, "size", targetSize, 0.5).set_ease(Tween.EASE_IN)
    tweener.tween_callback(func attach():
        flyout.reparent(_potFoodArea))

    await tweener.finished
    pass

func _random_pot_food_position() -> Vector2:
    var gRect: Rect2 = _potFoodArea.get_global_rect()
    var rng: = RandomNumberGenerator.new()
    var x: float = rng.randf_range(0.0, gRect.size.x)
    var y: float = rng.randf_range(0.0, gRect.size.y)

    var finalPos: Vector2 = Vector2(x, y) + gRect.position
    return finalPos

func _on_food_entered(node: Node):
    var tween: Tween = create_tween().bind_node(node)
    tween.finished.connect(_on_food_entered.bind(node))

    var rng: = RandomNumberGenerator.new()
    var randomPos: Vector2 = _random_pot_food_position()
    var randomRot: float = rng.randf_range(0.0, 15.0)

    tween.tween_property(node, "global_position", randomPos, rng.randf_range(5.0, 10.0))
    tween.parallel().tween_property(node, "rotation_degrees", randomRot, rng.randf_range(1.0, 5.0))
    pass

func play_cook_animation() -> Signal:
    for i in get_tree().get_processed_tweens():
        i.kill()

    for i in _ingredientVBox.get_children():
        await _spawn_flyout_object()

    AudioSystem.play_sfx(_audioFireShake)
    var rng: = RandomNumberGenerator.new()

    var potTween: Tween = _potFoodArea.create_tween()
    potTween.set_loops(2)
    potTween.tween_property(_potAspectRect, "scale", Vector2.ONE * 0.8, 0.3).set_ease(Tween.EASE_OUT)
    potTween.tween_property(_potAspectRect, "scale", Vector2.ONE * 1.0, 0.3).set_ease(Tween.EASE_OUT)

    for i in _potFoodArea.get_children():
        var randomHeight: float = rng.randf_range(200.0, 400.0)
        var globalPos: Vector2 = i.global_position
        var tween: Tween = i.create_tween()
        tween.set_loops(2)
        tween.tween_property(i, "global_position", globalPos - Vector2(0.0, randomHeight), 0.3).set_ease(Tween.EASE_OUT)
        tween.tween_property(i, "global_position", globalPos, 0.3).set_ease(Tween.EASE_OUT)

    await potTween.finished
    return get_tree().create_timer(2.0, false).timeout
