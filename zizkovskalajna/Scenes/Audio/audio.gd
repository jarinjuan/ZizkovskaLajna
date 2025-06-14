# bgm_player.gd
extends Node

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var lvlc_music: AudioStreamPlayer = $LevelCompletedMusic

func _ready():
	# If Autoplay is checked in editor, this is redundant but harmless
	if not background_music.playing:
		background_music.play()

func bus_toggle_mute(bus: StringName):
	var index_bus = AudioServer.get_bus_index(bus)
	if AudioServer.is_bus_mute(index_bus):
		AudioServer.set_bus_mute(index_bus, false)
	else:
		AudioServer.set_bus_mute(index_bus, true)

func bus_mute(bus: StringName):
	var index_bus = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_mute(index_bus, true)
	
func bus_unmute(bus: StringName):
	var index_bus = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_mute(index_bus, false)

func stop_audio_stream(audio_stream: AudioStreamPlayer):
	audio_stream.stop()
	
func play_audio_stream(audio_stream: AudioStreamPlayer):
	if not audio_stream.playing:
		audio_stream.play()
