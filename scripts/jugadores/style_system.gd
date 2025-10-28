extends Node

@onready var player = get_parent()

@export var style_points_to_next: Array = [100, 200, 300, 400]
@export var style_decay_rate: Array = [10.0, 20.0, 30.0, 40.0, 50.0]
@export var style_repeat_penalty: int = 20
@export var combo_style_bonus: int = 30

var current_style_level: int = 0
var current_style_points: float = 0.0
var last_attack_type: String = ""
var style_decay_timer: float = 0.0

func _process(delta: float) -> void:
	if current_style_level > 0 and not player.is_attacking:
		style_decay_timer += delta
		var decay_rate = style_decay_rate[current_style_level]
		if style_decay_timer >= 1.0:
			style_decay_timer = 0.0
			current_style_points = max(0, current_style_points - decay_rate)
			
			if current_style_points <= 0 and current_style_level > 0:
				current_style_level -= 1
				current_style_points = style_points_to_next[current_style_level] * 0.8
				print("¡Estilo bajó a: " + get_style_letter() + "!")

func add_style_points(points: int) -> void:
	if current_style_level >= 4: return
	current_style_points += points
	var threshold = style_points_to_next[current_style_level]
	if current_style_points >= threshold:
		current_style_points -= threshold
		current_style_level += 1
		print("¡Estilo subido a: " + get_style_letter() + "!")
		play_style_up_effect()

func play_style_up_effect() -> void:
	# Igual que antes
	var label = Label.new()
	label.text = get_style_letter() + "!"
	label.modulate = [Color.WHITE, Color.YELLOW, Color.ORANGE, Color.RED, Color.PURPLE][current_style_level]
	label.add_theme_font_size_override("font_size", 36)
	label.position = player.global_position + Vector2(-30, -80)
	player.get_parent().add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 60, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)

func get_style_letter() -> String:
	return ["D", "C", "B", "A", "S"][current_style_level]

func get_damage_multiplier() -> float:
	return [1.0, 1.2, 1.5, 1.8, 2.2][current_style_level]

func apply_attack_penalty(type: String) -> void:
	if last_attack_type == type and player.current_combo.size() == 0:
		current_style_points = max(0, current_style_points - style_repeat_penalty)
		print("¡Repetiste ataque! -" + str(style_repeat_penalty) + " estilo")
	else:
		add_style_points(15 if type == "basic" else 25)
	last_attack_type = type

func apply_hit_penalty() -> void:
	if current_style_level > 0:
		current_style_level -= 1
		current_style_points = style_points_to_next[current_style_level] * 0.7
		print("¡Estilo bajó por golpe! Ahora: " + get_style_letter())
