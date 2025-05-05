extends Condition_Base
class_name Condition_Day

@export var fromDay: KooehConstant.Day
@export var toDay: KooehConstant.Day

func query(variables: Dictionary) -> int:
    var retVal: bool = false
    var todayDay: KooehConstant.Day = variables[KooehConstant.dayVarName]

    if fromDay == toDay:
        retVal = todayDay == fromDay;
    else:
        var deltaA: int = toDay - todayDay
        var deltaB: int = todayDay - fromDay

        retVal = deltaA >= 0 && deltaB >= 0

    return retVal
