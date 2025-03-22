class_name FoodContainer extends Grabbable

signal contained_food_updated(food_item: FoodItem)

@export var acceptable_foods: Array[FoodItem]
var contained_food: FoodItem:
	set(v):
		contained_food = v
		contained_food_updated.emit(v)
