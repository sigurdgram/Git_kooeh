extends State
class_name State_FindSeatAndSit

func enter():
    var seats: Array = get_tree().get_nodes_in_group("Buildable.Seat")

    var selectedSeat: Buildable_Seat = null
    for i in seats:
        if not i.is_full():
            selectedSeat = i

    if not is_instance_valid(selectedSeat):
        _runner.move_to(self, "State_Leave")
        return

    _blackboard["Seat"] = selectedSeat
    var selectedChair: Buildable_Attachment_Seat = selectedSeat.get_available_chair()
    selectedChair.occupied = true
    _blackboard["Chair"] = selectedChair

    var owningActor: CharacterBase = _owner as CharacterBase
    owningActor.navigate_to(selectedChair.global_position)
    pass

func update(_delta: float):
    if _owner.is_navigation_finished():
        _runner.move_to(self, "State_Eat")
    pass
