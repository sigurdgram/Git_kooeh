extends Control
class_name QTEBar_HoldToRange

const SectorLimits: String = "sectorLimits"
const TapZoneColor: String = "tapZoneColor"
const Progress: String = "progress"
const ProcessMode_: String = "processMode"

@export var _qteTexture: TextureRect
@export var _pointerTexture: TextureRect
@export var tapZoneColor: Color

@export_range(0.0, 1.0)
var _progress: float = 1.0:
    set(value):
        _progress = value
        _qteTexture.material.set_shader_parameter(Progress, _progress)

var _tapZones: Array[Vector2]
var _tapRange: float = 0.01
var _interval: float = 0.1
var _elapsedTime: float = 0.0
signal onTimeOut
signal onBroadcastResult(passed: bool)



func _ready():
    set_process(false)
    set_process_input(false)
    _qteTexture.material.set_shader_parameter(TapZoneColor, tapZoneColor)
    await get_tree().process_frame
    _move_pointer(_progress)
    pass

func setup(qteData: QTEData_HoldToRange, startNow: bool):
    _tapRange = qteData.tapRange
    _interval = qteData.interval

    var rng: = RandomNumberGenerator.new()
    var point: float = rng.randf_range(0.0 + _tapRange, 1.0 - _tapRange)
    var point2: float = point + ((rng.randi() & 2) - 1) * _tapRange
    _tapZones.append(Vector2(min(point, point2), max(point, point2)))

    _qteTexture.material.set_shader_parameter(SectorLimits, _tapZones)
    _qteTexture.material.set_shader_parameter(ProcessMode_, 0)

    _progress = 0.0
    _elapsedTime = 0.0
    if startNow:
        ready.connect(start_QTE, CONNECT_ONE_SHOT)
    pass

func start_QTE():
    set_process_input(true)
    pass

func _input(event: InputEvent):
    if event.is_action_pressed("act_interact"):
        set_process(true)
        accept_event()
    elif event.is_action_released("act_interact"):
        set_process(false)
        onBroadcastResult.emit(_is_in_tap_zones(_progress))
        accept_event()
        set_process_input(false)
    pass

func _process(delta: float):
    _elapsedTime = _elapsedTime + delta
    _progress = min(Tween.interpolate_value(0.0, 1.0, _elapsedTime, 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN), 1.0)
    _move_pointer(_progress)
    pass

func _move_pointer(delta: float):
    var track = _qteTexture.get_rect()
    var trackX = track.size.x
    _pointerTexture.position.x = lerp(0.0, trackX, delta) - _pointerTexture.size.x
    pass

func _is_in_tap_zones(currentPos: float) -> bool:
    var lowerLimit: float = _tapZones[0].x
    var upperLimit: float = _tapZones[0].y

    return currentPos >= lowerLimit && currentPos <= upperLimit
