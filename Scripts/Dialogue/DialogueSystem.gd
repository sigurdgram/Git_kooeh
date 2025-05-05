extends Node

@export var _balloon: PackedScene

var _dialogueBalloon: UI_DialogueBalloon
var _isAutoplayOn: bool = false
var _autoplayPause: float = 1.5
var _isDialoguePlaying: bool

signal onDialogueStarted(dialogueSet: DialogueSet, title: String)
signal onDialogueEnded(dialogue: DialogueResource)
signal emote(emoteName: String)


func _ready():
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    pass

func _on_dialogue_ended(dialogue: DialogueResource):
    set_dialogue_is_playing(false)
    onDialogueEnded.emit(dialogue)
    if is_instance_valid(_dialogueBalloon):
        UITree.PopWidgetFromLayer(_dialogueBalloon, _dialogueBalloon.get_owning_layer_name())
    pass

func spawn_dialogue(dialogueSet: DialogueSet, dialogueTitle: String, layer: String = UITree.layerGame) -> UI_DialogueBalloon:
    set_dialogue_is_playing(true)
    _dialogueBalloon = UITree.PushWidgetToLayer(_balloon, layer) as UI_DialogueBalloon
    onDialogueStarted.emit(dialogueSet, dialogueTitle)
    _dialogueBalloon.start(dialogueSet, dialogueTitle)
    emote.connect(_dialogueBalloon.emote)
    return _dialogueBalloon

func spawn_dialogue_additive(dialogueSet: DialogueSet, dialogueTitle: String, layer: String = UITree.layerGame) -> UI_DialogueBalloon:
    set_dialogue_is_playing(true)
    _dialogueBalloon = UITree.AdditivePushWidgetToLayer(_balloon, layer) as UI_DialogueBalloon
    onDialogueStarted.emit(dialogueSet, dialogueTitle)
    _dialogueBalloon.start(dialogueSet, dialogueTitle)
    emote.connect(_dialogueBalloon.emote)
    return _dialogueBalloon

func set_enable_user_input(state: bool):
    _dialogueBalloon.set_enable_user_input(state)
    pass

func toggle_autoplay():
    _isAutoplayOn = not _isAutoplayOn

func get_autoplay_pause() -> float:
    return _autoplayPause

func set_dialogue_is_playing(isPlaying: bool):
    _isDialoguePlaying = isPlaying

func get_dialogue_is_playing() -> bool:
    return _isDialoguePlaying
