extends Node2D

const MAX_UNITS_PER_PLAYER = 6

const BASE_POSITIONS = {
	1: Vector2i(0, 0),
	2: Vector2i(11, 7),
}

var selected_unit_index = -1

@onready var mouse_input = $"../MouseInput"
@onready var player_economy = $"../PlayerEconomy"
@onready var turn_counter = $"../TurnCounter"
@onready var blue_base = $"../BlueBase"
@onready var red_base = $"../RedBase"

@onready var melee_blue_texture = preload("res://assets/Units/Blue/Melee/Melee.png")
@onready var melee_red_texture = preload("res://assets/Units/Red/Melee/Melee.png")
@onready var monk_blue_texture = preload("res://assets/Units/Blue/Monk/Monk.png")
@onready var monk_red_texture = preload("res://assets/Units/Red/Monk/Monk.png")

@onready var player1_hud = $"../CanvasLayer/Player1HUD"
@onready var player2_hud = $"../CanvasLayer/Player2HUD"
@onready var phase_hud = $"../CanvasLayer/Phase"

@onready var winner_label = $"../CanvasLayer/WinnerLabel"

var units: Array = []

func _process(_delta: float) -> void:
	update_hud()

func _ready() -> void:
	z_index = 10
	
	mouse_input.place_unit.connect(_on_place_unit)
	mouse_input.move_unit.connect(_on_move_unit)
	mouse_input.attack_unit.connect(_on_attack_unit)
	
	blue_base.base_destroyed.connect(_on_base_destroyed)
	red_base.base_destroyed.connect(_on_base_destroyed)
	
	player_economy.coins_changed.connect(update_hud)
	
	TurnManager.player_changed.connect(_on_player_changed)
	TurnManager.phase_changed.connect(_on_phase_changed)
	_on_phase_changed(TurnManager.current_player, TurnManager.get_current_phase())
	
	var grid = get_parent().get_node("BattleGrid")
	position = grid.position
	
func _draw() -> void:
	var bluebottomcenter = GridUtils.cell_to_pixel(Vector2i(0, 0)) + Vector2(32, 64)
	var bluesize = Vector2(128, 128)
	var bluepos = bluebottomcenter - Vector2(bluesize.x / 2, bluesize.y)
	draw_texture_rect(monk_blue_texture, Rect2(bluepos, Vector2(128,128)), false)
	
	var redbottomcenter = GridUtils.cell_to_pixel(Vector2i(11, 7)) + Vector2(32, 64)
	var redsize = Vector2(128, 128)
	var redpos = redbottomcenter - Vector2(redsize.x / 2, redsize.y)
	draw_texture_rect(monk_red_texture, Rect2(redpos, Vector2(128,128)), false)
	
	for unit in units:
		var texture = melee_blue_texture if unit["player"] == 1 else melee_red_texture
		var tile_bottom_center = GridUtils.cell_to_pixel(unit["position"]) + Vector2(32, 64)
		var size = Vector2(128, 128)
		var pos = tile_bottom_center - Vector2(size.x / 2, size.y)
		draw_texture_rect(texture, Rect2(pos, size), false)
		
	if selected_unit_index != -1:
			var pos = GridUtils.cell_to_pixel(units[selected_unit_index]["position"])
			draw_rect(Rect2(pos, Vector2(64, 64)), Color.YELLOW, false, 3.0)

func occupied_tiles() -> Array:
	var tiles = []
	for unit in units:
		tiles.append(unit["position"])
	return tiles
	
#
func _on_place_unit(tile: Vector2i) -> void:
	# figure out whose turn it is
	var current_player = TurnManager.current_player
	
	# look up that player's base position
	var base_position = BASE_POSITIONS[current_player]
	var deploy_zone = Deployment.get_adjacent_tiles(base_position)
	
	# if clicked tile is not in that list
	if tile not in deploy_zone:
		print("Selected tile is not in deploy zone")
	else: # if okat to deploy
		if tile in occupied_tiles():
			print("Tile already occupied")
			return
		
		if count_total_units(current_player) >= MAX_UNITS_PER_PLAYER:
			print("Max unit amount reached, cant deploy more")
			return
			
		# check unit cost
		var unit = UnitData.get_stats("melee")
		var cost = unit["cost"]
		
		# try to purchase
		if !player_economy.spend_coins(current_player, cost):
			print("Cant purchase unit, not enough coin")
			return
		else:
			units.append({
				"player": current_player,
				"type": "melee",
				"position": tile,
				"hp": UnitData.get_stats("melee")["hp"]
			})
			queue_redraw() # to make the cicle appear
			
func _on_player_changed(player: int) -> void:
	turn_counter.complete_turn()
	player_economy.give_passive_income(player, turn_counter.get_completed_turns() + 1)
	
func _on_base_destroyed(player: int) -> void:
	var winner = 1 if player == 2 else 2
	winner_label.text = "Player " + str(winner) + " wins!"
	winner_label.visible = true
	print("Player ", winner, " wins!")
	
func _on_attack_unit(tile: Vector2i) -> void:
	var current_player = TurnManager.current_player
	
	if selected_unit_index == -1:
		# nothing selected yet, try to select a unit at this tile
		for i in range(units.size()):
			if units[i]["position"] == tile and units[i]["player"] == current_player:
				selected_unit_index = i
				print("Selected unit at  ", tile)
				queue_redraw()
				return
		print("No unit of yours there to select")
	else:
		# reselect (friendly unit)
		for i in range(units.size()):
			if units[i]["position"] == tile and units[i]["player"] == current_player and i != selected_unit_index:
				selected_unit_index = i
				print("Selected unit at ", tile)
				queue_redraw()
				return
				
		# 
		var other_player = 1 if current_player == 2 else 2
		
		if tile == BASE_POSITIONS[other_player]:
			var i = selected_unit_index
			if AttackRange.can_attack(units[i]["position"], tile, UnitData.get_stats("melee")["range"]):
				var enemy_base = blue_base if other_player == 1 else red_base
				enemy_base.take_damage(UnitData.get_stats("melee")["atk"])
				selected_unit_index = -1
				queue_redraw()
				return
			
		var v = selected_unit_index
		for i in range(units.size()):
			if units[i]["position"] == tile and units[i]["player"] == other_player:
				if AttackRange.can_attack(units[v]["position"], tile, UnitData.get_stats("melee")["range"]):
					units[i]["hp"] -= UnitData.get_stats("melee")["atk"]
					if units[i]["hp"] <= 0:
						units.erase(units[i])
						print("Dealt damage, Unit removed")
						selected_unit_index = -1
						queue_redraw()
						return
					else:
						print("Dealt damage")
						selected_unit_index = -1
						queue_redraw()
						return
				else:
					print("Out of Range")
					queue_redraw()
					return
		
		print("No target here ", tile)
		
func _on_move_unit(tile: Vector2i) -> void:
	var current_player = TurnManager.current_player
	
	if selected_unit_index == -1:
		# nothing selected yet, try to select a unit at this tile
		for i in range(units.size()):
			if units[i]["position"] == tile and units[i]["player"] == current_player:
				selected_unit_index = i
				queue_redraw()
				print("Selected unit at  ", tile)
				return
		print("No unit of yours there to select")
	else:
		# reselect (friendly unit)
		for i in range(units.size()):
			if units[i]["position"] == tile and units[i]["player"] == current_player and i != selected_unit_index:
				selected_unit_index = i
				queue_redraw()
				print("Selected unit at ", tile)
				return
				
		if tile in occupied_tiles():
			print("Cant move to this tile, occupied!")
			return		
		
		var v = selected_unit_index
		if MovementRange.can_move(units[v]["position"], tile, units[v]["type"]):
			units[v]["position"] = tile
			print("Move unit to ", tile)
			selected_unit_index = -1
			queue_redraw()
			return
		else:
			print("Cant move to this tile")
			return
	
func _on_phase_changed(player: int, phase: String) -> void:
	selected_unit_index = -1
	queue_redraw()
	
	if phase == "Income" or phase == "End":
		TurnManager.advance_phase()
	elif (phase == "Move" or phase == "Act") and count_total_units(player) == 0:
		TurnManager.advance_phase()
	
	
func count_total_units(player: int) -> int:
	var count = 0
	for unit in units:
		if unit["player"] == player:
			count += 1
	return count
	
	
func update_hud() -> void:
	phase_hud.text = "%s" % [TurnManager.PHASES[TurnManager.current_phase_index]]
	player1_hud.text = "Player 1\nCoin: %d\nBase HP: %d" % [player_economy.get_coins(1), blue_base.base_hp]
	player2_hud.text = "Player 2\nCoin: %d\nBase HP: %d" % [player_economy.get_coins(2), red_base.base_hp]
	
	var p1_style = player1_hud.get_theme_stylebox("normal") as StyleBoxFlat
	p1_style.border_color = Color.YELLOW if TurnManager.current_player == 1 else Color.WHITE

	var p2_style = player2_hud.get_theme_stylebox("normal") as StyleBoxFlat
	p2_style.border_color = Color.YELLOW if TurnManager.current_player == 2 else Color.WHITE

		
	
func end_turn() -> void:
	TurnManager.advance_phase()
