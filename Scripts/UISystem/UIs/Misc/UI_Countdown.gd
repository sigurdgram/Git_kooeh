extends UI_Widget
class_name UI_Countdown

@export var _text: Label
@export var _audioReady: AudioStream
@export var _audioGo: AudioStream

var _commandArray: PackedStringArray
var tweener: Tween

signal onStart
signal onEnd


func _ready():
    pivot_offset = get_global_rect().get_center()
    scale = Vector2.ZERO
    pass

func setup(commandArray: PackedStringArray, startNow: bool):
    _commandArray = commandArray

    if startNow:
        tween()
    pass

func tween():
    if is_instance_valid(tweener):
        tweener.kill()

    tweener = create_tween()

    onStart.emit()
    var commandArraySize: int = _commandArray.size()
    for i in commandArraySize:
        var command: String = _commandArray[i]
        var audio: AudioStream = _audioReady if i < commandArraySize - 1 else _audioGo
        tweener.tween_callback(func set_text(): _text.text = command)
        tweener.tween_callback(func call(): AudioSystem.play_sfx(audio))
        tweener.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC)
        tweener.tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_ELASTIC)
    tweener.tween_callback(func end(): onEnd.emit())
    pass

func _exit_tree():
    if is_instance_valid(tweener):
        tweener.kill()
    pass
