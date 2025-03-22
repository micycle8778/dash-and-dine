class_name Customer extends Node3D

var desired_food_items: Array[FoodItem]

@onready var michael: Area3D = %Michael

@onready var dummy_ticket: Node3D = %Ticket
var ticket_transform: Transform3D

func _ready() -> void:
	ticket_transform = dummy_ticket.global_transform

	dummy_ticket.queue_free()

func _check_for_grabbable(body: Node3D, predicate: Callable) -> Grabbable:
	if body is not Grabbable: return null
	var grabbable := body as Grabbable
	if grabbable.state != Grabbable.State.FREE: return null
	if grabbable.linear_velocity.length() > .1: return null
	if grabbable.still_time < 1.: return
	if not predicate.call(grabbable): return null
	return grabbable

func _is_valid_ticket(grabbable: Grabbable) -> bool:
	if not desired_food_items.is_empty(): return false
	if grabbable is not Ticket: return false
	var ticket := grabbable as Ticket
	if ticket.written_in: return false
	return true

func _physics_process(_delta: float) -> void:
	for body in michael.get_overlapping_bodies():
		if _check_for_grabbable(body, _is_valid_ticket) != null:
			var ticket: Ticket = _check_for_grabbable(body, _is_valid_ticket)
			ticket.written_in = true
			ticket.state = Grabbable.State.ANIMATED
			ticket.global_transform = ticket_transform

			await get_tree().create_timer(3., false).timeout
			
			while desired_food_items.size() < 2:
				var food_item := FoodItem.get_random_food_item()
				ticket.add_food_item(food_item)
				desired_food_items.append(food_item)

			ticket.state = Grabbable.State.FREE
			ticket.global_transform = global_transform
			ticket.position.y += 1.5
			await get_tree().physics_frame
			ticket.apply_central_force(
				quaternion * \
				Quaternion.from_euler(Vector3(0., randf_range(-.2, .2), 0)) * \
				Vector3(0, 1, -1).normalized() * randf_range(1000, 1100)
			)
			ticket.apply_torque_impulse(Vector3(
				randf_range(-3, 3),
				randf_range(-3, 3),
				randf_range(-3, 3),
			))
