extends Node2D
class_name Seat

var _chairs: Array[Buildable_Chair]
var _table: Buildable_Table


var _spawnedFood: Array


func _process(_delta):
    if not is_instance_valid(_table):
        queue_free()

func get_spawned_food() -> Array:
    return _spawnedFood








func is_full() -> bool:
    for chair in _chairs:
        if not chair.get_is_occupied():
            return false
            break
    return true

func get_chairs() -> Array[Buildable_Chair]:
    var clean_array: Array[Buildable_Chair] = []
    for chair in _chairs:
        if is_instance_valid(chair):
            clean_array.append(chair)
    _chairs = clean_array
    return _chairs

func set_chair() -> Buildable_Chair:
    for chair in _chairs:
        if not chair.get_is_occupied():
            chair.set_is_occupied(true)
            return chair
    return null

func get_table() -> Buildable_Table:
    return _table

func use(customer: Customer):
    var foods: Dictionary = customer.release_food()
    var total: int = foods.values().reduce(func sum_food(accum, number): return accum + number, 0)
    var chair = customer.get_blackboard()["Chair"]
    var pos: Array = _table.get_food_arrangement(total, chair.global_position)
    pos.shuffle()

    for i in foods:
        var food: = Food.new(i)
        _spawnedFood.push_back(food)
        _table.add_child(food)
        food.global_position = pos.pop_back()
    pass

func add_chair(chr: Buildable_Chair):
    _chairs.push_back(chr)

func add_table(tbl: Buildable_Table):
    _table = tbl
