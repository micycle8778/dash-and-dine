class_name SpawningMachine extends StaticBody3D

@onready var spawn_pos: Vector3 = %SpawnPos.global_position:
	get:
		%SpawnSFX.play()
		return spawn_pos
