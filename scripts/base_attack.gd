extends Node

# Tiny War - Base Attack
# Task 2.1.3.2

# Each base deals 10 damage to adjacent enemy units.
const BASE_DAMAGE = 10


# Check if a unit is directly beside a base.
# Only up, down, left, and right count.
# Diagonal tiles do not count.
func is_adjacent(
	base_position: Vector2i,
	unit_position: Vector2i
) -> bool:

	# Make sure the base is inside the battlefield.
	if not GridUtils.is_cell_inside(base_position):
		return false

	# Make sure the unit is inside the battlefield.
	if not GridUtils.is_cell_inside(unit_position):
		return false

	# Calculate how far apart the two positions are.
	var difference = unit_position - base_position

	# Check the four directions around the base.
	if difference == Vector2i(1, 0):
		return true  # Right

	if difference == Vector2i(-1, 0):
		return true  # Left

	if difference == Vector2i(0, 1):
		return true  # Below

	if difference == Vector2i(0, -1):
		return true  # Above

	# The unit is not directly beside the base.
	return false


# Calculate the damage dealt by a base.
#
# base_position = position of the base
# unit_position = position of the unit
# is_enemy = whether the unit belongs to the opposing player
func get_base_attack_damage(
	base_position: Vector2i,
	unit_position: Vector2i,
	is_enemy: bool
) -> int:

	# Do not damage friendly units.
	if not is_enemy:
		return 0

	# Do not damage units that aren't adjacent.
	if not is_adjacent(base_position, unit_position):
		return 0

	# Deal 10 damage to an adjacent enemy.
	return BASE_DAMAGE
