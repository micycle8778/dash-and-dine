class_name Grabbable extends RigidBody3D

@export var outline_shader: ShaderMaterial

var grabbed_neighbors: Array[Grabbable]
var grabbed := false:
	set(v):
		grabbed = v
		freeze = grabbed

		if grabbed:
			grabbed_neighbors = []
			for body in get_colliding_bodies():
				if body is Grabbable and body.global_position.y > global_position.y:
					grabbed_neighbors.push_back(body)
					body.freeze = true
			last_pos = global_position
			enable_outline_shader()
		else:
			linear_velocity = instant_velocity
			for body in grabbed_neighbors:
				body.freeze = false
				body.linear_velocity = instant_velocity
			disable_outline_shader()

func enable_outline_shader() -> void:
	if outline_shader != null:
		outline_shader.set_shader_parameter("enabled", true)

func disable_outline_shader() -> void:
	if outline_shader != null:
		outline_shader.set_shader_parameter("enabled", false)

func _process(delta: float) -> void:
	$Sprite3D.visible = freeze #and false

var last_pos: Vector3
var instant_velocity: Vector3
func _physics_process(delta: float) -> void:
	if not grabbed: return
	instant_velocity = (global_position - last_pos) / delta
	last_pos = global_position

# check if we're colliding with a grabbed grabbable
# func _physics_process(delta: float) -> void:
# 	if grabbed: return
#
# 	for body in get_colliding_bodies():
# 		if body is Grabbable and body.grabbed:
# 			freeze = true
# 			return
# 	
# 	freeze = false
