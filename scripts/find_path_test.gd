extends Node2D

# Tiny War - Find Path Test
# Task 2.1.4.4
#
# Tests:
# 1. Shortest path with no obstacles.
# 2. Destination beyond movement range.
# 3. Finding a path around another unit.
# 4. Rejecting blocked destinations.
# 5. Rejecting destinations outside the map.
# 6. Preventing diagonal movement.


# Load the existing movement range script.
const MovementRange = preload("res://scripts/movement_range.gd")

# Create an instance for testing.
var movement = MovementRange.new()

# Count passed and failed tests.
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:

	# Add the movement system to the scene.
	add_child(movement)

	print("===== FIND PATH TEST =====")

	# TEST 1: Straight path with exactly 3 steps.
	var path1 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(5, 2),
		[],
		3
	)

	var expected1: Array[Vector2i] = [
		Vector2i(3, 2),
		Vector2i(4, 2),
		Vector2i(5, 2)
	]

	check(
		"Straight path uses 3 steps",
		path1 == expected1
	)

	print("Straight path: ", path1)

	# TEST 2: Destination is too far away.
	var path2 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(5, 2),
		[],
		2
	)

	check(
		"Maximum 2 steps rejects distant goal",
		path2.is_empty()
	)

	# TEST 3: A unit blocks the direct path.
	var path3 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(5, 2),
		[Vector2i(3, 2)],
		5
	)

	check(
		"Finds a 5-step path around a unit",
		path3.size() == 5
		and not path3.has(Vector2i(3, 2))
		and path3.back() == Vector2i(5, 2)
	)

	print("Path around unit: ", path3)

	# TEST 4: Goal is occupied by another unit.
	var path4 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(5, 2),
		[Vector2i(5, 2)],
		5
	)

	check(
		"Blocked destination returns empty path",
		path4.is_empty()
	)

	# TEST 5: Goal is outside the 12x8 map.
	var path5 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(12, 2),
		[],
		20
	)

	check(
		"Outside-grid destination returns empty path",
		path5.is_empty()
	)

	# TEST 6: Diagonal movement is not allowed.
	var path6 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(3, 3),
		[],
		1
	)

	check(
		"Diagonal destination cannot be reached in 1 step",
		path6.is_empty()
	)

	# TEST 7: Diagonal destination takes 2 steps.
	var path7 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(3, 3),
		[],
		2
	)

	check(
		"Diagonal destination requires 2 steps",
		path7.size() == 2
		and path7.back() == Vector2i(3, 3)
	)

	# TEST 8: Start and goal are the same.
	var path8 = movement.find_path(
		Vector2i(2, 2),
		Vector2i(2, 2),
		[],
		3
	)

	check(
		"Same start and goal returns empty path",
		path8.is_empty()
	)

	# Display the final results.
	print("===== TEST RESULTS =====")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)
	print("===== TEST COMPLETE =====")


# Check whether a test passed or failed.
func check(test_name: String, passed: bool) -> void:

	if passed:
		passed_tests += 1
		print("PASS: ", test_name)
	else:
		failed_tests += 1
		print("FAIL: ", test_name)
