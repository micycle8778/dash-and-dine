extends Node3D

func _ready() -> void:
	MouseStack.push(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_reset"):
		get_tree().reload_current_scene()
