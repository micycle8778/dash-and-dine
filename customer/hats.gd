extends Node3D

func _ready() -> void:
	get_children().pick_random().visible = true
