class_name World extends Node3D

static var instance: World

var difficulty: float = 1.

func _init() -> void:
	instance = self

func _ready() -> void:
	MouseStack.push(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	difficulty += delta / 200
	if Input.is_action_just_pressed("debug_reset"):
		get_tree().reload_current_scene()


func _on_stats_time_expired() -> void:
	pass # Replace with function body.

