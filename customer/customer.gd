class_name Customer extends Node3D

enum State {
	APPROACHING,
	SEATED,
	ORDERED,
	PAYING,
	LEAVING
}

var state = State.APPROACHING:
	set(v):
		state = v
		bobbing = state in [State.APPROACHING, State.LEAVING]

		if state == State.LEAVING:
			Globals.customer_leaves.emit(patience / initial_patience)

@export var head_material: StandardMaterial3D
@export var body_material: StandardMaterial3D
@export var head_colors: Gradient
@export var body_colors: Gradient

var money_scene := preload("res://customer/money.tscn")
var desired_food_items: Array[FoodItem]

var bob_clock: float = 0.
var bobbing := true:
	set(v):
		if bobbing != v:
			bob_clock = 0.
		bobbing = v


@onready var michael: Area3D = %Michael
@onready var mesh: Node3D = %customer

@onready var dummy_ticket: Node3D = %Ticket
@onready var ticket_transform = dummy_ticket.transform

@onready var patience_label: Label3D = %PatienceLabel
var patience := randf_range(80, 120)
@onready var initial_patience := patience

class Lifetime extends Node:
	var duration: float
	func _init(new_duration: float) -> void:
		duration = new_duration
	func _ready() -> void:
		await get_tree().create_timer(duration, false).timeout
		get_parent().queue_free()

func _ready() -> void:
	dummy_ticket.queue_free()

	head_material.albedo_color = head_colors.sample(randf())
	body_material.albedo_color = body_colors.sample(randf())

func _check_for_grabbable(body: Node3D, predicate: Callable) -> Grabbable:
	if body is not Grabbable: return null
	var grabbable := body as Grabbable
	if grabbable.state != Grabbable.State.FREE: return null
	if grabbable.linear_velocity.length() > .1: return null
	if grabbable.still_time < .4: return
	if not predicate.call(grabbable): return null
	return grabbable

func _is_valid_ticket(grabbable: Grabbable) -> bool:
	if not state == State.SEATED: return false
	if not desired_food_items.is_empty(): return false
	if grabbable is not Ticket: return false
	var ticket := grabbable as Ticket
	if ticket.written_in: return false
	return true

func _is_valid_tray(grabbable: Grabbable) -> bool:
	if not state == State.ORDERED: return false
	if grabbable is not Tray: return false
	if grabbable.still_time < 2.: return false
	return true

func _fling(body: RigidBody3D, z: float = -1, min_power: float = 1000, max_power: float = 1100) -> void:
	body.apply_central_force(
		global_transform * \
		(Vector3(0, 1, z).normalized() * randf_range(min_power, max_power)).rotated(Vector3.UP, randf_range(-.2, .2))
	)
	body.apply_torque_impulse(Vector3(
		randf_range(-3, 3),
		randf_range(-3, 3),
		randf_range(-3, 3),
	))

func _throw_fit(at_player: bool) -> void:
	for body in michael.get_overlapping_bodies():
		if body is Grabbable:
			var z := -1 if at_player else 1
			_fling(body, z)

func _process(delta: float) -> void:
	if state == State.SEATED or state == State.ORDERED:
		patience -= delta * World.instance.difficulty

		if patience <= 0:
			Globals.angry_customer.emit()
			state = State.LEAVING
	patience_label.text = "%.1f/%.1f" % [patience, initial_patience]
	
	if bobbing:
		bob_clock += delta * 2.5
		# magic number from initial mesh offset
		mesh.position.y = 0.812 + absf(sin(bob_clock)) / 2.
	

func _physics_process(_delta: float) -> void:
	for body in michael.get_overlapping_bodies():
		if _check_for_grabbable(body, _is_valid_ticket) != null:
			var ticket: Ticket = _check_for_grabbable(body, _is_valid_ticket)
			ticket.written_in = true
			ticket.state = Grabbable.State.ANIMATED
			state = State.ORDERED

			var t := create_tween().tween_property(ticket, "global_transform", global_transform * ticket_transform, .15)
			await t.finished
			await get_tree().create_timer(3., false).timeout

			state = State.ORDERED
			patience *= 1.5
			
			while desired_food_items.size() < 2:
				var food_item := FoodItem.get_random_food_item()
				ticket.add_food_item(food_item)
				desired_food_items.append(food_item)

			ticket.state = Grabbable.State.FREE
			ticket.global_transform = global_transform
			ticket.position.y += 1.5
			await get_tree().physics_frame
			_fling(ticket)
		elif _check_for_grabbable(body, _is_valid_tray) != null:
			var tray: Tray = _check_for_grabbable(body, _is_valid_tray)
			var fs := desired_food_items.duplicate()
			for container in tray.get_food_containers():
				if container.contained_food == null:
					_throw_fit(true)
					return
				else:
					# find contained food in list of desired foods
					var idx = fs.find_custom(func(x): return x.equals(container.contained_food))
					if idx == -1:
						_throw_fit(true)
						return
					fs.remove_at(idx)

			if fs.is_empty():
				# happy
				_throw_fit(false)
				
				for container in tray.get_food_containers():
					container.add_child(Lifetime.new(5.))
				tray.add_child(Lifetime.new(5.))

				var value := 7 + 20 * (patience / initial_patience)
				state = State.PAYING
				Globals.customer_served.emit()

				await get_tree().create_timer(2., false).timeout

				var cs := get_tree().current_scene as Node3D
				var money := money_scene.instantiate() as Money
				money.value = value
				money.position = cs.to_local(global_position) + Vector3.UP * 1.5

				cs.add_child(money)

				_fling(money, -1, 900, 1000)

				state = State.LEAVING

			else:
				_throw_fit(true)
				return
