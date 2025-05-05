extends Control
class_name UI_Settings_GeneralSettings

@export var _language: UI_Settings_Element_DropdownOption

var back: Callable


func _ready():
    var save: SaveGame = SaveLoadManager.get_current_save().get_ref()
    _setup_language_options(save)
    pass


func _on_invert_zoom_change(isPressed: bool):
    GameInstance.settingsManager.invertZoom = isPressed
    pass

func _setup_language_options(save: SaveGame):
    _language.item_selected.connect(_on_language_changed)
    var savedLanguageIndex: int = 0

    var index = 0
    for i in TranslationServer.get_loaded_locales():
        _language.add_item(i, index)
        if i == save.language:
            savedLanguageIndex = index
        index += 1

    pass

func _on_language_changed(index: int):
    var loadedLocales: PackedStringArray = TranslationServer.get_loaded_locales()
    TranslationServer.set_locale(loadedLocales[index])
    GameInstance.settingsManager.language = loadedLocales[index]
    pass
