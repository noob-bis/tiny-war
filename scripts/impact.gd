extends Node2D

const FLASH_TIME = 0.2

@onready var smoke: AnimatedSprite2D = $Smoke
@onready var fire: AnimatedSprite2D = $Fire
@onready var big_flame: AnimatedSprite2D = $BigFlame

func _ready() -> void:
	set_base_state("healthy")
	
func flash(target: CanvasItem) -> void:
	target.modulate = Color.RED
	var tween = target.create_tween()
	tween.tween_property(target, "modulate", Color.WHITE, FLASH_TIME)
	
func set_base_state(state: String) -> void:
	smoke.visible = state == "smoke"
	fire.visible = state == "fire" or state == "destroyed"
	big_flame.visible = state == "destroyed"
	for effect in [smoke, fire, big_flame]:
		if effect.visible:
			effect.play()
		else:
			effect.stop()
