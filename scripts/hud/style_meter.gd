extends Node

@export var letters: Array[Node] # Array de StyleLetter (D, C, B, A, S)
@export var active_color: Color = Color(1.0, 1.0, 0.2)
@export var inactive_color: Color = Color(0.4, 0.4, 0.4)

var current_level: int = 0
var current_points: float = 0.0
var max_points_for_level: float = 100.0

func _ready():
	update_visuals()

func set_style(level: int, points: float, max_points: float):
	current_level = clamp(level, 0, letters.size() - 1)
	current_points = points
	max_points_for_level = max_points
	update_visuals()

func update_visuals():
	for i in range(letters.size()):
		var letter_node = letters[i]
		if i < current_level:
			letter_node.set_value(100)
		elif i == current_level:
			var percent = (current_points / max_points_for_level) * 100.0
			letter_node.set_value(percent)
		else:
			letter_node.set_value(0)
