extends BuildableRestrictions_Base
class_name BuildableRestrictions_SeatCount

@export var _minSeats: int
@export var _maxSeats: int

func check(_buildable: BuildableData) -> bool:
    var count: int = 0
    var totalSeats = GameInstance.gameWorld.seatingSystem.get_children()

    for seat in totalSeats:
        for chair in seat._chairs:
            count += 1

    if count > _maxSeats or count < _minSeats:
        return false
    else:
        return true
