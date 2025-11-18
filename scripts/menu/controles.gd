extends Control

@onready var boton_volver = $Botones/Volver

func _ready():
	boton_volver.pressed.connect(_on_volver_pressed)
	MusicManager.play_menu_music()

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/main menu/main menu.tscn")
