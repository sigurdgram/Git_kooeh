class_name OrderData

var order: Dictionary = {}
var orderFiller: CustomerData

func _init(o: Dictionary, f: CustomerData):
    order = o
    orderFiller = f
    pass
