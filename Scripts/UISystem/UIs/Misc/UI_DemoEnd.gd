extends UI_Widget

@export var _mainMenuBtn: UI_BasicButton

func _ready():
    _mainMenuBtn.pressed.connect(_on_press_main_menu)
    pass

func ActivateWidget():
    super .ActivateWidget()
    _mainMenuBtn.grab_focus()
    pass

func _on_press_main_menu():
    GameInstance.change_scene("res://Scenes/Levels/LV_MainMenu.tscn")
    pass
