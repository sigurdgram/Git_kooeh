
class_name DMResolvedTagData extends RefCounted



var tags: PackedStringArray = []

var text_without_tags: String = ""


var regex: DMCompilerRegEx = DMCompilerRegEx.new()


func _init(text: String) -> void :
    var resolved_tags: PackedStringArray = []
    var tag_matches: Array[RegExMatch] = regex.TAGS_REGEX.search_all(text)
    for tag_match in tag_matches:
        text = text.replace(tag_match.get_string(), "")
        var tags = tag_match.get_string().replace("[#", "").replace("]", "").replace(", ", ",").split(",")
        for tag in tags:
            tag = tag.replace("#", "")
            if not tag in resolved_tags:
                resolved_tags.append(tag)

    tags = resolved_tags
    text_without_tags = text
