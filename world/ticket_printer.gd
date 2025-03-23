extends StaticBody3D

var ticket_scene := preload("res://world/ticket.tscn")
var ticket: Ticket = null

@onready var start_transform: Transform3D = %TicketStart.global_transform
@onready var end_transform: Transform3D = %TicketEnd.global_transform

func _ready() -> void:
	%TicketStart.queue_free()
	%TicketEnd.queue_free()

func _process(delta: float) -> void:
	if ticket == null:
		ticket = ticket_scene.instantiate()
		add_sibling(ticket)

		ticket.state = Grabbable.State.ANIMATED
		ticket.global_transform = start_transform
		var tween := create_tween() 
		tween.tween_property(ticket, "global_transform", end_transform, 2.)
		await tween.finished

		ticket.state = Grabbable.State.FREE

		await ticket.grabbed
		await get_tree().create_timer(2., false).timeout
		ticket = null
