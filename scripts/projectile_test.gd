extends Node2D

# Load the projectile scene so new projectiles can be created.
const PROJECTILE = preload("res://scenes/projectile.tscn")

# Set the starting position for each projectile.
const START_POSITION = Vector2(100, 100)

# Detect left mouse clicks to fire a projectile.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Create a new projectile instance.
			var projectile = PROJECTILE.instantiate()
			add_child(projectile)

			# Connect the projectile's hit signal to the test function.
			projectile.hit.connect(_on_projectile_hit)

			# Fire toward the mouse cursor position.
			projectile.fire(START_POSITION, get_global_mouse_position())

# Print a message when the projectile reaches its target.
func _on_projectile_hit() -> void:
	print("hit")
