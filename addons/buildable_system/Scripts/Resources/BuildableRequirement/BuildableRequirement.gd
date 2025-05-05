extends Resource
class_name BuildableRequirement

func init(buildableSystem: BuildableSystem, data: BuildableData) -> void :
    pass

func is_pass(buildableSystem: BuildableSystem, data: BuildableData) -> String:
    return ""

func get_check_time() -> BuildableTypes.ECheckTime:
    return BuildableTypes.ECheckTime.OnBuild
