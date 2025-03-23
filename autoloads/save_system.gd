extends Node

const save_file := "user://save.dat"

var save_data := {
	high_score = 0.,

	music_vol = 1.,
	sfx_vol = 1.,
	sens = 0.,

	tutorial_completed = false
}

func _ready() -> void:
	load_save()

func save() -> void:
	FileAccess.open(save_file, FileAccess.WRITE).store_var(save_data)

func load_save() -> void:
	if not FileAccess.file_exists(save_file): return
	save_data = FileAccess.open(save_file, FileAccess.READ).get_var()
	commit_volume()

func commit_volume() -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), save_data.music_vol)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), save_data.sfx_vol)

func sens_multiplier() -> float:
	var s := save_data.sens as float
	if s < 0.:
		return 1. / (1 - s)
	else:
		return 1. + s
