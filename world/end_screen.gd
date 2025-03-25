extends CanvasLayer

@onready var stats: Stats = %Stats
@onready var piggy_bank: PiggyBank = %PiggyBank

@onready var high_score_sfx: AudioStreamPlayer = %HighScoreSFX
@onready var score_tick_sfx: AudioStreamPlayer = %ScoreTickSFX

@onready var served_label: Label = %ServedLabel
@onready var lost_label: Label = %LostLabel
@onready var satisfaction_label: Label = %SatisfactionLabel
@onready var overtime_label: Label = %OvertimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel

var customers_served := 0
var angry_customers := 0
var satisfaction_count: int = 0
var satisfaction: float = 0.

func _on_customer_served() -> void:
	customers_served += 1

func _on_angry_customer() -> void:
	angry_customers += 1

func _on_customer_leaves(s: float) -> void:
	if satisfaction_count == 0:
		satisfaction = s
		satisfaction_count = 1
		return

	satisfaction = (satisfaction * satisfaction_count + s) / (satisfaction_count + 1)
	satisfaction_count += 1

	SaveSystem.save_data.tutorial_completed = true
	SaveSystem.save()

func _ready() -> void:
	Globals.customer_served.connect(_on_customer_served)
	Globals.angry_customer.connect(_on_angry_customer)
	Globals.customer_leaves.connect(_on_customer_leaves)
	pass

func _score_animate(v: float) -> void:
	score_label.text = "$%.2f" % v
	
	score_label.add_theme_font_size_override("font_size", int(remap(v, 0, 500, 36, 96)))
	var t := clampf(inverse_lerp(0, 500, v), 0, 1)
	score_label.add_theme_color_override("font_color", Color.BLACK.lerp(Color.GREEN, t))

	score_tick_sfx.pitch_scale = remap(v, 0, 500, 1, 3)
	score_tick_sfx.play()

func _anim_score_label_visible() -> void:
	var t := create_tween()
	t.tween_method(_score_animate, 0., piggy_bank.total, piggy_bank.total / 50)
	# t.tween_property(self, "score", piggy_bank.total, piggy_bank.total / 50)

	await t.finished
	await get_tree().create_timer(1.).timeout

	if SaveSystem.save_data.high_score == 0.:
		SaveSystem.save_data.high_score = piggy_bank.total
		SaveSystem.save()
	elif piggy_bank.total > SaveSystem.save_data.high_score:
		high_score_label.visible = true
		high_score_sfx.play()

		SaveSystem.save_data.high_score = piggy_bank.total
		SaveSystem.save()

	await get_tree().create_timer(3.).timeout
	SceneTransition.change_scene(preload("res://main_menu/main_menu.tscn"))

func _on_stats_time_expired() -> void:
	Player.instance.frozen = true
	DJMusicMan.stop_playing()

	# setup labels
	served_label.text = str(customers_served)
	lost_label.text = str(angry_customers)
	satisfaction_label.text = "%.1f%%" % (satisfaction * 100)
	
	var raw := stats.total_bonus_time
	var minutes := int(raw / 60)
	var seconds := int(raw) % 60
	var millis := fmod(raw, .1)
	var s := "%.3f" % millis
	overtime_label.text = "%02d:%02d.%s" % [minutes, seconds, s.get_slice('.', 1)]

	$AnimationPlayer.play("RESET")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("slide_in")
