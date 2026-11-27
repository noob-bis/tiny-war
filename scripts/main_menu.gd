extends Control

# these show in the Inspector when you click MainMenu
@export var ribbon_pad = 40.0 # the ribbon is this much wider than the button on each side
@export var ribbon_hover = 24.0 # extra width on each side when the mouse is over it
@export var cloud_drift = Vector2(80, 25) # how far a cloud can float from where it was placed
@export var duck_drift = Vector2(10, 60) # how far the duck floats up and down the river
@export var fade_time = 0.8 # seconds for the title, then the buttons, to fade in
@export var slide = 30.0 # how far they slide while fading in

# the land decoration is in the scene under Decor (Human, Monster, River):
# move, copy or delete it in the editor. Decor sorts by height, so lower things are in front.

@onready var clouds = [$Decoration/ClouldLeft, $Decoration/ClouldRight]
@onready var buttons = [$VBoxContainer/StartButton, $VBoxContainer/ExitButton]
@onready var decor = $Decor
@onready var duck = $Decor/River/Duck
@onready var title = $TitleArea
@onready var button_box = $VBoxContainer


func _ready() -> void:
	for sprite in decor.find_children("*", "AnimatedSprite2D"):
		sprite.frame = randi() % sprite.sprite_frames.get_frame_count(sprite.animation) # so they don't all move together
	wander(duck, duck.position, duck_drift)
	for cloud in clouds:
		wander(cloud, cloud.position, cloud_drift) # no await: each cloud moves on its own
	for button in buttons:
		button.mouse_entered.connect(stretch.bind(button, ribbon_hover))
		button.mouse_exited.connect(stretch.bind(button, 0.0))
	intro()


# When the player clicks Start Game
func _on_start_button_pressed() -> void:
	Sfx.play("click")
	# Open the battle scene
	get_tree().change_scene_to_file("res://scenes/battle_map.tscn")


# When the player clicks Exit
func _on_exit_button_pressed() -> void:
	Sfx.play("click")
	# Close the game
	get_tree().quit()


func wander(thing: CanvasItem, home: Vector2, drift: Vector2) -> void:
	# float to a random spot near home, then pick a new one, forever
	# (the tween belongs to the menu, so it stops when the menu is closed)
	while is_inside_tree():
		var target = home + Vector2(randf_range(-drift.x, drift.x), randf_range(-drift.y, drift.y))
		var tween = create_tween()
		tween.tween_property(thing, "position", target, randf_range(3.0, 5.0)).set_trans(Tween.TRANS_SINE)
		await tween.finished


func stretch(button: Button, extra: float) -> void:
	# the ribbon grows the same on both sides, so the text stays in the middle
	var ribbon = button.get_node("Ribbon")
	var tween = create_tween().set_parallel()
	tween.tween_property(ribbon, "offset_left", -ribbon_pad - extra, 0.12)
	tween.tween_property(ribbon, "offset_right", ribbon_pad + extra, 0.12)


func intro() -> void:
	# the swords and title come down and fade in, then the buttons come up
	title.modulate.a = 0.0
	button_box.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(0.3)
	tween.tween_property(title, "modulate:a", 1.0, fade_time)
	tween.parallel().tween_property(title, "position:y", title.position.y, fade_time).from(title.position.y - slide).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button_box, "modulate:a", 1.0, fade_time * 0.75)
	tween.parallel().tween_property(button_box, "position:y", button_box.position.y, fade_time * 0.75).from(button_box.position.y + slide).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
