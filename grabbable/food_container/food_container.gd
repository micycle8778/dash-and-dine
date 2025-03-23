class_name FoodContainer extends Grabbable

signal contained_food_updated(food_item: FoodItem)

@export var acceptable_foods: Array[FoodItem]
var contained_food: FoodItem:
	set(v):
		contained_food = v
		contained_food_updated.emit(v)

func can_accept_food(food_item: FoodItem) -> bool:
	for f in acceptable_foods:
		if f.equals(food_item):
			return true
	return false
