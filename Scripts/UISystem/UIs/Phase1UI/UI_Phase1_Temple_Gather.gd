extends UI_Widget
class_name UI_Phase1_Temple_Gather

enum {
    Default = 0, 
    Skip = 1, 
    Back = 2
}

@export var _artl: AdvancedRichTextLabel
@export var _container: Container
@export var _slot: PackedScene
@export var _audioRewardDrop1: AudioStream
@export var _audioRewardDrop2: AudioStream
@export var _audioRewardDrop3: AudioStream

const SkipText: String = "[center]Press [input]act_interact[/input] to Skip[/center]"
const BackText: String = "[center]Press [input]act_interact[/input] to Exit[/center]"
var state: int = Default
var _queue: Dictionary
var _counter: float
var _interval: float = 0.3
var _previousFocus: Control


func _ready():
    _previousFocus = get_viewport().gui_get_focus_owner()
    _artl.set("text", SkipText)
    set_physics_process(false)
    InputManager.set_game_input_enabled(false)
    pass

func _exit_tree():
    InputManager.set_game_input_enabled(true)

    if is_instance_valid(_previousFocus):
        _previousFocus.grab_focus()
    pass

func _input(event):
    if event.is_action_pressed("act_interact"):
        state += 1
        match state:
            Skip:
                _interval = 0.0
                _artl.set("text", BackText)
            Back:
                _close()
        accept_event()
    pass

func _physics_process(delta: float) -> void :
    while (_counter >= _interval):
        var childCount: int = _container.get_child_count()
        if childCount >= _queue.size():
            set_physics_process(false)
            return

        var slotNode = _slot.instantiate() as UI_Item_Frame
        var k = _queue.keys()[childCount - 1]
        var v = _queue.values()[childCount - 1]

        slotNode.setup(k, v)
        _container.add_child(slotNode)
        if state == Default:
            match slotNode.get_index():
                0: AudioSystem.play_sfx(_audioRewardDrop1)
                1: AudioSystem.play_sfx(_audioRewardDrop2)
                _: AudioSystem.play_sfx(_audioRewardDrop3)
        _counter = 0.0
    _counter += delta
    pass

func setup(randomIngredients: Dictionary):
    _queue = randomIngredients
    set_physics_process(true)
    pass

func _close():
    UITree.PopWidgetFromLayer(self, UITree.layerGameUI)
    pass
