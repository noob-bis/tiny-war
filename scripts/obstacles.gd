extends Node

const TILES = [
	Vector2i(5, 0), Vector2i(4, 1), Vector2i(5, 2), Vector2i(9, 2),
	Vector2i(6, 7), Vector2i(7, 6), Vector2i(6, 5), Vector2i(2, 5),
]

func is_blocked(tile: Vector2i) -> bool:
	return tile in TILES
