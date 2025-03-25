extends Node3D

func _ready() -> void:
	await get_tree().process_frame

	if not World.instance.tutorial: queue_free()
	$one.show()

	await Globals.ticket_grabbed

	$one.hide()
	var two :Label3D = $two
	remove_child(two)
	get_tree().get_first_node_in_group("Customer").add_child(two)
	two.position = Vector3(0, 5., 0)
	two.show()

	await Globals.ticket_written_in

	two.hide()

	var three: Label3D = $three
	three.show()
	
	await Globals.made_tray
	three.text = "Make plate"
	await Globals.made_plate
	three.text = "Make mug"
	await Globals.made_mug
	three.text = "Make burger"
	await Globals.made_burger
	three.text = "Place burger on plate"
	await Globals.burger_on_plate
	three.text = "Place mug in pourer"
	await Globals.in_pourer
	three.text = "Make soda"
	await Globals.made_soda

	three.text = "Mug and plate on tray"
	await Globals.two_on_tray

	three.hide()
	two.show()
	two.text = "Give customer tray with items"

	await Globals.customer_served

	two.hide()

	var four: Label3D = $four
	remove_child(four)
	four.position = Vector3(0., 2., 0.)
	%PiggyBank.add_child(four)
	four.show()

	await %PiggyBank.total_updated

	SaveSystem.save_data.tutorial_complete = true
	SaveSystem.save()
	World.instance.tutorial = false
	DJMusicMan.play_game()

	four.hide()
	queue_free()
