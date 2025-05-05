extends UI_Prompt
class_name UI_RewardPrompt

const Title1: String = "title1"
const TitleEmphasis: String = "titleEmphasis"
const RewardName: String = "rewardName"
const RTL1: String = "rtl1"
const RTL2: String = "rtl2"

@export var _title1: Label
@export var _titleEmphasis: Label
@export var _rewardName: Label
@export var _rtl1: RichTextLabel
@export var _rtl2: RichTextLabel
@export var _textureRect: TextureRect
@export var _animIn: AnimationPlayer

var _blockInput: bool
var _callback: Callable


func setup_prompt(_question: String, _yesCallback: Callable, _noCallback: Callable):
    assert (false, "Do not use this function, please use 'setup_reward_prompt'")
    pass

func _gui_input(event):
    if _blockInput:
        accept_event()
    elif event is InputEventMouseButton:
        if _callback.is_valid():
            _callback.call()
        queue_free()
    pass

func _input(event):
    if _blockInput:
        accept_event()
    elif event is InputEventKey:
        if _callback.is_valid():
            _callback.call()
        queue_free()
    pass

func unblock_input():
    _blockInput = false
    pass

func setup_reward_prompt(data, yesCallback: Callable):
    _blockInput = true
    _callback = yesCallback

    if data is FoodData:
        _food_data_reward(data as FoodData)
    else:
        assert (false, "Reward process unimplemented")

    _animIn.play("Anim_In")
    pass

func _food_data_reward(data: FoodData):
    if data.sprite:
        _textureRect.texture = data.sprite
    else:
        _textureRect.hide()

    _title1.text = "YOU'VE UNLOCKED A"
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
