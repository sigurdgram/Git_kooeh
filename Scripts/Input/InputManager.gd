extends Node

signal on_input_activation_changed(status: bool)
signal on_input_type_changed(inputType: KooehConstant.InputType)

@export var _gamepadDeadzone: float = 0.5
static  var _gameViewport: SubViewport
var _currentInputType: KooehConstant.InputType:
    set(value):
        if _currentInputType == value:
            return

        _currentInputType = value
        on_input_type_changed.emit(_currentInputType)
        pass



func _init():
    process_mode = Node.PROCESS_MODE_ALWAYS
    pass

func _ready():
    match OS.get_name():
        _:
            _currentInputType = KooehConstant.InputType.KEYBOARD_MOUSE

    Input.joy_connection_changed.connect(_on_joy_connection_changed)
    pass

func setup(gameViewport: SubViewport):
    _gameViewport = gameViewport
    pass

func _on_joy_connection_changed(_device: int, connected: bool):
    var text: String = "Gamepad connected" if connected else "Gamepad disconnected"
    UITree.fly_in_notification(text)
    pass

func _input(event):
    var newType: KooehConstant.InputType = KooehConstant.InputType.KEYBOARD_MOUSE
    match event.get_class():
        "InputEventJoypadButton":
            newType = KooehConstant.InputType.CONTROLLER
        "InputEventJoypadMotion":
            var deadzone: float = InputManager.get_gamepad_deadzone()
            if abs(event.axis_value) < deadzone:
                return
            newType = KooehConstant.InputType.CONTROLLER
        _:
            newType = KooehConstant.InputType.KEYBOARD_MOUSE

    _currentInputType = newType
    pass

func get_input_type() -> KooehConstant.InputType:
    return _currentInputType

func get_gamepad_deadzone() -> float:
    return _gamepadDeadzone

func get_game_input_enabled() -> bool:
    return not _gameViewport.gui_disable_input

func set_game_input_enabled(state: bool):
    _gameViewport.gui_disable_input = not state
    on_input_activation_changed.emit(state)
    pass
