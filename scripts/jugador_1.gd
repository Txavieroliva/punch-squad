extends CharacterBody2D

# Sistemas
@onready var animation_manager: Node = $AnimationManager
@onready var movement_system: Node = $MovementSystem
@onready var combat_system: Node = $CombatSystem
@onready var style_system: Node = $StyleSystem
@onready var parry_system: Node = $ParrySystem

# Variables compartidas
var is_attacking: bool = false
var is_blocking: bool = false
var current_combo: Array = []
var combo_timer: float = 0.0
var combo_active: bool = false

func _ready() -> void:
	# Conectar señal de animaciones terminadas
	animation_manager.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	# Inputs generales (solo si no atacando o en combo)
	if not is_attacking and not combo_active:
		if Input.is_action_just_pressed("basic_attack_p1"):
			combat_system.perform_basic_attack()
		if Input.is_action_just_pressed("strong_attack_p1"):
			combat_system.perform_strong_attack()
		if Input.is_action_just_pressed("block_p1"):
			parry_system.start_blocking()
		if Input.is_action_just_released("block_p1"):
			parry_system.stop_blocking()
	
	# Timer de combo
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			current_combo.clear()
			print("No hay más combo")

# Señal de animación terminada (controla is_attacking)
func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["Basic_attack", "Strong_attack"]:
		is_attacking = false
		disable_hitbox()
		animation_manager.play("Idle")

# Funciones compartidas
func enable_hitbox() -> void:
	$PunchHitbox.disabled = false

func disable_hitbox() -> void:
	$PunchHitbox.disabled = true

func register_attack(type: String) -> void:
	if combo_active: 
		return
	combo_timer = combat_system.combo_window  # Usa @export var combo_window = 1.2 en CombatSystem si quieres
	current_combo.append(type)
	if current_combo.size() > 4:
		current_combo.pop_front()
	check_combo()

func check_combo() -> void:
	var seq = current_combo
	if seq.size() >= 3 and seq[-3] == "strong" and seq[-2] == "basic" and seq[-1] == "strong":
		trigger_combo("Combo 1", 1)
	elif seq.size() >= 4 and seq[-4] == "strong" and seq[-3] == "basic" and seq[-2] == "basic" and seq[-1] == "strong":
		trigger_combo("Combo 2", 2)

func trigger_combo(name: String, id: int) -> void:
	if combo_active: return
	combo_active = true
	print("¡" + name + "!")
	style_system.add_style_points(style_system.combo_style_bonus * (id + 1))
	# Feedback visual (igual que antes)
	var label = Label.new()
	label.text = name
	label.modulate = Color(1, 0.8, 0)
	label.add_theme_font_size_override("font_size", 28)
	label.position = global_position + Vector2(-40, -60)
	get_parent().add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.8)
	tween.tween_callback(label.queue_free)
	await get_tree().create_timer(0.5).timeout
	current_combo.clear()
	combo_active = false

# Función para recibir daño (llamada desde parry_system)
func take_damage(amount: int, attacker) -> void:
	parry_system.take_damage(amount, attacker)
