extends Node

# Impassable tiles 
# Make a chokepoint in the middle rows
const TILES = [
	Vector2i(5, 1), Vector2i(9, 1), Vector2i(7, 2), Vector2i(3, 3),
	Vector2i(8, 4), Vector2i(4, 5), Vector2i(2, 6), Vector2i(6, 6),
]


func is_blocked(tile: Vector2i) -> bool:
	return tile in TILES
