extends CanvasLayer

var _uiLayers = {}

const layerBase = "Layer_Base"
const layerGame = "Layer_Game"
const layerGameUI = "Layer_GameUI"
const layerPrompt = "Layer_Prompt"
const layerPermanent1 = "Layer_Permanent1"
const layerPermanent2 = "Layer_Permanent2"

@export var _uiPrompt: PackedScene
@export var _rewardPrompt: PackedScene
@export var _flyInNotification: PackedScene

var _spawnedQuitPrompt: UI_Prompt

signal onWidgetPushed(widget: UI_Widget, layerName: String)


func _ready():
    match OS.get_name():
        "Windows":
            get_tree().auto_accept_quit = false

    RegisterUILayers()
    pass

func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        _quit_request()
    pass

func RegisterUILayers():
    _uiLayers.clear();

    var children = get_children()
    for child in children:
        var layerComponent = child as UI_Layer

        if ( !layerComponent):
            push_error("Direct child under UI_Tree must be a UI_Layer")

        _uiLayers[child.name] = layerComponent
    pass

func PushWidgetToLayer(packedScene: PackedScene, layerName: String) -> UI_Widget:
    var uilayer: UI_Layer = GetUILayer(layerName)
    assert (uilayer, "%s doesn't exist" % layerName)
    var widget: UI_Widget = uilayer.AddWidget(packedScene)
    onWidgetPushed.emit(widget, layerName)
    return widget

func AdditivePushWidgetToLayer(packedScene: PackedScene, layerName: String) -> UI_Widget:
    var uilayer: UI_Layer = GetUILayer(layerName)
    assert (uilayer, "%s doesn't exist" % layerName)
    var widget: UI_Widget = uilayer.AdditiveAddWidget(packedScene)
    onWidgetPushed.emit(widget, layerName)
    return widget

func PopWidgetFromLayer(widget: UI_Widget, layerName: String):
    var uilayer: UI_Layer = GetUILayer(layerName)
    assert (uilayer, "%s doesn't exist" % layerName)
    uilayer.RemoveWidget(widget)
    pass

func GetUILayer(layerName: String) -> UI_Layer:
    if ( !_uiLayers.has(layerName)):
        return null

    return _uiLayers[layerName]

func GetUILayers() -> Dictionary:
    return _uiLayers

func Prompt(text: String, yesCallback: Callable, noCallback: Callable) -> UI_Widget:
    var prompt = AdditivePushWidgetToLayer(_uiPrompt, layerPrompt) as UI_Prompt
    prompt.setup_prompt(text, yesCallback, noCallback)
    return prompt

func PromptError(text: String) -> void :
    push_error(text)
    var prompt = AdditivePushWidgetToLayer(_uiPrompt, layerPrompt) as UI_Prompt
    prompt.setup_prompt(text, func(): pass, func(): pass)
    pass

func fly_in_notification(text: String):
    var n = AdditivePushWidgetToLayer(_flyInNotification, layerPrompt) as UI_FlyInText
    n.set_text(text)
    pass

func reward_prompt(data, yesCallback: Callable):
    var prompt = PushWidgetToLayer(_rewardPrompt, layerPrompt) as UI_RewardPrompt
    prompt.setup_reward_prompt(data, yesCallback)
    pass

func _quit_request():
    if is_instance_valid(_spawnedQuitPrompt):
        get_tree().quit()
        return

    var currentFocus: Control = get_viewport().gui_get_focus_owner()
    _spawnedQuitPrompt = PushWidgetToLayer(_uiPrompt, layerPrompt) as UI_Prompt
    _spawnedQuitPrompt.setup_prompt(tr("PROMPT-QUIT_WARNING"), 
    func yes(): get_tree().quit(), 
    func no(): if is_instance_valid(currentFocus): currentFocus.grab_focus())
    pass

func fade_to_black():
    var tween: Tween = CampaignSystem.get_tree().create_tween()
    tween.tween_property(GameInstance, "modulate", Color.BLACK, 1.0)
    tween.tween_interval(0.5)
    return tween.finished

func fade_to_clear():
    var tween: Tween = CampaignSystem.get_tree().create_tween()
    tween.tween_property(GameInstance, "modulate", Color.WHITE, 1.0)
    tween.tween_interval(0.5)
    return tween.finished
