class_name Mug extends FoodContainer

@onready var soda: Node3D = %Soda
@onready var coffee: Node3D = %Coffee

func _ready() -> void:
	Globals.made_mug.emit()

func _on_contained_food_updated(food_item:FoodItem) -> void:
	soda.visible = contained_food.equals(FoodItem.Soda)
	coffee.visible = contained_food.equals(FoodItem.Coffee)

	if soda.visible:
		Globals.made_soda.emit()

