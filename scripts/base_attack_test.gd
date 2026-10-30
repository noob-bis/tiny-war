extends Node2D

# Tiny War - Base Attack Test
# Task 2.1.3.2

# Load our Base Attack script.
const BaseAttack = preload("res://scripts/base_attack.gd")

# Create the damage checker.
var base_attack = BaseAttack.new()

# Our test base is at tile (2, 2).
var base_position = Vector2i(2, 2)


# Run tests when the scene starts.
func _ready() -> void:

	print("===== BASE ATTACK TEST =====")

	# Enemy directly above the base.
	test_attack("Enemy above", Vector2i(2, 1), true, 10)

	# Enemy directly below the base.
	test_attack("Enemy below", Vector2i(2, 3), true, 10)

	# Enemy directly left of the base.
	test_attack("Enemy left", Vector2i(1, 2), true, 10)

	# Enemy directly right of the base.
	test_attack("Enemy right", Vector2i(3, 2), true, 10)

	# Diagonal enemies should not take damage.
	test_attack("Diagonal enemy", Vector2i(3, 3), true, 0)

	# Friendly units should not take damage.
	test_attack("Friendly unit", Vector2i(3, 2), false, 0)

	# Distant enemies should not take damage.
	test_attack("Distant enemy", Vector2i(6, 2), true, 0)

	# Enemies outside the battlefield cannot be attacked.
	test_attack("Outside grid", Vector2i(-1, 2), true, 0)

	print("===== TEST COMPLETE =====")


# Check whether the actual damage matches our expectation.
func test_attack(
	test_name: String,
	unit_position: Vector2i,
	is_enemy: bool,
	expected_damage: int
) -> void:

	var damage = base_attack.get_base_attack_damage(
		base_position,
		unit_position,
		is_enemy
	)

	if damage == expected_damage:
		print("PASS: ", test_name)
	else:
		print(
			"FAIL: ", test_name,
			" | Expected: ", expected_damage,
			" | Got: ", damage
		)
