class_name PiggyBank extends Area3D

signal total_updated(increment: float)

var total: float = 0:
	set(v):
		var diff := v - total
		total = v
		total_updated.emit(diff)

func _on_body_entered(body:Node3D) -> void:
	if body is Money:
		total += (body as Money).value
		%OinkSFX.play()
		body.queue_free()

