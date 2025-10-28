extends Node

@onready var sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var player = get_parent()

signal animation_finished(anim_name: String)

#func _ready() -> void:
	#sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func play(animation_name: String, force: bool = false) -> void:
	if force or sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_animated_sprite_2d_animation_finished() -> void:
	emit_signal("animation_finished", sprite.animation)
	# Reset automático si no hay prioridad
	if not player.is_attacking and not player.is_blocking:
		play("Idle")
