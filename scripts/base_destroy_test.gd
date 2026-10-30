
extends Node2D

# Load the original base destroy script.
const BaseScript = preload("res://scripts/base_destroy.gd")

func _ready() -> void:
	print("===== BASE DESTROY TEST =====")

	# Create Player 1 base.
	var base = BaseScript.new()
	base.player_id = 1
	add_child(base)

	# Connect the destroyed signal.
	base.base_destroyed.connect(_on_base_destroyed)

	# Test 1: Starting HP.
	print("Starting HP: ", base.base_hp)

	# Test 2: Take 100 damage.
	base.take_damage(100)

	# Test 3: Take another 200 damage.
	base.take_damage(200)

	# Test 4: Attack after destruction.
	base.take_damage(50)

	print("Final HP: ", base.base_hp)
	print("===== TEST FINISHED =====")


# Display the winner.
func _on_base_destroyed(player_id: int) -> void:
	print("Player ", 3 - player_id, " wins!")
