extends Node2D

@onready var player1 = $Jugador1
@onready var player2 = $Jugador2
@onready var player1_hitbox = $Jugador1/PlayerHitboxArea
@onready var player1_punch_hitbox = $Jugador1/PunchHitbox
@onready var player2_hitbox = $Jugador2/PlayerHitboxArea
@onready var player2_punch_hitbox = $Jugador2/PunchHitbox
@onready var player1_style = $Jugador1/StyleSystem
@onready var player2_style = $Jugador2/StyleSystem
@onready var hud = $HUD

var p1_rounds: int = 0
var p2_rounds: int = 0
var max_rounds: int = 3  # Best of 3

var round_timer := 99.0
var round_active := true

var p1_start_pos: Vector2 = Vector2(225, 685)  # Posición inicial P1
var p2_start_pos: Vector2 = Vector2(1705, 685)   # Posición inicial P2

func _ready():
	player1.player_suffix = "p1"
	player2.player_suffix = "p2"
	player1.global_position = p1_start_pos
	player2.global_position = p2_start_pos
	hud.reset_rounds()
	player1_style.style_changed.connect(_on_p1_style_changed)
	player2_style.style_changed.connect(_on_p2_style_changed)

func _process(delta):
	if player1.get_node("MovementSystem").direction.x == 0:
		player1.face_opponent(player2.global_position)
	if player2.get_node("MovementSystem").direction.x == 0:
		player2.face_opponent(player1.global_position)

	if round_active:
		round_timer -= delta
		if round_timer <= 0:
			round_active = false
		hud.update_timer(int(round_timer))

	hud.update_health(player1.health, player2.health)

	# ✅ Usamos update_style_meter en vez de update_style
	hud.update_style_meter(
		1,
		player1.style_system.current_style_level,
		player1.style_system.current_style_points,
		player1.style_system.style_points_to_next[player1.style_system.current_style_level]
	)
	hud.update_style_meter(
		2,
		player2.style_system.current_style_level,
		player2.style_system.current_style_points,
		player2.style_system.style_points_to_next[player2.style_system.current_style_level]
	)

func player_died(dead_player):
	if dead_player == player1:
		p2_rounds += 1
	else:
		p1_rounds += 1
	hud.update_rounds(p1_rounds, p2_rounds)
	
	await get_tree().create_timer(2.5).timeout
	reset_round()
	
	
	# Verificar victoria final
	if p1_rounds >= max_rounds:
		print("¡P1 GANA EL MATCH!")
		# Ir a pantalla de victoria
		get_tree().change_scene_to_file("res://victoria_p1.tscn")
	elif p2_rounds >= max_rounds:
		print("¡P2 GANA EL MATCH!")
		# Ir a pantalla de victoria
		get_tree().change_scene_to_file("res://victoria_p2.tscn")

func reset_round():
	round_timer = 99
	round_active = true
	hud.update_timer(round_timer)
	hud.update_rounds(p1_rounds, p2_rounds)
	
	# RESET P1
	player1.health = player1.max_health
	player1.is_dead = false
	player1.knockback_velocity = Vector2.ZERO
	player1.stun_timer = 0.0
	player1.is_stunned = false
	player1.hurt_flash_timer = 0.0
	player1.current_combo = []
	player1.combo_timer = 0.0
	player1.combo_active = false
	player1.style_system.current_style_level = 0
	player1.style_system.current_style_points = 0.0
	player1.velocity = Vector2.ZERO
	player1.global_position = p1_start_pos
	player1_hitbox.monitoring = true
	player1_punch_hitbox.monitoring = false
	player1.animation_manager.play("Idle")
	
	# RESET P2
	player2.health = player2.max_health
	player2.is_dead = false
	player2.knockback_velocity = Vector2.ZERO
	player2.stun_timer = 0.0
	player2.is_stunned = false
	player2.hurt_flash_timer = 0.0
	player2.current_combo = []
	player2.combo_timer = 0.0
	player2.combo_active = false
	player2.style_system.current_style_level = 0
	player2.style_system.current_style_points = 0.0
	player2.velocity = Vector2.ZERO
	player2.global_position = p2_start_pos
	player2_hitbox.monitoring = true
	player2_punch_hitbox.monitoring = false
	player2.animation_manager.play("Idle")

func _on_p1_style_changed(level, progress):
	hud.update_style_meter(
		1,
		$Jugador1/StyleSystem.current_style_level,
		$Jugador1/StyleSystem.current_style_points,
		$Jugador1/StyleSystem.style_points_to_next[$Jugador1/StyleSystem.current_style_level]
	)

func _on_p2_style_changed(level, progress):
	hud.update_style_meter(
		2,
		$Jugador2/StyleSystem.current_style_level,
		$Jugador2/StyleSystem.current_style_points,
		$Jugador2/StyleSystem.style_points_to_next[$Jugador2/StyleSystem.current_style_level]
	)
