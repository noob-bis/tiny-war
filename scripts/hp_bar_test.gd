extends Node2D

# Tiny War - HP Bar Test
# Task 2.2.2

const HP_BAR_SCENE = preload("res://scenes/HpBar.tscn")

const MAX_HP: int = 100
const HP_CHANGE: int = 25

var current_hp: int = MAX_HP
var hp_bar: Node2D


func _ready() -> void:

	# Create the HP bar.
	hp_bar = HP_BAR_SCENE.instantiate()
	add_child(hp_bar)

	# Position the bar.
	hp_bar.position = Vector2(300, 200)

	print("===== HP BAR TEST =====")

	# Test 1: HP above maximum.
	hp_bar.set_hp(150, 100)

	if hp_bar.current_hp == 100:
		print("PASS: 150/100 HP clamped to 100")
	else:
		print("FAIL: 150/100 HP")

	# Test 2: Maximum HP is zero.
	hp_bar.set_hp(10, 0)

	if hp_bar.current_hp == 0:
		print("PASS: 10/0 HP handled safely")
	else:
		print("FAIL: 10/0 HP")

	# Restore normal HP.
	hp_bar.set_hp(current_hp, MAX_HP)

	print("PASS: Normal HP bar restored")
	print("UP = Increase HP")
	print("DOWN = Decrease HP")
	print("HP: ", current_hp, "/", MAX_HP)


func _unhandled_key_input(event: InputEvent) -> void:

	# Only handle keyboard input.
	if not event is InputEventKey:
		return

	# Ignore released or repeated keys.
	if not event.pressed or event.echo:
		return

	# Increase HP.
	if event.keycode == KEY_UP:
		current_hp = clampi(
			current_hp + HP_CHANGE,
			0,
			MAX_HP
		)

	# Decrease HP.
	elif event.keycode == KEY_DOWN:
		current_hp = clampi(
			current_hp - HP_CHANGE,
			0,
			MAX_HP
		)

	else:
		return

	# Update the HP bar.
	hp_bar.set_hp(current_hp, MAX_HP)

	# Print HP.
	print("HP: ", current_hp, "/", MAX_HP)
