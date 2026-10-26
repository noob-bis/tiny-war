extends Node2D

# Tiny War - Unit Movement
# Task 2.1.4.4

# Battlefield settings
const COLUMNS = 12
const ROWS = 8
const TILE_SIZE = 64

# Use our existing movement range script
const MovementRange = preload("res://scripts/movement_range.gd")

var movement_checker = MovementRange.new()

# These are temporary units for testing movement.
# Each unit has its own position, type, and color.
var units = [
	{"type": "Melee", "position": Vector2i(2, 2), "color": Color.BLUE},
	{"type": "Ranged", "position": Vector2i(5, 2), "color": Color.GREEN},
	{"type": "Tank", "position": Vector2i(8, 2), "color": Color.RED}
]

# -1 means no unit is currently selected.
var selected_unit = -1


func _ready() -> void:
	# Make sure the test units draw above the battlefield.
	z_index = 10

	# The battlefield grid starts at the BattleGrid node.
	# Match this node's position to the grid.
	var grid = get_parent().get_node("BattleGrid")
	position = grid.position


# Draw our three test units.
func _draw() -> void:
	for i in range(units.size()):
		var unit = units[i]
		var tile = unit["position"]

		# Find the center of the unit's tile.
		var center = Vector2(
			tile.x * TILE_SIZE + TILE_SIZE / 2.0,
			tile.y * TILE_SIZE + TILE_SIZE / 2.0
		)

		# Draw the unit as a colored circle.
		draw_circle(center, 20, unit["color"])

		# Highlight whichever unit is selected.
		if i == selected_unit:
			draw_arc(
				center,
				25,
				0,
				TAU,
				32,
				Color.WHITE,
				3.0
			)


# Detect mouse clicks.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Find where the player clicked.
			var mouse_pos = get_local_mouse_position()

			# Convert the mouse position into a grid tile.
			var target = Vector2i(
				floori(mouse_pos.x / TILE_SIZE),
				floori(mouse_pos.y / TILE_SIZE)
			)

			# Check if the clicked tile contains a unit.
			for i in range(units.size()):
				if units[i]["position"] == target:
					selected_unit = i

					print("Selected: ", units[i]["type"])

					queue_redraw()
					return

			# Don't move anything if no unit is selected.
			if selected_unit == -1:
				return

			var unit = units[selected_unit]

			# Don't allow two units on the same tile.
			for other_unit in units:
				if other_unit["position"] == target:
					print("Tile is occupied!")
					return

			# Check if the movement is within the unit's range.
			if movement_checker.can_move(
				unit["position"],
				target,
				unit["type"]
			):

				# Update the unit's position.
				units[selected_unit]["position"] = target

				print(unit["type"], " movement allowed!")

			else:
				print(unit["type"], " movement blocked!")

			# Update the positions on screen.
			queue_redraw()
