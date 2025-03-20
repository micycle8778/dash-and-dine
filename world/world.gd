extends Node3D

func _ready() -> void:
	MouseStack.push(Input.MOUSE_MODE_CAPTURED)
