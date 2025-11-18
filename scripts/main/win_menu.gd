extends Control

signal restart_requested
signal return_to_menu_requested

func set_winner_text(player_name: String):
	$Panel/Ganador.text = player_name + " ganó la pelea!"

func _on_reiniciar_pressed() -> void:
	restart_requested.emit()


func _on_menu_principal_pressed() -> void:
	return_to_menu_requested.emit()
