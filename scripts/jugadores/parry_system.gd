extends Node

@onready var player = get_parent()
@onready var anim_manager = $"../AnimationManager"
@onready var style_system = $"../StyleSystem"

@export var parry_window: float = 0.15
@export var parry_style_bonus: int = 1

var parry_active: bool = false
var parry_timer: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("block_p1") and player.is_blocking:
		anim_manager.play("Block")
	if parry_active:
		parry_timer -= delta
		if parry_timer <= 0:
			parry_active = false

func start_blocking() -> void:
	if player.is_attacking: return
	player.is_blocking = true
	parry_active = true
	parry_timer = parry_window
	anim_manager.play("Block", true)
	print("¡Bloqueando! (Parry ventana: " + str(parry_window) + "s)")

func stop_blocking() -> void:
	player.is_blocking = false
	if not parry_active and not player.is_attacking:
		anim_manager.play("Idle")

func take_damage(amount: int, attacker) -> void:
	if parry_active:
		trigger_parry()
		return
	
	if player.is_blocking:
		amount = int(amount * 0.3)
		print("Bloqueado: " + str(amount) + " daño recibido")
	else:
		print("¡Golpeado! " + str(amount) + " daño")
	
	style_system.apply_hit_penalty()

func trigger_parry() -> void:
	parry_active = false
	player.is_blocking = false
	print("¡PARRY PERFECTO!")
	if style_system.current_style_level < 4:
		style_system.current_style_level += 1
	style_system.current_style_points = style_system.style_points_to_next[style_system.current_style_level] * 0.5
	# Feedback visual
	var label = Label.new()
	label.text = "PARRY!"
	label.modulate = Color.CYAN
	label.add_theme_font_size_override("font_size", 32)
	label.position = player.global_position + Vector2(-50, -70)
	player.get_parent().add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 50, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.8)
	tween.tween_callback(label.queue_free)
