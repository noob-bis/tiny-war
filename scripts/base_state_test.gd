extends Node2D

# Tiny War - Base Damage State Test
# Task 2.1.3.5

# Load the existing base script.
const BaseDestroy = preload("res://scripts/base_destroy.gd")

# Create a base for testing.
var base = BaseDestroy.new()

# Count how many times the state changes.
var signal_count: int = 0

# Track passed and failed tests.
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:

	add_child(base)

	# Listen for damage state changes.
	base.damage_state_changed.connect(_on_damage_state_changed)

	print("===== BASE DAMAGE STATE TEST =====")

	# TEST 1: New base starts healthy.
	check("New base is healthy", base.get_damage_state() == "healthy")

	# TEST 2: Small damage keeps the base healthy.
	base.take_damage(10)

	check("290 HP is healthy", base.get_damage_state() == "healthy")
	check("No signal while healthy", signal_count == 0)

	# TEST 3: Reduce HP to 200.
	base.take_damage(90)

	check("200 HP is smoke", base.get_damage_state() == "smoke")
	check("Smoke signal emitted once", signal_count == 1)

	# TEST 4: More damage while smoking.
	base.take_damage(50)

	check("150 HP is smoke", base.get_damage_state() == "smoke")
	check("No extra smoke signal", signal_count == 1)

	# TEST 5: Reduce HP to 100.
	base.take_damage(50)

	check("100 HP is fire", base.get_damage_state() == "fire")
	check("Fire signal emitted", signal_count == 2)

	# TEST 6: Destroy the base.
	base.take_damage(100)

	check("0 HP is destroyed", base.get_damage_state() == "destroyed")
	check("Destroyed signal emitted", signal_count == 3)

	# TEST 7: Further damage should not change anything.
	base.take_damage(10)

	check("HP stays at zero", base.base_hp == 0)
	check("No extra state signal", signal_count == 3)

	print("===== TEST RESULTS =====")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)
	print("===== TEST COMPLETE =====")


# Called whenever the base changes damage state.
func _on_damage_state_changed(
	_player_id: int,
	_state: String
) -> void:

	signal_count += 1


# Print PASS or FAIL for each test.
func check(test_name: String, passed: bool) -> void:

	if passed:
		passed_tests += 1
		print("PASS: ", test_name)
	else:
		failed_tests += 1
		print("FAIL: ", test_name)
