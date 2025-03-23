class_name Plate extends FoodContainer

@onready var burger_mesh: Node3D = %Burger
@onready var salad_mesh: Node3D = %Salad

func _ready() -> void:
	Globals.made_plate.emit()

func _on_contained_food_updated(food_item:FoodItem) -> void:
	burger_mesh.visible = food_item.equals(FoodItem.Burger)
	salad_mesh.visible = food_item.equals(FoodItem.Salad)

	if burger_mesh.visible:
		Globals.burger_on_plate.emit()

