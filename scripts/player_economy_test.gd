extends Node2D

# Tiny War - Player Economy Test
# Task 2.1.6.1
#
# This script tests:
# 1. Both players start with 250 coins.
# 2. Each player receives 150 coins per turn.
# 3. Players have separate coin balances.
# 4. Invalid player numbers are rejected.
# 5. Both players reset to 250 coins.


# Load the player economy script.
const PlayerEconomy = preload("res://scripts/player_economy.gd")

# Create an economy system for testing.
var economy = PlayerEconomy.new()

# Count how many times the coins_changed signal is sent.
var signal_count: int = 0


func _ready() -> void:

	# Add the economy system to the test scene.
	add_child(economy)

	# Connect the signal so we can count balance updates.
	economy.coins_changed.connect(_on_coins_changed)

	print("===== PLAYER ECONOMY TEST =====")

	# TEST 1: Player 1 starts with 250 coins.
	check(
		"Player 1 starts with 250 coins",
		economy.get_coins(1) == 250
	)

	# TEST 2: Player 2 starts with 250 coins.
	check(
		"Player 2 starts with 250 coins",
		economy.get_coins(2) == 250
	)

	# TEST 3: Give Player 1 passive income.
	economy.give_passive_income(1)

	check(
		"Player 1 receives 150 coins",
		economy.get_coins(1) == 400
	)

	# TEST 4: Player 2's balance should not change.
	check(
		"Player 2 balance stays at 250",
		economy.get_coins(2) == 250
	)

	# TEST 5: Give Player 2 passive income.
	economy.give_passive_income(2)

	check(
		"Player 2 receives 150 coins",
		economy.get_coins(2) == 400
	)

	# TEST 6: Give Player 1 income a second time.
	economy.give_passive_income(1)

	check(
		"Player 1 receives income again",
		economy.get_coins(1) == 550
	)

	# TEST 7: Make sure balances stay separate.
	check(
		"Player balances are independent",
		economy.get_coins(1) == 550 and economy.get_coins(2) == 400
	)

	# TEST 8: Invalid player number should be rejected.
	check(
		"Invalid player number rejected",
		not economy.is_valid_player(3)
	)

	# TEST 9: Invalid players should not receive income.
	economy.give_passive_income(3)

	check(
		"Invalid player receives no coins",
		economy.get_coins(3) == 0
	)

	# TEST 10: Income should have emitted 3 signals.
	check(
		"Income signals emitted correctly",
		signal_count == 3
	)

	# Reset both players' balances.
	economy.reset_economy()

	# TEST 11: Player 1 resets to 250.
	check(
		"Player 1 resets to 250",
		economy.get_coins(1) == 250
	)

	# TEST 12: Player 2 resets to 250.
	check(
		"Player 2 resets to 250",
		economy.get_coins(2) == 250
	)

	# TEST 13: Reset should emit 2 additional signals.
	check(
		"Reset signals emitted correctly",
		signal_count == 5
	)

	print("===== TEST COMPLETE =====")


# Called whenever a player's coin balance changes.
func _on_coins_changed(
	_player_number: int,
	_new_balance: int
) -> void:

	signal_count += 1


# Display PASS or FAIL for each test.
func check(test_name: String, passed: bool) -> void:

	if passed:
		print("PASS: ", test_name)
	else:
		print("FAIL: ", test_name)
