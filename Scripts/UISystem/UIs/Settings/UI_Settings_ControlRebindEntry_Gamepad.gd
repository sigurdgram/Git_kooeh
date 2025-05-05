extends Control
class_name UI_Settings_ControlRebindEntry_Gamepad

@export var _keyRebindUITemplate: PackedScene

@export var _actionTxt: Label
@export var _rebindBtn: Button
@export var _rebindTexture: TextureRect

var _event: InputEvent:
    set(value):
        if value == _event:
            return

        _event = value
        _rebindTexture.texture = KooehConstant.resolve_input_texture(_event)
        pass

var _currentFocus: Control
var _action: StringName
var _settingsManager: SettingsManager



func setup(settingsManager: SettingsManager, action: StringName, events: Array):
    _settingsManager = settingsManager
    _action = action
    _actionTxt.text = tr(action)

    _event = events[0]

    _settingsManager.on_refresh_bindings.connect(_on_refresh_bindings)
    _rebindBtn.pressed.connect(_start_rebind)
    pass

func _on_refresh_bindings():
    var inputEvents: Array = _settingsManager.get_console_bindings()[_action]
    _event = inputEvents[0]
    pass

func _start_rebind():
    _currentFocus = get_viewport().gui_get_focus_owner()
    var ui: UI_Widget = UITree.PushWidgetToLayer(_keyRebindUITemplate, UITree.layerGameUI) as UI_Settings_ControlRebindUI_Gamepad
    ui.onDeactivated.connect(_undo_focus)
    ui.activate_rebind(_settingsManager, _action, _event)
    pass

func _undo_focus():
    _on_refresh_bindings()
    _currentFocus.grab_focus()
    pass
