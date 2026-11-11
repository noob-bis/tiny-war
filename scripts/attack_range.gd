extends Node

# Tiny War - Attack Range Check
# Task 2.1.3.1 - Range Cleanup

# Map boundaries are checked using GridUtils.


# Check if an enemy is close enough to attack.
#
# attacker_position = the attacker's current tile
# target_position = the enemy's tile
# attack_range = how far the unit can attack
#
# The attack range comes from the team's unit stats.
func can_attack(
	attacker_position: Vector2i,
	target_position: Vector2i,
	attack_range: int
) -> bool:

	# Ask GridUtils if the attacker is inside the battlefield.
	if not GridUtils.is_cell_inside(attacker_position):
		return false

	# Ask GridUtils if the target is inside the battlefield.
	if not GridUtils.is_cell_inside(target_position):
		return false

	# Units must have a valid attack range.
	if attack_range <= 0:
		return false

	# Calculate the distance between the two units.
	# We count horizontal and vertical tiles.
	var distance: int = (
		abs(target_position.x - attacker_position.x)
		+ abs(target_position.y - attacker_position.y)
	)

	# A unit cannot attack its own tile.
	if distance == 0:
		return false

	# Block attacks that are too far away.
	if distance > attack_range:
		return false

	# The enemy is within attack range.
	return true
