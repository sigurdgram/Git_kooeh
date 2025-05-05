extends Control
class_name QTEBar_Drag

@export var path: Path2D
@export var border: Line2D
@export var line: Line2D
@export var end: Control
@export var knobScene: PackedScene
@export var targetScene: PackedScene

@export var knobSize: float = 40.0
@export var lineWidth: float = 60.0
@export var borderWidth: float = 5.0
@export var auto_move_speed: float = 0.5
@export var predefinedPositions: Array[float] = [0.1, 0.3, 0.5, 0.7, 0.9]
@export var targetRadius: float = 0.05

@export_group("Colors")
@export var target_default_color: Color = Color.GREEN
@export var target_clear_color: Color = Color.GRAY

var _knob: QTEBar_Drag_Knob
var _progress: float
var _qteData: QTEData_Drag
var _isStarted: bool = true
var _isAutoMoving: bool = true
var _executions: Array[bool] = []
var _targets: Array[Dictionary] = []
var _cleared_targets: int = 0

signal onBroadcastResult(success: bool)



func _ready():
    set_process(true)
    border.width = lineWidth + borderWidth
    line.width = lineWidth
    item_rect_changed.connect(_reposition)
    pass

func setup(qteData: QTEData_Drag, startNow: bool = true, autoMove: bool = true):
    _executions.clear()
    _qteData = qteData
    rotation_degrees = qteData.rotation_degrees
    _isStarted = startNow
    _isAutoMoving = autoMove

    _scale_curve(_qteData.referenceCurve)
    for i in range(qteData.numberOfExecutions):
        _executions.append(true)
    if not is_instance_valid(_knob):
        _knob = knobScene.instantiate() as QTEBar_Drag_Knob
        add_child(_knob)

    _spawn_targets(_qteData.numberOfExecutions)
    pass

func start_QTE():
    _isStarted = true

func _process(delta: float):
    if _isAutoMoving:
        var curve: Curve2D = path.curve
        var length: float = curve.get_baked_length()
        _progress += auto_move_speed * delta / length
        _progress = clamp(_progress, 0.0, 1.0)
        var baked_position: Vector2 = path.curve.sample_baked(_progress * path.curve.get_baked_length())
        _knob.position = baked_position

        if _cleared_targets == _qteData.numberOfExecutions:
            end_qte(true)
    pass

func _input(event: InputEvent):
    if event.is_action_pressed("act_interact"):
        _check_hit()

func end_qte(passed: bool):
    _isAutoMoving = false
    _isStarted = false
    set_process(false)
    onBroadcastResult.emit(passed)

func _spawn_targets(numberOfExecutions: int):
    var spawned_count = 0
    for pos in predefinedPositions:
        if spawned_count >= numberOfExecutions:
            break
        var target: Control = targetScene.instantiate() as Control
        var curve: Curve2D = path.curve
        var length: float = curve.get_baked_length()
        var baked_position: Vector2 = curve.sample_baked(pos * length)

        target.position = baked_position
        target.set_meta("progress", pos)
        target.modulate = target_default_color
        add_child(target)
        _targets.append({"instance": target, "remaining_taps": _qteData.numberOfExecutions})
        spawned_count += 1

func _check_hit():
    if _cleared_targets >= _qteData.numberOfExecutions:
        return

    for target_dict in _targets:
        var target = target_dict["instance"]
        var target_progress: float = target.get_meta("progress")

        if abs(_progress - target_progress) < targetRadius:
            _cleared_targets += 1
            _targets.erase(target_dict)
            target.modulate = target_clear_color
            target.queue_free()
            _executions[_cleared_targets - 1] = true

    if _cleared_targets == _qteData.numberOfExecutions:
        print("All targets cleared. Ending QTE.")
        end_qte(true)

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

    var points: PackedVector2Array = newCurve.get_baked_points()
    var pointSize: int = points.size()
    for i in pointSize:
        var point: Vector2 = points[i]
        line.add_point(point)
        border.add_point(point)

    var stepper: float = knobSize + 10.0

    while stepper < 120.0:
        stepper += 1.0

    path.curve = newCurve
    _reposition()
    pass

func _reposition():
    var curve = path.curve
    end.position = curve.get_point_position(curve.point_count - 1) - end.get_rect().size * 0.5
    if get_parent_control():
        position = get_parent_control().size * 0.5
    pass
