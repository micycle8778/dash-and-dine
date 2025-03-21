class_name Grabbable extends RigidBody3D

var grabbed := false:
	set(v):
		grabbed = v
		freeze = grabbed

func _process(delta: float) -> void:
	$Sprite3D.visible = freeze

# check if we're colliding with a grabbed grabbable
func _physics_process(delta: float) -> void:
	if grabbed: return

	for body in get_colliding_bodies():
		if body is Grabbable and body.grabbed:
			freeze = true
			return
	
	freeze = false
