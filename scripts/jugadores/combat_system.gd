extends Node

@onready var player = get_parent()
@onready var anim_manager = player.get_node("AnimationManager")
@onready var style_system = player.get_node("StyleSystem")

@export var basic_damage: int = 10
@export var strong_damage: int = 20
@export var combo_window: float = 1.2

func perform_basic_attack() -> void:
	player.is_attacking = true
	anim_manager.play("Basic_attack", true)
	player.enable_hitbox()
	print("Ataque básico: " + str(basic_damage * style_system.get_damage_multiplier()) + " daño")
	style_system.apply_attack_penalty("basic")
	player.register_attack("basic")

func perform_strong_attack() -> void:
	player.is_attacking = true
	anim_manager.play("Strong_attack", true)
	player.enable_hitbox()
	print("Ataque fuerte: " + str(strong_damage * style_system.get_damage_multiplier()) + " daño")
	style_system.apply_attack_penalty("strong")
	player.register_attack("strong")
