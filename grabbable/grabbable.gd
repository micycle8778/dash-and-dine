class_name Grabbable extends Node3D

## Object to be moved by the player when being held
@export var target: RigidBody3D

@onready var remote: RemoteTransform3D = %RemoteTransform3D
@onready var grab_box: Area3D = %GrabBox

func _ready() -> void:
	remove_child(remote)
	target.add_child(remote)
	remote.remote_path = remote.get_path_to(grab_box)
