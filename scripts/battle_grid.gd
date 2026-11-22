extends Node2D

const NO_TILE = Vector2i(-1, -1)
const CURSOR_TEXTURE = preload("res://assets/UI Elements/UI Elements/Cursors/Cursor_04.png")

var hovered_tile := NO_TILE

@onready var game_flow = $"../GameFlow"

func _ready() -> void:
	z_index = 11 # above GameFlow (10)

# the board has no lines, only the tile under the mouse is outlined
func _process(_delta: float) -> void:
	var pos = get_local_mouse_position()
	var tile = Vector2i((pos / GridUtils.TILE_SIZE).floor())
	if not GridUtils.is_cell_inside(tile):
		tile = NO_TILE
	if tile != hovered_tile:
		hovered_tile = tile
		queue_redraw()

func _draw() -> void:
	if hovered_tile == NO_TILE:
		return
	draw_texture_rect(CURSOR_TEXTURE, hover_rect(), false)

# the tile under the mouse, or the whole 2x2 block when the mouse is on a base
func hover_rect() -> Rect2:
	var tile_size = Vector2(GridUtils.TILE_SIZE, GridUtils.TILE_SIZE)
	for player in game_flow.BASE_POSITIONS:
		if hovered_tile in game_flow.base_tiles(player):
			return Rect2(GridUtils.cell_to_pixel(game_flow.BASE_POSITIONS[player]), tile_size * 2)
	return Rect2(GridUtils.cell_to_pixel(hovered_tile), tile_size)
