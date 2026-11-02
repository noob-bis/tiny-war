extends Node2D

@onready var result_label = $ResultLabel

var first_player: int = 0

func _ready() -> void:
	result_label.text = "Flipping the coin ..."
	await get_tree().create_timer(1.0).timeout
	flip_coin()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/battle_map.tscn")

func flip_coin() -> void:
	first_player = randi_range(1, 2)
	result_label.text = "Done! Player " + str(first_player) + " goes first!"
	print(result_label.text)
	TurnManager.start_match(first_player)
