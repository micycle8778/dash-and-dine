class_name World extends Node3D

static var instance: World

var difficulty: float = 1.

@onready var tutorial: bool = not SaveSystem.save_data.tutorial_completed

func _init() -> void:
	instance = self

func _ready() -> void:
	MouseStack.push(Input.MOUSE_MODE_CAPTURED)

	if tutorial:
		DJMusicMan.play_tutorial()
	else:
		DJMusicMan.play_game()

func _process(delta: float) -> void:
	difficulty += (delta / 175) * 2.
	if Input.is_action_just_pressed("debug_reset") and OS.has_feature("editor"):
		get_tree().reload_current_scene()

