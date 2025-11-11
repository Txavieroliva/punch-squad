extends Control

@onready var button_jugar = $Botones/Jugar
#@onready var button_opciones = $Botones/Opciones
@onready var button_controles = $Botones/Controles
@onready var button_tienda = $Botones/Tienda
@onready var button_salir = $Botones/Salir

@onready var gem_label = $Imagenes/Gemas/GemasLabel
@onready var gem_add_button = $Imagenes/Gemas/TextureButton

@onready var label_tiempo = $Imagenes/SkinPJ/TimerLabel  # Reemplaza con el path correcto del Label del tiempo
@export var duracion_inicial: int = 60 * 30  # 30 minutos = 1800 segundos
var tiempo_restante: int

#@onready var mission_label = $BottomPanel/MissionsPanel/MissionLabel
#@onready var mission_progress = $BottomPanel/MissionsPanel/MissionProgress
#@onready var battle_pass_label = $BottomPanel/BattlePassPanel/LevelLabel
#@onready var outfit_timer = $Imagenes/SkinPJ/TimerLabel

var gems := 100
var battle_pass_level := 1
var outfit_timer_seconds := 25 * 60  # 25 minutos

func _ready():
	# Conectar botones
	button_jugar.pressed.connect(_on_jugar_pressed)
	#button_opciones.pressed.connect(_on_opciones_pressed)
	button_tienda.pressed.connect(_on_tienda_pressed)
	button_salir.pressed.connect(_on_salir_pressed)
	button_controles.pressed.connect(_on_controles_pressed)
	gem_add_button.pressed.connect(_on_add_gems)
	
	# Actualizar labels iniciales
	_update_ui()
	
	tiempo_restante = duracion_inicial
	actualizar_tiempo()
	
	# Crea un temporizador que dispare cada segundo
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_tick)

#func _process(delta):
	## Temporizador falso de outfit
	#if outfit_timer_seconds > 0:
		#outfit_timer_seconds -= delta
		#outfit_timer.text = _format_time(outfit_timer_seconds)
	#else:
		#outfit_timer.text = "¡OFERTA TERMINADA!"

func _update_ui():
	gem_label.text = str(gems)
	#battle_pass_label.text = str(battle_pass_level)
	#mission_label.text = "Alcanza el rango de Estilo S en 3 partidas distintas"
	#mission_progress.text = "0/3"

# --- Botones principales ---
func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/jugar.tscn")

#func _on_opciones_pressed():
	#get_tree().change_scene_to_file("res://ui/OpcionesMenu.tscn")

func _on_tienda_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/tienda.tscn")

func _on_controles_pressed():
	get_tree().change_scene_to_file("res://escenas/main menu/controles.tscn")

func _on_salir_pressed():
	get_tree().quit()

# --- Gemas falsas ---
func _on_add_gems():
	gems += 50
	_update_ui()

func _on_tick():
	if tiempo_restante > 0:
		tiempo_restante -= 1
		actualizar_tiempo()
	else:
		finalizar_oferta()

func actualizar_tiempo():
	var minutos = tiempo_restante / 60
	var segundos = tiempo_restante % 60
	label_tiempo.text = "%02d:%02d" % [minutos, segundos]

func finalizar_oferta():
	label_tiempo.text = "¡FINALIZADA!"
	$DescuentoLabel.text = "-%0"
	# Aquí podés añadir cualquier animación o notificación adicional
