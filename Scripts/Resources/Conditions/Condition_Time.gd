extends Condition_Base
class_name Condition_Time

@export var fromTime: String = "00:00:00"
@export var toTime: String = "00:00:00"

func query(variables: Dictionary) -> int:
    var retVal: bool = false
    var currentTime: int = variables[KooehConstant.timeVarName]
    var fromTimeInt: int = Time.get_unix_time_from_datetime_string(fromTime)
    var toTimeInt: int = Time.get_unix_time_from_datetime_string(toTime)

    if fromTimeInt == toTimeInt:
        retVal = currentTime == fromTimeInt
    else:
        var deltaA: int = toTimeInt - currentTime
        var deltaB: int = currentTime - fromTimeInt

        retVal = deltaA >= 0 && deltaB >= 0
    return retVal
