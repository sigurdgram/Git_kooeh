extends Node
class_name OnlineSubsystem

const OnlineSubsystem: StringName = &"OnlineSubsystem"

func initialize() -> bool:
    return true

func get_achievement(id: String) -> Dictionary:
    return Dictionary()

func set_achievement(id: String) -> void :
    pass

func set_stat_int(key: String, count: int) -> void :
    pass
