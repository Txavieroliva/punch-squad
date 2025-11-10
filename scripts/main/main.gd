extends Node2D

@onready var player1 = $Jugador1
@onready var player2 = $Jugador2
@onready var hud = $HUD

@onready var player1_style = $Jugador1/StyleSystem
@onready var player2_style = $Jugador2/StyleSystem

var p1_rounds: int = 0
var p2_rounds: int = 0
var max_rounds: int = 3
var round_timer := 99.0
var round_active := true

var p1_start_pos: Vector2 = Vector2(225, 685)
var p2_start_pos: Vector2 = Vector2(1705, 685)

func _ready():
	player1.player_suffix = "p1"
	player2.player_suffix = "p2"
	player1.global_position = p1_start_pos
	player2.global_position = p2_start_pos
	
	hud.reset_rounds()
	
	# Conectar los cambios de estilo
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
	reset_round()
	
	if p1_rounds >= max_rounds:
		print("¡P1 GANA EL MATCH!")
		get_tree().change_scene_to_file("res://victoria_p1.tscn")
	elif p2_rounds >= max_rounds:
		print("¡P2 GANA EL MATCH!")
		get_tree().change_scene_to_file("res://victoria_p2.tscn")

func reset_round():
	round_timer = 99
	round_active = true
	hud.update_timer(round_timer)
	hud.update_rounds(p1_rounds, p2_rounds)

	player1.reset()
	player2.reset()
	player1.global_position = p1_start_pos
	player2.global_position = p2_start_pos
