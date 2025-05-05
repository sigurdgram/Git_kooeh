extends AspectRatioContainer
class_name QTEBar_WishingTree

const L1Limits: String = "l1Limits"
const L2Limits: String = "l2Limits"

@export var _zonesTextureRect: TextureRect
@export var _pointerTextureRect: TextureRect
@export var _qteLeft: AudioStream
@export var _qteRight: AudioStream

var _moveSpeedPointer: float = 0.05

var _l1Params: Vector2
var _l2Params: Vector2

var _l1Spread: float = 0.15
var _l1Deviation: float = 0.1

var _l2Spread: float = 0.1
var _l2Deviation: float = 0.1

var _moveSpeedRange: Vector2 = Vector2(0.1, 0.5)
var _moveSpeedL1: float
var _moveSpeedL2: float

signal onBroadcastResult(tapSuccess: int)


func setup(_startNow: bool = false):
    var rng: = RandomNumberGenerator.new()
    var a: float = rng.randf()
    var ba: float = 0
    var bb: float = 0

    while _l2Params.y - _l2Params.x < 0.05:
        ba = clamp(rng.randfn(max(a - _l2Spread, 0.0), _l2Deviation), 0.0, 1.0)
        bb = clamp(rng.randfn(min(a + _l2Spread, 1.0), _l2Deviation), 0.0, 1.0)

        _l2Params.x = min(a, ba, bb)
        _l2Params.y = max(a, ba, bb)

    ba = clamp(rng.randfn(max(_l2Params.x - _l1Spread, 0.0), _l1Deviation), 0.0, 1.0)
    bb = clamp(rng.randfn(min(_l2Params.y + _l1Spread, 1.0), _l1Deviation), 0.0, 1.0)

    _l1Params.x = min(_l2Params.x, ba)
    _l1Params.y = max(_l2Params.y, bb)

    var zoneMat: Material = _zonesTextureRect.material
    zoneMat.set_shader_parameter(L1Limits, Vector2(_l1Params.x, _l1Params.y))
    zoneMat.set_shader_parameter(L2Limits, Vector2(_l2Params.x, _l2Params.y))

    _moveSpeedL1 = rng.randf_range(_moveSpeedRange.x, _moveSpeedRange.y)
    _moveSpeedL2 = rng.randf_range(_moveSpeedRange.x, _moveSpeedRange.y)
    pass

func _ready():
    if Engine.is_editor_hint():
        return

    set_process(false)
    pass

func start():
    set_process(true)
    pass

func stop():
    set_process(false)
    pass

func _calculate_zone_movement(delta: float, params: Vector2, moveSpeed: float) -> Array:
    if params.x < 0 or params.y > 1.0:
        moveSpeed *= -1

        if params.y > 1.0:
            var overshoot: float = params.y - 1.0
            params.x -= overshoot
            params.y = 1.0
        elif params.x < 0.0:
            var overshoot: float = abs(params.x)
            params.x = 0.0
            params.y += overshoot

    params.x += delta * moveSpeed
    params.y += delta * moveSpeed
    return [params, moveSpeed]

func _move_pointer(delta: float):
    var track = _zonesTextureRect.get_rect()
    var ycenter = track.get_center().x
    var halfSize = track.size.x * 0.5
    var a: float = ycenter - halfSize - (_pointerTextureRect.size.x * 0.5)
    var b: float = a + track.size.x

    var c = _pointerTextureRect.position.x + (lerp(a, b, delta) * _moveSpeedPointer)
    if c > b or c < a:
        AudioSystem.play_sfx(_qteRight if _moveSpeedPointer > 0.0 else _qteLeft)
        _moveSpeedPointer *= -1.0
        if c > b:
            _pointerTextureRect.position.x = b
        elif c < a:
            _pointerTextureRect.position.x = a
    else:
        _pointerTextureRect.position.x = c
    pass

func _process(delta: float):
    if Engine.is_editor_hint():
        return

    var ret = _calculate_zone_movement(delta, _l1Params, _moveSpeedL1)
    _l1Params = ret[0]
    _moveSpeedL1 = ret[1]

    ret = _calculate_zone_movement(delta, _l2Params, _moveSpeedL2)
    _l2Params = ret[0]
    _moveSpeedL2 = ret[1]

    var zoneMat: Material = _zonesTextureRect.material
    zoneMat.set_shader_parameter(L1Limits, Vector2(_l1Params.x, _l1Params.y))
    zoneMat.set_shader_parameter(L2Limits, Vector2(_l2Params.x, _l2Params.y))

    _move_pointer(delta)
    pass

func _input(event):
    if not is_processing():
        return

    if event.is_action_pressed("act_interact"):
        onBroadcastResult.emit(_tap())
    pass

func _tap() -> int:
    var track = _zonesTextureRect.get_rect()
    var ycenter = track.get_center().x
    var halfSize = track.size.x * 0.5
    var a: float = ycenter - halfSize - (_pointerTextureRect.size.x * 0.5)
    var b: float = a + track.size.x
    var normalizedPos: float = inverse_lerp(a, b, _pointerTextureRect.position.x)

    var tolerance: float = 0.01

    if _is_within_range(normalizedPos, _l2Params):
        return 2
    elif _is_within_range(normalizedPos, _l1Params):
        if normalizedPos >= (_l2Params.x - tolerance) and normalizedPos <= (_l2Params.y + tolerance):
            return 2
        return 1
    return 0

func _is_within_range(value: float, constraints: Vector2) -> bool:
    return value >= constraints.x and value <= constraints.y
