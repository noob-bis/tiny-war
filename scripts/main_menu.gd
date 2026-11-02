extends Control

# When the player clicks Start Game
func _on_start_button_pressed() -> void:
	# Open the battle scene
	get_tree().change_scene_to_file("res://scenes/coin_flip.tscn")


# When the player clicks Exit
func _on_exit_button_pressed() -> void:
	# Close the game
	get_tree().quit()
