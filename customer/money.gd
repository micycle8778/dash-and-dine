class_name Money extends Grabbable

@onready var value_label: Label3D = %ValueLabel

var value: float = 5.:
	set(v):
		value = v
		_update_value()

func _update_value():
	if not is_node_ready(): return
	value_label.text = "$%.2f" % value

func _ready() -> void:
	_update_value()
