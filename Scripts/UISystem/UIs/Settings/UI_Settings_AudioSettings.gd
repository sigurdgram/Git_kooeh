extends Control
class_name UI_Settings_AudioSettings

@export var _masterVolume: UI_Settings_Element_Slider
@export var _musicVolume: UI_Settings_Element_Slider
@export var _sfxVolume: UI_Settings_Element_Slider

@export var _muteMaster: CheckBox
@export var _muteMusic: CheckBox
@export var _muteSFX: CheckBox



func _ready():
    var settingsManager = GameInstance.settingsManager
    _masterVolume.set_value_no_signal(settingsManager.masterVol)
    _musicVolume.set_value_no_signal(settingsManager.musicVol)
    _sfxVolume.set_value_no_signal(settingsManager.sfxVol)

    _muteMaster.button_pressed = settingsManager.masterMute
    _muteMusic.button_pressed = settingsManager.musicMute
    _muteSFX.button_pressed = settingsManager.sfxMute

    _masterVolume.valueChanged.connect(_on_master_vol_change)
    _musicVolume.valueChanged.connect(_on_music_vol_change)
    _sfxVolume.valueChanged.connect(_on_sfx_vol_change)

    _muteMaster.toggled.connect(_on_master_mute)
    _muteMusic.toggled.connect(_on_music_mute)
    _muteSFX.toggled.connect(_on_sfx_mute)
    pass

func _on_master_vol_change(value: float):
    var settingsManager = GameInstance.settingsManager
    settingsManager.masterVol = value
    pass

func _on_music_vol_change(value: float):
    var settingsManager = GameInstance.settingsManager
    settingsManager.musicVol = value
    pass

func _on_sfx_vol_change(value: float):
    var settingsManager = GameInstance.settingsManager
    settingsManager.sfxVol = value
    pass

func _on_master_mute(value: bool):
    var settingsManager = GameInstance.settingsManager
    settingsManager.masterMute = value
    pass

func _on_music_mute(value: bool):
    var settingsManager = GameInstance.settingsManager
    settingsManager.musicMute = value
    pass

func _on_sfx_mute(value: bool):
    var settingsManager = GameInstance.settingsManager
    settingsManager.sfxMute = value
    pass
