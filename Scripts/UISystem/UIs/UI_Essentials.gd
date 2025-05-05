extends UI_Widget
class_name UI_Essentials

@export var _pauseMenuUI: PackedScene
@export var _hamburgerBtn: Button

var _uiInstance: UI_Widget
var _currentFocus: Control


func _ready():
    GameInstance.onSceneChange.connect(_on_back_to_main_menu)
    _hamburgerBtn.pressed.connect(_on_click_hamburger)
    Input.joy_connection_changed.connect(_on_joy_connection_changed)
    pass

func _on_back_to_main_menu(scenePath: String):
    if scenePath.ends_with("LV_MainMenu.tscn"):
        queue_free()
    pass

func _on_joy_connection_changed(_device: int, connected: bool):
    if not connected:
        _on_click_hamburger()
    pass

func _unhandled_input(event):
    if event.is_action_pressed("act_pause"):
        _on_click_hamburger()
    pass

func _on_click_hamburger():
    if is_instance_valid(_uiInstance):
        return

    _currentFocus = get_viewport().gui_get_focus_owner()
    _uiInstance = UITree.AdditivePushWidgetToLayer(_pauseMenuUI, UITree.layerPrompt)
    if is_instance_valid(_currentFocus):
        _uiInstance.onDeactivated.connect(_on_pause_menu_deactivated)

    get_viewport().set_input_as_handled()
    pass

func _on_pause_menu_deactivated():
    _currentFocus.grab_focus()
    pass
