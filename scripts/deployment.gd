extends Node

# 4 tiles next to a central tile
const TILES_OFFSETS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

# get adjacent tiles based on position
func get_adjacent_tiles(tile_position: Vector2i) -> Array:
	var result = []
	for offset in TILES_OFFSETS:
		result.append(tile_position + offset)
	return result

# to check if a tile is occupied by a unit or not
func is_tile_open(tile: Vector2i, occupied_tiles: Array) -> bool:
	if GridUtils.is_cell_inside(tile):
		return not (tile in occupied_tiles)
	return false

# get open tiles next to bases available to deploy units
func get_open_deploy_tiles(base_position: Vector2i, occupied_tiles: Array) -> Array:
	var list = [base_position] + get_adjacent_tiles(base_position)
	var result = []
	for tile in list:
		if is_tile_open(tile, occupied_tiles):
			result.append(tile)
	return result
