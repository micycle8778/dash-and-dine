extends Node3D

var container: FoodContainer
var flung_container: FoodContainer
var filled_container: FoodContainer

@onready var area: Area3D = %Area3D
@onready var pos: Vector3 = %Pos.global_position

@onready var pour_sfx: AudioStreamPlayer3D = %PourSFX

@onready var soda_vfx: Node3D = %SodaVFX
@onready var coffee_vfx: Node3D = %CoffeeVFX
@onready var soup_vfx: Node3D = %SoupVFX
@onready var fruit_vfx: Node3D = %FruitVFX

@onready var explode_particles: CPUParticles3D = %ExplosionVFX
@onready var smoke_particles: CPUParticles3D = %SmokeVFX
@onready var explode_sound: AudioStreamPlayer3D = %ExplosionSFX

func _new_container() -> void:
	container.linear_velocity = Vector3.ZERO
	container.state = Grabbable.State.ANIMATED
	container.rotation = Vector3.ZERO
	container.global_position = pos

	if container is Mug:
		Globals.in_pourer.emit()

func _physics_process(_delta: float) -> void:
	if filled_container != null: return
	if container == null:
		for body in area.get_overlapping_bodies():
			if body == flung_container: continue
			if body is Mug or body is Bowl:
				var fc := body as FoodContainer
				if fc.contained_food == null:
					container = fc
					_new_container()
					return

func _get_vfx(food_item: FoodItem) -> Node3D:
	if food_item.equals(FoodItem.Soda):
		return soda_vfx
	if food_item.equals(FoodItem.Coffee):
		return coffee_vfx
	if food_item.equals(FoodItem.Soup):
		return soup_vfx
	if food_item.equals(FoodItem.Fruit):
		return fruit_vfx
	return null

var pouring := false
func _pour(food_item: FoodItem) -> void:
	if container == null: return
	if pouring: return

	if not container.can_accept_food(food_item):
		container.state = Grabbable.State.FREE
		await get_tree().physics_frame
		container.apply_central_force(
			quaternion * \
			Quaternion.from_euler(Vector3(0., randf_range(-.3, .3), 0)) * \
			Vector3(0, 1, -2).normalized() * randf_range(1000, 1100)
		)

		explode_particles.emitting = true
		smoke_particles.emitting = true
		explode_sound.playing = true

		flung_container = container
		container = null
		return

	pouring = true

	var vfx := _get_vfx(food_item)
	vfx.visible = true
	pour_sfx.play()
	await pour_sfx.finished
	vfx.visible = false

	pouring = false
	container.contained_food = food_item
	container.state = Grabbable.State.FREE
	filled_container = container
	container = null

func _on_coffee_button_pressed() -> void:
	_pour(FoodItem.Coffee)

func _on_soda_button_pressed() -> void:
	_pour(FoodItem.Soda)

func _on_fruit_button_pressed() -> void:
	_pour(FoodItem.Fruit)

func _on_soup_button_pressed() -> void:
	_pour(FoodItem.Soup)

func _on_area_3d_body_exited(body:Node3D) -> void:
	if body == filled_container:
		filled_container = null
	if body == flung_container:
		flung_container = null

