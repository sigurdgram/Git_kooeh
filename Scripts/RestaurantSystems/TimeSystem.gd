extends Node
class_name TimeSystem





@export var _endingUnixTime: int
var _startingUnixTime: int
var _day: KooehConstant.Day
var _unixTime: int = 0
var _timer: Timer

const SecondsPerDay: int = 86400
const Log2: float = log(2)
signal onStart(day: KooehConstant.Day, unixTime: int)
signal onTick(_unixTime)
signal onEnd()



func _ready():
    _timer = Timer.new()
    _timer.timeout.connect(_tick)
    add_child(_timer)
    pass

func start():



    _day = GameplayVariables.get_var(KooehConstant.dayVarName)
    _unixTime = _startingUnixTime
    _timer.start(1.0)
    onStart.emit(_day, _unixTime)
    pass

func stop():
    _timer.stop()
    onEnd.emit()
    pass

func _tick():
    _unixTime = (_unixTime + 1) % SecondsPerDay
    onTick.emit(_unixTime)

    if _unixTime == _endingUnixTime:
        stop()
    pass

func get_day() -> KooehConstant.Day:
    return _day

func get_unix_time() -> int:
    return _unixTime

func get_starting_hours_unix_time() -> int:
    return _startingUnixTime

func get_ending_hours_unix_time() -> int:
    return _endingUnixTime
