extends Node2D

@onready var player1 = $Jugador1
@onready var player2 = $Jugador2

@onready var p1_hitbox = player1.get_node("PlayerHitboxArea")
@onready var p1_punch = player1.get_node("PunchHitbox")
@onready var p2_hitbox = player2.get_node("PlayerHitboxArea")
@onready var p2_punch = player2.get_node("PunchHitbox")

var p1_rounds: int = 0
var p2_rounds: int = 0

func _ready():
	player1.player_suffix = "p1"
	player2.player_suffix = "p2"

func _process(delta):
	# J1 QUIETO → Mirar a J2
	if player1.get_node("MovementSystem").direction.x == 0:
		var flip1 = player2.global_position.x < player1.global_position.x
		player1.get_node("AnimationManager").sprite.flip_h = flip1
		player1.get_node("PunchHitbox").position.x = -30 if flip1 else 30
	
	# J2 QUIETO → Mirar a J1
	if player2.get_node("MovementSystem").direction.x == 0:
		var flip2 = player1.global_position.x < player2.global_position.x
		player2.get_node("AnimationManager").sprite.flip_h = flip2
		player2.get_node("PunchHitbox").position.x = -30 if flip2 else 30

func player_died(dead_player):
	if dead_player == player1:
		p2_rounds += 1
		print("¡P2 GANA ROUND! " + str(p1_rounds) + " - " + str(p2_rounds))
	else:
		p1_rounds += 1
		print("¡P1 GANA ROUND! " + str(p1_rounds) + " - " + str(p2_rounds))
	
	await get_tree().create_timer(2.5).timeout
	reset_round()

func reset_round():
	player1.health = player1.max_health
	player1.is_dead = false
	p1_hitbox.monitoring = true
	p1_punch.monitoring = true
	player1.animation_manager.play("Idle")
	
	player2.health = player2.max_health
	player2.is_dead = false
	p2_hitbox.monitoring = true
	p2_punch.monitoring = true
	player2.animation_manager.play("Idle")
