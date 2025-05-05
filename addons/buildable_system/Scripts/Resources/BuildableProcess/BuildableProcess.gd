extends Resource
class_name BuildableProcess

@export var processMenu: PackedScene

var _buildableSystem: BuildableSystem

func setup(buildableSystem: BuildableSystem) -> void :
    _buildableSystem = buildableSystem
    pass

func get_process_name() -> String:
    return ""

func enter() -> void :
    pass

func exit() -> void :
    pass

func input(event: InputEvent) -> void :
    pass
