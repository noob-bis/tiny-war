extends Node2D

const MAX_UNITS_PER_PLAYER = 6
const BASE_POSITIONS = {
	1: Vector2i(1, 1),
	2: Vector2i(10,6),}
const SKINS = {
	"1_melee": preload("res://assets/Units/Blue/Melee/Melee.png"),
	"2_melee": preload("res://assets/Units/Red/Melee/Melee.png"),
	"1_ranged": preload("res://assets/Units/Blue/Ranged/Ranged.png"),
	"2_ranged": preload("res://assets/Units/Red/Ranged/Ranged.png"),
	"1_tank": preload("res://assets/Units/Blue/Tank/Warrior_Blue.png"),
	"2_tank": preload("res://assets/Units/Red/Tank/Warrior_Red.png"),}

const HP_BAR_SCENE = preload("res://scenes/HpBar.tscn")

var selected_unit_index = -1
var selected_deploy_type := "melee";
var units: Array = []
var base_bars: Dictionary = {}

@onready var mouse_input = $"../MouseInput"
@onready var player_economy = $"../PlayerEconomy"
@onready var turn_counter = $"../TurnCounter"
@onready var blue_base = $"../BlueBase"
@onready var red_base = $"../RedBase"
@onready var monk_blue_texture = preload("res://assets/Units/Blue/Monk/Monk.png")
@onready var monk_red_texture = preload("res://assets/Units/Red/Monk/Monk.png")
@onready var player1_hud = $"../CanvasLayer/Player1HUD"
@onready var player2_hud = $"../CanvasLayer/Player2HUD"
@onready var phase_hud = $"../CanvasLayer/Phase"
@onready var winner_label = $"../CanvasLayer/WinnerLabel"
@onready var picker = $"../CanvasLayer/Picker"

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

func _draw() -> void:
	for tile in Obstacles.TILES:
		draw_rect(Rect2(GridUtils.cell_to_pixel(tile), Vector2(64, 64)), Color(0.3, 0.3, 0.3))

	var bluebottomcenter = GridUtils.cell_to_pixel(BASE_POSITIONS[1]) + Vector2(32, 64)
	var bluesize = Vector2(128, 128)
	var bluepos = bluebottomcenter - Vector2(bluesize.x / 2, bluesize.y)
	draw_texture_rect(monk_blue_texture, Rect2(bluepos, Vector2(128,128)), false)
	
	var redbottomcenter = GridUtils.cell_to_pixel(BASE_POSITIONS[2]) + Vector2(32, 64)
	var redsize = Vector2(128, 128)
	var redpos = redbottomcenter - Vector2(redsize.x / 2, redsize.y)
	draw_texture_rect(monk_red_texture, Rect2(redpos, Vector2(128,128)), false)
	
	for unit in units:
		var texture = SKINS["%d_%s" % [unit["player"], unit["type"]]]
		var tile_bottom_center = GridUtils.cell_to_pixel(unit["position"]) + Vector2(32, 64)
		var size = Vector2(128, 128)
		var pos = tile_bottom_center - Vector2(size.x / 2, size.y)
		draw_texture_rect(texture, Rect2(pos, size), false)
		
	if selected_unit_index != -1:
			var pos = GridUtils.cell_to_pixel(units[selected_unit_index]["position"])
			draw_rect(Rect2(pos, Vector2(64, 64)), Color.YELLOW, false, 3.0)

func occupied_tiles() -> Array:
	var tiles = BASE_POSITIONS.values() + Obstacles.TILES
	for unit in units:
		tiles.append(unit["position"])
	return tiles

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
		var unit = UnitData.get_stats(selected_deploy_type)
		var cost = unit["cost"]

		# try to purchase
		if !player_economy.spend_coins(current_player, cost):
			print("Cant purchase unit, not enough coin")
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
				
		if units[selected_unit_index]["acted"]:
			print("This unit already attacked this turn")
			return

		var other_player = 1 if current_player == 2 else 2
		
		if tile == BASE_POSITIONS[other_player]:
			var i = selected_unit_index
			if AttackRange.can_attack(units[i]["position"], tile, UnitData.get_stats(units[i]["type"])["range"]):
				var enemy_base = blue_base if other_player == 1 else red_base
				units[i]["acted"] = true
				enemy_base.take_damage(UnitData.get_stats(units[i]["type"])["atk"])
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

		var moving_index = selected_unit_index
		var mover = units[moving_index]
		if mover["moved"]:
			print("This unit already moved this turn")
			return

		var path = MovementRange.find_path(
			mover["position"],
			tile,
			occupied_tiles(),
			MovementRange.get_movement_range(mover["type"])
		)
		if path.is_empty():
			print("Cant move to this tile")
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
			unit["hp"] -= BaseAttack.get_base_attack_damage(BASE_POSITIONS[enemy], unit["position"], true)
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

	if winner == 0:
		winner_label.text = "Draw!"
	else:
		winner_label.text = "Player %d wins!" % winner
	winner_label.visible = true

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
		bar.position = GridUtils.cell_to_pixel(BASE_POSITIONS[player]) + Vector2(8, -30)
		if bar.current_hp != base.base_hp:
			bar.set_hp(base.base_hp, base.MAX_BASE_HP)

func end_turn() -> void:
	TurnManager.advance_phase()
