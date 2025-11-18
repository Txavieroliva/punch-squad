extends Node

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

var menu_music: AudioStream
var gameplay_music: AudioStream

func _ready():
	# Cargar musicas
	menu_music = load("res://assets/musica/Musica-menu.wav")
	gameplay_music = load("res://assets/musica/Musica-combate.wav")

	play_menu_music()

func play_menu_music():
	if music_player.stream != menu_music:
		music_player.stream = menu_music
		music_player.play()

func play_gameplay_music():
	music_player.stream = gameplay_music
	music_player.play()  # Reinicia desde el inicio

func stop_music():
	music_player.stop()
