extends CanvasLayer

@onready var p1_health_bar = $P1Container/P1HealthBar
@onready var p1_style_meter = $P1Container/P1StyleMeter
@onready var p2_health_bar = $P2Container/P2HealthBar
@onready var p2_style_meter = $P2Container/P2StyleMeter
@onready var timer_label = $CenterTimer
@onready var p1_rounds = $P1Rounds.get_children()
@onready var p2_rounds = $P2Rounds.get_children()

var round_time: int = 99
var health_tween_duration := 0.25

func _ready():
	timer_label.text = str(round_time)
	reset_rounds()

# ---------------------------------------------------------------
# ROUNDS
# ---------------------------------------------------------------
func reset_rounds():
	for circle in p1_rounds:
		circle.modulate = Color(1, 1, 1)
	for circle in p2_rounds:
		circle.modulate = Color(1, 1, 1)

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

# ---------------------------------------------------------------
# TIMER
# ---------------------------------------------------------------
func update_timer(time_left: int):
	timer_label.text = str(time_left)

# ---------------------------------------------------------------
# HEALTH
# ---------------------------------------------------------------
func update_health(p1_health: int, p2_health: int):
	var tween1 = create_tween()
	tween1.tween_property(p1_health_bar, "value", p1_health, health_tween_duration)
	var tween2 = create_tween()
	tween2.tween_property(p2_health_bar, "value", p2_health, health_tween_duration)

# ---------------------------------------------------------------
# STYLE METER (usa el script StyleMeter)
# ---------------------------------------------------------------
func update_style_meter(player_id: int, level: int, points: float, threshold: float):
	if player_id == 1 and p1_style_meter:
		p1_style_meter.set_style(level, points, threshold)
	elif player_id == 2 and p2_style_meter:
		p2_style_meter.set_style(level, points, threshold)
