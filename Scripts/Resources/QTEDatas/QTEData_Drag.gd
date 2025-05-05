extends QTEData_Base
class_name QTEData_Drag

@export var difficulty: KooehConstant.Difficulty = KooehConstant.Difficulty.Easy:
    set(value):
        difficulty = value
        match difficulty:
            KooehConstant.Difficulty.Easy:
                numberOfExecutions = 3
            KooehConstant.Difficulty.Normal:
                numberOfExecutions = 4
            KooehConstant.Difficulty.Hard:
                numberOfExecutions = 5
        pass

@export var referenceCurve: Curve2D
@export var scale: float
@export var rotation_degrees: float
@export var qteHint: String

var numberOfExecutions: int

func describe() -> String:
    return "QTEBar_Drag: %s" % referenceCurve.resource_name

func _get_property_list():
    return [
    {
        "name": "numberOfExecutions", 
        "type": TYPE_INT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }]

func _get(property: StringName):
    if property == "numberOfExecutions":
        return numberOfExecutions

func get_execution_limit() -> int:
    return numberOfExecutions
