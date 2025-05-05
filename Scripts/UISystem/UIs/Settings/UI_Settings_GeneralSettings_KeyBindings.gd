extends Control
class_name UI_Settings_GeneralSettings_KeyRebinds

@export var _inputRebindButtons: HBoxContainer
@export var _applySettings: UI_BasicButton
@export var _restoreDefault: UI_BasicButton
@export var _rebindControlsEntry: PackedScene
@export var _rebindControlsUI: PackedScene

var _currentBindings: Dictionary
var _newBindings: Dictionary

var back: Callable
var _currentFocus: Control


func _ready():



















    pass

func request_rebind(action: StringName, currentEvent: InputEvent):




    pass

func is_key_available(newBind: InputEvent) -> bool:
    if not is_instance_valid(newBind):
        return true

    var newBindText = Utils.InputStatics.get_input_event_text_safe(newBind)

    var names = _currentBindings.values()\
.map(func get_name(x): return Utils.InputStatics.get_input_event_text_safe(x))
    return not names.has(newBindText)

func rebind(action: StringName, newEvent: InputEvent):
    _newBindings[action] = newEvent
    pass

func refresh_bindings():






    pass

func _is_unchanged() -> bool:
    var retVal: int = 1
    for binding in _currentBindings:
        var currentBinding: String = Utils.InputStatics.get_input_event_text_safe(_currentBindings[binding])
        var newBinding: String = Utils.InputStatics.get_input_event_text_safe(_newBindings[binding])
        retVal &= int(currentBinding == newBinding)

    return retVal

func on_back():
    if _is_unchanged():
        back.call()
        return

    var prompt = UITree.Prompt("Do you want to apply the unsaved settings?", 
    _on_pressed_apply_bindings, 
    _restore_previous_bindings) as UI_Prompt
    prompt.onDeactivated.connect(func x(): back.call())
    prompt.grab_focus()
    pass

func _on_pressed_apply_bindings():
    var settingsManager = GameInstance.settingsManager
    _currentBindings = _newBindings.duplicate()
    var newBindings: Array = []

    for input in _newBindings:
        var action = input
        var event = var_to_str(_newBindings[input])
        newBindings.push_back([action, event])

    settingsManager.inputBindings = newBindings
    pass

func _restore_previous_bindings():
    _newBindings = _currentBindings.duplicate()

    var bindings: Array = _newBindings.values()
    var index = 0
    for entry in get_children():
        var event: InputEvent = bindings[index]
        entry._event = event
        index += 1

    refresh_bindings()
    pass

func _on_pressed_restore_default():
    InputMap.load_from_project_settings()
    for binding in Utils.get_default_input_bindings():
        var action: StringName = binding[0]
        var event: InputEvent = str_to_var(binding[1]) as InputEvent
        _newBindings[action] = event

    refresh_bindings()
    pass

func _on_scrollcont_key_rebinds_visibility_changed():
    if % SCROLLCONT_KeyRebinds.visible:
        _currentFocus.grab_focus()
    else:
        on_back()
    pass
