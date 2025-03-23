extends Node

const save_file := "user://save.dat"

var save_data := {
	high_score = 0.,

	main_vol = 0.,
	music_vol = 0.,
	sfx_vol = 0.,
	vo_vol = 0.,
}

func _ready() -> void:
	load_save()

func save() -> void:
	FileAccess.open(save_file, FileAccess.WRITE).store_var(save_data)

func load_save() -> void:
	if not FileAccess.file_exists(save_file): return
	save_data = FileAccess.open(save_file, FileAccess.READ).get_var()
