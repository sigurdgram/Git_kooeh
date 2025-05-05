extends UI_Widget
class_name UI_VideoPlayer

@export var _player: VideoStreamPlayer
var _prompt: UI_Prompt


func _ready():
    await get_tree().process_frame
    grab_focus()
    pass

func finished() -> Signal:
    return _player.finished

func _input(event):
    if event.is_action_pressed("act_pause"):
        if not is_instance_valid(_prompt):
            _prompt = UITree.Prompt("Are you sure you want to skip?", _force_done, _unpause)
            _player.paused = true
        else:
            _prompt.show()

    accept_event()
    pass

func play_video(video: VideoStream):
    _player.stream = video
    _player.finished.connect(func pop():
        UITree.PopWidgetFromLayer(self, _parentLayer.name), CONNECT_ONE_SHOT)
    _player.play()
    pass

func _unpause():
    _player.paused = false
    grab_focus()
    pass

func _force_done():
    _player.finished.emit()
    pass
