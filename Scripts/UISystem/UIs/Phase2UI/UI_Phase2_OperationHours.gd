extends Control
class_name UI_Phase2_OperationHours

@export var _dayTxt: Label
@export var _handleControl: Control
@export var _animOvertime: AnimationPlayer

var _timeSystem: TimeSystem
const Log2: float = log(2)
var _startTime: float
var _endTime: float


func _ready():
    _timeSystem = GameInstance.gameWorld.timeSystem
    _timeSystem.onStart.connect(_on_time_start)
    _timeSystem.onTick.connect(_on_time_tick)
    _timeSystem.onEnd.connect(_on_time_end)
    pass

func _on_time_start(day: KooehConstant.Day, unixTime: int):
    @warning_ignore("narrowing_conversion")
    var dayIndex: int = log(day) / Log2
    _dayTxt.text = KooehConstant.AllDays[dayIndex]
    _startTime = float(unixTime)
    _endTime = float(_timeSystem.get_ending_hours_unix_time())

    _on_time_tick(unixTime)
    pass

func _on_time_tick(unixTime: int):
    var lerpTime: float = inverse_lerp(_startTime, _endTime, float(unixTime))
    var lerpAngle: float = lerp(0.0, 282.0, lerpTime)
    _handleControl.rotation_degrees = lerpAngle
    pass

func _on_time_end():
    var customerSpawner: CustomerSpawner = GameInstance.gameWorld.customerSpawner
    if customerSpawner.get_customer_count() > 0:
        _animOvertime.play("Anim_Overtime")
    pass
