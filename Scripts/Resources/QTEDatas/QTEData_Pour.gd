@tool
extends QTEData_Base
class_name QTEData_Pour

@export var referenceCurve: Curve2D
@export var scale: float
@export var difficulty: KooehConstant.Difficulty = KooehConstant.Difficulty.Easy:
    set(value):
        difficulty = value
        match difficulty:
            KooehConstant.Difficulty.Easy:
                qteHitCount = 3
                qteSpeed = 0.4
                pass
            KooehConstant.Difficulty.Normal:
                qteHitCount = 4
                qteSpeed = 0.4
                pass
            KooehConstant.Difficulty.Hard:
                qteHitCount = 5
                qteSpeed = 0.5
                pass
        pass

var qteHint: String = "[center]Press [input white]act_interact[/input] when the ring hits the circle.[/center]"
var qteHitCount: int
var qteSpeed: float



func _init() -> void :
    difficulty = KooehConstant.Difficulty.Easy
    pass

func describe() -> String:
    return "QTEBar_Pour: %s" % referenceCurve.resource_name

func get_execution_limit() -> int:
    return qteHitCount

func _get_property_list():
    return [
    {
        "name": "qteHitCount", 
        "type": TYPE_INT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }, 
    {
        "name": "qteSpeed", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }]

func _get(property: StringName):
    match property:
        "qteHitCount": return qteHitCount
        "qteSpeed": return qteSpeed
    pass

func _set(property, value):
    match property:
        "qteHitCount": qteHitCount = value
        "qteSpeed": qteSpeed = value
    pass
