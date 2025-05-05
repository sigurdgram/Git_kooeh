extends Node
class_name Phase1GameMode

@export var _essentialsUI: PackedScene
@export var _phase1Music: AudioStream
@export var _interactionSystem: InteractionSystem

var tutorial: WeakRef
var _essentialsUIInstance: UI_Widget


func _ready():
    InputManager.set_game_input_enabled(false)
    GameInstance.gameWorld = self
    AudioSystem.play_music(_phase1Music, AudioSystem.AudioPlayMode.SOLO)
    call_deferred("_setup")

    initialize_tutorial_mode()
    var tree: SceneTree = get_tree()
    _interactionSystem = tree.get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    pass

func _exit_tree():
    if is_instance_valid(_essentialsUIInstance):
        UITree.PopWidgetFromLayer(_essentialsUIInstance, _essentialsUIInstance.get_owning_layer_name())
    pass

func _setup():
    _essentialsUIInstance = UITree.AdditivePushWidgetToLayer(_essentialsUI, UITree.layerPermanent1)
    pass

func get_interaction_system():
    return _interactionSystem

func initialize_tutorial_mode():
    var tutorial_nodes = get_tree().get_nodes_in_group("tutorial_prologue")
    if tutorial_nodes.size() > 0:
        tutorial = weakref(tutorial_nodes[0])
    else:
        tutorial = null
        InputManager.set_game_input_enabled(true)

func is_tutorial_mode() -> bool:
    return tutorial != null and is_instance_valid(tutorial.get_ref())
