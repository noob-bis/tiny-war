extends Node2D

const MAX_UNITS_PER_PLAYER = 6
const BASE_POSITIONS = {
	1: Vector2i(0, 0),
	2: Vector2i(10, 6),}
const SKINS = {
	"1_melee": preload("res://assets/Units/Blue/Melee/Melee.png"),
	"2_melee": preload("res://assets/Units/Red/Melee/Melee.png"),
	"1_ranged": preload("res://assets/Units/Blue/Ranged/Ranged.png"),
	"2_ranged": preload("res://assets/Units/Red/Ranged/Ranged.png"),
	"1_tank": preload("res://assets/Units/Blue/Tank/Warrior_Blue.png"),
	"2_tank": preload("res://assets/Units/Red/Tank/Warrior_Red.png"),}
const HP_BAR_SCENE = preload("res://scenes/HpBar.tscn")
const HIGHLIGHT_DEPLOY = Color(0.2, 0.9, 0.3, 0.35)
const HIGHLIGHT_MOVE = Color(0.2, 0.5, 1.0, 0.35)
const HIGHLIGHT_ATTACK = Color(1.0, 0.2, 0.2, 0.8)
const MESSAGE_TIME = 2.0
const IMPACT_SCENE = preload("res://scenes/impact.tscn")
const FLASH_TIME_UNIT = 0.2
const DONE_TINT = Color(0.5, 0.5, 0.5)
const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")
const ARROW_SCENE = preload("res://scenes/arrow.tscn")
const BASE_TEXTURES = {
	1: preload("res://assets/Buildings/Blue Buildings/Barracks.png"),
	2: preload("res://assets/Buildings/Black Buildings/Barracks.png"),}
const BASE_SIZE = Vector2(128, 171)
const ROCK_BIG = preload("res://assets/Terrain/Decorations/Rocks/Rock4.png")
const ROCK_SMALL = preload("res://assets/Terrain/Decorations/Rocks/Rock2.png")
const BUSH = preload("res://assets/Terrain/Decorations/Bushes/Bushe3.png")
const OBSTACLE_ART = [
	{"texture": ROCK_BIG, "size": Vector2(80, 80), "shift": Vector2(0, 0)},
	{"texture": BUSH, "size": Vector2(116, 116), "shift": Vector2(0, 8)},
	{"texture": ROCK_SMALL, "size": Vector2(80, 80), "shift": Vector2(0, 0)},
	{"texture": BUSH, "size": Vector2(116, 116), "shift": Vector2(0, 8)},]


var selected_unit_index = -1
var selected_deploy_type := "melee";
var units: Array = []
var base_bars: Dictionary = {}
var game_over := false
var message_timer: SceneTreeTimer
var base_effects: Dictionary = {}

@onready var mouse_input = $"../MouseInput"
@onready var player_economy = $"../PlayerEconomy"
@onready var turn_counter = $"../TurnCounter"
@onready var blue_base = $"../BlueBase"
@onready var red_base = $"../RedBase"
@onready var player1_hud = $"../CanvasLayer/Player1HUD"
@onready var player2_hud = $"../CanvasLayer/Player2HUD"
@onready var phase_hud = $"../CanvasLayer/Phase"
@onready var winner_label = $"../CanvasLayer/WinnerLabel"
@onready var picker = $"../CanvasLayer/Picker"
@onready var end_turn_button = $"../CanvasLayer/EndturnButton"
@onready var message_label = $"../CanvasLayer/Message"

# METHODS
func _process(_delta: float) -> void:
	update_hud()
	for unit in units:
		update_bar(unit)
	update_base_bars()

func _ready() -> void:
	z_index = 10
	
	mouse_input.place_unit.connect(_on_place_unit)
	mouse_input.move_unit.connect(_on_move_unit)
	mouse_input.attack_unit.connect(_on_attack_unit)
	
	blue_base.base_destroyed.connect(_on_base_destroyed)
	red_base.base_destroyed.connect(_on_base_destroyed)
	
	TurnManager.player_changed.connect(_on_player_changed)
	TurnManager.phase_changed.connect(_on_phase_changed)
	_on_phase_changed(TurnManager.current_player, TurnManager.get_current_phase())
	
	var grid = get_parent().get_node("BattleGrid")
	position = grid.position
	
	for button in picker.get_children():
		button.pressed.connect(_on_pick.bind(String(button.name)))
		button.text = "%s\n%d" % [button.name, UnitData.get_stats(String(button.name))["cost"]]
	_on_pick("melee")
	turn_counter.turn_limit_reached.connect(_on_turn_limit)
	
	for player in BASE_POSITIONS:
		var base_bar = HP_BAR_SCENE.instantiate()
		add_child(base_bar)
		base_bars[player] = base_bar
		
	for player in BASE_POSITIONS:
		var effect = IMPACT_SCENE.instantiate()
		add_child(effect)
		effect.position = GridUtils.cell_to_pixel(BASE_POSITIONS[player]) + Vector2(64, 40)
		base_effects[player] = effect
	blue_base.damage_state_changed.connect(_on_base_state_changed)
	red_base.damage_state_changed.connect(_on_base_state_changed)

func _draw() -> void:
	for i in Obstacles.TILES.size():
		var art = OBSTACLE_ART[i % OBSTACLE_ART.size()]
		var center = GridUtils.cell_to_pixel(Obstacles.TILES[i]) + Vector2(32, 32) + art["shift"]
		var target = Rect2(center - art["size"] / 2, art["size"])
		var frame_size = art["texture"].get_height() # the first frame is a square
		draw_texture_rect_region(art["texture"], target, Rect2(0, 0, frame_size, frame_size))

		
	var marks = highlight_tiles()
	for tile in marks:
		var rect = Rect2(GridUtils.cell_to_pixel(tile), Vector2(64, 64))
		if marks[tile] == HIGHLIGHT_ATTACK:
			draw_rect(rect, marks[tile], false, 3.0)
		else:
			draw_rect(rect.grow(-2), marks[tile])


	for player in BASE_POSITIONS:
		var block_bottom_center = GridUtils.cell_to_pixel(BASE_POSITIONS[player]) + Vector2(64, 128)
		var base_pos = block_bottom_center - Vector2(BASE_SIZE.x / 2, BASE_SIZE.y)
		draw_texture_rect(BASE_TEXTURES[player], Rect2(base_pos, BASE_SIZE), false)


	
	for unit in units:
		var texture = SKINS["%d_%s" % [unit["player"], unit["type"]]]
		var tile_bottom_center = GridUtils.cell_to_pixel(unit["position"]) + Vector2(32, 64)
		var size = Vector2(128, 128)
		var pos = tile_bottom_center - Vector2(size.x / 2, size.y)
		var tint = DONE_TINT if is_done(unit) else Color.WHITE
		if unit.get("flash", false):
			tint = Color(1, 0.3, 0.3)
		draw_texture_rect(texture, Rect2(pos, size), false, tint)
		
	if selected_unit_index != -1:
			var pos = GridUtils.cell_to_pixel(units[selected_unit_index]["position"])
			draw_rect(Rect2(pos, Vector2(64, 64)), Color.YELLOW, false, 3.0)

func occupied_tiles() -> Array:
	var tiles = base_tiles(1) + base_tiles(2) + Obstacles.TILES
	for unit in units:
		tiles.append(unit["position"])
	return tiles

func _on_place_unit(tile: Vector2i) -> void:
	if game_over : return
	
	# figure out whose turn it is
	var current_player = TurnManager.current_player

	# look up that player's base position
	var deploy_zone = base_deploy_tiles(current_player)

	# if clicked tile is not in that list
	if tile not in deploy_zone:
		show_message("Deploy next to your own base")
	else: # if okat to deploy
		if tile in occupied_tiles():
			show_message("That tile is taken")
			return

		if count_total_units(current_player) >= MAX_UNITS_PER_PLAYER:
			show_message("You already have 6 units")
			return

		# check unit cost
		var unit = UnitData.get_stats(selected_deploy_type)
		var cost = unit["cost"]

		# try to purchase
		if !player_economy.spend_coins(current_player, cost):
			show_message("Not enough coins")
			return
		else:
			var bar = HP_BAR_SCENE.instantiate()
			add_child(bar)
			units.append({
				"player": current_player,
				"type": selected_deploy_type,
				"position": tile,
				"hp": unit["hp"],
				"acted": false,
				"moved": false,
				"bar": bar
			})

			queue_redraw() # to make the cicle appear

func _on_player_changed(player: int) -> void:
	turn_counter.complete_turn()
	# each player's first turn uses only the starting bank (250)
	if turn_counter.get_completed_turns() >= 2:
		player_economy.give_passive_income(player, turn_counter.get_completed_turns() + 1)

func _on_base_destroyed(player: int) -> void:
	var winner = 1 if player == 2 else 2
	finish_game("Player %d wins!" % winner)

func _on_attack_unit(tile: Vector2i) -> void:
	if game_over : return
	
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
				
		if units[selected_unit_index]["acted"]:
			show_message("This unit already attacked")
			return

		var other_player = 1 if current_player == 2 else 2
		
		if tile in base_tiles(other_player):
			var i = selected_unit_index
			if base_in_range(units[i]["position"], other_player, UnitData.get_stats(units[i]["type"])["range"]):
				var enemy_base = blue_base if other_player == 1 else red_base
				units[i]["acted"] = true
				enemy_base.take_damage(UnitData.get_stats(units[i]["type"])["atk"])
				if units[i]["type"] == "ranged":
					shoot(units[i]["position"], tile)
				selected_unit_index = -1
				queue_redraw()
				return
			
		var attacker_index = selected_unit_index
		var attacker_type = units[attacker_index]["type"]
		var attacker_stats = UnitData.get_stats(attacker_type)
		
		for i in range(units.size()):
			
			if units[i]["position"] == tile and units[i]["player"] == other_player:
				
				if AttackRange.can_attack(units[attacker_index]["position"], tile, attacker_stats["range"]):
					var damage = Damage.calculate_damage(attacker_type, units[i]["type"], attacker_stats["atk"])
					units[attacker_index]["acted"] = true
					units[i]["hp"] -= damage
					flash_unit(units[i])
					if attacker_type == "ranged":
						shoot(units[attacker_index]["position"], tile)

					if units[i]["hp"] <= 0:
						var bonus = player_economy.get_kill_bonus(units[i]["type"])
						player_economy.add_coins(current_player, bonus)
						units[i]["bar"].queue_free()
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
					show_message("Out of range")
					queue_redraw()
					return

		print("No target here ", tile)

func _on_move_unit(tile: Vector2i) -> void:
	if game_over : return
	
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
			show_message("Can't move there")
			return

		var moving_index = selected_unit_index
		var mover = units[moving_index]
		if mover["moved"]:
			show_message("This unit already moved")
			return

		var path = MovementRange.find_path(
			mover["position"],
			tile,
			occupied_tiles(),
			MovementRange.get_movement_range(mover["type"])
		)
		if path.is_empty():
			show_message("Can't move there")
			return

		mover["position"] = tile
		mover["moved"] = true

		print("Move unit to ", tile)
		selected_unit_index = -1
		queue_redraw()

func _on_phase_changed(player: int, phase: String) -> void:
	selected_unit_index = -1
	queue_redraw()
	
	if phase == "Income":
		for unit in units:
			if unit["player"] == player:
				unit["acted"] = false
				unit["moved"] = false

	if phase == "End":
		apply_base_damage(player)
	
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

func _on_pick(kind: String) -> void:
	selected_deploy_type = kind
	for b in picker.get_children():
		b.modulate = Color.YELLOW if b.name == kind else Color.WHITE

func apply_base_damage(player: int) -> void:
	var enemy = 1 if player == 2 else 2
	var survivors = []
	for unit in units:
		if unit["player"] == player:
			if unit["position"] in base_deploy_tiles(enemy):
				unit["hp"] -= BaseAttack.BASE_DAMAGE
				base_shoot(enemy, unit)
			if unit["hp"] <= 0:
				unit["bar"].queue_free()
				continue
		survivors.append(unit)
	units = survivors
	selected_unit_index = -1
	queue_redraw()

func army_value(player: int) -> int:
	var total = 0
	for unit in units:
		if unit["player"] == player:
			total += UnitData.get_stats(unit["type"])["cost"]
	return total

func _on_turn_limit() -> void:
	var winner = 0
	if blue_base.base_hp > red_base.base_hp:
		winner = 1
	elif red_base.base_hp > blue_base.base_hp:
		winner = 2
	elif army_value(1) > army_value(2):
		winner = 1
	elif army_value(2) > army_value(1):
		winner = 2

	finish_game("Draw!" if winner == 0 else "Player %d wins!" % winner)

func update_bar(unit: Dictionary) -> void:
	var bar = unit["bar"]
	bar.position = GridUtils.cell_to_pixel(unit["position"]) + Vector2(8, 0)
	var max_hp = UnitData.get_stats(unit["type"])["hp"]
	if bar.current_hp != unit["hp"] or bar.maximum_hp != max_hp:
		bar.set_hp(unit["hp"], max_hp)

func update_base_bars() -> void:
	for player in base_bars:
		var base = blue_base if player == 1 else red_base
		var bar = base_bars[player]
		bar.position = GridUtils.cell_to_pixel(BASE_POSITIONS[player]) + Vector2(40, -12)
		if bar.current_hp != base.base_hp:
			bar.set_hp(base.base_hp, base.MAX_BASE_HP)

func end_turn() -> void:
	if game_over : return
	TurnManager.advance_phase()

func finish_game(text: String) -> void:
	game_over = true
	selected_unit_index = -1
	winner_label.text = text
	winner_label.visible = true
	end_turn_button.disabled = true
	queue_redraw()

func highlight_tiles() -> Dictionary:
	# {tile: color} for what the current player can do right now
	var result = {}
	if game_over:
		return result
	var player = TurnManager.current_player
	var phase = TurnManager.get_current_phase()
	if phase == "Deploy":
		var taken = occupied_tiles()
		for tile in base_deploy_tiles(player):
			if tile not in taken:
				result[tile] = HIGHLIGHT_DEPLOY
	elif selected_unit_index != -1:
		var unit = units[selected_unit_index]
		if phase == "Move" and not unit["moved"]:
			for tile in reachable_tiles(unit):
				result[tile] = HIGHLIGHT_MOVE
		elif phase == "Act" and not unit["acted"]:
			for tile in attack_targets(unit):
				result[tile] = HIGHLIGHT_ATTACK
	return result

func reachable_tiles(unit: Dictionary) -> Array:
	var tiles = []
	var blocked = occupied_tiles()
	var steps = MovementRange.get_movement_range(unit["type"])
	for x in range(GridUtils.GRID_COLS):
		for y in range(GridUtils.GRID_ROWS):
			var tile = Vector2i(x, y)
			if not MovementRange.find_path(unit["position"], tile, blocked, steps).is_empty():
				tiles.append(tile)
	return tiles

func attack_targets(unit: Dictionary) -> Array:
	var tiles = []
	var attack_range = UnitData.get_stats(unit["type"])["range"]
	var enemy = 1 if unit["player"] == 2 else 2
	for other in units:
		if other["player"] == enemy and AttackRange.can_attack(unit["position"], other["position"], attack_range):
			tiles.append(other["position"])
	if base_in_range(unit["position"], enemy, attack_range):
		tiles += base_tiles(enemy)
	return tiles

func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	var timer = get_tree().create_timer(MESSAGE_TIME)
	message_timer = timer
	await timer.timeout
	if message_timer == timer:  # a newer message keeps showing
		message_label.visible = false

func _on_base_state_changed(player: int, state: String) -> void:
	base_effects[player].set_base_state(state)

func flash_unit(unit: Dictionary) -> void:
	unit["flash"] = true
	queue_redraw()
	await get_tree().create_timer(FLASH_TIME_UNIT).timeout
	unit["flash"] = false
	queue_redraw()

func is_done(unit: Dictionary) -> bool:
	# grey when the unit has nothing left to do in this phase
	if unit["player"] != TurnManager.current_player:
		return false
	var phase = TurnManager.get_current_phase()
	return (phase == "Move" and unit["moved"]) or (phase == "Act" and unit["acted"])

func shoot(from_tile: Vector2i, to_tile: Vector2i) -> void:
	var projectile = ARROW_SCENE.instantiate()
	add_child(projectile)
	projectile.z_index = 5
	var center = Vector2(32, 32)
	var from_pos = to_global(GridUtils.cell_to_pixel(from_tile) + center)
	var to_pos = to_global(GridUtils.cell_to_pixel(to_tile) + center)
	projectile.fire(from_pos, to_pos)

func base_shoot(player: int, unit: Dictionary) -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	add_child(projectile)
	projectile.z_index = 5
	projectile.scale = Vector2(0.2, 0.2) # the fireball picture is 429 px wide
	projectile.speed = 250.0 # the target is close, so fly slower
	var from_pos = to_global(GridUtils.cell_to_pixel(BASE_POSITIONS[player]) + Vector2(64, 64))
	var to_pos = to_global(GridUtils.cell_to_pixel(unit["position"]) + Vector2(32, 32))
	projectile.fire(from_pos, to_pos)
	await projectile.hit
	flash_unit(unit)

func base_tiles(player: int) -> Array:
	# the base covers a 2x2 block, BASE_POSITIONS is its top-left tile
	var corner = BASE_POSITIONS[player]
	return [corner, corner + Vector2i(1, 0), corner + Vector2i(0, 1), corner + Vector2i(1, 1)]

func base_deploy_tiles(player: int) -> Array:
	# every tile on the board that touches the base block
	var block = base_tiles(player)
	var result = []
	for tile in block:
		for next in Deployment.get_adjacent_tiles(tile):
			if GridUtils.is_cell_inside(next) and next not in block and next not in result:
				result.append(next)
	return result

func base_in_range(from_tile: Vector2i, player: int, attack_range: int) -> bool:
	for tile in base_tiles(player):
		if AttackRange.can_attack(from_tile, tile, attack_range):
			return true
	return false
