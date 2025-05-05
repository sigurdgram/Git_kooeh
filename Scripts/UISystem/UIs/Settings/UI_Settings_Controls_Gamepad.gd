extends PanelContainer
class_name UI_Settings_Controls_Gamepad

@export var _keyBindings: VBoxContainer
@export_group("Packed Scenes")
@export var _keyBindEntryTemplate: PackedScene


var _owner: UI_Settings

const OrderedKeys = ["act_up", "act_down", "act_left", "act_right", "act_interact", "act_pause"]


func setup(inName: String, inOwner: UI_Settings):
    name = inName
    _owner = inOwner
    pass

func _ready():
    var settingsManager = GameInstance.settingsManager
    var bindings: Dictionary = settingsManager.get_console_bindings()
    for binding in OrderedKeys:
        var spawnedEntry: UI_Settings_ControlRebindEntry_Gamepad = _keyBindEntryTemplate.instantiate()
        spawnedEntry.setup(settingsManager, binding, bindings[binding])
        _keyBindings.add_child(spawnedEntry)
        spawnedEntry.owner = _owner
    pass
