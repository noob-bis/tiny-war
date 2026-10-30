extends Node2D

# Left-click to select a tile for placing or attacking.

# Signals to communicate with other scripts.
signal place_unit(tile)
signal attack_unit(tile)

# The game board has 12 columns and 8 rows.
var tile_size = 64


# Detects mouse clicks.
func _input(event):

	if event is InputEventMouseButton and event.pressed:

		# Only accept the left mouse button.
		if event.button_index == MOUSE_BUTTON_LEFT:

			# Get mouse position on the game board.
			var pos = get_local_mouse_position()

			# Convert pixels into grid coordinates.
			var x = int(floor(pos.x / tile_size))
			var y = int(floor(pos.y / tile_size))

			# Stop if the click is outside the board.
			if x < 0 or x >= 12 or y < 0 or y >= 8:
				print("Outside the grid!")
				return

			# Save the clicked tile.
			var tile = Vector2i(x, y)

			# Check the current game phase.
			var phase = TurnManager.get_current_phase()

			# Deploy phase: choose where to place a unit.
			if phase == "Deploy":
				print("Place unit at: ", tile)
				place_unit.emit(tile)

			# Act phase: choose where to attack.
			elif phase == "Act":
				print("Attack unit at: ", tile)
				attack_unit.emit(tile)
