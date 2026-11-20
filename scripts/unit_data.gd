extends Node

const UNIT_STATS = {
	"melee": {"hp": 50, "atk": 25, "move": 2, "range": 1, "cost": 100},
	"ranged": {"hp": 40, "atk": 25, "move": 2, "range": 3, "cost": 120},
	"tank": {"hp": 75, "atk": 20, "move": 2, "range": 1, "cost": 150},
}

# to get units data
func get_stats(unit_type: String) -> Dictionary:
	return UNIT_STATS.get(unit_type, {}) # get() will look up unit_type, it nothing match, it return {} ~ empty Dic as fallback (because our return type is a Dictionary)
