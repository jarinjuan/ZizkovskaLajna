# bgm_player.gd
extends Node

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var lvlc_music: AudioStreamPlayer = $LevelCompletedMusic
var playbackPosition = 0

func _ready():
	# If Autoplay is checked in editor, this is redundant but harmless
	if not background_music.playing:
		background_music.play()

func stop_bg_music():
	background_music.stop()

func play_bg_music():
	if not background_music.playing:
		background_music.play()
		
func mute_bg_music(toggled_on: bool) -> void:
	if toggled_on:
		playbackPosition = background_music.get_playback_position()
		background_music.stop()			
	else:
		background_music.play(playbackPosition)
		

func stop_lvlc_music():
	lvlc_music.stop()

func play_lvlc_music():
	if not lvlc_music.playing:
		lvlc_music.play()
