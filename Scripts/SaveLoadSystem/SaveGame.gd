extends RefCounted

class_name SaveGame

@export var playTime: String
@export var masterVol: float
@export var masterMute: bool
@export var musicVol: float
@export var musicMute: bool
@export var sfxVol: float
@export var sfxMute: bool
@export var resolution: int
@export var windowMode: int
@export var invertZoom: bool
@export var edgePan: bool = true
@export var cameraPanSpeed: float

@export var language: String
@export var gameplayVariables: Dictionary


func _init():
    playTime = Time.get_datetime_string_from_system(false, true)
    masterVol = Utils.get_default_master_volume()
    musicVol = Utils.get_default_music_volume()
    sfxVol = Utils.get_default_sfx_volume()
    resolution = -1
    windowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
    cameraPanSpeed = Utils.get_default_camera_speed()
    language = Utils.get_fallback_language()
    pass

func init_new_save():
    var currentLocale: String = OS.get_locale_language()
    var loadedLocales: PackedStringArray = TranslationServer.get_loaded_locales()

    if loadedLocales.has(currentLocale):
        language = currentLocale
    pass
