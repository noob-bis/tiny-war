extends Node2D

# godot calls this automatically on every input event
# we check "was this a left click?"
# if so -> get the mouse's pixel position and convert it back to a cell address.
# and if that cell is on the board -> print it
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_local_mouse_position()
		var cell = Vector2i(pos.x / GridUtils.TILE_SIZE, pos.y / GridUtils.TILE_SIZE)
		if GridUtils.is_cell_inside(cell):
			print(cell)

func _draw() -> void:
	# vertical lines
	for x in range(GridUtils.GRID_COLS + 1):
		var x_pos = x * GridUtils.TILE_SIZE
		draw_line(
			Vector2(x_pos, 0),
			Vector2(x_pos, GridUtils.GRID_ROWS * GridUtils.TILE_SIZE),
			Color(1, 1, 1, 0.6),
			1.5
		)

	# horizontal lines
	for y in range(GridUtils.GRID_ROWS + 1):
		var y_pos = y * GridUtils.TILE_SIZE
		draw_line(
			Vector2(0, y_pos),
			Vector2(GridUtils.GRID_COLS * GridUtils.TILE_SIZE, y_pos),
			Color(1, 1, 1, 0.6),
			1.5
		)
