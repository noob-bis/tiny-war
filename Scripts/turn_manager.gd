
extends Node

# Signals to notify other scripts.
signal phase_changed(player, phase)
signal player_changed(player)

# Five phases in order.
const PHASES = ["Income", "Move", "Act", "Deploy", "End"]

# Current player and phase.
var current_player = 1
var current_phase_index = 0
var match_started = false


# Get the current phase name.
func get_current_phase():
	return PHASES[current_phase_index]


# Start the match after the coin flip.
func start_match(starting_player):
	if match_started:
		return

	if starting_player != 1 and starting_player != 2:
		print("Invalid player")
		return

	current_player = starting_player
	current_phase_index = 0
	match_started = true

	player_changed.emit(current_player)
	phase_changed.emit(current_player, get_current_phase())

	print_status()


# Move to the next phase.
func advance_phase():
	if not match_started:
		return

	if current_phase_index == 4:
		# Return to Income.
		current_phase_index = 0

		# Switch players.
		if current_player == 1:
			current_player = 2
		else:
			current_player = 1

		player_changed.emit(current_player)
	else:
		current_phase_index += 1

	phase_changed.emit(current_player, get_current_phase())
	print_status()


# Print the current player and phase.
func print_status():
	print("Player ", current_player, " - ", get_current_phase())

# Temporary test.
func _ready():
	start_match(1)

	for i in range(10):
		advance_phase()
