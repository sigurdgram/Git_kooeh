@tool
extends QTEData_Base
class_name QTEData_Steam

const StandardBarLength: float = 0.1

@export var difficulty: KooehConstant.Difficulty = KooehConstant.Difficulty.Easy:
    set(value):
        difficulty = value
        match difficulty:
            KooehConstant.Difficulty.Easy:
                speed = 0.4
                barLengthMultiplier = 1.35
                pass
            KooehConstant.Difficulty.Normal:
                speed = 0.6
                barLengthMultiplier = 1.15
                pass
            KooehConstant.Difficulty.Hard:
                speed = 0.7
                barLengthMultiplier = 1.0
                pass
        pass

var holdDuration: float = 3.0
var speed: float
var barLengthMultiplier: float
var qteHint: String = "[center]Hold [input white]act_interact[/input] at orange band to progress[/center]"

func _init() -> void :
    difficulty = KooehConstant.Difficulty.Easy
    pass

func describe() -> String:
    return "QTEBar_Steam: speed=%s barLengthmultiplier=%s" % [speed, barLengthMultiplier]

func get_execution_limit() -> int:
    return 2

func _get_property_list():
    return [
    {
        "name": "speed", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }, 
    {
        "name": "barLengthMultiplier", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }, 
    {
        "name": "holdDuration", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }]

func _get(property: StringName):
    match property:
        "speed": return speed
        "barLengthMultiplier": return barLengthMultiplier
        "holdDuration": return holdDuration
    pass

func _set(property, value):
    match property:
        "speed": speed = value
        "barLengthMultiplier": barLengthMultiplier = value
        "holdDuration": holdDuration = value
    pass
