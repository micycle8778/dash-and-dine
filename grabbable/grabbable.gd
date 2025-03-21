class_name Grabbable extends RigidBody3D

@export var inertia_curve: Curve
@export var outline_shader: ShaderMaterial

enum State {
	FREE,
	GRABBED,
	PASSENGER
}

var state: State = State.FREE:
	set(v):
		freeze = v != State.FREE
		_leave_state(state)
		state = v
		_enter_state(v)

var driver: Grabbable
var passengers: Array[Grabbable]

func enable_outline_shader() -> void:
	if outline_shader != null:
		outline_shader.set_shader_parameter("enabled", true)

func disable_outline_shader() -> void:
	if outline_shader != null:
		outline_shader.set_shader_parameter("enabled", false)

func _leave_state(old_state: State) -> void:
	match old_state:
		State.GRABBED:
			linear_velocity = instant_velocity
			for body in passengers:
				if body.state == State.PASSENGER:
					body.state = State.FREE
					body.linear_velocity = instant_velocity
			disable_outline_shader()

func _enter_state(new_state: State) -> void:
	match new_state:
		State.GRABBED:
			passengers = []
			for body in get_colliding_bodies():
				if body is Grabbable and body.global_position.y > global_position.y:
					passengers.push_back(body)
					body.driver = self
					body.state = State.PASSENGER
			last_pos = global_position
			enable_outline_shader()
			has_moved = false

var has_moved := false
## move grabbed object to specified global position
func move_to(global_pos: Vector3, delta: float) -> void:
	assert(state == State.GRABBED)

	var relative_poss: Dictionary[Grabbable, Vector3]
	for body in passengers:
		relative_poss[body] = to_local(body.global_position)
	
	global_position = global_pos

	for body in relative_poss:
		body.displace(to_global(relative_poss[body]) - body.global_position, delta, has_moved)

	has_moved = true

var passenger_velocity: Vector3
func displace(amount: Vector3, delta: float, grabbed_has_moved: bool) -> void:
	position.y += amount.y
	amount.y = 0

	if not grabbed_has_moved:
		passenger_velocity = Vector3.ZERO
		position += amount
		linear_velocity = Vector3.ZERO
		return

	var requested_velocity = amount / delta
	if abs(requested_velocity.length() - passenger_velocity.length()) < 2.:
		passenger_velocity = requested_velocity
	else:
		passenger_velocity = passenger_velocity.lerp(requested_velocity, 0.1)
	
	position += passenger_velocity * delta

	# position += linear_velocity * delta
	# rotation += angular_velocity * delta
	# var requested_accel = (requested_velocity - linear_velocity) / delta
	# apply_central_force(requested_accel * 10)

func _process(_delta: float) -> void:
	$Sprite3D.visible = freeze #and false

var last_pos: Vector3
var instant_velocity: Vector3

# track grabbed velocity
func _physics_process(delta: float) -> void:
	if state != State.GRABBED: return
	instant_velocity = (global_position - last_pos) / delta
	last_pos = global_position

func _on_body_exited(body:Node) -> void:
	var grabbable := body as Grabbable
	if state != State.PASSENGER: return
	if body is not Grabbable: return
	if body.state != State.GRABBED: return
	grabbable.passengers.remove_at(grabbable.passengers.find(self))
	state = State.FREE
