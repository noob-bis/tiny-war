
extends Node2D

@onready var impact = $Impact
@onready var test_square = $TestSquare

# Keyboard controls for testing the impact effects.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F:
				impact.flash(test_square)
				print("Flash tested")
			KEY_1:
				impact.set_base_state("healthy")
				print("Base state: healthy")
			KEY_2:
				impact.set_base_state("smoke")
				print("Base state: smoke")
			KEY_3:
				impact.set_base_state("fire")
				print("Base state: fire")
			KEY_4:
				impact.set_base_state("destroyed")
				print("Base state: destroyed")
