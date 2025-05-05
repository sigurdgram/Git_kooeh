extends UI_Widget
class_name UI_Phase1_WishingTree

enum BackableState{CONFIGURATING, CUTSCENE, REWARDDROP, SAFETOEXIT}

@export var _maxIngredientWishAmount: int = 3
@export var _uiButtonFrame: PackedScene
@warning_ignore("unused_private_class_variable")
@export var _wishPaperButton: PackedScene
@export var _wishBtn: UI_BasicButton
@export var _tabContainer: TabContainer
@export var _animPlayer: AnimationPlayer
@export var _pressEscTxt: RichTextLabel
@export var _audioSelect1: AudioStream
@export var _audioSelect2: AudioStream
@export var _audioSelect3: AudioStream
@export var _audioWishingTreeAnimatics: AudioStream
@export var _audioWishingPaperToss: AudioStream
@export var _audioRewardDrop1: AudioStream
@export var _audioRewardDrop2: AudioStream
@export var _audioRewardDrop3: AudioStream
@export var _audioRewardFly1: AudioStream
@export var _audioRewardFly2: AudioStream
@export var _audioRewardFly3: AudioStream
@export var _audioReady: AudioStream
@export var _audioGo: AudioStream
@export var _audioQTEComplete: AudioStream
@export var _audioYouHaveReceived: AudioStream

@export_group("Select Ingredients")
@export var _selectIngredientGrid: GridContainer
@export var _ingredientCountTxt: RichTextLabel

@export_group("Wish QTE")
@export var _wishQTEReadyRating: Label
@export var _wishTxt: RichTextLabel
@export var _wishQTERatingColors: Dictionary
@export var _qteBarWishingTree: QTEBar_WishingTree
@export var _wishingPaperVBox: VBoxContainer
@export var _wishingRibbon: TextureRect

@export_group("Reward")
@export var _rewardDrop: PackedScene
@export var _inventorySlot: PackedScene
@export var _rewardRefRect: ReferenceRect
@export var _rewardSpawnPosition: Control
@export var _rewardDropPosition: Control
@export var _rewardHFlow: HFlowContainer
@export var _rewardScroll: ScrollContainer
@export var _rewardTxt: Label

var _selectedIngredients: PackedStringArray
var _wishingTree: Buildable_WishingTree1
var _backableState: BackableState = BackableState.CONFIGURATING
var _rewards: Dictionary
var _rewardCount: int
var _currentFocus: Control
var _selectedButtons: Array = []
var _isStarted: bool = true
var _blockInput: bool

signal destroyDrops


func get_wishingTree_QTEBar() -> QTEBar_WishingTree:
    return _qteBarWishingTree

func play_you_have_received_audio():
    AudioSystem.play_sfx(_audioYouHaveReceived)
    pass

func _ready():
    _pressEscTxt.hide()
    _wishBtn.pressed.connect(_on_click_wish)
    _wishBtn.disabled = _selectedIngredients.is_empty()
    _qteBarWishingTree.onBroadcastResult.connect(_on_tap)
    _tabContainer.current_tab = 0

    var ingredients: Array[WeakRef] = IngredientLibrary.get_all_ingredients()

    for child in _selectIngredientGrid.get_children():
        child.queue_free()

    for i in ingredients:
        var ingredientID: String = i.get_ref().resource_name
        var slotNode = _uiButtonFrame.instantiate() as UI_Button_Frame
        slotNode.setup(ingredientID, _on_slot_clicked)
        _selectIngredientGrid.add_child(slotNode)
        if not is_instance_valid(_currentFocus):
            _currentFocus = slotNode

    _buildIngredientGridNavigation()
    for i in _maxIngredientWishAmount:
        var wish = _wishPaperButton.instantiate() as UI_Ingredient_Frame
        wish.add_to_group("WishPaperButton")
        wish.setup("")
        _wishingPaperVBox.add_child(wish)

    InputManager.set_game_input_enabled(false)
    _currentFocus.grab_focus()
    pass

func get_wish_button() -> UI_BasicButton:
    return _wishBtn

func get_press_esc_text() -> RichTextLabel:
    return _pressEscTxt

func _exit_tree():
    if GameInstance.gameWorld.tutorial:
        pass
    else:
        InputManager.set_game_input_enabled(true)

func _input(event):
    if _blockInput:
        accept_event()













    elif event.is_action_pressed("ui_cancel")\
or ( not _backableState == BackableState.CONFIGURATING and event.is_action_pressed("act_interact")):
        _on_back()
        accept_event()
    pass

func set_block_input(blockInput: bool):
    _blockInput = blockInput
    pass

func _on_back():
    match _backableState:
        BackableState.CONFIGURATING:
            if GameInstance.gameWorld.tutorial:
                return

            _currentFocus = get_viewport().gui_get_focus_owner()
            var prompt = UITree.Prompt("Are you want to exit the session? \n You can only wish once per day.", 
            func yes():
                UITree.PopWidgetFromLayer(self, UITree.layerGameUI)
                AudioSystem.set_pause_music(false), 
            func no(): _currentFocus.grab_focus()) as UI_Prompt
            prompt.grab_focus()
            pass
        BackableState.CUTSCENE:
            var length: float = _animPlayer.current_animation_length
            var pos: float = _animPlayer.current_animation_position
            _animPlayer.advance(length - pos)
            pass
        BackableState.REWARDDROP:
            _rewards.clear()
            for i in _rewardHFlow.get_children():
                i.modulate = Color.WHITE
            pass
        BackableState.SAFETOEXIT:
            UITree.PopWidgetFromLayer(self, UITree.layerGameUI)
            AudioSystem.set_pause_music(false)
            pass
    pass

func setup(wishingTree: Buildable_WishingTree1):
    _wishingTree = wishingTree
    pass

func _on_slot_clicked(button: UI_Button_Frame, itemWeakRef: WeakRef):
    var itemData: IngredientData = itemWeakRef.get_ref()

    if _selectedIngredients.has(itemData.resource_name):
        var new_selected_ingredients: = PackedStringArray()
        for ingredient in _selectedIngredients:
            if ingredient != itemData.resource_name:
                new_selected_ingredients.append(ingredient)
        _selectedIngredients = new_selected_ingredients
        button.deselect_ingredient()
        _selectedButtons.erase(button)
        AudioSystem.play_sfx(_audioSelect1)
        _enable_wish()
        _update_ingredient_count()
        return

    if _selectedIngredients.size() >= _maxIngredientWishAmount:
        return

    if _selectedButtons.size() >= _maxIngredientWishAmount:
        return

    match _selectedIngredients.size():
        0: AudioSystem.play_sfx(_audioSelect1)
        1: AudioSystem.play_sfx(_audioSelect2)
        2: AudioSystem.play_sfx(_audioSelect3)

    _selectedIngredients.append(itemData.resource_name)
    button.select_ingredient()
    _selectedButtons.append(button)
    _enable_wish()
    _update_ingredient_count()
    pass

func _on_tap(tapRating: int):
    _qteBarWishingTree.stop()
    AudioSystem.play_sfx(_audioQTEComplete)
    var text = ""
    match tapRating:
        0: text = "OK"
        1: text = "GREAT"
        2: text = "PERFECT"

    _rewards = _wishingTree.random_wish_ingredients(tapRating, _selectedIngredients)

    await tween_ready_rating(_wishQTERatingColors[tapRating], text)
    await get_tree().create_timer(1.0, false).timeout
    _qteBarWishingTree.hide()
    _wishTxt.hide()
    _wishQTEReadyRating.text = ""
    _wishingRibbon.show()

    _animPlayer.play("WishingPaperToss")
    AudioSystem.play_sfx(_audioWishingPaperToss)
    _pressEscTxt.show()

    await get_tree().create_timer(0.6, false).timeout
    _animPlayer.pause()
    _wishingPaperVBox.show()
    await tween_wishing_paper_vbox(_wishingPaperVBox)
    _animPlayer.play()

    GameplayVariables.add_wish()

    _backableState = BackableState.CUTSCENE
    await _animPlayer.animation_finished
    pass

func play_animatic_music():
    AudioSystem.set_pause_music(true)
    var player = AudioSystem.play_music(_audioWishingTreeAnimatics, AudioSystem.AudioPlayMode.ADDITIVE)

    onDeactivated.connect(func disable_animation_music():
        if is_instance_valid(player):
            player.finished.emit()
    , CONNECT_ONE_SHOT)
    pass

func _on_click_wish():
    _wishBtn.disabled = true
    _tabContainer.current_tab = 1

    await get_tree().process_frame
    _wishQTEReadyRating.pivot_offset = _wishQTEReadyRating.get_global_rect().size * 0.5
    _qteBarWishingTree.setup()
    _qteBarWishingTree.set_process(false)
    start_wish_qte()
    pass

func set_can_start(canStart: bool):
    _isStarted = canStart
    pass

func start_wish_qte():
    if not _isStarted:
        return

    AudioSystem.play_sfx(_audioReady)
    await tween_ready_rating(_wishQTERatingColors[-1], "Ready")
    await get_tree().create_timer(0.5, false).timeout
    AudioSystem.play_sfx(_audioGo)
    await tween_ready_rating(_wishQTERatingColors[-1], "Go")
    _wishQTEReadyRating.scale = Vector2.ZERO
    _qteBarWishingTree.start()
    pass

func _on_click_wishing_paper_button(itemWeakRef: WeakRef):
    var data: IngredientData = itemWeakRef.get_ref()
    var index: int = _selectedIngredients.find(data.resource_name)
    _selectedIngredients.remove_at(index)
    AudioSystem.play_sfx(_audioSelect1)
    _enable_wish()
    _update_ingredient_count()
    pass

func tween_ready_rating(color: Color, text: String):
    _wishQTEReadyRating.pivot_offset = _wishQTEReadyRating.size / 2
    _wishQTEReadyRating.scale = Vector2.ZERO
    _wishQTEReadyRating.text = text
    _wishQTEReadyRating.add_theme_color_override("font_color", color)
    var scaleTween: Tween = create_tween()
    await scaleTween.tween_property(_wishQTEReadyRating, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_CUBIC).finished
    pass

func tween_wishing_paper_vbox(container: VBoxContainer):
    container.scale = Vector2.ZERO
    container.pivot_offset = container.size / 2
    container.show()
    var scaleTween: Tween = create_tween()
    await scaleTween.tween_property(container, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_CUBIC).finished
    pass

func _enable_wish():
    for i in _wishingPaperVBox.get_child_count():
        var button: UI_Ingredient_Frame = _wishingPaperVBox.get_child(i)

        var ingredientID: String = _selectedIngredients[i] if i <= _selectedIngredients.size() - 1 else ""
        button.setup(ingredientID)

    _wishBtn.disabled = _selectedIngredients.size() != _maxIngredientWishAmount
    pass

func show_reward_drops():
    for i in _rewards:
        var slot: = _inventorySlot.instantiate() as UI_Item_Frame
        var value: int = _rewards[i]
        slot.setup(i, value)
        _rewardHFlow.add_child(slot)
        slot.modulate = Color.TRANSPARENT

    await get_tree().process_frame
    _animate_reward_drop()
    _backableState = BackableState.REWARDDROP
    pass

func _animate_reward_drop():
    var spawnLoc: Vector2 = _rewardSpawnPosition.get_global_rect().get_center()
    var key: String
    var index: int = _rewardCount
    _rewardCount += 1

    for i in _rewards:
        key = i
        var drop: = _rewardDrop.instantiate() as UI_Phase1_WishingTree_RewardDrop
        destroyDrops.connect(drop.queue_free)
        var slot: = _rewardHFlow.get_child(index) as UI_Item_Frame

        var value: int = _rewards[i]

        var audioDropToPlay: AudioStream
        var audioFlyToPlay: AudioStream
        match index:
            0:
                audioDropToPlay = _audioRewardDrop1
                audioFlyToPlay = _audioRewardFly1
            1:
                audioDropToPlay = _audioRewardDrop2
                audioFlyToPlay = _audioRewardFly2
            _:
                audioDropToPlay = _audioRewardDrop3
                audioFlyToPlay = _audioRewardFly3

        await get_tree().process_frame
        _rewardScroll.ensure_control_visible(slot)
        _rewardRefRect.add_child(drop)
        drop.setup(key, value, spawnLoc, _rewardDropPosition.global_position, slot, \
_animate_reward_drop, audioDropToPlay, audioFlyToPlay)
        break

    if _rewards.is_empty():
        _backableState = BackableState.SAFETOEXIT

    _rewards.erase(key)
    pass

func _on_refrect_reward_visibility_changed():
    if visible:
        await get_tree().process_frame
        _rewardTxt.pivot_offset = _rewardTxt.get_global_rect().get_center()
    pass

func _update_ingredient_count():
    var count_text = str(_selectedIngredients.size())
    var max_text = str(_maxIngredientWishAmount)
    if _selectedIngredients.size() == _maxIngredientWishAmount:
        _ingredientCountTxt.bbcode_text = "[center]" + "WISH"
    else:
        _ingredientCountTxt.bbcode_text = "[center]" + "([color=red]" + count_text + "[/color]/" + max_text + ") Ingredients"
    pass

func _buildIngredientGridNavigation() -> void :
    var cols: int = _selectIngredientGrid.columns
    var elementCount: int = _selectIngredientGrid.get_child_count()
    var nullPath: NodePath = NodePath("null")
    for i in elementCount:
        var element: Control = _selectIngredientGrid.get_child(i)
        var i1 = i + 1

        if i1 % cols > 0 and i1 < elementCount:
            element.focus_neighbor_right = _selectIngredientGrid.get_child(i1).get_path()
        else:
            element.focus_neighbor_right = nullPath

        if i % cols > 0:
            element.focus_neighbor_left = _selectIngredientGrid.get_child(i - 1).get_path()
        else:
            element.focus_neighbor_left = nullPath




    pass
