extends Node

enum AudioPlayMode{
    SOLO, 
    ADDITIVE, 
}

var _musicGroup: Node
var _sfxGroup: Node

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    _musicGroup = Node.new()
    add_child(_musicGroup)

    _sfxGroup = Node.new()
    add_child(_sfxGroup)
    pass


func play_music(stream: AudioStream, playMode: AudioPlayMode, position: float = 0.0, autoDestroy: bool = true) -> AudioStreamPlayer:
    var player: = AudioStreamPlayer.new()
    player.bus = "Music"
    player.stream = stream
    player.seek(position)
    player.autoplay = true

    if autoDestroy:
        player.finished.connect(player.queue_free)

    if playMode == AudioPlayMode.SOLO:
        for i in _musicGroup.get_children():
            i.queue_free()

    _musicGroup.add_child(player)
    return player

func play_sfx(stream: AudioStream, playmode: AudioPlayMode = AudioPlayMode.ADDITIVE) -> AudioStreamPlayer:
    var player: = AudioStreamPlayer.new()
    player.bus = "SFX"
    player.stream = stream
    player.autoplay = true
    player.finished.connect(player.queue_free)

    if playmode == AudioPlayMode.SOLO:
        for i in _sfxGroup.get_children():
            i.finished.emit()

    _sfxGroup.add_child(player)
    return player

func stop_music():
    for i in _musicGroup.get_children():
        i.finished.emit()
        i.queue_free()
    pass

func set_pause_music(state: bool):
    for i in _musicGroup.get_children():
        i.stream_paused = state
    pass

func stop_sfx():
    for i in _sfxGroup.get_children():
        i.finished.emit()
        i.queue_free()
    pass

func set_pause_sfx(state: bool):
    for i in _sfxGroup.get_children():
        i.stream_paused = state
    pass
