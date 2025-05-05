
class_name DialogueResponse extends RefCounted



var id: String


var type: String = DMConstants.TYPE_RESPONSE


var next_id: String = ""


var is_allowed: bool = true


var character: String = ""


var character_replacements: Array[Dictionary] = []


var text: String = ""


var text_replacements: Array[Dictionary] = []


var tags: PackedStringArray = []


var translation_key: String = ""


func _init(data: Dictionary = {}) -> void :
    if data.size() > 0:
        id = data.id
        type = data.type
        next_id = data.next_id
        is_allowed = data.is_allowed
        character = data.character
        character_replacements = data.character_replacements
        text = data.text
        text_replacements = data.text_replacements
        tags = data.tags
        translation_key = data.translation_key


func _to_string() -> String:
    return "<DialogueResponse text=\"%s\">" % text


func get_tag_value(tag_name: String) -> String:
    var wrapped: = "%s=" % tag_name
    for t in tags:
        if t.begins_with(wrapped):
            return t.replace(wrapped, "").strip_edges()
    return ""
