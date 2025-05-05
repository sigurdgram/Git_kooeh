extends Control
class_name QTEBar_Steam

const SectorLimits: String = "sectorLimits"
const Progress: String = "progress"
const ProcessMode_: String = "processMode"

@export var _qteTexture: TextureRect
@export var _pointerTexture: TextureRect
@export var _progressBar: TextureProgressBar
@export_group("Audio")
@export var _passAudio: AudioStream

var _progress: float = 0.0:
    set(value):
        _progress = value
        _qteTexture.material.set_shader_parameter(Progress, _progress)

var _currentTapZone: Vector2
var _tapZones: Array[Vector2]
var _speed: float
var _holdDuration: float
var _barLengthMultiplier: float

signal onTimeOut
signal onBroadcastResult(passed: bool)

func _ready() -> void :
    _qteTexture.material.set_shader_parameter(ProcessMode_, 0)
    set_physics_process(false)
    set_process_input(false)
    await get_tree().process_frame
    _move_pointer(_progress)
    pass

func setup(qteData: QTEData_Steam, startNow: bool) -> void :
    _speed = qteData.speed
    _holdDuration = qteData.holdDuration
    _barLengthMultiplier = qteData.barLengthMultiplier

    var barLength: float = qteData.StandardBarLength * _barLengthMultiplier
    for i in 2:
        var anchor: float = 0.5 if i == 0 else 0.75
        var vector: = Vector2(anchor - barLength, anchor + barLength)
        _tapZones.append(vector)

    if startNow:
        start_QTE()
    pass

func start_QTE():
    _currentTapZone = _tapZones.pop_front()
    _set_tap_zones_in_shader()
    set_process_input(true)
    set_physics_process(true)
    pass

func _physics_process(delta: float) -> void :
    var direction: float = 1 if Input.is_action_pressed("act_interact") else -1
    _progress = clampf(_progress + _speed * direction * delta, 0.0, 1.0)
    _move_pointer(_progress)

    if not _is_in_tap_zones(_progress):
        return

    _progressBar.value = clampf(_progressBar.value + delta / _holdDuration, 0.0, 1.0)

    if _progressBar.ratio >= 1.0:
        _next()
    pass

func _set_tap_zones_in_shader():
    var tapZones: = Array([_currentTapZone], TYPE_VECTOR2, "", null)
    _qteTexture.material.set_shader_parameter(SectorLimits, tapZones)
    var parentSizeX: float = _progressBar.get_parent_area_size().x

    var barLength: float = parentSizeX * QTEData_Steam.StandardBarLength * _barLengthMultiplier
    _progressBar.position.x = parentSizeX * _currentTapZone.x - (_progressBar.size.x * 0.5) + barLength
    pass

func _move_pointer(delta: float):
    var track = _qteTexture.get_rect()
    var trackX = track.size.x
    _pointerTexture.position.x = lerp(0.0, trackX, delta) - _pointerTexture.size.x
    pass

func _next():
    set_physics_process(false)

    onBroadcastResult.emit(true)
    AudioSystem.play_sfx(_passAudio)

    if _tapZones.is_empty():
        return

    var tween: Tween = create_tween()
    await tween.tween_interval(1).finished
    _progress = 0.0
    _move_pointer(_progress)
    _progressBar.value = _progress

    _currentTapZone = _tapZones.pop_front()
    _set_tap_zones_in_shader()
    set_physics_process(true)
    pass

func _is_in_tap_zones(currentPos: float) -> bool:
    var lowerLimit: float = _currentTapZone.x
    var upperLimit: float = _currentTapZone.y

    return currentPos >= lowerLimit && currentPos <= upperLimit
