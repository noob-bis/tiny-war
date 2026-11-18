
extends Node2D

@onready var coin_sound: AudioStreamPlayer = $AudioStreamPlayer

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_SPACE:
			coin_sound.play()
			print("Coin gain sound played!")
