extends BuildableRestrictions_Base
class_name BuildableRestrictions_Minimum

@export var _minAmount: int

func check(_buildable: BuildableData) -> bool:
    var count: int = 0
    if not GameplayVariables.placedResources.is_empty():
        for value in GameplayVariables.placedResources[_buildable.layer].values():
            if value == _buildable:
                count += 1

    if count < _minAmount:
        return false
    else:
        return true
