extends CharacterBody2D

# --- Movimiento de jugador ---
@export var speed: float = 450.0  # Velocidad de movimiento lateral
@export var jump_velocity: float = -680.0  # Fuerza de salto (ajusta para altura)
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2 = Vector2.ZERO

# --- Manejo de ataques ---
@export var basic_damage: int = 10
@export var strong_damage: int = 20
var is_attacking: bool = false

# --- Sistema de Combos ---
@export var combo_window: float = 1.2
@export var combo_style_bonus: int = 30
var current_combo: Array = []
var combo_timer: float = 0.0
var combo_active: bool = false

# --- Sistema de Estilo ---
@export var style_points_to_next: Array = [100, 200, 300, 400]  # D→C, C→B, B→A, A→S
@export var style_decay_rate: Array = [10.0, 20.0, 30.0, 40.0, 50.0]  # Por segundo en cada nivel
@export var style_repeat_penalty: int = 20
@export var style_hit_penalty: int = 50  # Más adelante

var current_style_level: int = 0  # 0=D, 1=C, 2=B, 3=A, 4=S
var current_style_points: float = 0.0
var last_attack_type: String = ""
var style_decay_timer: float = 0.0

# --- Sistema de Parry ---
@export var parry_window: float = 0.15  # Ventana en segundos para parry
@export var parry_style_bonus: int = 1  # Sube 1 nivel de estilo

var is_blocking: bool = false
var parry_active: bool = false
var parry_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Aplicar gravedad siempre
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_attacking:
		# Movimiento lateral
		direction.x = Input.get_action_strength("move_right_p1") - Input.get_action_strength("move_left_p1")
		velocity.x = direction.x * speed
		
		# Salto (solo si en suelo)
		if Input.is_action_just_pressed("jump_p1") and is_on_floor():
			velocity.y = jump_velocity
		
		# Animaciones
		if not is_on_floor():
			if velocity.y < 0:
				$AnimatedSprite2D.play("Jump")  # Ascenso
			else:
				$AnimatedSprite2D.play("Jump_fall")  # Descenso
		else:
			if is_blocking:
				$AnimatedSprite2D.play("Block")  # PRIORIDAD MÁXIMA
			elif direction.x != 0:
				$AnimatedSprite2D.play("Run")
			else:
				$AnimatedSprite2D.play("Idle")
		
		# Voltear sprite
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		elif direction.x < 0:
			$AnimatedSprite2D.flip_h = true
	else:
		# Durante ataque, detiene movimiento lateral pero permite caída si en aire
		velocity.x = 0
	
	move_and_slide()

func _process(delta: float) -> void:
	
	# Manejo de ataques
	if not is_attacking and not combo_active:
		if Input.is_action_just_pressed("basic_attack_p1"):
			perform_basic_attack()
		elif Input.is_action_just_pressed("strong_attack_p1"):
			perform_strong_attack()
	
	# Timer de ventana de combo
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			current_combo.clear()  # Timeout
			print("No hay más combo")
	
	#Manejo de estilo
	if current_style_level > 0 and not is_attacking:
		style_decay_timer += delta
		var decay_rate = style_decay_rate[current_style_level]
		if style_decay_timer >= 1.0:
			style_decay_timer = 0.0
			current_style_points = max(0, current_style_points - decay_rate)
			
			# Bajar de nivel si se vacía
			if current_style_points <= 0 and current_style_level > 0:
				current_style_level -= 1
				current_style_points = style_points_to_next[current_style_level] * 0.8  # Mitad llena
				print("¡Estilo bajó a: ", get_style_letter(), "!")
	
	# Manejo de Parry y Bloqueo
	if not is_attacking and not combo_active:
		if Input.is_action_just_pressed("block_p1"):
			start_blocking()  # Activa parry + bloqueo
		elif Input.is_action_pressed("block_p1") and is_blocking:
			# Mantener bloqueo mientras se presiona
			$AnimatedSprite2D.play("Block")
		elif Input.is_action_just_released("block_p1"):
			stop_blocking()
	
	# Timer de parry (solo para la ventana de parry)
	if parry_active:
		parry_timer -= delta
		if parry_timer <= 0:
			parry_active = false  # Solo termina la ventana de parry, NO el bloqueo
	
	# === PRUEBA DE PARRY (ELIMINAR DESPUÉS) ===
	if Input.is_action_just_pressed("ui_accept"):  # Presiona ENTER
		print("Simulando golpe...")
		take_damage(20, null)  # ¡DESCOMENTADO!
	# ========================================

func perform_basic_attack() -> void:
	is_attacking = true
	$AnimatedSprite2D.play("Basic_attack")
	enable_hitbox()
	print("Ataque básico: " + str(basic_damage * get_damage_multiplier()) + " daño")
	
	# --- ESTILO ---
	if last_attack_type == "basic":
		apply_attack_penalty()
	else:
		add_style_points(15)  # Puntos base por ataque variado
	
	last_attack_type = "basic"
	register_attack("basic")

func perform_strong_attack() -> void:
	is_attacking = true
	$AnimatedSprite2D.play("Strong_attack")
	enable_hitbox()
	print("Ataque fuerte: " + str(strong_damage * get_damage_multiplier()) + " daño")
	
	# --- ESTILO ---
	if last_attack_type == "strong":
		apply_attack_penalty()
	else:
		add_style_points(25)  # Fuerte da más puntos (riesgo/recompensa)
	
	last_attack_type = "strong"
	register_attack("strong")

# Señal conectada desde AnimatedSprite2D
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation in ["Basic_attack", "Strong_attack"]:
		is_attacking = false
		disable_hitbox()
		$AnimatedSprite2D.play("Idle")

func enable_hitbox() -> void:
	$PunchHitbox.disabled = false

func disable_hitbox() -> void:
	$PunchHitbox.disabled = true

func register_attack(type: String) -> void:
	if combo_active:
		return
	combo_timer = combo_window
	current_combo.append(type)
	if current_combo.size() > 4:
		current_combo.pop_front()
	check_combo()

func check_combo() -> void:
	var seq = current_combo
	# Combo 1: Fuerte + Básico + Fuerte
	if seq.size() >= 3 and seq[-3] == "strong" and seq[-2] == "basic" and seq[-1] == "strong":
		trigger_combo("Combo 1", 1)
		print("Combo 1 detectado")
	# Combo 2: Fuerte Fuerte Básico Fuerte
	elif seq.size() >= 4 and seq[-4] == "strong" and seq[-3] == "basic" and seq[-2] == "basic" and seq[-1] == "strong":
		trigger_combo("Combo 2", 2)
		print("Combo 2 detectado")

func trigger_combo(name: String, id: int) -> void:
	if combo_active: return
	combo_active = true
	print("¡" + name + "!")
	
	# --- ESTILO: BONUS DE COMBO ---
	add_style_points(combo_style_bonus * (id + 1))  # Combo 1 = 30, Combo 2 = 60
	
	# Feedback visual
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

func add_style_points(points: int) -> void:
	if current_style_level >= 4:
		return  # Ya en S
	current_style_points += points
	# Subir de nivel si se alcanza el umbral
	var threshold = style_points_to_next[current_style_level]
	if current_style_points >= threshold:
		current_style_points -= threshold
		current_style_level += 1
		print("¡Estilo subido a: ", get_style_letter(), "!")
		play_style_up_effect()

func play_style_up_effect() -> void:
	var label = Label.new()
	label.text = get_style_letter() + "!"
	label.modulate = [Color.WHITE, Color.YELLOW, Color.ORANGE, Color.RED, Color.PURPLE][current_style_level]
	label.add_theme_font_size_override("font_size", 36)
	label.position = global_position + Vector2(-30, -80)
	get_parent().add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 60, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)

func get_style_letter() -> String:
	return ["D", "C", "B", "A", "S"][current_style_level]

func get_damage_multiplier() -> float:
	return [1.0, 1.2, 1.5, 1.8, 2.2][current_style_level]  # Ajusta según balance

func apply_attack_penalty() -> void:
	if last_attack_type != "" and current_combo.size() == 0:
		current_style_points = max(0, current_style_points - style_repeat_penalty)
		print("¡Repetiste ataque! -", style_repeat_penalty, " estilo")

func start_blocking() -> void:
	is_blocking = true
	parry_active = true
	parry_timer = parry_window
	$AnimatedSprite2D.play("Block")
	print("¡Bloqueando! (Parry ventana: ", parry_window, "s)")

func stop_blocking() -> void:
	is_blocking = false
	# Solo volver a Idle si no hay parry activo y no estamos atacando
	if not parry_active and not is_attacking:
		$AnimatedSprite2D.play("Idle")

func trigger_parry() -> void:
	parry_active = false
	is_blocking = false
	print("¡PARRY PERFECTO!")
	
	# Subir 1 nivel de estilo
	if current_style_level < 4:
		current_style_level += 1
	current_style_points = style_points_to_next[current_style_level] * 0.5  # Mitad llena
	
	# Feedback visual
	var label = Label.new()
	label.text = "PARRY!"
	label.modulate = Color.CYAN
	label.add_theme_font_size_override("font_size", 32)
	label.position = global_position + Vector2(-50, -70)
	get_parent().add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 50, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.8)
	tween.tween_callback(label.queue_free)
	

func apply_hit_penalty() -> void:
	if current_style_level > 0:
		current_style_level -= 1
		current_style_points = style_points_to_next[current_style_level] * 0.7
		print("¡Estilo bajó por golpe! Ahora: ", get_style_letter())

func take_damage(amount: int, attacker) -> void:
	if parry_active:
		# ¡PARRY EXITOSO!
		trigger_parry()
		return  # No recibe daño
	
	if is_blocking:
		# Bloqueo normal: reduce daño
		amount = int(amount * 0.3)
		print("Bloqueado: ", amount, " daño recibido")
	else:
		print("¡Golpeado! ", amount, " daño")
	# health -= amount
	apply_hit_penalty()  # Baja estilo
