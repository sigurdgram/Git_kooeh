extends UI_Widget

@export var _btnStart: UI_BasicButton
@export var _btnSettings: UI_BasicButton
@export var _btnCredits: UI_BasicButton
@export var _btnQuit: UI_BasicButton
@export var _btnDebug: Button
@export var _journalBtn: Button
@export var _animPlayer: AnimationPlayer
@export var _audioStreamIntro: AudioStream
@export var _audioStreamLoop: AudioStream

@export_category("Packed Scenes")
@export var _settingsMenuUI: PackedScene
@export var _creditsMenuUI: PackedScene
@export var _journalUI: PackedScene

var _introPlayer: AudioStreamPlayer
var _currentFocus: Control


func _ready():
    _btnStart.pressed.connect(_on_pressed_start)
    _btnSettings.pressed.connect(_on_pressed_settings)
    _btnCredits.pressed.connect(_on_pressed_credits)
    _btnQuit.pressed.connect(_on_pressed_quit)
    _journalBtn.pressed.connect(_on_pressed_journal)
    _btnDebug.pressed.connect(_on_pressed_debug)
    _animPlayer.play("Anim_In")
    _introPlayer = AudioSystem.play_music(_audioStreamIntro, AudioSystem.AudioPlayMode.SOLO)
    pass

func ActivateWidget():
    _btnStart.grab_focus()
    pass

func _process(_delta):
    if not is_instance_valid(_introPlayer):
        return

    if _introPlayer.get_playback_position() >= 12:
        AudioSystem.play_music(_audioStreamLoop, AudioSystem.AudioPlayMode.SOLO, 0.0, true)
        set_process(false)
    pass

func _on_pressed_start():
    SaveLoadManager.new_game()
    await get_tree().process_frame

    if CampaignSystem.is_event_executable(KooehConstant.Prologue):
        if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
            var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
            oss.set_achievement(KooehConstant.ACH_START_NEW_GAME)
        CampaignSystem.set_event_active(KooehConstant.Prologue)
    else:
        GameInstance.change_scene("res://Scenes/Levels/Prologue/LV_Prologue_Phase1.tscn")
    pass

func _on_pressed_settings():
    _currentFocus = get_viewport().gui_get_focus_owner()
    var ui: UI_Widget = UITree.PushWidgetToLayer(_settingsMenuUI, UITree.layerGameUI)
    ui.tree_exiting.connect(_undo_focus)
    pass

func _undo_focus():
    _currentFocus.grab_focus()
    pass

func _on_pressed_credits():
    _currentFocus = get_viewport().gui_get_focus_owner()
    var ui: UI_Widget = UITree.PushWidgetToLayer(_creditsMenuUI, UITree.layerGameUI)
    ui.onDeactivated.connect(_undo_focus)
    pass

func _on_pressed_quit():
    _currentFocus = get_viewport().gui_get_focus_owner()
    get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    pass

func _on_pressed_journal():
    _currentFocus = get_viewport().gui_get_focus_owner()
    var ui: UI_Widget = UITree.PushWidgetToLayer(_journalUI, UITree.layerGameUI)
    ui.onDeactivated.connect(_undo_focus)
    pass

func _on_pressed_debug():
    get_tree().change_scene_to_file("res://Tests/Phase3Tests/test_Phase3Test.tscn")
    pass
