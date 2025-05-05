extends Control
class_name UI_Settings_ControlRebindEntry_KBM

@export var _keyRebindUITemplate: PackedScene

@export var _actionTxt: Label
@export var _rebindBtn: Button
@export var _rebindTexture: TextureRect
@export var _rebindBtn2: Button
@export var _rebindTexture2: TextureRect

var _event: InputEvent:
    set(value):
        if value == _event:
            return

        _event = value
        _rebindTexture.texture = KooehConstant.resolve_input_texture(_event)
        pass

var _event2: InputEvent:
    set(value):
        if value == _event2:
            return

        _event2 = value
        _rebindTexture2.texture = KooehConstant.resolve_input_texture(_event2)
        pass

var _currentFocus: Control
var _action: StringName
var _settingsManager: SettingsManager


func setup(settingsManager: SettingsManager, action: StringName, events: Array):
    _settingsManager = settingsManager
    _action = action
    _actionTxt.text = tr(action)

    if events.size() >= 1:
        _event = events[0]

    if events.size() == 2:
        _event2 = events[1]

    _settingsManager.on_refresh_bindings.connect(_on_refresh_bindings)
    _rebindBtn.pressed.connect(_start_rebind.bind(_event))
    _rebindBtn2.pressed.connect(_start_rebind.bind(_event2))
    pass

func _on_refresh_bindings():
    var inputEvents: Array = _settingsManager.get_pc_bindings()[_action]
    match inputEvents.size():
        0:
            _event = null
            _event2 = null
        1:
            _event = inputEvents[0]
            _event2 = null
        2:
            _event = inputEvents[0]
            _event2 = inputEvents[1]
    pass

func get_button():
    return _rebindBtn

func _start_rebind(e: InputEvent):
    _currentFocus = get_viewport().gui_get_focus_owner()

    var uiSettings: = owner as UI_Settings
    var ui: UI_Widget = UITree.PushWidgetToLayer(_keyRebindUITemplate, uiSettings.get_owning_layer_name()) as UI_Settings_ControlRebindUI_KBM

    ui.onDeactivated.connect(_undo_focus)
    ui.activate_rebind(_settingsManager, _action, e)
    pass

func _undo_focus():
    _on_refresh_bindings()
    _currentFocus.grab_focus()
    pass
