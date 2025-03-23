extends CanvasLayer

func pause() -> void:
	visible = true
	get_tree().paused = true
	MouseStack.push(Input.MOUSE_MODE_VISIBLE)

func unpause() -> void:
	visible = false
	get_tree().paused = false
	MouseStack.pop(Input.MOUSE_MODE_VISIBLE)
	SaveSystem.save()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not Player.instance.frozen:
		if get_tree().paused:
			unpause()
		else:
			pause()

func _on_sens_slider_value_changed(value:float) -> void:
	SaveSystem.save_data.sens = value

func _on_sfx_vol_slider_value_changed(value:float) -> void:
	SaveSystem.save_data.sfx_vol = value
	SaveSystem.commit_volume()

func _on_music_vol_slider_value_changed(value:float) -> void:
	SaveSystem.save_data.music_vol = value
	SaveSystem.commit_volume()

func _on_resume_button_pressed() -> void:
	unpause()

