extends Node

# TEST BRANCH: "pillars" (Nov 25). The second half is the first half turned around.
# Four ways across (not only through the flag), cover next to the flag for Ranged.
const TILES = [
	Vector2i(4, 2), Vector2i(7, 2), Vector2i(2, 4), Vector2i(8, 0),
	Vector2i(7, 5), Vector2i(4, 5), Vector2i(9, 3), Vector2i(3, 7),
]

func is_blocked(tile: Vector2i) -> bool:
	return tile in TILES
