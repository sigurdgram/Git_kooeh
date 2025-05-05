
class_name DMTreeLine extends RefCounted



var line_number: int = 0



var parent: WeakRef

var id: String

var type: String = ""

var is_random: bool = false

var indent: int = 0

var text: String = ""

var children: Array[DMTreeLine] = []

var notes: String = ""


func _init(initial_id: String) -> void :
    id = initial_id


func _to_string() -> String:
    var tabs = []
    tabs.resize(indent)
    tabs.fill("	")
    tabs = "".join(tabs)

    return tabs.join([tabs + "{\n", 
        "	id: %s\n" % [id], 
        "	type: %s\n" % [type], 
        "	is_random: %s\n" % ["true" if is_random else "false"], 
        "	text: %s\n" % [text], 
        "	notes: %s\n" % [notes], 
        "	children: []\n" if children.size() == 0 else "	children: [\n" + ",\n".join(children.map(func(child): return str(child))) + "]\n", 
    "}"])
