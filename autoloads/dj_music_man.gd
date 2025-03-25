extends AudioStreamPlayer

var playback: AudioStreamPlaybackInteractive

func _ready() -> void:
	play()
	playback = get_stream_playback()

func play_title_screen() -> void:
	playback.switch_to_clip_by_name("title-screen")

func play_tutorial() -> void:
	playback.switch_to_clip_by_name("tutorial")

func play_game() -> void:
	playback.switch_to_clip_by_name("game")

func stop_playing() -> void:
	playback.switch_to_clip_by_name("empty")
