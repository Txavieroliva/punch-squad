extends CharacterBody2D

@export var player_suffix: String = "p1"
@export var max_health: int = 350
@onready var animation_manager: Node = $AnimationManager
@onready var movement_system: Node = $MovementSystem
@onready var combat_system: Node = $CombatSystem
@onready var style_system: Node = $StyleSystem
@onready var parry_system: Node = $ParrySystem

var is_attacking: bool = false
var is_blocking: bool = false
var current_combo: Array = []
var combo_timer: float = 0.0
var combo_active: bool = false
var health: int = max_health
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var stun_timer: float = 0.0
var is_stunned: bool = false
var hurt_flash_timer: float = 0.0


func _ready() -> void:
	animation_manager.animation_finished.connect(_on_animation_finished)
	$PunchHitbox.body_entered.connect(_on_punch_hitbox_body_entered)
	style_system.style_changed.connect(_on_style_changed)
	disable_hitbox()

func _process(delta: float) -> void:
	# DETECTAR COMBO UPPERCUT: C + V PRESIONADOS AL MISMO TIEMPO
	var basic_pressed = Input.is_action_just_pressed("basic_attack_" + player_suffix)
	var strong_pressed = Input.is_action_just_pressed("strong_attack_" + player_suffix)
	if basic_pressed and strong_pressed and not is_attacking and not combo_active:
		combat_system.perform_uppercut()
		return # Cancelar otros ataques
	
	# Inputs normales
	if not is_attacking and not combo_active:
		if basic_pressed:
			combat_system.perform_basic_attack()
		elif strong_pressed:
			combat_system.perform_strong_attack()
		if Input.is_action_just_pressed("block_" + player_suffix):
			parry_system.start_blocking()
		if Input.is_action_just_released("block_" + player_suffix):
			parry_system.stop_blocking()
	
	# Timer de combo
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			current_combo.clear()
			print("No hay más combo")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name in ["Basic_attack", "Strong_attack", "Uppercut"]:
		is_attacking = false
		disable_hitbox()
		animation_manager.play("Idle")

func enable_hitbox() -> void:
	$PunchHitbox.monitoring = true
	$PunchHitbox.monitorable = true

func disable_hitbox() -> void:
	$PunchHitbox.monitoring = false
	$PunchHitbox.monitorable = false

func register_attack(type: String) -> void:
	if combo_active: return
	combo_timer = combat_system.combo_window
	current_combo.append(type)
	if current_combo.size() > 4:
		current_combo.pop_front()
	check_combo()

func check_combo() -> void:
	var seq = current_combo
	# Combo 1: Fuerte + Básico + Fuerte (para AMBOS jugadores)
	if seq.size() >= 3 and seq.slice(-3) == ["strong", "basic", "strong"]:
		# !ANIMACIÓN ESPECIAL PARA COMBO 1!
		trigger_combo_with_animation("Combo 1", 1, "Combo_1")
		return
	
	# Combo 2: Fuerte + Fuerte + Básico + Fuerte
	if seq.size() >= 4 and seq.slice(-4) == ["strong", "basic", "basic", "strong"]:
		trigger_combo("Combo 2", 2)
		return

func trigger_combo(names: String, id: int) -> void:
	if combo_active: return
	combo_active = true
	print("¡" + names + "!")
	style_system.add_style_points(style_system.combo_style_bonus * (id + 1))
	# Feedback visual (igual)
	var label = Label.new()
	label.text = names
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

func trigger_combo_with_animation(names: String, id: int, anim_name: String) -> void:
	if combo_active: return
	combo_active = true
	# INTERRUMPIR ATAQUE Y REPRODUCIR COMBO ESPECIAL
	is_attacking = true
	animation_manager.play(anim_name, true)
	enable_hitbox()
	print("¡" + names + " - ANIMACIÓN ESPECIAL!")
	style_system.add_style_points(style_system.combo_style_bonus * (id + 1) + 50) # Bonus extra
	# Feedback visual
	var label = Label.new()
	label.text = names
	label.modulate = Color(1, 0.8, 0)
	label.add_theme_font_size_override("font_size", 32)
	label.position = global_position + Vector2(-40, -60)
	get_parent().add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.8)
	tween.tween_callback(label.queue_free)
	# Esperar duración de la animación Combo_1 (ajusta según tu animación)
	await get_tree().create_timer(1.2).timeout
	current_combo.clear()
	combo_active = false
	is_attacking = false
	disable_hitbox()
	animation_manager.play("Idle")

func take_damage(amount: int, attacker) -> void:
	if parry_system.take_damage(amount, attacker): return
	
	health = max(0, health - amount)
	# PARPADEO BLANCO
	hurt_flash_timer = 0.3
	# KNOCKBACK + STUN
	var kb_dir = sign(global_position.x - attacker.global_position.x)
	knockback_velocity = Vector2(kb_dir * 2500, 0)
	stun_timer = amount * 0.02
	is_stunned = true
	if health <= 0:
		die()

func _on_punch_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body != self and not body.is_dead:
		# Calcular daño según animación actual
		var damage = combat_system.basic_damage
		match animation_manager.sprite.animation:
			"Strong_attack":
				damage = combat_system.strong_damage
			"Uppercut":
				damage = combat_system.uppercut_damage
			"Combo_1":
				damage = combat_system.strong_damage * 1.5 # Bonus combo
		damage *= style_system.get_damage_multiplier()
		body.take_damage(int(damage), self)
		print("¡DAÑO APLICADO! " + str(damage))

func face_opponent(opponent_global_pos: Vector2) -> void:
	if is_attacking: return # No girar durante ataque
	var my_pos = global_position
	var dir_to_opponent = sign(opponent_global_pos.x - my_pos.x)
	if dir_to_opponent == 0: return # Mismo eje X
	var should_flip = dir_to_opponent < 0 # true = mirar izquierda
	# Solo cambiar si NO hay input de movimiento
	if get_node("MovementSystem").direction.x == 0:
		get_node("AnimationManager").sprite.flip_h = should_flip
		get_node("PunchHitbox").scale.x = -1 if should_flip else 1

func die() -> void:
	#if is_dead: return
	is_dead = true
	print("¡" + player_suffix.to_upper() + " MUERTO!")
	# REPRODUCIR ANIMACIÓN DEATH
	animation_manager.play("Death", true)
	# Desactivar colisiones y inputs
	$PlayerHitboxArea.monitoring = false
	$PunchHitbox.monitoring = false
	# Notificar a Main para round
	get_parent().player_died(self)

func _on_style_changed(level: int, points: float, threshold: float) -> void:
	var hud = get_node_or_null("/root/Main/HUD")
	if hud == null:
		return

	# Obtener la letra correspondiente según nivel
	var style_letter = ["d", "c", "b", "a", "s"][level]

	# Ruta a la escena de la letra (ej: res://ui/style_letters/D.tscn)
	var letter_path = "res://ui/style_letter_" + style_letter + ".tscn"

	if ResourceLoader.exists(letter_path):
		var letter_scene = load(letter_path)
		# Mostrar la letra correspondiente en el HUD
		hud.show_style_letter(1 if player_suffix == "p1" else 2, letter_scene)
