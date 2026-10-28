extends Node2D

# Tiny War - Attack Range Test
# Task 2.1.3.1

# Load the attack range checker
const AttackRange = preload("res://scripts/attack_range.gd")

# Create a checker to use in our tests
var attack_checker = AttackRange.new()


# Run the tests when the scene starts
func _ready() -> void:

	print("===== ATTACK RANGE TEST =====")

	# Melee can attack 1 tile away
	test_attack("Melee 1 tile", Vector2i(2, 2), Vector2i(3, 2), 1, true)

	# Melee cannot attack 2 tiles away
	test_attack("Melee 2 tiles", Vector2i(2, 2), Vector2i(4, 2), 1, false)

	# Ranged can attack 3 tiles away
	test_attack("Ranged 3 tiles", Vector2i(2, 2), Vector2i(5, 2), 3, true)

	# Ranged cannot attack 4 tiles away
	test_attack("Ranged 4 tiles", Vector2i(2, 2), Vector2i(6, 2), 3, false)

	# Tank can attack 1 tile away
	test_attack("Tank 1 tile", Vector2i(2, 2), Vector2i(3, 2), 1, true)

	# Tank cannot attack 2 tiles away
	test_attack("Tank 2 tiles", Vector2i(2, 2), Vector2i(4, 2), 1, false)

	# Attacking outside the battlefield should fail
	test_attack("Outside grid", Vector2i(0, 0), Vector2i(-1, 0), 3, false)

	print("===== TEST COMPLETE =====")


# Compare the actual result with the expected result
func test_attack(
	test_name: String,
	start: Vector2i,
	target: Vector2i,
	attack_range: int,
	expected: bool
) -> void:

	var result = attack_checker.can_attack(start, target, attack_range)

	if result == expected:
		print("PASS: ", test_name)
	else:
		print("FAIL: ", test_name)
