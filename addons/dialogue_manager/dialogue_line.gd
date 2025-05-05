
class_name DialogueLine extends RefCounted



var id: String


var type: String = DMConstants.TYPE_DIALOGUE


var next_id: String = ""


var character: String = ""


var character_replacements: Array[Dictionary] = []


var text: String = ""


var text_replacements: Array[Dictionary] = []


var translation_key: String = ""


var pauses: Dictionary = {}


var speeds: Dictionary = {}


var inline_mutations: Array[Array] = []


var responses: Array = []


var concurrent_lines: Array[DialogueLine] = []


var extra_game_states: Array = []


var time: String = ""


var tags: PackedStringArray = []


var mutation: Dictionary = {}


var conditions: Dictionary = {}


func _init(data: Dictionary = {}) -> void :
    if data.size() > 0:
        id = data.id
        next_id = data.next_id
        type = data.type
        extra_game_states = data.get("extra_game_states", [])

        match type:
            DMConstants.TYPE_DIALOGUE:
                character = data.character
                character_replacements = data.get("character_replacements", [] as Array[Dictionary])
                text = data.text
                text_replacements = data.get("text_replacements", [] as Array[Dictionary])
                translation_key = data.get("translation_key", data.text)
                pauses = data.get("pauses", {})
                speeds = data.get("speeds", {})
                inline_mutations = data.get("inline_mutations", [] as Array[Array])
                time = data.get("time", "")
                tags = data.get("tags", [])
                concurrent_lines = data.get("concurrent_lines", [] as Array[DialogueLine])

            DMConstants.TYPE_MUTATION:
                mutation = data.mutation


func _to_string() -> String:
    match type:
        DMConstants.TYPE_DIALOGUE:
            return "<DialogueLine character=\"%s\" text=\"%s\">" % [character, text]
        DMConstants.TYPE_MUTATION:
            return "<DialogueLine mutation>"
    return ""


func get_tag_value(tag_name: String) -> String:
    var wrapped: = "%s=" % tag_name
    for t in tags:
        if t.begins_with(wrapped):
            return t.replace(wrapped, "").strip_edges()
    return ""
