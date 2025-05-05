extends Control
class_name QTEBar_Stir

const DegreeRange: float = 7.0

@export var _knob: Control
@export var _target: Control

@export_group("Colors")
@export var _defaultTargetColor: Color

@export_group("Audio")
@export var _passAudio: AudioStream
@export var _failAudio: AudioStream

var _targetChild: Control
var _executions: Array[float]
var _speed: float
signal onBroadcastResult(passed: bool)



func _ready():
    _targetChild = _target.get_child(0)
    _target.modulate = _defaultTargetColor

    set_process(false)
    set_process_input(false)

    await get_tree().process_frame

    _knob.pivot_offset = _knob.get_parent_area_size() * 0.5
    _target.pivot_offset = _target.get_parent_area_size() * 0.5
    _targetChild.pivot_offset = _targetChild.get_rect().size * 0.5
    _targetChild.rotation_degrees = wrapf( - _target.rotation_degrees, 0.0, 360.0)
    pass

func setup(qteData: QTEData_Stir, startNow: bool):
    _speed = qteData.speed
    var executionCount: int = qteData.numberOfExecutions

    var rng: = RandomNumberGenerator.new()
    for i in executionCount:
        _executions.append(rng.randf_range(0.0, 360.0))

    _target.rotation_degrees = _executions.pop_front()
    if startNow:
        start_QTE()
    pass

func start_QTE():
    set_process(true)
    set_process_input(true)
    pass

func _process(delta: float):
    _knob.rotation_degrees = wrapf(_knob.rotation_degrees + _speed * delta, 0.0, 360.0)
    pass

func _input(event: InputEvent):
    if event.is_action_pressed("act_interact"):
        _tap()
        accept_event()
    pass

func _next(passed: bool):
    if _executions.size() > 0:
        _target.modulate = _defaultTargetColor
        _target.position = Vector2.ZERO
        _target.get_child(0).scale = Vector2.ONE

        _target.rotation_degrees = _executions.pop_front()
        _targetChild.rotation_degrees = wrapf( - _target.rotation_degrees, 0.0, 360.0)
        set_process_input(true)
    else:
        set_process(false)

    onBroadcastResult.emit(passed)
    pass

func _tap():
    var tween: Tween = create_tween()
    tween.tween_callback(set_process_input.bind(false))

    var isPassed: bool = abs(_knob.rotation_degrees - _target.rotation_degrees) <= DegreeRange
    if isPassed:
        AudioSystem.play_sfx(_passAudio)
        tween.tween_property(_target, "modulate", Color.GREEN, 0.0)
    else:
        AudioSystem.play_sfx(_failAudio)
        tween.tween_property(_target, "modulate", Color.GRAY, 0.0)
        tween.parallel().tween_property(_target, "position", Vector2.DOWN * 300, 0.2).from_current()

    tween.parallel().tween_property(_target.get_child(0), "scale", Vector2.ONE * 0.3, 0.2).from_current()
    tween.parallel().tween_property(_target, "modulate:a", 0.0, 0.2).from_current()
    tween.tween_callback(_next.bind(isPassed))
    pass
