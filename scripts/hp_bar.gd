extends Node2D

# Tiny War - HP Bar
# Task 2.2.2

# Size of the HP bar in pixels.
const BAR_WIDTH: int = 48
const BAR_HEIGHT: int = 6

# Colours used by the HP bar.
const BACKGROUND_COLOR = Color(0.15, 0.15, 0.15)
const GREEN_COLOR = Color.GREEN
const YELLOW_COLOR = Color.YELLOW
const RED_COLOR = Color.RED

# Store the unit's current and maximum HP.
var current_hp: int = 100
var maximum_hp: int = 100


# Update the HP bar when HP changes.
func set_hp(current: int, maximum: int) -> void:

	# Prevent negative maximum HP.
	maximum_hp = max(0, maximum)

	# Prevent division by zero.
	if maximum_hp == 0:
		current_hp = 0
	else:
		# Keep HP between zero and the maximum.
		current_hp = clampi(current, 0, maximum_hp)

	# Tell Godot to draw the bar again.
	queue_redraw()


# Draw the HP bar on the screen.
func _draw() -> void:

	# Draw the dark background rectangle.
	draw_rect(
		Rect2(0, 0, BAR_WIDTH, BAR_HEIGHT),
		BACKGROUND_COLOR
	)

	# Stop if maximum HP is zero.
	if maximum_hp <= 0:
		return

	# Calculate how much HP remains.
	var hp_ratio: float = float(current_hp) / float(maximum_hp)

	# Calculate the width of the coloured rectangle.
	var fill_width: float = BAR_WIDTH * hp_ratio

	# No coloured bar when HP is zero.
	if current_hp <= 0:
		return

	# Choose the colour based on remaining HP.
	var bar_color: Color = GREEN_COLOR

	if hp_ratio <= 0.25:
		bar_color = RED_COLOR
	elif hp_ratio <= 0.50:
		bar_color = YELLOW_COLOR

	# Draw the coloured rectangle over the background.
	draw_rect(
		Rect2(0, 0, fill_width, BAR_HEIGHT),
		bar_color
	)
