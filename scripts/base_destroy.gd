extends Node2D

# Tiny War - Base Damage State
# Task 2.1.3.5

# Notify other scripts when a base is destroyed.
signal base_destroyed(player_id: int)

# Notify other scripts only when the damage state changes.
signal damage_state_changed(player_id: int, state: String)

# Base HP and damage thresholds.
const MAX_BASE_HP = 300
const SMOKE_HP = 200
const FIRE_HP = 100

# Identify which player owns this base.
@export var player_id: int = 1

# Each base starts with full HP.
var base_hp: int = MAX_BASE_HP


# Return the base's current damage state.
func get_damage_state() -> String:

	# A base with no HP is destroyed.
	if base_hp <= 0:
		return "destroyed"

	# A base with 100 HP or less is on fire.
	if base_hp <= FIRE_HP:
		return "fire"

	# A base with 200 HP or less is smoking.
	if base_hp <= SMOKE_HP:
		return "smoke"

	# A base above 200 HP is healthy.
	return "healthy"


# Reduce base HP when attacked.
# Keep the original function input unchanged.
func take_damage(damage: int) -> void:

	# Ignore damage if the base is already destroyed
	# or if the damage amount is invalid.
	if base_hp <= 0 or damage <= 0:
		return

	# Remember the state before taking damage.
	var old_state: String = get_damage_state()

	# Reduce HP without going below zero.
	base_hp = max(0, base_hp - damage)

	print("Player ", player_id, " Base HP: ", base_hp)

	# Check the state after taking damage.
	var new_state: String = get_damage_state()

	# Only send the signal if the state changed.
	if old_state != new_state:
		damage_state_changed.emit(player_id, new_state)

		print(
			"Player ", player_id,
			" base state changed to: ", new_state
		)

	# Keep the existing base destruction check.
	check_base_destroyed()


# Check whether the base is destroyed.
func check_base_destroyed() -> void:

	if base_hp <= 0:
		print("Player ", player_id, " base destroyed!")
		base_destroyed.emit(player_id)
