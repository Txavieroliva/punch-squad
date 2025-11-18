extends Node2D

@onready var player1 = $Jugador1
@onready var player2 = $Jugador2
@onready var player1_hitbox = $Jugador1/PlayerHitboxArea
@onready var player1_punch_hitbox = $Jugador1/PunchHitbox
@onready var player2_hitbox = $Jugador2/PlayerHitboxArea
@onready var player2_punch_hitbox = $Jugador2/PunchHitbox
@onready var player1_style = $Jugador1/StyleSystem
@onready var player2_style = $Jugador2/StyleSystem   # ✅ corregido
@onready var hud = $HUD
@onready var pause_menu = $PauseMenu
@onready var win_menu = $WinMenu


var p1_rounds: int = 0
var p2_rounds: int = 0
var max_rounds: int = 3
var round_timer := 99.0
var round_active := true

var p1_start_pos: Vector2 = Vector2(225, 790)
var p2_start_pos: Vector2 = Vector2(1705, 790)

func _ready():
	player1.player_suffix = "p1"
	player2.player_suffix = "p2"
	player1.global_position = p1_start_pos
	player2.global_position = p2_start_pos
	MusicManager.play_gameplay_music()
	hud.reset_rounds()
	
	# Conectar los cambios de estilo
	player1_style.style_changed.connect(_on_p1_style_changed)
	player2_style.style_changed.connect(_on_p2_style_changed)
	win_menu.restart_requested.connect(_on_restart_match)
	win_menu.return_to_menu_requested.connect(_on_return_to_menu)


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

func _on_p1_style_changed(level: int, points: float, threshold: float):
	var style_letter = ["D", "C", "B", "A", "S"][level]
	hud.p1_style_meter.upgrade_style(style_letter)

func _on_p2_style_changed(level: int, points: float, threshold: float):
	var style_letter = ["D", "C", "B", "A", "S"][level]
	hud.p2_style_meter.upgrade_style(style_letter)


func player_died(dead_player):
	if dead_player == player1:
		p2_rounds += 1
	else:
		p1_rounds += 1

	hud.update_rounds(p1_rounds, p2_rounds)

	await get_tree().create_timer(2.5).timeout

	# ¿Alguien ganó el match?
	if p1_rounds >= max_rounds:
		show_win_menu("Player 1")
	elif p2_rounds >= max_rounds:
		show_win_menu("Player 2")
	else:
		reset_round()



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
	# RESET ESTILO (delegado al StyleSystem)
	player1.style_system.reset_style()
	player2.style_system.reset_style()
	
	# Forzar actualización visual en HUD (por si hubiera desincronía)
	var style_letter_p1 = ["D", "C", "B", "A", "S"][player1.style_system.current_style_level]
	var style_letter_p2 = ["D", "C", "B", "A", "S"][player2.style_system.current_style_level]
	hud.p1_style_meter.upgrade_style(style_letter_p1)
	hud.p2_style_meter.upgrade_style(style_letter_p2)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		# Si el juego está pausado, ESC reanuda
		if get_tree().paused:
			pause_menu.hide_menu()
		else:
			pause_menu.show_menu()

func show_win_menu(winner_name: String):
	get_tree().paused = true
	win_menu.set_winner_text(winner_name)
	win_menu.visible = true

	# Ocultar el HUD y el PauseMenu
	hud.visible = false
	pause_menu.visible = false

func _on_restart_match():
	get_tree().paused = false
	p1_rounds = 0
	p2_rounds = 0
	hud.reset_rounds()
	win_menu.visible = false
	hud.visible = true
	reset_round()

func _on_return_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
