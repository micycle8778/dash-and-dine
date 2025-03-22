extends Node3D

var salad_scene := preload("res://food/salad.tscn")
var burger_scene := preload("res://food/burger.tscn")

@onready var spawning_machine: SpawningMachine = %SpawningMachine

func _spawn(ps: PackedScene) -> void:
	var node := ps.instantiate() as Node3D
	node.position = get_parent().to_local(spawning_machine.spawn_pos)
	add_sibling(node)

func _on_salad_button_pressed() -> void:
	_spawn(salad_scene)

func _on_burger_button_pressed() -> void:
	_spawn(burger_scene)
