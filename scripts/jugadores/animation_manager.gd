extends Node

@onready var sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var player = get_parent()

signal animation_finished(anim_name: String)

func _ready() -> void:
	sprite.animation_finished.connect(_on_sprite_animation_finished)

func play(animation_name: String, force: bool = false) -> void:
	if player.is_dead and animation_name != "Death":
		return # No reproducir nada si está muerto
	if force or sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_sprite_animation_finished() -> void:
	var current_anim = sprite.animation
	emit_signal("animation_finished", current_anim)
	
	# SOLO ATAQUES Y COMBOS VUELVEN A IDLE
	if current_anim in ["Basic_attack", "Strong_attack", "Uppercut", "Combo_1"]:
		if not player.is_blocking:
			play("Idle")

# === EFECTO DE PARPADEO BLANCO (MOVIDO AQUÍ) ===
func _process(delta: float) -> void:
	if player.hurt_flash_timer > 0:
		player.hurt_flash_timer -= delta
		var flash = sin(player.hurt_flash_timer * 25) * 0.5 + 0.5  # Parpadeo rápido
		sprite.modulate = Color.WHITE.lerp(Color(2.5, 2.5, 2.5), flash)
		if player.hurt_flash_timer <= 0:
			sprite.modulate = Color.WHITE
