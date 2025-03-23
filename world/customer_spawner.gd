extends Node3D

const WALK_SPEED := 1.78 * 1.5

var customers: Dictionary[Customer, PathFollow3D]
var customer_scene := preload("res://customer/customer.tscn")

@onready var first_path: Path3D = %FirstPath
@onready var branching_paths: Node3D = %BranchingPaths
@onready var spawn_timer: Timer = %SpawnTimer

func _ready() -> void:
	_on_spawn_timer_timeout()

func _get_random_path() -> Path3D:
	return branching_paths.get_children()\
			.filter(func(x: Node): return x.get_child_count() == 0)\
			.pick_random()

# drive path follows
func _process(delta: float) -> void:
	for customer in customers:
		var path_follow := customers[customer]
		if customer.state == Customer.State.APPROACHING:
			path_follow.progress += delta * WALK_SPEED
			if path_follow.progress_ratio >= 1.:
				if path_follow.get_parent() == first_path:
					first_path.remove_child(path_follow)
					_get_random_path().add_child(path_follow)
					path_follow.progress = 0
				else:
					print("hai")
					customer.state = Customer.State.SEATED
		elif customer.state == Customer.State.LEAVING:
			path_follow.progress -= delta * WALK_SPEED
			if path_follow.progress_ratio <= 0.:
				if path_follow.get_parent() != first_path:
					path_follow.get_parent().remove_child(path_follow)
					first_path.add_child(path_follow)
					path_follow.progress = 1.
				else:
					path_follow.queue_free()

func _remove_customer(customer: Customer) -> void:
	if customer.state == Customer.State.LEAVING and customer.get_parent().get_parent() == first_path:
		customers.erase(customer)

func _on_spawn_timer_timeout() -> void:
	spawn_timer.start(spawn_timer.wait_time - 0.2)
	if customers.size() >= 5: return

	var customer: Customer = customer_scene.instantiate()
	var path_follow := PathFollow3D.new()
	path_follow.loop = false
	customers[customer] = path_follow
	customer.tree_exiting.connect(_remove_customer.bind(customer))

	path_follow.add_child(customer)
	first_path.add_child(path_follow)



