extends Node

const SOUNDS = {
	"sword": preload("res://assets/Audio/sword.mp3"),
	"arrow": preload("res://assets/Audio/arrow.mp3"),
	"fireball": preload("res://assets/Audio/fireball.mp3"),
	"footsteps": preload("res://assets/Audio/footsteps.mp3"),
	"base_hit": preload("res://assets/Audio/base_hit.mp3"),
	"click": preload("res://assets/Audio/click.mp3"),
	"deploy": preload("res://assets/Audio/deploy.mp3"),
	"deploy_2": preload("res://assets/Audio/deploy_2.mp3"),
	"coin": preload("res://assets/Audio/coin.mp3"),
	"death_1": preload("res://assets/Audio/death_1.mp3"),
	"death_2": preload("res://assets/Audio/death_2.mp3"),
	"hit_melee": preload("res://assets/Audio/hit_melee.mp3"),
	"hit_ranged": preload("res://assets/Audio/hit_ranged.mp3"),
	"hit_tank": preload("res://assets/Audio/hit_tank.mp3"),
	"endgame": preload("res://assets/Audio/endgame.mp3"),
}
const PLAYER_COUNT = 8 # up to 8 sounds at the same time

var players: Array = []

func _ready() -> void:
	for i in PLAYER_COUNT:
		var player = AudioStreamPlayer.new()
		add_child(player)
		players.append(player)

func play(sound: String, volume_db := 0.0) -> AudioStreamPlayer:
	if not SOUNDS.has(sound):
		return null
	for player in players:
		if not player.playing:
			player.stream = SOUNDS[sound]
			player.volume_db = volume_db
			player.play()
			return player
	return null

func play_first(sounds: Array, volume_db := 0.0) -> AudioStreamPlayer:
	# plays the first sound we have a file for
	for sound in sounds:
		if SOUNDS.has(sound):
			return play(sound, volume_db)
	return null
