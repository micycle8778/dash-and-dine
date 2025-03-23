class_name Bowl extends FoodContainer

@onready var soup: Node3D = %Soup
@onready var fruit: Node3D = %Fruit

func _on_contained_food_updated(food_item:FoodItem) -> void:
	soup.visible = contained_food.equals(FoodItem.Soup)
	fruit.visible = contained_food.equals(FoodItem.Fruit)
