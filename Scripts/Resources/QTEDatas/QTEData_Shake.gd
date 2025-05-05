extends QTEData_Base
class_name QTEData_Shake

@export var distance: float
@export var timecount: float
var qteHint: String = "[center]Move [input white]ui_shake[/input] to progress[/center]"

func describe() -> String:
    return "QTEBar_Shake"

func get_execution_limit() -> int:
    return 1
