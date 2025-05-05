extends Control
class_name UI_InputLegend

@export var input: String
@export var _translationContext: String


func _ready():
    _on_input_type_changed(InputManager.get_input_type())
    InputManager.on_input_type_changed.connect(_on_input_type_changed)
    pass

func _on_input_type_changed(_inputType: KooehConstant.InputType):

    var texture: Texture2D = null
    if InputMap.has_action(input):
        var events: Array[InputEvent] = InputMap.action_get_events(input)
        if events.is_empty():
            return

        texture = KooehConstant.resolve_input_texture(_get_first_of_input_type(events, InputManager.get_input_type()))
    else:
        texture = KooehConstant.resolve_input_texture(input)

    % IMG_Input.texture = texture
    % TXT_Input.text = tr(input, _translationContext)
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
