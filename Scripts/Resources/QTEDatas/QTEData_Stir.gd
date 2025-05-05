@tool
extends QTEData_Base
class_name QTEData_Stir

@export var difficulty: KooehConstant.Difficulty = KooehConstant.Difficulty.Easy:
    set(value):
        difficulty = value
        match difficulty:
            KooehConstant.Difficulty.Easy:
                numberOfExecutions = 3
                speed = 100.0
            KooehConstant.Difficulty.Normal:
                numberOfExecutions = 4
                speed = 150.0
            KooehConstant.Difficulty.Hard:
                numberOfExecutions = 5
                speed = 175.0
        pass

var speed: float = 50.0
var numberOfExecutions: int
var qteHint: String = "[center]Press [input white]act_interact[/input] when the ring hits the circle.[/center]"


func _init():
    difficulty = KooehConstant.Difficulty.Easy
    pass

func get_execution_limit() -> int:
    return numberOfExecutions

func describe() -> String:
    return "QTEBar_Stir"

func _get_property_list():
    return [
    {
        "name": "numberOfExecutions", 
        "type": TYPE_INT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }, 
    {
        "name": "speed", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
    }]

func _get(property: StringName):
    if property == "numberOfExecutions":
        return numberOfExecutions

func _set(property: StringName, value: Variant):
    if property == "numberOfExecutions":
        numberOfExecutions = value
    pass
