extends Node

@export var intact_texture: Texture2D
@export var broken_texture: Texture2D
@export var glass_break_sound: AudioStream

var is_broken = false

func _ready():
	$Sprite2D.texture = intact_texture

func break_glass():
	if is_broken: return
	is_broken = true

	# Změna textury
	$Sprite2D.texture = broken_texture

	# Zrušení kolize
	$CollisionShape2D.set_deferred("disabled", true)

	# Zvuk skla (volitelný, ale stylový jak kráva)
	if glass_break_sound:
		var sfx = AudioStreamPlayer.new()
		sfx.stream = glass_break_sound
		add_child(sfx)
		sfx.play()
