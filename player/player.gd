extends CharacterBody3D

const MOVE_SPEED: float = 8

const GRAVITY: float = 35
const JUMP_POWER: float = 15
const MOUSE_SENSITIVITY: float = 0.0032

@onready var camera: Camera3D = %Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sens := MOUSE_SENSITIVITY # * Globals.sensitivity
		rotation.y -= event.relative.x * sens
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * sens, -PI / 2 + 0.1, PI / 2)

func _process(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input = transform.basis * Vector3(raw_input.x, 0, raw_input.y) * MOVE_SPEED
	velocity.x = input.x
	velocity.z = input.z

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity += Vector3.UP * JUMP_POWER

	velocity += Vector3.DOWN * GRAVITY * delta

	move_and_slide()
