extends Node2D

# Signal emitted when the projectile reaches its target.
signal hit

# Projectile movement speed in pixels per second.
const SPEED = 600.0

# Hide the projectile when it is first created.
func _ready() -> void:
	hide()

# Fires the projectile from its starting position toward the target.
func fire(from_pos: Vector2, to_pos: Vector2) -> void:
	# Make the projectile visible and set its starting position.
	show()
	global_position = from_pos

	# Start the fireball animation.
	$AnimatedSprite2D.play("fireball")

	# Rotate the projectile to face the target.
	look_at(to_pos)

	# Calculate the distance and time needed to reach the target.
	var distance = from_pos.distance_to(to_pos)
	var travel_time = distance / SPEED

	# Create a tween to move the projectile smoothly.
	var tween = create_tween()
	tween.tween_property(self, "global_position", to_pos, travel_time)

	# Wait until the projectile reaches its destination.
	await tween.finished

	# Notify that the projectile has hit its target.
	hit.emit()

	# Remove the projectile from the scene.
	queue_free()
