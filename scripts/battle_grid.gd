extends Node2D

const GRID_COLS = 12
const GRID_ROWS = 8
const TILE_SIZE = 64 # each tile 64 pixels

# convert a cell address (like (3,2)) into an pixel on screen
func cell_to_pixel(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE)

# check if the cell is part of the board, if not return false
func is_cell_inside(cell: Vector2i) -> bool:
	return (cell.x >= 0 and cell.x < GRID_COLS) and (cell.y >= 0 and cell.y < GRID_ROWS)

# godot calls this automatically on every input event
# we check "was this a left click?"
# if so -> get the mouse's pixel position and convert it back to a cell address.
# and if that cell is on the board -> print it
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_local_mouse_position()
		var cell = Vector2i(pos.x / TILE_SIZE, pos.y / TILE_SIZE)
		if is_cell_inside(cell):
			print(cell)

func _draw() -> void:
	# vertical lines
	for x in range(GRID_COLS + 1):
		var x_pos = x * TILE_SIZE
		draw_line(
			Vector2(x_pos, 0),
			Vector2(x_pos, GRID_ROWS * TILE_SIZE),
			Color(1, 1, 1, 0.6),
			1.5
		)

	# horizontal lines
	for y in range(GRID_ROWS + 1):
		var y_pos = y * TILE_SIZE
		draw_line(
			Vector2(0, y_pos),
			Vector2(GRID_COLS * TILE_SIZE, y_pos),
			Color(1, 1, 1, 0.6),
			1.5
		)
