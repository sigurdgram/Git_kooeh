extends Node
class_name SeatingSystem



func find_available_seat() -> Seat:
    var emptySeats: Array = get_children().filter(func select_not_full(x): return not x.is_full())
    if not emptySeats.is_empty():
        return emptySeats.pick_random()
    return null

func find_available_chair(seat: Seat) -> Buildable_Chair:
    return seat.set_chair()

func book_seat(seat: Seat):
    seat.set_occupied(true)
    pass

func unbook_seat(seat: Node2D):
    seat.set_occupied(false)
    pass
