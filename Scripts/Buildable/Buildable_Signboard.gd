extends Buildable_Base
class_name Buildable_Signboard

@export var _levelToLoad: PackedScene

signal onLevelLoaded()



func interact(_interactor: Node2D):
    super .interact(_interactor)
    InputManager.set_game_input_enabled(false)
    await UITree.fade_to_black()
    onLevelLoaded.emit()
    GameInstance.change_scene_packed(_levelToLoad)
    pass
