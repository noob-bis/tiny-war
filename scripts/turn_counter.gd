extends Node

# Tiny War - Turn Counter
# Task 2.1.1.4

# Maximum number of turns in a match.
const MAX_TURNS = 40

# Tracks how many turns have been completed.
var completed_turns: int = 0

# Tracks whether the turn limit has been reached.
var game_over: bool = false

# Notify other scripts when the turn limit is reached.
signal turn_limit_reached


# Called when a player finishes a turn.
func complete_turn() -> void:

	# Do not count additional turns after the match ends.
	if game_over:
		return

	# Increase the number of completed turns.
	completed_turns += 1

	print("Turn completed: ", completed_turns)

	# Check whether the match has reached its turn limit.
	if completed_turns >= MAX_TURNS:

		game_over = true

		print("40-turn limit reached!")

		# Let the game's other systems know.
		turn_limit_reached.emit()


# Return the current number of completed turns.
func get_completed_turns() -> int:
	return completed_turns


# Check whether the match has reached its turn limit.
func has_reached_turn_limit() -> bool:
	return game_over


# Reset the counter when starting a new match.
func reset_counter() -> void:

	completed_turns = 0
	game_over = false

	print("Turn counter reset.")
