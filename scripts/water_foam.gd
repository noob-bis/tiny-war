extends Node2D

# puts an animated foam under every tile on the edge of the island
const FOAM_SCENE = preload("res://scenes/foam.tscn")

@onready var ground: TileMapLayer = $"../Ground"

func _ready() -> void:
	for cell in ground.get_used_cells():
		if is_edge(cell):
			var foam = FOAM_SCENE.instantiate()
			add_child(foam)
			foam.position = ground.position + ground.map_to_local(cell)

func is_edge(cell: Vector2i) -> bool:
	for next in ground.get_surrounding_cells(cell):
		if ground.get_cell_source_id(next) == -1: # no tile there, so it is water
			return true
	return false
