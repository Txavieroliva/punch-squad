extends Node2D

@export var style_levels = {
	"D": preload("res://escenas/hud/style_letter_d.tscn"),
	"C": preload("res://escenas/hud/style_letter_c.tscn"),
	"B": preload("res://escenas/hud/style_letter_b.tscn"),
	"A": preload("res://escenas/hud/style_letter_a.tscn"),
	"S": preload("res://escenas/hud/style_letter_S.tscn")
}

var current_level: String = "D"
var current_letter: Node2D = null

func _ready():
	show_style(current_level)

func show_style(level: String):
	if current_letter:
		var tween = create_tween()
		tween.tween_property(current_letter, "modulate:a", 0, 0.3)
		await tween.finished
		current_letter.queue_free()

	var scene = style_levels[level].instantiate()
	add_child(scene)
	scene.modulate.a = 0
	scene.scale = Vector2(0.8, 0.8)

	var tween_in = create_tween()
	tween_in.tween_property(scene, "modulate:a", 1, 0.4)
	tween_in.parallel().tween_property(scene, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	current_letter = scene

	match level:
		"S": start_vibration(scene, 6, 2.5)
		"A": start_vibration(scene, 4, 1.8)
		"B": start_vibration(scene, 3, 1.5)
		"C": start_vibration(scene, 2, 1.2)
		"D": start_vibration(scene, 1, 1.0)

func upgrade_style(level: String):
	if level != current_level and style_levels.has(level):
		current_level = level
		show_style(level)

func start_vibration(node: Node2D, strength: float, speed: float):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(node, "position:x", node.position.x + strength, 0.05 / speed).as_relative()
	tween.tween_property(node, "position:x", node.position.x - strength, 0.05 / speed).as_relative()
