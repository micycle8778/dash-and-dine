extends Node

@onready var tray: Tray = get_parent()

func _ready() -> void:
	if not World.instance.tutorial: queue_free()

func _physics_process(delta: float) -> void:
	if tray.get_food_containers().size() == 2:
		Globals.two_on_tray.emit()
