# bgm_player.gd
extends Node

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
var playbackPosition = 0

func _ready():
	# If Autoplay is checked in editor, this is redundant but harmless
	if not background_music.playing:
		background_music.play()

func stop_music():
	background_music.stop()

func play_music():
	if not background_music.playing:
		background_music.play()
		
func mute_music(toggled_on: bool) -> void:
	if toggled_on:
		playbackPosition = background_music.get_playback_position()
		background_music.stop()			
	else:
		background_music.play(playbackPosition)
