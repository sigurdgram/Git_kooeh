extends SubViewportContainer
@export var gameViewport: SubViewport

signal onSceneChange(scenePath: String)
signal onGameWorldSet(node: Node)

var _canPause: bool = true
var settingsManager: SettingsManager
var undoRedo: UndoRedo
var gameWorld: Node:
    set(value):
        gameWorld = value
        onGameWorldSet.emit(gameWorld)

func _init():
    undoRedo = UndoRedo.new()
    settingsManager = SettingsManager.new()
    pass

func _ready():
    assert (mouse_filter == Control.MOUSE_FILTER_PASS)
    settingsManager.init_world(get_window())
    InputManager.setup(gameViewport)
    get_viewport().gui_focus_changed.connect(_on_focus_changed)
    pass

func _on_focus_changed(control: Control):

    pass

func change_scene(scenePath: String):
    for i in gameViewport.get_children():
        i.free()

    await get_tree().process_frame

    if not ResourceLoader.exists(scenePath):
        push_error("%s does not exist" % scenePath)
    var scene = load(scenePath).instantiate()
    gameViewport.add_child(scene)
    onSceneChange.emit(scenePath)
    pass

func change_scene_packed(packedScene: PackedScene):
    for i in gameViewport.get_children():
        i.free()

    await get_tree().process_frame

    var scene = packedScene.instantiate()
    gameViewport.add_child(scene)
    onSceneChange.emit(packedScene.resource_path)
    pass

func can_game_pause():
    return _canPause

func set_can_game_pause(canPause: bool):
    _canPause = canPause
