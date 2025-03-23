extends Button

func _ready() -> void:
	if OS.has_feature("web"):
		queue_free()
