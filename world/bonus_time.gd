class_name FlashingLabel extends Label

var clock := 0.0

func _process(delta: float) -> void:
	if clock <= 0: 
		visible = false
		return

	clock -= delta
	visible = fmod(clock, .5) > 0.25
