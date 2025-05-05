extends UI_Widget
class_name UI_InGamePause

@export var _resumeBtn: Button
@export var _journalBtn: Button
@export var _settingBtn: Button
@export var _quitToMainBtn: Button
@export var _quitGameBtn: Button
@export var _inAnim: AnimationPlayer

@export_group("Packed Scenes")
@export var _settingsUITemplate: PackedScene
@export var _journalUI: PackedScene

var _currentFocus: Control
var _journalInstance: Control = null



func _enter_tree():
    get_tree().paused = true
    pass

func _exit_tree():
    get_tree().paused = false
    pass

func _input(event):
    if event.is_action_pressed("ui_cancel") and visible:
        _on_click_resume()
    pass

func _ready():
    _resumeBtn.pressed.connect(_on_click_resume)
    _journalBtn.pressed.connect(_on_pressed_journal)
    _settingBtn.pressed.connect(_on_click_settings)
    _quitToMainBtn.pressed.connect(_on_return_to_main)
    _quitGameBtn.pressed.connect(_on_click_quit_game)

    _inAnim.animation_finished.connect(
        func enable_interaction(_animName):
            _resumeBtn.grab_focus()
            , CONNECT_ONE_SHOT)
    _inAnim.play("InGamePause_In")

    pass

func _on_click_resume():
    _inAnim.animation_finished.connect(
    func destroy(_animName):
        if (is_instance_valid(self)):
            UITree.PopWidgetFromLayer(self, _parentLayer.name)
        , CONNECT_ONE_SHOT)

    _inAnim.play_backwards("InGamePause_In")
    pass

func _on_click_settings():
    _currentFocus = get_viewport().gui_get_focus_owner()
    var ui: UI_Settings = UITree.PushWidgetToLayer(_settingsUITemplate, UITree.layerPrompt)
    ui.onDeactivated.connect(func x(): _currentFocus.grab_focus())
    pass

func _on_pressed_journal():
    _currentFocus = get_viewport().gui_get_focus_owner()
    var journal: UI_Journal = UITree.PushWidgetToLayer(_journalUI, UITree.layerPrompt)
    journal.onDeactivated.connect(func x(): _currentFocus.grab_focus())
    pass

func _on_return_to_main():
    UITree.Prompt("Are you sure you want to quit to main menu? \n All unsaved progress will be lost.", 
        func yes(): GameInstance.change_scene("res://Scenes/Levels/LV_MainMenu.tscn"), 
        func no():
            _toggle_focus(true)
            _quitToMainBtn.grab_focus())

    _toggle_focus(false)
    pass

func _toggle_focus(isOn: bool):
    var mode: Control.FocusMode = Control.FOCUS_ALL if isOn else Control.FOCUS_NONE

    _resumeBtn.focus_mode = mode
    _journalBtn.focus_mode = mode
    _settingBtn.focus_mode = mode
    _quitToMainBtn.focus_mode = mode
    _quitGameBtn.focus_mode = mode
    pass


func _on_click_quit_game():
    get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    pass

func _on_journal_closed():
    _journalInstance = null
    _journalBtn.grab_focus()
