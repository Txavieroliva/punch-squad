extends Control

@onready var boton_volver = $Botones/Volver

func _ready():
	boton_volver.pressed.connect(_on_boton_volver_pressed)

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
