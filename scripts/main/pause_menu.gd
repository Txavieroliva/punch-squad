extends Control

@onready var boton_reanudar = $Panel/Reanudar
@onready var boton_menu = $Panel/MenuPrincipal

func _ready():
	visible = false
	boton_reanudar.pressed.connect(_on_boton_reanudar_pressed)
	boton_menu.pressed.connect(_on_boton_menu_pressed)

func show_menu():
	get_tree().paused = true
	visible = true

func hide_menu():
	get_tree().paused = false
	visible = false

func _on_boton_reanudar_pressed():
	hide_menu()

func _on_boton_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
