extends AnimatedSprite2D

func _ready() -> void:
	play(animation)
	# start on a random frame so they dont all move together
	frame = randi() % sprite_frames.get_frame_count(animation)
