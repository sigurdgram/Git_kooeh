extends UI_Widget
class_name UI_Settings_ControlRebindUI_Gamepad

@export var _keyTexture: TextureRect

var _action: StringName
var _currentEvent: InputEvent
var _newEvent: InputEvent:
    set(value):
        _newEvent = value
        _keyTexture.texture = KooehConstant.resolve_input_texture(value)

var _settingsManager: SettingsManager
var _prompt: UI_Prompt
var _ignoredControlTypes: Array = ["InputEventScreenDrag", "InputEventScreenTouch", "InputEventKey", "InputEventMouseButton", "InputEventMouseMotion"]


func _ready():
    grab_focus()
    pass

func _gui_input(event: InputEvent):
    if not visible or _newEvent == event or _ignoredControlTypes.has(event.get_class()) or event.is_echo():
        get_viewport().set_input_as_handled()
        accept_event()
        return

    if not event.is_pressed():
        return

    if event.is_action_pressed("ui_cancel"):
        _rebind()
        get_viewport().set_input_as_handled()
        accept_event()
        return

    var texture: Texture2D = KooehConstant.resolve_input_texture(event)
    if texture != null:
        if "axis_value" in event:
            event.axis_value = roundf(event.axis_value)
        _newEvent = event
    else:
        var text: String = "Key is Unavailable. Please Select Other Keys."
        _warn(text)

    get_viewport().set_input_as_handled()
    accept_event()
    pass

func _unhandled_input(_event):
    accept_event()
    pass

func activate_rebind(settingsManager: SettingsManager, action: StringName, currentEvent: InputEvent):
    _settingsManager = settingsManager
    _action = action
    _currentEvent = currentEvent
    _newEvent = currentEvent
    grab_focus()
    pass

func _rebind():
    if _currentEvent == _newEvent:
        UITree.PopWidgetFromLayer(self, _parentLayer.name)
        return

    var newBindText: String = _newEvent.as_text() if is_instance_valid(_newEvent) else ""
    var currentBindText: String = _currentEvent.as_text() if is_instance_valid(_currentEvent) else ""
    if newBindText == currentBindText:
        UITree.PopWidgetFromLayer(self, _parentLayer.name)
        return

    if _settingsManager.rebind_action_console(_action, _currentEvent, _newEvent):
        UITree.PopWidgetFromLayer(self, _parentLayer.name)
    else:
        _newEvent = _currentEvent
        _warn("The Key is Used By Another Action. Please Select Other Keys.")
    pass

func _warn(text: String):
    if not is_instance_valid(_prompt):
        _prompt = UITree.Prompt(text, _restore_previous_binding, _restore_previous_binding) as UI_Prompt
    _prompt.grab_focus()
    pass

func _restore_previous_binding():
    _newEvent = _currentEvent
    grab_focus()
    pass
