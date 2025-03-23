extends CanvasLayer

var _target_scene: PackedScene

func _anim_change_scene() -> void:
	get_tree().change_scene_to_packed(_target_scene)

func change_scene(target: PackedScene) -> void:
	_target_scene = target
	$AnimationPlayer.play("transition")
