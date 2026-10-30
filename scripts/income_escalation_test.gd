extends Node2D

# Tiny War - Income Escalation Test
# Task 2.1.6.2
#
# Tests whether passive income increases
# by 25 coins after every 5 turns.


# Load the existing economy system.
const PlayerEconomy = preload("res://scripts/player_economy.gd")

# Create an economy system for testing.
var economy = PlayerEconomy.new()

# Count how many tests pass or fail.
var passed_tests: int = 0
var failed_tests: int = 0


func _ready() -> void:

	# Add the economy system to the scene.
	add_child(economy)

	print("===== INCOME ESCALATION TEST =====")

	# Check the starting income.
	check("Turn 1 gives 150 coins", economy.get_income_for_turn(1) == 150)
	check("Turn 5 gives 150 coins", economy.get_income_for_turn(5) == 150)

	# Check the first income increase.
	check("Turn 6 gives 175 coins", economy.get_income_for_turn(6) == 175)
	check("Turn 10 gives 175 coins", economy.get_income_for_turn(10) == 175)

	# Check the second income increase.
	check("Turn 11 gives 200 coins", economy.get_income_for_turn(11) == 200)
	check("Turn 15 gives 200 coins", economy.get_income_for_turn(15) == 200)

	# Check later income increases.
	check("Turn 16 gives 225 coins", economy.get_income_for_turn(16) == 225)
	check("Turn 21 gives 250 coins", economy.get_income_for_turn(21) == 250)
	check("Turn 26 gives 275 coins", economy.get_income_for_turn(26) == 275)
	check("Turn 31 gives 300 coins", economy.get_income_for_turn(31) == 300)
	check("Turn 36 gives 325 coins", economy.get_income_for_turn(36) == 325)
	check("Turn 40 gives 325 coins", economy.get_income_for_turn(40) == 325)

	# Invalid turns should not produce income.
	check("Turn 0 gives no income", economy.get_income_for_turn(0) == 0)
	check("Negative turn gives no income", economy.get_income_for_turn(-1) == 0)

	# Test whether actual coin balances increase correctly.
	economy.give_passive_income(1, 1)

	check(
		"Player 1 receives 150 coins on turn 1",
		economy.get_coins(1) == 400
	)

	economy.give_passive_income(1, 6)

	check(
		"Player 1 receives 175 coins on turn 6",
		economy.get_coins(1) == 575
	)

	# Player 2 should still have their starting coins.
	check(
		"Player 2 balance stays at 250",
		economy.get_coins(2) == 250
	)

	# Check that Player 2 receives escalated income.
	economy.give_passive_income(2, 11)

	check(
		"Player 2 receives 200 coins on turn 11",
		economy.get_coins(2) == 450
	)

	# Invalid turns must not change coin balances.
	economy.give_passive_income(1, 0)

	check(
		"Invalid turn does not add coins",
		economy.get_coins(1) == 575
	)

	# Reset the economy.
	economy.reset_economy()

	check(
		"Player 1 resets to 250 coins",
		economy.get_coins(1) == 250
	)

	check(
		"Player 2 resets to 250 coins",
		economy.get_coins(2) == 250
	)

	# Show the final test results.
	print("===== TEST RESULTS =====")
	print("PASSED: ", passed_tests)
	print("FAILED: ", failed_tests)
	print("===== TEST COMPLETE =====")


# Print PASS or FAIL for each test.
func check(test_name: String, passed: bool) -> void:

	if passed:
		passed_tests += 1
		print("PASS: ", test_name)
	else:
		failed_tests += 1
		print("FAIL: ", test_name)
