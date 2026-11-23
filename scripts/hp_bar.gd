extends Node2D

# The frame picture is 3 pieces in one file: left end, middle, right end.
const FRAME = preload("res://assets/UI Elements/UI Elements/Bars/SmallBar_Base.png")
const LEFT_END = Rect2(49, 22, 15, 19)
const MIDDLE = Rect2(128, 22, 64, 19)
const RIGHT_END = Rect2(256, 22, 15, 19)
const END_WIDTH = 15
const BAR_HEIGHT = 19

# The coloured slot inside the frame.
const SLOT_X = 10 # from each side
const SLOT_Y = 8
const SLOT_HEIGHT = 3

# Colours used by the HP bar.
const GREEN_COLOR = Color(0.35, 0.85, 0.35)
const YELLOW_COLOR = Color(1.0, 0.85, 0.2)
const RED_COLOR = Color(0.95, 0.25, 0.25)
const EMPTY_COLOR = Color(0.22, 0.19, 0.2)


# Width in pixels. Bases use a wider bar.
var bar_width: int = 56


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

func _draw() -> void:

	# Draw the frame: the two ends stay the same size, the middle stretches.
	draw_texture_rect_region(FRAME, Rect2(0, 0, END_WIDTH, BAR_HEIGHT), LEFT_END)
	draw_texture_rect_region(FRAME, Rect2(END_WIDTH, 0, bar_width - END_WIDTH * 2, BAR_HEIGHT), MIDDLE)
	draw_texture_rect_region(FRAME, Rect2(bar_width - END_WIDTH, 0, END_WIDTH, BAR_HEIGHT), RIGHT_END)

	# Paint the whole slot dark first, so the lost HP shows as an empty part.
	var slot_width: float = bar_width - SLOT_X * 2
	draw_rect(Rect2(SLOT_X, SLOT_Y, slot_width, SLOT_HEIGHT), EMPTY_COLOR)


	# No coloured bar when there is no HP.
	if maximum_hp <= 0 or current_hp <= 0:
		return

	# Calculate how much HP remains.
	var hp_ratio: float = float(current_hp) / float(maximum_hp)

	# Choose the colour based on remaining HP.
	var bar_color: Color = GREEN_COLOR

	if hp_ratio <= 0.25:
		bar_color = RED_COLOR
	elif hp_ratio <= 0.50:
		bar_color = YELLOW_COLOR

	# Fill the slot inside the frame.
	draw_rect(Rect2(SLOT_X, SLOT_Y, slot_width * hp_ratio, SLOT_HEIGHT), bar_color)
