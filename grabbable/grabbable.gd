class_name Grabbable extends RigidBody3D

var grabbed_neighbors: Array[Grabbable]
var grabbed := false:
	set(v):
		grabbed = v
		freeze = grabbed

		if grabbed:
			grabbed_neighbors = []
			for body in get_colliding_bodies():
				if body is Grabbable:
					grabbed_neighbors.push_back(body)
					body.freeze = true
		else:
			for body in grabbed_neighbors:
				body.freeze = false


func _process(delta: float) -> void:
	$Sprite3D.visible = freeze #and false

# check if we're colliding with a grabbed grabbable
# func _physics_process(delta: float) -> void:
# 	if grabbed: return
#
# 	for body in get_colliding_bodies():
# 		if body is Grabbable and body.grabbed:
# 			freeze = true
# 			return
# 	
# 	freeze = false
