extends Label

func _ready() -> void:
	if SaveSystem.save_data.high_score == 0.:
		visible = false
	
	text = text % SaveSystem.save_data.high_score
