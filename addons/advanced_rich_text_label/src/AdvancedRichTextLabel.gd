extends RichTextLabel
class_name AdvancedRichTextLabel

@export var _parsers: Array[AdvancedRichTextLabelParser]



func _init():
    bbcode_enabled = true
    pass

func _ready():



    for p in _parsers:
        p.set_owner(self)

    if not text.is_empty():
        set("text", text)

    pass

func _set(property: StringName, value: Variant):
    match property:
        "text":
            var sourceString: String = value
            var displayedText = sourceString
            for p in _parsers:
                displayedText = p.parse(sourceString)

            text = displayedText
            return true
    pass
