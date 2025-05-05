extends Control
class_name QTEBar_Radial_TapInRange

const SectorLimits: String = "sectorLimits"
const Progress: String = "progress"
const ProcessMode_: String = "processMode"

@export_range(0.0, 1.0)
var _progress: float = 1.0:
    set(value):
        _progress = value
        _qteTexture.material.set_shader_parameter(Progress, _progress)
        _knob.rotation_degrees = lerpf(0.0, 360.0, _progress)

@export var _qteTexture: TextureRect
@export var _knob: Control
@export var _qteLeft: AudioStream
@export var _qteRight: AudioStream

var _tapZones: Array[Vector2]
var _interval: float
var _processMode: Utils.QTEProcessMode
var _tickDirection: float = 1.0
var _tapCount: int = -1
var _currentTapZoneIndex: int = -1

signal onTimeOut
signal onBroadcastResult(passed: bool)


func _ready():
    set_process(false)
    pass

func setup(qteData: QTEData_Radial, startNow: bool):
    if qteData.zones.size() > 4:
        push_error("%s only support up to 4 tap zones" % self)
        return

    for i in qteData.zones:
        _tapZones.append(i)

    _qteTexture.material.set_shader_parameter(SectorLimits, _tapZones)

    var shaderProcessMode: int = 0
    if qteData.processMode == Utils.QTEProcessMode.PINGPONG:
        shaderProcessMode = 1

    _qteTexture.material.set_shader_parameter(ProcessMode_, shaderProcessMode)

    _interval = qteData.interval
    _processMode = qteData.processMode
    _progress = 0.0
    set_process(startNow)
    pass

func start_QTE():
    if is_processing():
        return

    if _interval == 0.0:
        push_error("Timer wait_time is 0.0")
        return

    set_process(true)
    pass

func tap():
    if _currentTapZoneIndex == -1:
        onBroadcastResult.emit(false)
        return

    _tapCount += 1

    if _tapCount == 0:
        onBroadcastResult.emit(true)
    elif _tapCount > 0:
        onBroadcastResult.emit(false)
    pass

func _process(delta):
    match _processMode:
        Utils.QTEProcessMode.ONESHOT:
            _progress += delta / _interval
            _process_tap_zones()
            if _progress >= 1.0:
                onTimeOut.emit()
                set_process(false)
        Utils.QTEProcessMode.PINGPONG:
            _progress += (delta / _interval) * _tickDirection
            _process_tap_zones()
            if _progress >= 1.0 || _progress <= 0.0:
                AudioSystem.play_sfx(_qteRight if _tickDirection > 0.0 else _qteLeft)
                _tickDirection *= -1.0
    _progress = clampf(_progress, 0.0, 1.0)

func _process_tap_zones():
    if _tapZones.size() == 0:
        push_error("TapZones count is 0")
        return

    var currentLimit = lerp(0.0, 360.0, _progress)
    var currentZoneIndex = _get_current_tap_zone_index(currentLimit)
    var isTransitioning = currentZoneIndex != _currentTapZoneIndex

    if isTransitioning:
        var lowerLimit = _tapZones[max(_currentTapZoneIndex, currentZoneIndex)].x
        var upperLimit = _tapZones[max(_currentTapZoneIndex, currentZoneIndex)].y

        if _tickDirection == 1.0:
            if currentLimit >= lowerLimit and currentLimit < upperLimit:
                _tapCount = -1

            if currentLimit >= upperLimit and _processMode == Utils.QTEProcessMode.ONESHOT:
                if _tapCount == -1:
                    onBroadcastResult.emit(false)
                _tapCount = -1
        else:
            if currentLimit <= upperLimit and currentLimit > lowerLimit:
                _tapCount = -1

            if currentLimit <= lowerLimit and _processMode == Utils.QTEProcessMode.ONESHOT:
                if _tapCount == -1:
                    onBroadcastResult.emit(false)
                _tapCount = -1

    _currentTapZoneIndex = currentZoneIndex
    pass

func _get_current_tap_zone_index(currentLimit: float) -> int:
    var currentIndex: int = -1
    var zoneIndex: int = 0
    for zone in _tapZones:
        var lowerLimit = zone.x
        var upperLimit = zone.y

        if currentLimit >= lowerLimit && currentLimit <= upperLimit:
            currentIndex = zoneIndex
            break
        else:
            currentIndex = -1

        zoneIndex += 1

    return currentIndex

func _on_knob_control_resized():
    _knob.pivot_offset = _knob.size * 0.5
    pass
