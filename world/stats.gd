extends Sprite3D

signal time_expired
var clock := 300.
var running := true

@onready var piggy_bank: PiggyBank = %PiggyBank
@onready var clock_label: Label = %ClockLabel
@onready var total_label: Label = %TotalLabel
@onready var bonus_label: FlashingLabel = %BonusTimeLabel

func _process(delta: float) -> void:
	if not running: return

	clock -= delta
	if clock <= 0.:
		running = false
		time_expired.emit()
	
	var minutes := int(clock / 60.)
	var seconds := int(clock) % 60
	var millis := fmod(clock, 1.)
	var s := "%.3f" % millis
	clock_label.text = "%02d:%02d.%s" % [minutes, seconds, s.get_slice('.', 1)]

func _on_piggy_bank_total_updated(increment:float) -> void:
	total_label.text = "$%.2f" % piggy_bank.total
	var bonus_time := increment * randf_range(2., 2.5)
	clock += bonus_time
	bonus_label.text = "BONUS TIME: %.2f" % bonus_time
	bonus_label.clock = 2.
