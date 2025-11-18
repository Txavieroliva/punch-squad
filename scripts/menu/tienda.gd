extends Control

@onready var label_gemas = $Imagenes/Gemas/GemasLabel  # Ajustá el path según tu escena
@onready var boton_comprar = $Botones/Compra  # Botón de $10.99
@onready var boton_volver = $Botones/Volver

var gemas: int = 0

func _ready():
	# Cargar gemas guardadas (si existen)
	if FileAccess.file_exists("user://datos_jugador.save"):
		var file = FileAccess.open("user://datos_jugador.save", FileAccess.READ)
		var data = file.get_var()
		file.close()
		gemas = data.get("gemas", 0)
	
	actualizar_gemas()
	boton_comprar.pressed.connect(_on_comprar_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)
	MusicManager.play_menu_music()

func _on_comprar_pressed():
	gemas += 1000
	actualizar_gemas()
	guardar_datos()

func actualizar_gemas():
	label_gemas.text = str(gemas)

func guardar_datos():
	var file = FileAccess.open("user://datos_jugador.save", FileAccess.WRITE)
	file.store_var({"gemas": gemas})
	file.close()

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/main menu.tscn")
