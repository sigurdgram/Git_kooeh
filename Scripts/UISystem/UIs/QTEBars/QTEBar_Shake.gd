extends Control
class_name QTEBar_Shake

@export var _axisSensitivity: float = 4200.0
@export var _bottleContainer: AspectRatioContainer
@export var _percentageLabel: Label

var _originalPosition: Vector2
var _targetPosition: Vector2

var _timeCount: float
var _time: float = 0.0
var _distance: float
var _score = 0.0
var _movementTimer = 0

var _isButtonInput: bool = false
var _isStarted: bool = true

signal onBroadcastResult(success: bool)



func _ready():
    _time = 0
    set_process_input(true)
    pass

func setup(qteData: QTEData_Shake, startNow: bool = true):
    _distance = qteData.distance
    _timeCount = qteData.timecount
    _isStarted = startNow
    pass

func start_QTE():
    _targetPosition = get_rect().get_center() - _bottleContainer.size * 0.5
    _originalPosition = _targetPosition
    _bottleContainer.position = _originalPosition
    _isStarted = true
    pass

func _shakeMovement():
    var currentPosition = _bottleContainer.position
    var movement = _originalPosition - currentPosition
    var length = movement.length()
    if length > _distance || length < - (_distance):
        if _movementTimer <= _timeCount:
            _originalPosition = currentPosition
            _increaseProgress()
        _movementTimer = 0
        _originalPosition = currentPosition
    pass

func _increaseProgress():
    _score += 1
    _score = min(_score, 100)
    _percentageLabel.text = str(_score) + "%"
    if _score == 100:
        _percentageLabel.text = "Task Complete"
    pass

func _scoreRecord():
    if _time > 10:
        onBroadcastResult.emit(false)
    pass

func _input(event: InputEvent):
    match event.get_class():
        "InputEventMouseButton", "InputEventMouseMotion":
            _isButtonInput = false
            _mouseInput()
        "InputEventJoypadMotion":
            _isButtonInput = false
            _axisInput(get_process_delta_time())
    pass

func _process(delta):
    if _score < 100:
        _time += delta
        _movementTimer += delta
        _shakeMovement()
        _bottleContainer.position = lerp(_bottleContainer.position, _targetPosition, 0.1)
    else:
        _scoreRecord()
        onBroadcastResult.emit(true)

    if _isButtonInput:
        _axisInput(delta)
    pass

func _mouseInput():
    var mouse_position = get_viewport().get_mouse_position()
    var halfSize = _bottleContainer.size * 0.5
    var tempPos = get_parent_control().make_canvas_position_local(mouse_position) - halfSize
    _targetPosition = _clamp_target_position(tempPos)
    pass

func _axisInput(delta: float):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", InputManager.get_gamepad_deadzone())
    var tempPos = _targetPosition + (direction * _axisSensitivity * delta)
    _targetPosition = _clamp_target_position(tempPos)
    pass

func _clamp_target_position(targetPosition: Vector2) -> Vector2:
    var halfSize = _bottleContainer.size * 0.5

    var r: Rect2 = get_rect()
    var rStart: Vector2 = r.position
    var rEnd: Vector2 = r.end

    return targetPosition.clamp(rStart - halfSize, rEnd - halfSize)
