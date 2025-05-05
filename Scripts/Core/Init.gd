extends Node

func _ready():
    InputMap.load_from_project_settings()

    if OS.has_feature("steam"):
        var steam: OnlineSubsystem = load("res://addons/godotsteam/GDSteam.gd").new()
        GameInstance.add_child(steam)
        if await steam.initialize():
            Engine.register_singleton(OnlineSubsystem.OnlineSubsystem, steam)

    _main_menu_start()


    pass

func _main_menu_start() -> void :
    GameInstance.change_scene("res://Scenes/Levels/LV_MainMenu.tscn")
    queue_free()
    pass

func _debug_start_phase1() -> void :
    CampaignSystem.debugCampaignEnabled = false
    SaveLoadManager.load_game()
    var debugFoodID: PackedStringArray = [FoodLibrary.KuihLapis, FoodLibrary.SirapLimau, FoodLibrary.OndehOndeh]

    var current_unix_time = Time.get_unix_time_from_system()
    var completion_date = Time.get_datetime_string_from_unix_time(current_unix_time, true)
    var stars: int = 3

    for i in debugFoodID:
        GameplayVariables.add_unlocked_recipe(i)
        GameplayVariables.add_learned_recipe(i, completion_date, stars)

    GameplayVariables.set_var(KooehConstant.moneyVarName, 10000.0)
    GameInstance.change_scene("res://Scenes/Levels/Prologue/LV_Prologue_Phase1.tscn")
    queue_free()
    pass

func _debug_submission_1_scene() -> void :
    GameplayVariables.set_var(KooehConstant.moneyVarName, 10000.0)
    CampaignSystem.debugCampaignEnabled = false
    GameInstance.change_scene("res://Scenes/Levels/Submission_1_Scene.tscn")
    queue_free()
    pass
