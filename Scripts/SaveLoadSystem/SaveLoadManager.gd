extends Node

var _currentSave: SaveGame

const savePath: String = "user://save.kooeh"
signal collectSaveData(saveGame: SaveGame)
signal onGameSave()
signal onGameLoad()



func _init():
    _autoload_save()
    pass

func _autoload_save():
    if FileAccess.file_exists(savePath):
        load_game()
    else:
        save_game()
    pass

func load_game():
    var file: FileAccess = FileAccess.open(savePath, FileAccess.READ)
    _currentSave = SaveGame.new()
    for value in _currentSave.get_property_list():
        if Utils.is_flag_enabled(value["usage"], PROPERTY_USAGE_SCRIPT_VARIABLE):
            var data = str_to_var(file.get_pascal_string())
            _currentSave.set(value["name"], data)
    file.close()

    onGameLoad.emit()
    pass

func new_game():
    GameplayVariables.reset()
    CampaignSystem.init()
    save_game()
    pass

func save_game():
    var file: FileAccess = FileAccess.open(savePath, FileAccess.WRITE)

    if _currentSave == null:
        _currentSave = SaveGame.new()
        _currentSave.init_new_save()
    collectSaveData.emit(_currentSave)

    for value in _currentSave.get_property_list():
        if Utils.is_flag_enabled(value["usage"], PROPERTY_USAGE_SCRIPT_VARIABLE):
            var data = _currentSave.get(value["name"])
            file.store_pascal_string(var_to_str(data))
    file.close()

    onGameSave.emit()
    pass

func get_current_save() -> WeakRef:
    return weakref(_currentSave)
