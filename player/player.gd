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
func _handle_holding(delta: float) -> void:
	if holding == null:
		if Input.is_action_just_pressed("pickup"):
			if grab_raycast.is_colliding():
				print("get_collider = ", grab_raycast.get_collider())
				holding = grab_raycast.get_collider().get_parent()

				holding.target.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
				holding.target.freeze = true
				hold_distance_raycast.add_exception(holding.target)
			else: return
		else: return

	if Input.is_action_just_released("pickup"):
		# drop the object!
		holding.target.freeze = false
		hold_distance_raycast.remove_exception(holding.target)
		holding = null
		return

	var pos := hold_distance_raycast.to_global(hold_distance_raycast.target_position)
	if hold_distance_raycast.is_colliding():
		pos = hold_distance_raycast.get_collision_point()
	holding.target.global_position = pos

func _handle_hold_icon() -> void:
	hold_icon.visible = grab_raycast.is_colliding() and holding == null

func _process(delta: float) -> void:
	_kinematics(delta)
	_handle_hold_icon()
	_handle_holding(delta)
