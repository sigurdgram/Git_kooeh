
class_name DMCompiledLine extends RefCounted



var id: String

var translation_key: String = ""

var type: String = ""

var character: String = ""

var character_replacements: Array[Dictionary] = []

var text: String = ""

var text_replacements: Array[Dictionary] = []

var responses: PackedStringArray = []

var siblings: Array[Dictionary] = []

var concurrent_lines: PackedStringArray = []

var tags: PackedStringArray = []

var expression: Dictionary = {}

var next_id: String = ""

var next_id_expression: Array[Dictionary] = []

var is_snippet: bool = false

var next_sibling_id: String = ""

var next_id_after: String = ""

var notes: String = ""





func _init(initial_id: String, initial_type: String) -> void :
    id = initial_id
    type = initial_type


func _to_string() -> String:
    var s: Array = [
        "[%s]" % [type], 
        "%s:" % [character] if character != "" else null, 
        text if text != "" else null, 
        expression if expression.size() > 0 else null, 
        "[%s]" % [",".join(tags)] if tags.size() > 0 else null, 
        str(siblings) if siblings.size() > 0 else null, 
        str(responses) if responses.size() > 0 else null, 
        "=> END" if "end" in next_id else "=> %s" % [next_id], 
        "(~> %s)" % [next_sibling_id] if next_sibling_id != "" else null, 
        "(==> %s)" % [next_id_after] if next_id_after != "" else null, 
    ].filter(func(item): return item != null)

    return " ".join(s)








func to_data() -> Dictionary:
    var d: Dictionary = {
        id = id, 
        type = type, 
        next_id = next_id
    }

    if next_id_expression.size() > 0:
        d.next_id_expression = next_id_expression

    match type:
        DMConstants.TYPE_CONDITION:
            d.condition = expression
            if not next_sibling_id.is_empty():
                d.next_sibling_id = next_sibling_id
            d.next_id_after = next_id_after

        DMConstants.TYPE_WHILE:
            d.condition = expression
            d.next_id_after = next_id_after

        DMConstants.TYPE_MATCH:
            d.condition = expression
            d.next_id_after = next_id_after
            d.cases = siblings

        DMConstants.TYPE_MUTATION:
            d.mutation = expression

        DMConstants.TYPE_GOTO:
            d.is_snippet = is_snippet
            d.next_id_after = next_id_after
            if not siblings.is_empty():
                d.siblings = siblings

        DMConstants.TYPE_RANDOM:
            d.siblings = siblings

        DMConstants.TYPE_RESPONSE:
            d.text = text

            if not responses.is_empty():
                d.responses = responses

            if translation_key != text:
                d.translation_key = translation_key
            if not expression.is_empty():
                d.condition = expression
            if not character.is_empty():
                d.character = character
            if not character_replacements.is_empty():
                d.character_replacements = character_replacements
            if not text_replacements.is_empty():
                d.text_replacements = text_replacements
            if not tags.is_empty():
                d.tags = tags
            if not notes.is_empty():
                d.notes = notes

        DMConstants.TYPE_DIALOGUE:
            d.text = text

            if translation_key != text:
                d.translation_key = translation_key

            if not character.is_empty():
                d.character = character
            if not character_replacements.is_empty():
                d.character_replacements = character_replacements
            if not text_replacements.is_empty():
                d.text_replacements = text_replacements
            if not tags.is_empty():
                d.tags = tags
            if not notes.is_empty():
                d.notes = notes
            if not siblings.is_empty():
                d.siblings = siblings
            if not concurrent_lines.is_empty():
                d.concurrent_lines = concurrent_lines

    return d
