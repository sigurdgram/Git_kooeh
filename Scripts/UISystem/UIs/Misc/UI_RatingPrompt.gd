extends UI_Prompt
class_name UI_RatingPrompt

const Title1: String = "title1"
const TitleEmphasis: String = "titleEmphasis"
const RewardName: String = "rewardName"
const RTL1: String = "rtl1"
const RTL2: String = "rtl2"

@export var _audioRecipeLearned: AudioStream
@export var _title1: Label
@export var _titleEmphasis: Label
@export var _rewardName: Label
@export var _rtl1: RichTextLabel
@export var _rtl2: RichTextLabel
@export var _textureRect: TextureRect
@export var _animIn: AnimationPlayer
@export var _star1: TextureRect
@export var _star2: TextureRect
@export var _star3: TextureRect

var _blockInput: bool
var _callback: Callable
var _rating: int



func _ready():
    assert (process_mode == PROCESS_MODE_PAUSABLE)
    if is_instance_valid(_btnNo):
        _btnNo.grab_focus.call_deferred()
    pass

func ActivateWidget():
    pass

func DeactivateWidget():
    pass

func setup_prompt(_question: String, _yesCallback: Callable, _noCallback: Callable):
    assert (false, "Do not use this function, please use 'setup_rating_prompt'")
    pass

func _gui_input(_event):
    if _blockInput:
        accept_event()
    elif _event.is_action_pressed("act_interact"):
        if _callback.is_valid():
            _callback.call()
        queue_free()
        accept_event()
    pass

func _input(_event):
    if _blockInput:
        accept_event()
    elif _event.is_action_pressed("act_interact"):
        if _callback.is_valid():
            _callback.call()
        queue_free()
        accept_event()
    pass

func unblock_input():
    _blockInput = false
    pass

func show_rating_stars():
    if _rating <= 0:
        return

    var i: int = 0
    var tweener: Tween = create_tween()
    while (i <= _rating):
        match i:
            1: tweener.tween_property(_star1, "scale", Vector2.ONE * 1.2, 0.3).set_trans(Tween.TRANS_BOUNCE)
            2: tweener.tween_property(_star2, "scale", Vector2.ONE * 1.5, 0.3).set_trans(Tween.TRANS_BOUNCE)
            3: tweener.tween_property(_star3, "scale", Vector2.ONE * 1.2, 0.3).set_trans(Tween.TRANS_BOUNCE)
        i += 1
    pass

func setup_rating_prompt(data: WeakRef, rating: int, yesCallback: Callable, noFail: bool = false):
    _blockInput = true
    _callback = yesCallback
    _rating = rating

    if data.get_ref() is FoodData:
        _food_data_rating(data.get_ref())
    else:
        assert (false, "Reward process unimplemented")

    if noFail:
        _animIn.play("Anim_Success")
        AudioSystem.play_sfx(_audioRecipeLearned)
    else:
        var anim: String = "Anim_Success" if _rating > 0 else "Anim_Failed"
        _animIn.play(anim)
    pass

func _food_data_rating(data: FoodData):
    if data.sprite:
        _textureRect.texture = data.sprite
    else:
        _textureRect.hide()

    _title1.text = "YOU'VE LEARNED A"
    _titleEmphasis.text = "NEW RECIPE!"
    _rewardName.text = data.name

    var colorText: String
    match data.difficulty:
        KooehConstant.Difficulty.Easy: colorText = "[color=%s]%s[/color]" % [Color.DARK_GREEN.to_html(), "Easy"]
        KooehConstant.Difficulty.Normal: colorText = "[color=%s]%s[/color]" % [Color.ORANGE.to_html(), "Normal"]
        KooehConstant.Difficulty.Hard: colorText = "[color=%s]%s[/color]" % [Color.RED.to_html(), "Hard"]

    _rtl1.text = "Difficulty: " + colorText
    _rtl2.text = "Cooking Time: %ss" % data.cookTime
    pass

func get_anim_player() -> AnimationPlayer:
    return _animIn
