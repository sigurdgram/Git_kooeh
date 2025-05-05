extends Control
class_name QTEBar_Pour

const Tolerance: float = 0.03

@export var path: Path2D
@export var border: Line2D
@export var line: Line2D
@export var hint: Line2D
@export var _knob: Control
@export var _ring: Control
@export var lineWidth: float = 60.0
@export var borderWidth: float = 5.0
@export var knobSize: float = 40.0
@export var _knobGroup: Control

@export_group("Audio")
@export var _passAudio: AudioStream
@export var _failAudio: AudioStream

var _tapZones: Array
var _qteData: QTEData_Pour
var _counter: float
var _qteSpeed: float

signal onBroadcastResult(passed: bool)



func _ready() -> void :
    set_physics_process(false)
    border.width = lineWidth + borderWidth
    line.width = lineWidth
    item_rect_changed.connect(_reposition)
    pass

func start_QTE():
    set_physics_process(true)
    pass

func setup(qteData: QTEData_Pour, startNow: bool):
    _qteData = qteData
    _qteSpeed = qteData.qteSpeed
    _scale_curve(_qteData.referenceCurve)

    var step: float = 0.8 / qteData.qteHitCount
    for i in qteData.qteHitCount:
        var knob: Control = _knob.duplicate()
        _knobGroup.add_child(knob)
        var offset: float = 0.2 + step * i
        var pos: Vector2 = path.curve.samplef(offset) + path.position
        knob.position = pos - knob.get_rect().size * 0.5
        knob.show()
        _tapZones.push_back([offset, knob])

    _ring.position = path.curve.get_point_position(0) + path.position - _ring.get_rect().size * 0.5

    if startNow:
        set_physics_process(true)
    pass

func _scale_curve(curve: Curve2D):
    var newCurve: Curve2D = Curve2D.new()
    newCurve.bake_interval = curve.bake_interval
    var s: float = _qteData.scale
    for i in curve.point_count:
        var pos: Vector2 = curve.get_point_position(i) * s
        var posIn: Vector2 = curve.get_point_in(i) * s
        var posOut: Vector2 = curve.get_point_out(i) * s
        newCurve.add_point(pos, posIn, posOut)

    line.clear_points()
    border.clear_points()
    hint.clear_points()

    var points: PackedVector2Array = newCurve.get_baked_points()
    var pointSize: int = points.size()
    for i in pointSize:
        var point: Vector2 = points[i]
        line.add_point(point)
        border.add_point(point)

    var stepper: float = knobSize + 10.0

    while stepper < 120.0:
        hint.add_point(newCurve.sample_baked(stepper))
        stepper += 1.0

    path.curve = newCurve
    _reposition()
    pass

func _physics_process(delta: float) -> void :
    _counter = clampf(_counter + delta * _qteSpeed, 0, 1.0)
    _ring.position = path.curve.samplef(_counter) + path.position - _ring.get_rect().size * 0.5

    if not _tapZones.is_empty():
        var currentTapZone: float = _tapZones[0][0]
        var diff: float = _counter - currentTapZone

        if diff > Tolerance:
            _pop_tap_zone(false)

        elif Input.is_action_just_pressed("act_interact"):
            _tap(diff)
            return

    if _counter >= 1.0:
        set_physics_process(false)
    pass

func _tap(diff: float):
    _pop_tap_zone(abs(diff) <= Tolerance)
    pass

func _pop_tap_zone(passed: bool) -> void :
    var e = _tapZones.pop_front()
    var color: Color

    if passed:
        color = Color.WEB_GREEN
        AudioSystem.play_sfx(_passAudio)
    else:
        color = Color.DARK_RED
        AudioSystem.play_sfx(_failAudio)

    var knob: Control = e[1]
    var tween: Tween = knob.create_tween()
    tween.tween_property(knob, "modulate", color, 0.2)
    tween.tween_property(knob, "modulate:a", 0.0, 0.1)
    tween.tween_callback(knob.free)
    onBroadcastResult.emit(passed)
    pass

func _reposition():
    if get_parent_control():
        position = get_parent_control().size * 0.5
    pass
