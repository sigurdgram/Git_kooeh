extends UI_Widget
class_name UI_Settings

@export var _inAnim: AnimationPlayer
@export var _controlsTabCont: TabContainer

@export_group("Controls")
@export var _controlPrevious: Button

@export_group("Focus")
@export var _settingsPageInitialFocus: Control

var _controlReference: Dictionary = {
    KooehConstant.InputType.KEYBOARD_MOUSE: "Control.KBM", 
    KooehConstant.InputType.CONTROLLER: "Control.Gamepad", 
}

var back: Callable
var _currentInputType: KooehConstant.InputType = KooehConstant.InputType.INVALID
var _currentFocus: Control
var _isInteractionDisabled: bool:
    set(value):
        _isInteractionDisabled = value



func _exit_tree():
    AssetManager.unload_assets_of_type("Control")
    InputManager.on_input_type_changed.disconnect(_on_input_type_changed)
    pass

func _input(event: InputEvent):
    if _isInteractionDisabled:
        accept_event()

    if event.is_action_pressed("ui_cancel"):
        on_back()
        accept_event()
    pass

func ActivateWidget():
    set_process_input(true)
    pass

func DeactivateWidget():
    set_process_input(is_visible_in_tree())
    pass

func _ready():
    _isInteractionDisabled = true

    _controlPrevious.pressed.connect(GameInstance.settingsManager.restore_default_inputs)
    _on_input_type_changed(InputManager.get_input_type())
    InputManager.on_input_type_changed.connect(_on_input_type_changed)

    _inAnim.animation_finished.connect(
        func enable_interaction(_animName):
            _isInteractionDisabled = false, CONNECT_ONE_SHOT)
    _inAnim.play("Settings_In")

    _currentFocus = _settingsPageInitialFocus

    await get_tree().process_frame
    _currentFocus.grab_focus()
    pass

func _on_input_type_changed(inputType: KooehConstant.InputType):
    if _currentInputType == inputType:
        return

    _currentInputType = inputType

    var assetName: String = _controlReference[inputType]
    var control: Control = _controlsTabCont.find_child(assetName.validate_node_name(), false, false)
    if control == null:
        var ref: WeakRef = AssetManager.load_asset(assetName)
        control = ref.get_ref().instantiate()
        control.setup(assetName, self)
        _controlsTabCont.add_child(control)

    _controlsTabCont.current_tab = control.get_index()
    pass

func on_back():
    _isInteractionDisabled = true
    GameInstance.settingsManager.save_config()
    _inAnim.animation_finished.connect(
        func destroy(_animName):
            release_focus()
            UITree.PopWidgetFromLayer(self, get_owning_layer_name())
            , CONNECT_ONE_SHOT)

    _inAnim.play_backwards("Settings_In")
    pass
