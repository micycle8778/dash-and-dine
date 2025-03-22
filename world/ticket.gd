class_name Ticket extends Grabbable

var written_in := false
@onready var food_items: VBoxContainer = %FoodItems

func add_food_item(food_item: FoodItem) -> void:
	var label = Label.new()
	label.text = food_item.display_name
	food_items.add_child(label)

	written_in = true
