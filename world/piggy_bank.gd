class_name PiggyBank extends Area3D

signal total_updated(new_total: float)

var total: float = 0:
	set(v):
		total = v
		total_updated.emit(v)

func _on_body_entered(body:Node3D) -> void:
	if body is Money:
		total += (body as Money).value
		body.queue_free()

