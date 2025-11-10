extends CanvasLayer

@onready var p1_health_bar = $P1Container/P1HealthBar
@onready var p2_health_bar = $P2Container/P2HealthBar
@onready var timer_label = $CenterTimer
@onready var p1_rounds = $P1Rounds.get_children()
@onready var p2_rounds = $P2Rounds.get_children()
@onready var p1_style_meter = $P1StyleMeter
@onready var p2_style_meter = $P2StyleMeter

var round_time: int = 99
var health_tween_duration := 0.25

func _ready():
	timer_label.text = str(round_time)
	reset_rounds()

func reset_rounds():
	for circle in p1_rounds:
		circle.modulate = Color(1, 1, 1)
	for circle in p2_rounds:
		circle.modulate = Color(1, 1, 1)

func update_health(p1_health: int, p2_health: int):
	var tween1 = create_tween()
	tween1.tween_property(p1_health_bar, "value", p1_health, health_tween_duration)
	var tween2 = create_tween()
	tween2.tween_property(p2_health_bar, "value", p2_health, health_tween_duration)

func update_timer(time_left: int):
	timer_label.text = str(time_left)

func update_rounds(p1_wins: int, p2_wins: int):
	reset_rounds()
	for i in range(p1_wins):
		if i < p1_rounds.size():
			var tween = create_tween()
			tween.tween_property(p1_rounds[i], "modulate", Color(0, 1, 0), 0.4)
	for i in range(p2_wins):
		if i < p2_rounds.size():
			var tween = create_tween()
			tween.tween_property(p2_rounds[i], "modulate", Color(1, 0, 0), 0.4)

func show_style_letter(player_id: int, letter_scene: PackedScene):
	var container = p1_style_meter if player_id == 1 else p2_style_meter
	
	# Eliminar letra anterior
	for c in container.get_children():
		c.queue_free()
	
	# Instanciar la nueva
	var letter = letter_scene.instantiate()
	container.add_child(letter)
	
	# Animación de aparición / vibración
	if letter.has_node("Label"):
		var label = letter.get_node("Label")
		var tween = create_tween()
		var intensity = 2.0 + (player_id * 0.2)
		tween.tween_property(label, "scale", Vector2(1.1, 0.9), 0.05)
		tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.05)
