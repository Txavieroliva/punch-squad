extends Control

@onready var boton_jugar = $Botones/PVP
@onready var boton_volver = $Botones/Volver

func _ready():
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_volver.pressed.connect(_on_boton_volver_pressed)

func _on_boton_jugar_pressed():
	get_tree().change_scene_to_file("res://escenas/main/main.tscn")  # Escena de pelea local

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/jugar.tscn")
