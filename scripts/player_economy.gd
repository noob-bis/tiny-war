extends Node

# Each player starts with 250 coins
const STARTING_COINS = 250

# Each player initially earns 150 coins per turn
const PASSIVE_INCOME = 150

# Passive income increases by 25 coins every 5 turns
const INCOME_INCREASE = 25
const TURNS_PER_INCREASE = 5

# Store each player's coins separately
var player_coins = {
	1: STARTING_COINS,
	2: STARTING_COINS
}

# Tell other scripts whenever a player's coins change
signal coins_changed(player_number: int, new_balance: int)


# Check if the player number is valid
func is_valid_player(player_number: int) -> bool:
	return player_number == 1 or player_number == 2


# Get the current coin balance for a player
func get_coins(player_number: int) -> int:

	if not is_valid_player(player_number):
		return 0

	return player_coins[player_number]


# Calculate passive income based on the turn number
# Turns 1-5:   150 coins
# Turns 6-10:  175 coins
# Turns 11-15: 200 coins
# Turns 16-20: 225 coins
# Income increases after every 5 completed turns
func get_income_for_turn(turn_number: int) -> int:

	# Invalid turn numbers do not receive income
	if turn_number < 1:
		return 0

	# Calculate how many 5-turn groups have passed
	var increases: int = (turn_number - 1) / TURNS_PER_INCREASE

	# Add 25 coins for each completed group
	var income: int = PASSIVE_INCOME + increases * INCOME_INCREASE

	return income


# Give passive income to a player
# player_number identifies Player 1 or Player 2.
# turn_number determines how much income they receive.
# If no turn number is provided, the original
# 150-coin income is used.
func give_passive_income(
	player_number: int, turn_number: int = 1 ) -> void:

	# Reject invalid player numbers.
	if not is_valid_player(player_number):
		return

	# Reject invalid turn numbers.
	if turn_number < 1:
		return

	# Calculate income for the current turn.
	var income: int = get_income_for_turn(turn_number)

	# Add the income to the correct player's balance.
	player_coins[player_number] += income

	# Notify the interface that the balance changed.
	coins_changed.emit(
		player_number,
		player_coins[player_number]
	)

	# Show income information in Godot's Output panel.
	print(
		"Player ", player_number,
		" received ", income,
		" coins on turn ", turn_number,
		". Balance: ", player_coins[player_number]
	)

func spend_coins(player_number: int, amount: int) -> bool:
	if not is_valid_player(player_number):
		return false
	if amount <= 0:
		return false
	if player_coins[player_number] < amount:
		return false
	else:
		player_coins[player_number] -= amount
		coins_changed.emit(player_number, player_coins[player_number])
		#print("Spend coin -> true")
		return true

# Reset both players' coins when starting a new match.
func reset_economy() -> void:

	# Restore both players' starting balances.
	player_coins[1] = STARTING_COINS
	player_coins[2] = STARTING_COINS

	# Notify the interface about both balances.
	coins_changed.emit(1, player_coins[1])
	coins_changed.emit(2, player_coins[2])

	print("Player economy reset.")

# Return half the cost of a defeated enemy unit.
func get_kill_bonus(unit_type: String) -> int:
	# Get the unit information from UnitData.
	var stats: Dictionary = UnitData.get_stats(unit_type)

	# Check if the unit type is invalid.
	if stats.is_empty():
		push_warning("Invalid unit type: " + unit_type)
		return 0

	# Get the original cost from UnitData.
	var unit_cost: int = int(stats.get("cost", 0))

	# Calculate 50% of the unit cost.
	var bonus: int = int(unit_cost * 0.5)

	return bonus
