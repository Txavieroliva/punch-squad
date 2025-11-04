extends Node

@onready var sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var player = get_parent()

signal animation_finished(anim_name: String)

func _ready() -> void:
	sprite.animation_finished.connect(_on_sprite_animation_finished)

func play(animation_name: String, force: bool = false) -> void:
	if force or sprite.animation != animation_name:
		sprite.play(animation_name)

func _on_sprite_animation_finished() -> void:
	var current_anim = sprite.animation
	emit_signal("animation_finished", current_anim)
	
	if current_anim in ["Basic_attack", "Strong_attack", "Uppercut", "Combo_1", "Hurt"]:
		if not player.is_blocking:
			play("Idle")
			# RESETEAR FLAG DE HURT
			if current_anim == "Hurt":
				player.is_hurt_playing = false
