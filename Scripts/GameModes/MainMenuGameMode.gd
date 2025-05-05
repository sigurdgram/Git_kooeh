extends Node
@export var _mainMenuPackedScene: PackedScene

func _ready():
    call_deferred("_deferred_ready")
    pass

func _deferred_ready():
    UITree.PushWidgetToLayer(_mainMenuPackedScene, UITree.layerGame)
    GameInstance.onSceneChange.connect(_on_scene_change)
    pass

func _on_scene_change(_scenePath: String):
    queue_free()
    pass
