extends Node

@onready var player = get_parent()
@onready var anim_manager = player.get_node("AnimationManager")
@onready var punch_hitbox: Area2D = player.get_node("PunchHitbox")
@onready var punch_shape: CollisionShape2D = punch_hitbox.get_node("CollisionShape2D")

@export var speed: float = 450.0
@export var jump_velocity: float = -680.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# STUN: Bloquea movimiento y aplica fricción
	if player.is_stunned:
		player.stun_timer -= delta
		player.velocity.x *= 0.85  # Fricción fuerte
		if player.stun_timer <= 0:
			player.is_stunned = false
			player.stun_timer = 0.0
		# Durante stun: NO permitir input de movimiento
		direction.x = 0
	else:
		# Solo leer input si NO está stunned
		direction.x = Input.get_action_strength("move_right_" + player.player_suffix) - Input.get_action_strength("move_left_" + player.player_suffix)

	# KNOCKBACK: Aplica siempre si existe
	if player.knockback_velocity != Vector2.ZERO:
		player.velocity += player.knockback_velocity * delta
		player.knockback_velocity = player.knockback_velocity.lerp(Vector2.ZERO, 0.2)
		if player.knockback_velocity.length() < 10:
			player.knockback_velocity = Vector2.ZERO

	# GRAVEDAD
	if not player.is_on_floor():
		player.velocity.y += gravity * delta

	# MOVIMIENTO NORMAL (solo si no está atacando ni stunned)
	if not player.is_attacking and not player.is_stunned:
		player.velocity.x = direction.x * speed
		
		if Input.is_action_just_pressed("jump_" + player.player_suffix) and player.is_on_floor():
			player.velocity.y = jump_velocity
	else:
		# Durante ataque o stun: mantener momentum pero con fricción
		if not player.is_stunned:
			player.velocity.x *= 0.9

	# ANIMACIONES
	if not player.is_on_floor():
		anim_manager.play("Jump" if player.velocity.y < 0 else "Jump_fall")
	elif not player.is_attacking and not player.is_blocking:
		anim_manager.play("Run" if direction.x != 0 else "Idle")

	# FLIP + HITBOX (TU CÓDIGO ORIGINAL, SIN TOCAR)
	var flip_h = direction.x < 0
	if direction.x == 0:
		flip_h = anim_manager.sprite.flip_h
	anim_manager.sprite.flip_h = flip_h
	punch_hitbox.position.x = -30 if flip_h else 30

	player.move_and_slide()
