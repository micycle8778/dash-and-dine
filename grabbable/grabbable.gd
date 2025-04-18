class_name Grabbable extends RigidBody3D

signal grabbed

enum State {
	FREE,
	GRABBED,
	PASSENGER,
	ANIMATED
}

const GRAV_MUL := 1.75

@export var outline_shader: ShaderMaterial

var state: State = State.FREE:
	set(v):
		# freeze = v != State.FREE
		freeze = v == State.GRABBED or v == State.ANIMATED
		_leave_state(state)
		state = v
		_enter_state(v)

var driver: Grabbable
var passengers: Array[Grabbable]
var still_time := 0.
var grabbable := false

@onready var driver_cast: RayCast3D = %DriverCast

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
		State.PASSENGER:
			gravity_scale /= GRAV_MUL
		State.ANIMATED:
			process_mode = Node.PROCESS_MODE_INHERIT

func _enter_state(new_state: State) -> void:
	match new_state:
		State.GRABBED:
			grabbed.emit()
			passengers = []
			for body in get_colliding_bodies():
				if body is Grabbable and body.global_position.y > global_position.y:
					passengers.push_back(body)
					body.driver = self
					body.state = State.PASSENGER
			last_pos = global_position
			enable_outline_shader()
			has_moved = false
		State.PASSENGER:
			gravity_scale *= GRAV_MUL
		State.ANIMATED:
			grabbable = false
			process_mode = Node.PROCESS_MODE_DISABLED

func _ready() -> void:
	var aabb := AABB()
	for child in get_children():
		if child is MeshInstance3D:
			var mi := child as MeshInstance3D
			aabb = aabb.merge(mi.get_aabb())
	
	$Label3D.text = "%.2f" % aabb.size.y
	driver_cast.target_position.y = -(aabb.size.y / 2. + .05)

	if outline_shader == null or not outline_shader.resource_local_to_scene:
		push_error(get_path(), " does not have a unique outline shader!")

var has_moved := false
## move grabbed object to specified global position
func move_to(global_pos: Vector3, global_rot: Vector3, delta: float) -> void:
	assert(state == State.GRABBED)

	var relative_poss: Dictionary[Grabbable, Vector3]
	for body in passengers:
		relative_poss[body] = to_local(body.global_position)
	
	global_position = global_pos
	global_rotation = global_rot

	for body in relative_poss:
		body.displace(to_global(relative_poss[body]) - body.global_position, delta, has_moved)

	has_moved = true

var passenger_velocity: Vector3
func displace(amount: Vector3, delta: float, grabbed_has_moved: bool) -> void:
	if not grabbed_has_moved:
		passenger_velocity = Vector3.ZERO
		position += amount
		linear_velocity = Vector3.ZERO

var last_pos: Vector3
var instant_velocity: Vector3

# track grabbed velocity
func _grabbed_physics(delta: float) -> void:
	instant_velocity = (global_position - last_pos) / delta
	last_pos = global_position

func _physics_process(delta: float) -> void:
	if state == State.FREE and linear_velocity.is_zero_approx():
		still_time += delta
	else:
		still_time = 0.

	if state == State.GRABBED:
		_grabbed_physics(delta)
		return

	var grabbable: Grabbable = driver_cast.get_collider()
	if grabbable == null: return
	var is_passenger = driver_cast.is_colliding() and grabbable.state == State.GRABBED
	if is_passenger and state != State.PASSENGER:
		driver = grabbable
		driver.passengers.push_back(self)
		state = State.PASSENGER
	elif not is_passenger and state != State.FREE:
		driver.passengers.remove_at(driver.passengers.find(self))
		driver = null
		state = State.FREE
