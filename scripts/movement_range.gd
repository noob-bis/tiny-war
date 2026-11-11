extends Node

# Tiny War - Movement Range and Pathfinding
# Task 2.1.3.1 - Range Cleanup
# Task 2.1.4.4 - Find Path
#
# Unit movement values come from UnitData.
# Map boundaries are checked using GridUtils.


# Get the movement range for a unit.
func get_movement_range(unit_type: String) -> int:

	# Ask UnitData for the unit's stats.
	var stats: Dictionary = UnitData.get_stats(unit_type)

	# Unknown units cannot move.
	if stats.is_empty():
		return 0

	# Return the movement number from UnitData.
	return int(stats.get("move", 0))


# Check whether a unit can move to another tile.
func can_move(
	start: Vector2i,
	target: Vector2i,
	unit_type: String
) -> bool:

	# Both positions must be inside the battlefield.
	if not GridUtils.is_cell_inside(start):
		return false

	if not GridUtils.is_cell_inside(target):
		return false

	# Get the movement limit from UnitData.
	var move_limit: int = get_movement_range(unit_type)

	# Unknown unit types cannot move.
	if move_limit <= 0:
		return false

	# Calculate horizontal and vertical distance.
	var distance: int = (
		abs(target.x - start.x)
		+ abs(target.y - start.y)
	)

	# A unit must move to a different tile.
	if distance == 0:
		return false

	# Reject movement beyond the unit's range.
	if distance > move_limit:
		return false

	return true


# Find the shortest path from start to goal.
#
# start: The unit's current tile.
# goal: The destination tile.
# blocked: Tiles occupied by other units.
# max_steps: Maximum number of tiles the unit can move.
#
# Returns a list of tiles to walk through.
# The starting tile is not included.
#
# Returns an empty array if no valid path exists.
func find_path(
	start: Vector2i,
	goal: Vector2i,
	blocked: Array,
	max_steps: int
) -> Array[Vector2i]:

	# Store the final path.
	var path: Array[Vector2i] = []

	# Reject starting positions outside the map.
	if not GridUtils.is_cell_inside(start):
		return path

	# Reject destinations outside the map.
	if not GridUtils.is_cell_inside(goal):
		return path

	# Reject occupied destinations.
	if goal in blocked:
		return path

	# No movement is needed if start and goal match.
	if start == goal:
		return path

	# Reject invalid movement limits.
	if max_steps <= 0:
		return path

	# Four allowed movement directions.
	# Diagonal movement is not allowed.
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),   # Right
		Vector2i(-1, 0),  # Left
		Vector2i(0, 1),   # Down
		Vector2i(0, -1)   # Up
	]

	# Breadth-First Search (BFS) finds the shortest path.
	# It checks nearby tiles before distant tiles.
	var queue: Array[Vector2i] = [start]

	# Track which tiles have already been visited.
	var visited = {
		start: true
	}

	# Remember the previous tile for each position.
	# This lets us rebuild the path later.
	var came_from = {}

	# Track the number of steps from the start.
	var distances = {
		start: 0
	}

	# Track the next tile to check.
	var queue_index: int = 0

	# Keep searching while there are tiles in the queue.
	while queue_index < queue.size():

		# Get the next tile.
		var current: Vector2i = queue[queue_index]
		queue_index += 1

		# Stop if we reached the destination.
		if current == goal:
			break

		# Do not exceed the movement limit.
		if distances[current] >= max_steps:
			continue

		# Check the four neighboring tiles.
		for direction in directions:

			var next_tile: Vector2i = current + direction

			# Ignore tiles outside the battlefield.
			if not GridUtils.is_cell_inside(next_tile):
				continue

			# Ignore tiles occupied by other units.
			if next_tile in blocked:
				continue

			# Ignore tiles that were already checked.
			if visited.has(next_tile):
				continue

			# Mark the tile as visited.
			visited[next_tile] = true

			# Remember which tile led here.
			came_from[next_tile] = current

			# Record the distance from the start.
			distances[next_tile] = distances[current] + 1

			# Add this tile to the search queue.
			queue.append(next_tile)

	# No path exists if the goal was never reached.
	if not visited.has(goal):
		return path

	# Rebuild the shortest path backward.
	var current_tile: Vector2i = goal

	while current_tile != start:

		# Insert the tile at the front of the path.
		path.push_front(current_tile)

		# Move backward to the previous tile.
		current_tile = came_from[current_tile]

	# Return the completed shortest path.
	return path
