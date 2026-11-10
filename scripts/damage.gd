extends Node

# Stores which unit type beats another
const COUNTERS = {
	"melee": "ranged",
	"ranged": "tank",
	"tank": "melee"
}

# Gets the damage modifier based on unit types
func get_modifier(attacker_type: String, target_type: String) -> float:
	# Attacker has advantage (50% more damage)
	if COUNTERS.get(attacker_type) == target_type:
		return 1.5

	# Target has advantage (40% less damage)
	if COUNTERS.get(target_type) == attacker_type:
		return 0.6

	# No advantage (normal damage, 100%)
	return 1.0

# Calculates final damage and rounds down
func calculate_damage(attacker_type: String, target_type: String, atk: int) -> int:
	var modifier = get_modifier(attacker_type, target_type)
	var damage = floori(atk * modifier)
	return damage
