extends CharacterBody3D

const RUN_MUL: float = 2.
const WALK_MUL: float = .5
const MOVE_SPEED: float = 8.

const GRAVITY: float = 35
const JUMP_POWER: float = 15
const MOUSE_SENSITIVITY: float = 0.0015

@onready var camera: Camera3D = %Camera3D
@onready var grab_raycast: RayCast3D = %GrabRaycast
@onready var hold_distance_raycast: RayCast3D = %HoldDistanceRaycast
@onready var button_raycast: RayCast3D = %ButtonRaycast

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sens := MOUSE_SENSITIVITY # * Globals.sensitivity
		rotation.y -= event.relative.x * sens
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * sens, -PI / 2 + 0.1, PI / 2)

func _kinematics(delta: float) -> void:
	var run_mul := 1.

	if Input.is_action_pressed("sprint"):
		run_mul *= RUN_MUL
	if Input.is_action_pressed("walk"):
		run_mul *= WALK_MUL

	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var desired_vel := transform.basis * Vector3(raw_input.x, 0, raw_input.y) * MOVE_SPEED * run_mul
	var accel :=  MOVE_SPEED * run_mul * delta * 3.5

	var dv := Vector2(desired_vel.x, desired_vel.z)
	var v := Vector2(velocity.x, velocity.z)
	
	v = v.move_toward(dv, accel)
	velocity.x = v.x
	velocity.z = v.y

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

				holding.state = Grabbable.State.GRABBED
				hold_distance_raycast.add_exception(holding)
			else: return
		else: return

	if holding.state == Grabbable.State.ANIMATED:
		holding = null
		return

	# if the player is dropping the object, drop it then return
	if Input.is_action_just_released("pickup"):
		# drop the object!
		holding.state = Grabbable.State.FREE
		hold_distance_raycast.remove_exception(holding)
		holding = null
		return

	# move the object
	var pos := hold_distance_raycast.to_global(hold_distance_raycast.target_position)
	if hold_distance_raycast.is_colliding():
		pos = hold_distance_raycast.to_local(hold_distance_raycast.get_collision_point())
		pos -= pos.normalized() * 0.20
		pos = hold_distance_raycast.to_global(pos)

	holding.move_to(pos, global_rotation, _delta)

var last_grabbable_hovered: Grabbable
func _handle_hold() -> void:
	if holding != null: return

	if grab_raycast.is_colliding():
		var grabbable = grab_raycast.get_collider()

		# apparently you can raycast a freed object??????
		if grabbable == null: return

		# check if we swapped to a different grabbable
		if last_grabbable_hovered != null and grabbable != last_grabbable_hovered:
			last_grabbable_hovered.disable_outline_shader()
		last_grabbable_hovered = grabbable

		# check if the grabbable has an outline shader
		if last_grabbable_hovered.outline_shader != null:
			last_grabbable_hovered.enable_outline_shader()
		else:
			last_grabbable_hovered = null

	# check if we just stopped looking at a grabbable
	elif last_grabbable_hovered != null:
		last_grabbable_hovered.disable_outline_shader()
		last_grabbable_hovered = null

var last_button_hovered: Button3D
func _handle_button() -> void:
	if button_raycast.is_colliding():
		var button := button_raycast.get_collider().get_parent() as Button3D

		if last_button_hovered != null and button != last_button_hovered:
			last_button_hovered.disable_outline_shader()
		last_button_hovered = button
		last_button_hovered.enable_outline_shader()

	elif last_button_hovered != null:
		last_button_hovered.disable_outline_shader()
		last_button_hovered = null

	if last_button_hovered != null and Input.is_action_just_pressed("pickup"):
		last_button_hovered.pressed.emit()

func _process(delta: float) -> void:
	_kinematics(delta)
	_handle_hold()
	_handle_holding(delta)
	_handle_button()
