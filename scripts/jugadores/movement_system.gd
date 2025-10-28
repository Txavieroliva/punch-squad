extends Node

@onready var player = get_parent()
@onready var anim_manager = player.get_node("AnimationManager")

@export var speed: float = 450.0
@export var jump_velocity: float = -680.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Gravedad
	if not player.is_on_floor():
		player.velocity.y += gravity * delta
	
	if not player.is_attacking:
		# Movimiento lateral
		direction.x = Input.get_action_strength("move_right_p1") - Input.get_action_strength("move_left_p1")
		player.velocity.x = direction.x * speed
		
		# Salto
		if Input.is_action_just_pressed("jump_p1") and player.is_on_floor():
			player.velocity.y = jump_velocity
	
	else:
		player.velocity.x = 0
	
	# Animaciones (solo si no bloqueando o atacando)
	if not player.is_on_floor():
		anim_manager.play("Jump" if player.velocity.y < 0 else "Jump_fall")
	elif not player.is_attacking and not player.is_blocking:
		anim_manager.play("Run" if direction.x != 0 else "Idle")
	
	# Flip sprite
	if direction.x > 0:
		anim_manager.sprite.flip_h = false
	elif direction.x < 0:
		anim_manager.sprite.flip_h = true
	
	player.move_and_slide()
