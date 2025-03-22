@tool
class_name Conveyor extends Node3D

@export var shader: ShaderMaterial

@onready var sb: StaticBody3D = %StaticBody3D

@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var conveyor_speed: float = 1.0:
	set(v):
		conveyor_speed = v
		_update_speed()

func _update_speed() -> void:
	if shader != null:
		shader.set_shader_parameter("speed", conveyor_speed)
	if sb != null:
		sb.constant_linear_velocity.z = -conveyor_speed * .9

func _ready() -> void:
	_update_speed()
