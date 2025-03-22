@tool
class_name Button3D extends Node3D

signal pressed

@onready var label: Label3D = %Label3D

@export var text: String:
	set(v):
		text = v
		_update_text()

@export var outline_shader: ShaderMaterial

func _update_text() -> void:
	if label:
		label.text = text

func _ready() -> void:
	_update_text()

func enable_outline_shader() -> void:
	if outline_shader != null:
		outline_shader.set_shader_parameter("enabled", true)

func disable_outline_shader() -> void:
	if outline_shader != null:
		outline_shader.set_shader_parameter("enabled", false)
