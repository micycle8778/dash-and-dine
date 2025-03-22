class_name PlateFood extends Grabbable

@export var food_item: FoodItem

func _on_body_entered(body:Node) -> void:
	if body is Plate:
		var plate := body as Plate
		if plate.contained_food != null: return
		plate.contained_food = food_item
		queue_free()

