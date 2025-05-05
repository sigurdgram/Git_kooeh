extends BuildableRestrictions_Base
class_name BuildableRestrictions_Maximum

@export var _maxAmount: int

func check(_buildable: BuildableData) -> bool:
    var count: int = 0
    if not GameplayVariables.placedResources.is_empty():
        for value in GameplayVariables.placedResources[_buildable.layer].values():
            if value == _buildable:
                count += 1

    if count > _maxAmount:
        return false
    else:
        return true
