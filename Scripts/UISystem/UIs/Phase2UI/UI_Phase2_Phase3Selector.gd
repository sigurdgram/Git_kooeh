extends UI_Widget
class_name UI_Phase2_Phase3Selector

@export var _shopCustomizationBtn: Button
@export var _recipeDiscoveryBtn: Button
@export var _endDayBtn: Button
@export var _demoEndUI: PackedScene
@export var _cookBookPhase3: PackedScene

var _gameMode: GameplayGameMode


func _ready():
    _recipeDiscoveryBtn.pressed.connect(_on_click_recipe_discovery)
    _endDayBtn.pressed.connect(_on_click_end_day)
    _shopCustomizationBtn.pressed.connect(on_click_customization)
    InputManager.set_game_input_enabled(false)
    pass

func setup(gameMode: GameplayGameMode):
    _gameMode = gameMode
    pass

func ActivateWidget():
    super .ActivateWidget()
    _endDayBtn.grab_focus()
    pass

func on_click_customization() -> void :
    _gameMode.on_click_customization()
    pass

func _on_click_recipe_discovery():
    var cookbook: UI_Phase3_Cookbook = UITree.PushWidgetToLayer(_cookBookPhase3, UITree.layerGame)
    cookbook.unblock_input()
    pass

func _on_click_end_day():
    SaveLoadManager.save_game()


    GameInstance.change_scene("res://Scenes/Levels/Prologue/LV_Prologue_Phase1.tscn")
    pass
