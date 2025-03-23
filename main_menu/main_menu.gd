extends Node3D

@onready var burger: Node3D = %Burger
@onready var mug: Node3D = %Mug
@onready var logo: Sprite2D = %Logo

@onready var burger_pos := burger.position
@onready var mug_pos := mug.position
@onready var logo_pos := logo.position

var clock := 0.

func _ready() -> void:
	MouseStack.override(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	clock += delta

	var amplitude := 0.1
	burger.position = burger_pos + Vector3(0., sin(clock), 0.) * amplitude
	mug.position = mug_pos + Vector3(0., sin(clock + PI / 4), 0.) * amplitude

	logo.position = logo_pos + Vector2(0., -cos(clock)) * 15

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world/world.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

