extends Node

var currency: float



func get_currency() -> float:
    return GameplayVariables.get_var(KooehConstant.moneyVarName)
