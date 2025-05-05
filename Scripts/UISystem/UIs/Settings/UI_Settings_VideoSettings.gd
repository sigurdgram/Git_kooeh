extends Control
class_name UI_Settings_VideoSettings

@export var _resolution: UI_Settings_Element_DropdownOption
@export var _windowMode: UI_Settings_Element_DropdownOption
@export var _applySettings: Button
@export var _restoreDefault: Button
@export var _confirmationTimeSeconds: int = 10

var _res: Vector2i
var windowMode: int

var _confirmationTimeCounter: int
var _prompt: UI_Prompt

const ConfirmationString: String = "Do you want to keep the applied settings?\n(Reverting settings in %s seconds)"


func _ready():
    var settingsManager: SettingsManager = GameInstance.settingsManager

    _setup_window_mode(settingsManager.windowMode)
    _setup_resolution_options(settingsManager.resolution)

    _applySettings.pressed.connect(_apply_settings_pressed)
    _restoreDefault.pressed.connect(_restore_default_pressed)
    pass

func _setup_resolution_options(resolution: int):
    var supportedRes: Array = Utils.get_supported_resolutions()
    _res = supportedRes[resolution]

    for element in supportedRes:
        var resString: String = "%s x %s" % [element.x, element.y]
        _resolution.add_item(resString)

    _resolution.select(resolution)
    _resolution.item_selected.connect(_on_resolution_selected)
    _resolution.visible = windowMode == DisplayServer.WINDOW_MODE_WINDOWED;
    pass

func _on_resolution_selected(index: int):
    _res = Utils.get_supported_resolutions()[index]
    pass


func _setup_window_mode(inMode: int):
    var supported_window_modes: Dictionary = Utils.get_supported_window_modes()
    for mode in supported_window_modes:
        _windowMode.add_item(supported_window_modes[mode], mode)

    windowMode = inMode

    _windowMode.select(_windowMode.get_item_index(windowMode))
    _windowMode.item_selected.connect(_on_window_mode_changed)
    pass

func _on_window_mode_changed(index: int):
    windowMode = _windowMode.get_item_id(index)
    _resolution.visible = windowMode == DisplayServer.WINDOW_MODE_WINDOWED;
    pass

func _apply_settings_pressed(force: bool = false):
    if (_is_settings_unchanged() && !force):
        return


    DisplayServer.window_set_mode(windowMode)


    if windowMode == DisplayServer.WINDOW_MODE_WINDOWED:
        DisplayServer.window_set_size(_res);

    if is_instance_valid(_prompt):
        return

    _confirmationTimeCounter = _confirmationTimeSeconds
    var s: String = ConfirmationString % _confirmationTimeCounter
    _prompt = UITree.Prompt(s, keep_settings, restore_to_previous_settings) as UI_Prompt

    var timer: = Timer.new()
    timer.autostart = true
    timer.timeout.connect(func update_confirmation_prompt():
        _confirmationTimeCounter -= 1
        if _confirmationTimeCounter < 1:
            restore_to_previous_settings()
            _prompt.queue_free()
            return

        _prompt.set_description(ConfirmationString % _confirmationTimeCounter)
    )
    _prompt.add_child(timer)
    pass

func keep_settings():
    var settingsManager = GameInstance.settingsManager
    settingsManager.resolution = _resolution.selected
    settingsManager.windowMode = windowMode
    pass

func restore_to_previous_settings():
    var settingsManager = GameInstance.settingsManager
    _windowMode.select(_windowMode.get_item_index(settingsManager.windowMode), true)
    _resolution.select(settingsManager.resolution, true)
    _apply_settings_pressed(true)
    pass

func _update_confirmation_prompt():
    _confirmationTimeCounter -= 1
    if _confirmationTimeCounter < 1:
        _prompt.queue_free()
        return

    var s: String = ConfirmationString % _confirmationTimeCounter
    _prompt.set_description(s)
    pass

func _is_settings_unchanged() -> bool:
    var save: SaveGame = SaveLoadManager.get_current_save().get_ref()
    return save.resolution == _resolution.selected && \
save.windowMode == windowMode

func _restore_default_pressed():
    await get_tree().process_frame

    _on_window_mode_changed(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
    _on_resolution_selected(-1)
    pass
