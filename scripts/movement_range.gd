extends Node

# Tiny War - Movement Range
# Task 2.1.4.4

# Our battlefield has 12 columns and 8 rows.
const COLUMNS = 12
const ROWS = 8

# Each unit has a different movement limit.
# Melee can move 3 tiles.
# Ranged can move 2 tiles.
# Tank can move 1 tile.
const MELEE_MOVE = 3
const RANGED_MOVE = 2
const TANK_MOVE = 1


# Find out how far a unit is allowed to move.
func get_movement_range(unit_type: String) -> int:

	if unit_type == "Melee":
		return MELEE_MOVE

	elif unit_type == "Ranged":
		return RANGED_MOVE

	elif unit_type == "Tank":
		return TANK_MOVE

	# If the unit type isn't recognized, return 0.
	return 0


# Check whether a tile is inside the battlefield.
func is_inside_grid(tile: Vector2i) -> bool:

	# Check the horizontal position.
	if tile.x < 0 or tile.x >= COLUMNS:
		return false

	# Check the vertical position.
	if tile.y < 0 or tile.y >= ROWS:
		return false

	return true


# Check whether a unit can move to another tile.
#
# start = the unit's current tile
# target = the tile the player clicked
# unit_type = Melee, Ranged, or Tank
func can_move(
	start: Vector2i,
	target: Vector2i,
	unit_type: String
) -> bool:

	# Both positions must be inside the battlefield.
	if not is_inside_grid(start):
		return false

	if not is_inside_grid(target):
		return false

	# Get the movement limit for this unit.
	var move_limit = get_movement_range(unit_type)

	# Unknown unit types cannot move.
	if move_limit == 0:
		return false

	# Calculate the distance between the two tiles.
	# This counts horizontal and vertical movement.
	var distance = abs(target.x - start.x) + abs(target.y - start.y)

	# The unit must move to a different tile.
	if distance == 0:
		return false

	# Block movement beyond the unit's limit.
	if distance > move_limit:
		return false

	# The movement is within the allowed range.
	return true
