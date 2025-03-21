extends CharacterBody3D

const MOVE_SPEED: float = 8

const GRAVITY: float = 35
const JUMP_POWER: float = 15
const MOUSE_SENSITIVITY: float = 0.0015

@onready var camera: Camera3D = %Camera3D
@onready var grab_raycast: RayCast3D = %GrabRaycast
@onready var hold_distance_raycast: RayCast3D = %HoldDistanceRaycast
@onready var hold_icon: CanvasItem = %HoldIcon

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sens := MOUSE_SENSITIVITY # * Globals.sensitivity
		rotation.y -= event.relative.x * sens
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * sens, -PI / 2 + 0.1, PI / 2)

func _kinematics(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input = transform.basis * Vector3(raw_input.x, 0, raw_input.y) * MOVE_SPEED
	velocity.x = input.x
	velocity.z = input.z

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity += Vector3.UP * JUMP_POWER

	velocity += Vector3.DOWN * GRAVITY * delta

	move_and_slide()

var holding: Grabbable = null
func _handle_holding(_delta: float) -> void:
	# if we're not holding anything, check if the player is trying to hold something
	# if they aren't or can't, return
	if holding == null:
		if Input.is_action_just_pressed("pickup"):
			if grab_raycast.is_colliding():
				holding = grab_raycast.get_collider()

				holding.grabbed = true
				hold_distance_raycast.add_exception(holding)
			else: return
		else: return

	# if the player is dropping the object, drop it then return
	if Input.is_action_just_released("pickup"):
		# drop the object!
		holding.grabbed = false
		hold_distance_raycast.remove_exception(holding)
		holding = null
		return

	# move the object
	var pos := hold_distance_raycast.to_global(hold_distance_raycast.target_position)
	if hold_distance_raycast.is_colliding():
		pos = hold_distance_raycast.get_collision_point()

	# first, lets build a list of items that `holding` is touching
	var cols: Dictionary[Grabbable, Vector3] # grabbable : position relative to `holding`
	for body in holding.grabbed_neighbors:
		cols[body] = holding.to_local(body.global_position)

	# execute the move
	holding.global_position = pos

	# move everything else
	for body in cols:
		body.global_position = holding.to_global(cols[body])

func _handle_hold_icon() -> void:
	hold_icon.visible = grab_raycast.is_colliding() and holding == null

func _process(delta: float) -> void:
	_kinematics(delta)
	_handle_hold_icon()
	_handle_holding(delta)
