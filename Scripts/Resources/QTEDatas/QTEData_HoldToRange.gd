@tool
extends QTEData_Base
class_name QTEData_HoldToRange

@export var difficulty: KooehConstant.Difficulty = KooehConstant.Difficulty.Easy:
    set(value):
        difficulty = value
        match difficulty:
            KooehConstant.Difficulty.Easy:
                tapRange = 0.25
                interval = 1.5
            KooehConstant.Difficulty.Normal:
                tapRange = 0.15
                interval = 1.0
            KooehConstant.Difficulty.Hard:
                tapRange = 0.1
                interval = 0.8
        pass

var tapRange: float = 0.1
var interval: float = 1.0

var qteHint: String = "[center]Hold [input white]act_interact[/input] at blue band to progress[/center]"

func describe() -> String:
    return "QTEBar_HoldToRange: TapRange: %s Interval: %s" % [tapRange, interval]

func get_execution_limit() -> int:
    return 1

func _get_property_list():
    return [
    {
        "name": "tapRange", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }, 
    {
        "name": "interval", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }]

func _get(property: StringName):
    if property == "tapRange":
        return tapRange
    elif property == "interval":
        return interval

func _set(property, value):
    if property == "tapRange":
        tapRange = value
    elif property == "interval":
        interval = value
    pass
