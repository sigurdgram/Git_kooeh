extends UI_Widget
class_name UI_Prompt

@export var _descriptionTxt: Label
@export var _btnYes: Button
@export var _btnNo: Button
@export var _audioPrompt: AudioStream
@export var _audioYes: AudioStream
@export var _audioNo: AudioStream

var _isPrePaused: bool = false


func _ready():
    assert (process_mode == PROCESS_MODE_ALWAYS)
    if is_instance_valid(_btnNo):
        _btnNo.grab_focus.call_deferred()
    pass

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        accept_event()
    pass

func ActivateWidget():
    _isPrePaused = get_tree().paused

    if not _isPrePaused:
        get_tree().paused = true
    pass

func DeactivateWidget():
    if not _isPrePaused:
        get_tree().paused = false
    pass

func setup_prompt(question: String, yesCallback: Callable, noCallback: Callable):
    AudioSystem.set_pause_sfx(true)
    AudioSystem.play_sfx(_audioPrompt)

    _descriptionTxt.text = question
    _btnYes.pressed.connect(
        func yes():
            if not yesCallback.is_null():
                yesCallback.call()
            AudioSystem.play_sfx(_audioYes)
            UITree.PopWidgetFromLayer(self, _parentLayer.name)
    , CONNECT_ONE_SHOT)

    _btnNo.pressed.connect(
        func no():
            if not noCallback.is_null():
                noCallback.call()
            AudioSystem.set_pause_sfx(false)
            AudioSystem.play_sfx(_audioNo)
            UITree.PopWidgetFromLayer(self, _parentLayer.name)
    , CONNECT_ONE_SHOT)
    pass

func set_description(value: String):
    _descriptionTxt.text = value
    pass
