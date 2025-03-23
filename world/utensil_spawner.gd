extends Node3D

var plate_scene := preload("res://grabbable/food_container/plate.tscn")
var bowl_scene := preload("res://grabbable/food_container/bowl.tscn")
var mug_scene := preload("res://grabbable/food_container/mug.tscn")
var tray_scene := preload("res://grabbable/tray.tscn")

@onready var spawning_machine: SpawningMachine = %SpawningMachine

func _spawn(ps: PackedScene) -> void:
	var node := ps.instantiate() as Node3D
	node.position = get_parent().to_local(spawning_machine.spawn_pos)
	add_sibling(node)

func _on_plate_button_pressed() -> void:
	_spawn(plate_scene)

func _on_tray_button_pressed() -> void:
	_spawn(tray_scene)

func _on_bowl_button_pressed() -> void:
	_spawn(bowl_scene)

func _on_mug_button_pressed() -> void:
	_spawn(mug_scene)
	pass # Replace with function body.

