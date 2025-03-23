class_name Tray extends Grabbable

@onready var area: Area3D = %Area3D

func get_food_containers() -> Array[FoodContainer]:
	var ret: Array[FoodContainer] = []
	for body in area.get_overlapping_bodies():
		if body is FoodContainer:
			ret.push_back(body)
	return ret
