extends Resource
class_name BuildableRestrictions_Base

@export var restrictionMessage: String

func check(_buildable: BuildableData) -> bool:
    return false

func show_restriction_message() -> String:
    return restrictionMessage
