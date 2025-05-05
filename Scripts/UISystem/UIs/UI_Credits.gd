extends UI_Widget

@export var _animPlayer: AnimationPlayer
@export var _scrollCont: ScrollContainer
@export var _scrollSpeedPerSeconds: float = 8.0

var _endScrollValue: int
var _scrollCounter: float = 0
var _scrollModifier: float = 1.0


func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel"):
        on_back()
        accept_event()
    pass

func on_back():
    _animPlayer.animation_finished.connect(
    func enable_interaction(_animName):
        UITree.PopWidgetFromLayer(self, _parentLayer.name)
        , CONNECT_ONE_SHOT)
    _animPlayer.play_backwards("Anim_In")
    pass

func _ready():
    set_process(false)
    _scrollCont.grab_focus()

    await get_tree().process_frame
    _endScrollValue = floori(_scrollCont.get_child(0).get_rect().size.y)

    _animPlayer.animation_finished.connect(
    func enable_interaction(_animName):
        set_process(true)
        , CONNECT_ONE_SHOT)
    _animPlayer.play("Anim_In")
    _scrollCounter = 0
    pass

func _process(delta):
    _scrollCounter += (delta / _scrollSpeedPerSeconds) * _scrollModifier;
    var f: int = clampi(lerp(0, _endScrollValue, _scrollCounter), 0, _endScrollValue)
    _scrollCont.scroll_vertical = f
    pass

func _on_scrollcont_credits_gui_input(event: InputEvent):
    if event.is_action_pressed("ui_down", false):
        _scrollModifier = -1.0
        accept_event()

    if event.is_action_released("ui_up") or event.is_action_released("ui_down"):
        _scrollModifier = 1.0
    pass
