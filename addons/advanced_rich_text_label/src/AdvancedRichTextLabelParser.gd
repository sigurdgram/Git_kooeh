extends Resource
class_name AdvancedRichTextLabelParser




const PARSE_TAG_PATTERN = "\\[$.*?](?<value>.*?)\\[\\/$]"
var _parseRegex: RegEx

var owner: AdvancedRichTextLabel



func get_parse_tag() -> String:
    return ""

func get_parse_tag_pattern() -> String:
    return PARSE_TAG_PATTERN

func _init():
    _parseRegex = RegEx.new()
    _parseRegex.compile(get_parse_tag_pattern().replace("$", get_parse_tag()))
    pass

func set_owner(inOwner: AdvancedRichTextLabel):
    owner = inOwner
    pass


func parse(inputText: String) -> String:
    for m in _parseRegex.search_all(inputText):
        inputText = inputText.replace(m.get_string(), "yo")
    return inputText
