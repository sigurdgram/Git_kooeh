extends Control

@export var _label: Label



func _ready():
    _show_currency(EconomySystem.get_currency(), 0)
    GameplayVariables.onEconomyUpdate.connect(_show_currency)
    pass

func _show_currency(amount: float, _delta: float):
    _label.text = _comma_per_thousands(int(amount))
    pass

func _comma_per_thousands(number: int) -> String:
    var numString: String = str(number)
    var retVal: String = ""

    var mod = numString.length() % 3
    for i in range(0, numString.length()):
        if i != 0 && i % 3 == mod:
            retVal += ","
        retVal += numString[i]

    return retVal
