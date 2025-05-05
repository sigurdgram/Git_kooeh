extends AdvancedRichTextLabelParser
class_name AdvancedRichTextLabelParser_Input

var _sourceString: String
@export var _imageScale: float = 2.0


func _notification(what: int):
    if what == NOTIFICATION_PREDELETE && is_instance_valid(InputManager) && is_instance_valid(self):
        InputManager.on_input_type_changed.disconnect(_on_input_type_changed)
    pass

func set_owner(inOwner: AdvancedRichTextLabel):
    super .set_owner(inOwner)

    if not (InputManager.on_input_type_changed.is_connected(_on_input_type_changed)):
        InputManager.on_input_type_changed.connect(_on_input_type_changed)
    pass

func get_parse_tag() -> String:
    return "input"

func get_parse_tag_pattern() -> String:
    return "\\[$\\s?(?<color>.*?)\\](?<value>.*?)\\[\\/$]"

func parse(inputText: String) -> String:
    _sourceString = inputText
    var fontSize: int = owner.get_theme_font_size("normal_font_size", owner.theme_type_variation)
    var replacementString: String = inputText
    var matches: Array[RegExMatch] = _parseRegex.search_all(inputText)
    for m in matches:
        var value: String = m.get_string("value")
        var color: String = m.get_string("color")

        if color.is_empty():
            color = "#32160c"

        if value.is_empty():
            continue

        var texture: Texture2D = null
        if InputMap.has_action(value):
            var events: Array[InputEvent] = InputMap.action_get_events(value)

            texture = KooehConstant.resolve_input_texture(_get_first_of_input_type(events, InputManager.get_input_type()))
        else:
            texture = KooehConstant.resolve_input_texture(value)

        var texturePath: String = texture.resource_path
        var textureSize: Vector2 = texture.get_size()

        var ratio: Vector2 = Vector2.ONE / (textureSize / fontSize)
        var highestRatio: float = ratio[ratio.max_axis_index()] * _imageScale
        textureSize *= highestRatio

        var options: String = "width=%s, height=%s, color=%s" % [textureSize.x, textureSize.y, color]
        var imgString: String = "[img %s]%s[/img]" % [options, texturePath]
        replacementString = replacementString.replace(m.get_string(), imgString)

    return replacementString

func _on_input_type_changed(_inputType: KooehConstant.InputType):
    if is_instance_valid(owner):
        owner.set("text", _sourceString)
    pass

func _get_first_of_input_type(events: Array[InputEvent], inputType: KooehConstant.InputType) -> InputEvent:
    for event in events:
        if inputType == KooehConstant.InputType.KEYBOARD_MOUSE:
            match event.get_class():
                "InputEventKey", "InputEventMouseButton":
                    return event
        elif inputType == KooehConstant.InputType.CONTROLLER:
            match event.get_class():
                "InputEventJoypadButton", "InputEventJoypadMotion":
                    return event
    return null
