extends QTEData_Base
class_name QTEData_Radial

@export var zones: Array[Vector2]
@export var interval: float
@export var processMode: Utils.QTEProcessMode
var qteHint: String = "[center]Press [input white]act_interact[/input] at the orange band to progress[/center]"

func describe() -> String:
    return "QTEBar_Hori: Zones: %s Interval: %s" % [zones, interval]

func get_execution_limit() -> int:
    return zones.size()
