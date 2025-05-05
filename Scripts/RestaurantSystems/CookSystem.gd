extends Node
class_name CookSystem

var cookTimers: Array[CookTimer]



func cook(foodWeakRef: WeakRef) -> WeakRef:
    var timer: = CookTimer.new(self, foodWeakRef)
    timer.onCookTimeUp.connect(_on_cook_time_up.bind(foodWeakRef.get_ref().resource_name))
    add_child(timer)
    return weakref(timer)

func _on_cook_time_up(foodID: String) -> void :
    GameplayVariables.add_cooked_food(foodID)
    pass
