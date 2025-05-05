class_name SettingsManager

signal on_refresh_bindings

const audioBus_Master: String = "Master"
const audioBus_Music: String = "Music"
const audioBus_SFX: String = "SFX"

var masterVol: float = 0.75:
    set(value):
        masterVol = value
        _set_bus_volume(audioBus_Master, masterVol)

var musicVol: float = 0.75:
    set(value):
        musicVol = value
        _set_bus_volume(audioBus_Music, musicVol)

var sfxVol: float = 0.75:
    set(value):
        sfxVol = value
        _set_bus_volume(audioBus_SFX, sfxVol)

var masterMute: bool = false:
    set(value):
        masterMute = value
        _set_bus_mute(audioBus_Master, masterMute)

var musicMute: bool = false:
    set(value):
        musicMute = value
        _set_bus_mute(audioBus_Music, musicMute)

var sfxMute: bool = false:
    set(value):
        sfxMute = value
        _set_bus_mute(audioBus_SFX, sfxMute)

var resolution: int = 0
var windowMode: int = DisplayServer.WINDOW_MODE_FULLSCREEN
var invertZoom: bool = false
var edgePan: bool = false
var cameraPanSpeed: float = 3

var language: String = ProjectSettings.get_setting("internationalization/locale/fallback")
var _window: Window

const settingsPath: String = "user://settings.cfg"
var _pc_bindings: Dictionary
var _console_bindings: Dictionary


func init_world(window: Window):
    _window = window

    var settingsConfig = null
    if not FileAccess.file_exists(settingsPath):
        settingsConfig = _generate_default()
        settingsConfig.save(settingsPath)

    else:
        settingsConfig = load_config()
    pass


    var mode = windowMode
    DisplayServer.window_set_mode(mode)


    if mode == DisplayServer.WINDOW_MODE_WINDOWED:
        var targetResolution: Vector2i = Utils.get_supported_resolutions()[resolution]
        window.size = targetResolution;


    if not Utils.is_testing_locale():
        TranslationServer.set_locale(language)
    pass

func _generate_default() -> SettingsConfig:
    var settingsConfig: SettingsConfig = SettingsConfig.new()
    settingsConfig.set_value("Audio", "masterVol", masterVol)
    settingsConfig.set_value("Audio", "masterMute", masterMute)
    settingsConfig.set_value("Audio", "musicVol", musicVol)
    settingsConfig.set_value("Audio", "musicMute", musicMute)
    settingsConfig.set_value("Audio", "sfxVol", sfxVol)
    settingsConfig.set_value("Audio", "sfxMute", sfxMute)

    settingsConfig.set_value("Graphics", "resolution", resolution)
    settingsConfig.set_value("Graphics", "windowMode", windowMode)

    settingsConfig.set_value("General", "invertZoom", invertZoom)
    settingsConfig.set_value("General", "edgePan", edgePan)
    settingsConfig.set_value("General", "cameraPanSpeed", cameraPanSpeed)
    settingsConfig.set_value("General", "language", language)

    InputMap.load_from_project_settings()

    var inputMapping: Dictionary = {}
    for i in InputMap.get_actions():
        if not i.begins_with("act"):
            continue

        var inputEvents: Array[InputEvent] = InputMap.action_get_events(i)
        inputMapping[i] = inputEvents

        for j in inputEvents:
            match j.get_class():
                "InputEventKey", "InputEventMouseButton":
                    if not _pc_bindings.has(i):
                        _pc_bindings[i] = []
                    _pc_bindings[i].push_back(j)
                "InputEventJoypadButton", "InputEventJoypadMotion":
                    if not _console_bindings.has(i):
                        _console_bindings[i] = []
                    _console_bindings[i].push_back(j)

    settingsConfig.set_value("General", "inputBindings", inputMapping)
    return settingsConfig

func save_config():
    var settingsConfig: = SettingsConfig.new()
    settingsConfig.set_value("Audio", "masterVol", masterVol)
    settingsConfig.set_value("Audio", "masterMute", masterMute)
    settingsConfig.set_value("Audio", "musicVol", musicVol)
    settingsConfig.set_value("Audio", "musicMute", musicMute)
    settingsConfig.set_value("Audio", "sfxVol", sfxVol)
    settingsConfig.set_value("Audio", "sfxMute", sfxMute)

    settingsConfig.set_value("Graphics", "resolution", resolution)
    settingsConfig.set_value("Graphics", "windowMode", windowMode)

    settingsConfig.set_value("General", "invertZoom", invertZoom)
    settingsConfig.set_value("General", "edgePan", edgePan)
    settingsConfig.set_value("General", "cameraPanSpeed", cameraPanSpeed)
    settingsConfig.set_value("General", "language", language)

    var inputMapping: Dictionary = {}
    for i in _pc_bindings:
        if not inputMapping.has(i):
            inputMapping[i] = Array([], TYPE_OBJECT, "InputEvent", null)
        inputMapping[i].append_array(_pc_bindings[i])

    for i in _console_bindings:
        if not inputMapping.has(i):
            inputMapping[i] = Array([], TYPE_OBJECT, "InputEvent", null)
        inputMapping[i].append_array(_console_bindings[i])

    settingsConfig.set_value("General", "inputBindings", inputMapping)
    settingsConfig.save(settingsPath)
    pass

func load_config():
    _pc_bindings.clear()
    _console_bindings.clear()

    var settingsConfig: = SettingsConfig.new()
    settingsConfig.load(settingsPath)
    masterVol = settingsConfig.get_value("Audio", "masterVol")
    masterMute = settingsConfig.get_value("Audio", "masterMute")
    musicVol = settingsConfig.get_value("Audio", "musicVol")
    musicMute = settingsConfig.get_value("Audio", "musicMute")
    sfxVol = settingsConfig.get_value("Audio", "sfxVol")
    sfxMute = settingsConfig.get_value("Audio", "sfxMute")

    resolution = settingsConfig.get_value("Graphics", "resolution")
    windowMode = settingsConfig.get_value("Graphics", "windowMode")

    invertZoom = settingsConfig.get_value("General", "invertZoom")
    edgePan = settingsConfig.get_value("General", "edgePan")
    cameraPanSpeed = settingsConfig.get_value("General", "cameraPanSpeed")
    language = settingsConfig.get_value("General", "language")
    var bindings: Dictionary = settingsConfig.get_value("General", "inputBindings")

    for action in bindings:
        var inputEvents: Array = bindings[action]
        InputMap.action_erase_events(action)
        for e in inputEvents:
            InputMap.action_add_event(action, e)
            match e.get_class():
                "InputEventKey", "InputEventMouseButton":
                    if not _pc_bindings.has(action):
                        _pc_bindings[action] = []
                    _pc_bindings[action].push_back(e)
                "InputEventJoypadButton", "InputEventJoypadMotion":
                    if not _console_bindings.has(action):
                        _console_bindings[action] = []
                    _console_bindings[action].push_back(e)

    pass

func _set_bus_volume(busName: String, vol: float):
    var busIndex: int = AudioServer.get_bus_index(busName)
    AudioServer.set_bus_volume_db(busIndex, linear_to_db(vol))
    pass

func _set_bus_mute(busName: String, mute: bool):
    var busIndex: int = AudioServer.get_bus_index(busName)
    AudioServer.set_bus_mute(busIndex, mute)
    pass

func get_pc_bindings() -> Dictionary:
    return _pc_bindings

func get_console_bindings() -> Dictionary:
    return _console_bindings

func rebind_action_pc(action: StringName, currentEvent: InputEvent, newEvent: InputEvent) -> bool:
    if not is_key_available_pc(newEvent):
        return false

    if is_instance_valid(currentEvent):
        _pc_bindings[action].erase(currentEvent)
        InputMap.action_erase_event(action, currentEvent)

    if is_instance_valid(newEvent):
        _pc_bindings[action].push_back(newEvent)
        InputMap.action_add_event(action, newEvent)

    return true

func is_key_available_pc(event: InputEvent) -> bool:
    if not is_instance_valid(event):
        return false

    for action in _pc_bindings:
        for binding in _pc_bindings[action]:
            if binding.is_match(event, false):
                return false
    return true

func is_event_available_console(event: InputEvent) -> bool:
    for action in _console_bindings:
        for binding in _console_bindings[action]:
            if binding.is_match(event, true):
                return false
    return true

func rebind_action_console(action: StringName, currentEvent: InputEvent, newEvent: InputEvent) -> bool:
    if not is_event_available_console(newEvent):
        return false
    _console_bindings[action].erase(currentEvent)
    _console_bindings[action].push_back(newEvent)

    InputMap.action_erase_event(action, currentEvent)
    InputMap.action_add_event(action, newEvent)
    return true

func restore_default_inputs():
    _pc_bindings.clear()
    _console_bindings.clear()

    InputMap.load_from_project_settings()

    var inputMapping: Dictionary = {}
    for i in InputMap.get_actions():
        if not i.begins_with("act"):
            continue

        var inputEvents: Array[InputEvent] = InputMap.action_get_events(i)
        inputMapping[i] = inputEvents

        for j in inputEvents:
            match j.get_class():
                "InputEventKey", "InputEventMouseButton":
                    if not _pc_bindings.has(i):
                        _pc_bindings[i] = []
                    _pc_bindings[i].push_back(j)
                "InputEventJoypadButton", "InputEventJoypadMotion":
                    if not _console_bindings.has(i):
                        _console_bindings[i] = []
                    _console_bindings[i].push_back(j)

    on_refresh_bindings.emit()
    pass

class SettingsConfig extends ConfigFile:
    pass
