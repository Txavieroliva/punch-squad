extends Control

@onready var boton_local = $Botones/Local
@onready var boton_volver = $Botones/Volver

func _ready():
	boton_local.pressed.connect(_on_boton_local_pressed)
	boton_volver.pressed.connect(_on_boton_volver_pressed)

func _on_boton_local_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/local.tscn")  # Ruta al modo local

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/main menu.tscn")  # Ruta al menú principal
