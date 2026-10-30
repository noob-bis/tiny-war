extends Node2D

# Tiny War - Turn Counter Test
# Task 2.1.1.4

# Load the turn counter script.
const TurnCounter = preload("res://scripts/turn_counter.gd")

# Create a turn counter for testing.
var counter = TurnCounter.new()

# Count how many times the limit signal is emitted.
var signal_count: int = 0


func _ready() -> void:
	# Listen for the turn-limit signal.
	counter.turn_limit_reached.connect(_on_turn_limit_reached)

	print("===== TURN COUNTER TEST =====")

	# New matches should start at zero.
	check("Starts at 0", counter.get_completed_turns() == 0)

	# Complete the first turn.
	counter.complete_turn()
	check("First turn counted", counter.get_completed_turns() == 1)

	# Complete another 38 turns.
	# Total completed turns should now be 39.
	for i in range(38):
		counter.complete_turn()

	check("39 turns counted", counter.get_completed_turns() == 39)
	check("Game still active at 39", not counter.has_reached_turn_limit())

	# Complete turn 40.
	counter.complete_turn()

	check("Stops at 40", counter.get_completed_turns() == 40)
	check("Game over at 40", counter.has_reached_turn_limit())
	check("Signal emitted once", signal_count == 1)

	# Try completing an additional turn.
	counter.complete_turn()

	check("Cannot exceed 40", counter.get_completed_turns() == 40)
	check("No duplicate signal", signal_count == 1)

	# Reset the counter.
	counter.reset_counter()

	check("Reset returns to 0", counter.get_completed_turns() == 0)
	check("Reset clears game over", not counter.has_reached_turn_limit())

	print("===== TEST COMPLETE =====")


# Called when the counter reaches 40 turns.
func _on_turn_limit_reached() -> void:
	signal_count += 1


# Print PASS or FAIL for each test.
func check(test_name: String, passed: bool) -> void:
	if passed:
		print("PASS: ", test_name)
	else:
		print("FAIL: ", test_name)
