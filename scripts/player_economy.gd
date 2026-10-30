extends Node

# Tiny War - Player Economy
# Task 2.1.6.1

# Each player starts with 250 coins.
const STARTING_COINS = 250

# Each player earns 150 coins at the start of their turn.
const PASSIVE_INCOME = 150

# Store each player's coins separately.
var player_coins = {
	1: STARTING_COINS,
	2: STARTING_COINS
}

# Tell other scripts when a player's coins change.
signal coins_changed(player_number: int, new_balance: int)


# Check if the player number is valid.
func is_valid_player(player_number: int) -> bool:
	return player_number == 1 or player_number == 2


# Get the current coin balance for a player.
func get_coins(player_number: int) -> int:

	if not is_valid_player(player_number):
		return 0

	return player_coins[player_number]


# Give passive income to the player starting their turn.
func give_passive_income(player_number: int) -> void:

	if not is_valid_player(player_number):
		return

	# Add 150 coins to this player's balance.
	player_coins[player_number] += PASSIVE_INCOME

	# Notify the interface that the balance changed.
	coins_changed.emit(
		player_number,
		player_coins[player_number]
	)

	print(
		"Player ", player_number,
		" received ", PASSIVE_INCOME,
		" coins. Balance: ", player_coins[player_number]
	)


# Reset both players' coins when starting a new match.
func reset_economy() -> void:

	player_coins[1] = STARTING_COINS
	player_coins[2] = STARTING_COINS

	coins_changed.emit(1, player_coins[1])
	coins_changed.emit(2, player_coins[2])

	print("Player economy reset.")
