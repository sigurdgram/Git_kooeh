extends Buildable
class_name Buildable_Signboard1

@export var _levelToLoad: PackedScene

@onready var _interactableComp: InteractableComponent = $InteractableComponent
var _interactionSystem: InteractionSystem

signal onLevelLoaded()



func _ready() -> void :
    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    _interactableComp.onInteract.connect(onInteract)
    pass

func onInteract(_interactor: Node2D):
    InputManager.set_game_input_enabled(false)
    await UITree.fade_to_black()
    onLevelLoaded.emit()
    GameInstance.change_scene_packed(_levelToLoad)
    pass
