extends Node

# Tiny War - Movement Range and Pathfinding
# Task 2.1.4.4 - Find Path


# Our battlefield has 12 columns and 8 rows.
const COLUMNS = 12
const ROWS = 8

# Each unit has a different movement limit.
const MELEE_MOVE = 3
const RANGED_MOVE = 2
const TANK_MOVE = 1


# Find out how far a unit is allowed to move.
func get_movement_range(unit_type: String) -> int:

	if unit_type == "melee":
		return MELEE_MOVE

	elif unit_type == "ranged":
		return RANGED_MOVE

	elif unit_type == "tank":
		return TANK_MOVE

	# Unknown unit types cannot move.
	return 0


# Check whether a tile is inside the battlefield.
func is_inside_grid(tile: Vector2i) -> bool:

	if tile.x < 0 or tile.x >= COLUMNS:
		return false

	if tile.y < 0 or tile.y >= ROWS:
		return false

	return true


# Check whether a unit can move to another tile.
# This is the original movement-range check.
func can_move(
	start: Vector2i,
	target: Vector2i,
	unit_type: String
) -> bool:

	# Both positions must be inside the battlefield.
	if not is_inside_grid(start):
		return false

	if not is_inside_grid(target):
		return false

	# Get the movement limit for this unit.
	var move_limit = get_movement_range(unit_type)

	# Unknown unit types cannot move.
	if move_limit == 0:
		return false

	# Calculate horizontal and vertical distance.
	var distance = abs(target.x - start.x) + abs(target.y - start.y)

	# A unit must move to a different tile.
	if distance == 0:
		return false

	# Reject movement beyond the unit's range.
	if distance > move_limit:
		return false

	return true


# NEW FUNCTION - Task 2.1.4.4
#
# Find the shortest path from start to goal.
#
# start: The unit's current tile.
# goal: The destination tile.
# blocked: Tiles occupied by other units.
# max_steps: Maximum number of tiles the unit can move.
#
# Returns the tiles the unit should walk through.
# The starting tile is NOT included.
#
# Returns an empty array if no valid path exists.
func find_path(
	start: Vector2i,
	goal: Vector2i,
	blocked: Array,
	max_steps: int
) -> Array[Vector2i]:

	# Stores the final path.
	var path: Array[Vector2i] = []

	# Reject positions outside the battlefield.
	if not is_inside_grid(start):
		return path

	if not is_inside_grid(goal):
		return path

	# The destination cannot be occupied.
	if goal in blocked:
		return path

	# No movement is needed if already at the goal.
	if start == goal:
		return path

	# Reject invalid movement limits.
	if max_steps <= 0:
		return path

	# Four allowed directions.
	# Diagonal movement is not allowed.
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),   # Right
		Vector2i(-1, 0),  # Left
		Vector2i(0, 1),   # Down
		Vector2i(0, -1)   # Up
	]

	# Breadth-First Search (BFS) checks nearby tiles
	# before checking tiles farther away.
	#
	# This allows us to find the shortest path.
	var queue: Array[Vector2i] = [start]

	# Remember which tiles have already been visited.
	var visited = {
		start: true
	}

	# Store where we came from for each tile.
	# This lets us rebuild the shortest path.
	var came_from = {}

	# Store the distance from the starting tile.
	var distances = {
		start: 0
	}

	# Track the next tile to process.
	var queue_index: int = 0

	# Continue until every reachable tile is checked.
	while queue_index < queue.size():

		# Get the next tile to examine.
		var current: Vector2i = queue[queue_index]
		queue_index += 1

		# Stop searching if we reached the destination.
		if current == goal:
			break

		# Do not search beyond the movement limit.
		if distances[current] >= max_steps:
			continue

		# Check all four neighboring tiles.
		for direction in directions:

			var next_tile: Vector2i = current + direction

			# Skip tiles outside the battlefield.
			if not is_inside_grid(next_tile):
				continue

			# Skip tiles occupied by other units.
			if next_tile in blocked:
				continue

			# Skip tiles we already checked.
			if visited.has(next_tile):
				continue

			# Remember this tile.
			visited[next_tile] = true

			# Remember how we reached this tile.
			came_from[next_tile] = current

			# Record how many steps it took.
			distances[next_tile] = distances[current] + 1

			# Add the tile to the search queue.
			queue.append(next_tile)

	# If the destination was never reached,
	# there is no valid path.
	if not visited.has(goal):
		return path

	# Rebuild the path by walking backward
	# from the destination to the starting tile.
	var current_tile: Vector2i = goal

	while current_tile != start:

		# Add each tile to the beginning of the path.
		path.push_front(current_tile)

		# Move backward to the previous tile.
		current_tile = came_from[current_tile]

	# Return the shortest path.
	return path
