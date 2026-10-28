extends Node

const UNIT_STATS = {
	"melee": {"hp": 100, "atk": 25, "move": 3, "range": 1, "cost": 100},
	"ranged": {"hp": 60, "atk": 20, "move": 2, "range": 3, "cost": 120},
	"tank": {"hp": 160, "atk": 20, "move": 1, "range": 1, "cost": 150},
}

# to get units data
func get_stats(unit_type: String) -> Dictionary:
	return UNIT_STATS.get(unit_type, {}) # get() will look up unit_type, it nothing match, it return {} ~ empty Dic as fallback (because our return type is a Dictionary)

func _ready() -> void:
	print("""
	+------------------------+
	|	Test load unit data  |
	+------------------------+
	Melee: %s
	Dragon: %s
	+------------------------+
	Unit data loaded
	+------------------------+
		""" % [get_stats("melee"), get_stats("dragon")])
