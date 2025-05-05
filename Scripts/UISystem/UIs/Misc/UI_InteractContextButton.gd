extends Button

@export var _audioClick: AudioStream

func _ready():
    pressed.connect(_on_pressed)
    pass

func _on_pressed():
    AudioSystem.play_sfx(_audioClick)
    pass
