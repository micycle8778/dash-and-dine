class_name FoodItem extends Resource

static var Burger = FoodItem.create("burger")
static var Salad = FoodItem.create("salad")

static var Soup = FoodItem.create("soup")
static var Fruit = FoodItem.create("fruit")

static var Soda = FoodItem.create("soda")
static var Coffee = FoodItem.create("coffee")

@export var display_name: String

static func create(display_name: String) -> FoodItem:
	var ret := FoodItem.new()
	ret.display_name = display_name

	return ret

static func get_random_food_item() -> FoodItem:
	return [Burger, Salad, Soup, Fruit, Soda, Coffee].pick_random()
