extends Node

const GRID_COLS = 12
const GRID_ROWS = 8
const TILE_SIZE = 64 # each tile 64 pixels

# convert a cell address (like (3,2)) into an pixel on screen
func cell_to_pixel(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE)

# check if the cell is part of the board, if not return false
func is_cell_inside(cell: Vector2i) -> bool:
	return (cell.x >= 0 and cell.x < GRID_COLS) and (cell.y >= 0 and cell.y < GRID_ROWS)
