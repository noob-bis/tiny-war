
extends Node2D
#Logic: base (1/2) HP > 0 => game continue Else, win
# Notify other scripts when a base is destroyed.
signal base_destroyed(player_id: int)

# Each base starts with 300 HP.
@export var player_id: int = 1
var base_hp: int = 300

# Reduce base HP when attacked.
func take_damage(damage: int) -> void:
	if base_hp <= 0 or damage <= 0:
		return

	base_hp = max(0, base_hp - damage)
	print("Player ", player_id, " Base HP: ", base_hp)

	check_base_destroyed()


# Check whether the base is destroyed.
func check_base_destroyed() -> void:
	if base_hp <= 0:
		print("Player ", player_id, " base destroyed!")
		base_destroyed.emit(player_id)
