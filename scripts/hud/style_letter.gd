extends Node

@export var progress_bar: TextureProgressBar
@export var label: Label

# Texturas configurables desde el editor
@export var texture_under: Texture2D
@export var texture_progress: Texture2D

# Datos de la letra
@export var letter_name: String = "D"
@export var description: String = "Domador"

# Colores y tween
@export var full_color: Color = Color(0.2, 1.0, 0.2)  # Verde
@export var empty_color: Color = Color(1.0, 1.0, 1.0) # Blanco
@export var tween_duration := 0.3

var tween: Tween

func _ready():
	if texture_under:
		progress_bar.texture_under = texture_under
	if texture_progress:
		progress_bar.texture_progress = texture_progress
	
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_bar.tint_progress = empty_color
	
	if label:
		label.text = description
	
	tween = create_tween()

func set_value(value: float):
	if not progress_bar:
		return
	
	value = clamp(value, 0, 100)
	
	if tween:
		tween.kill()
	tween = create_tween()
	
	tween.tween_property(progress_bar, "value", value, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	var ratio = value / 100.0
	var new_color = empty_color.lerp(full_color, ratio)
	progress_bar.tint_progress = new_color
