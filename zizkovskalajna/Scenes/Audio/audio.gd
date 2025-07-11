
extends Node

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var lvlc_music: AudioStreamPlayer = $LevelCompletedMusic

func _ready():
	# If Autoplay is checked in editor, this is redundant but harmless
	if not background_music.playing:
		background_music.play()

func change_bus_value(bus: StringName, value:float):
	var index_bus = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_linear(index_bus, value)

func bus_toggle_mute(bus: StringName):
	var index_bus = AudioServer.get_bus_index(bus)
	if AudioServer.is_bus_mute(index_bus):
		AudioServer.set_bus_mute(index_bus, false)
	else:
		AudioServer.set_bus_mute(index_bus, true)

func bus_toggle_bool_mute(bus: StringName, toggled:bool):
	var index_bus = AudioServer.get_bus_index(bus)
	if toggled:
		AudioServer.set_bus_mute(index_bus, true)
	else:
		AudioServer.set_bus_mute(index_bus, false)
	
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

func audio_setup():
	change_bus_value("Master", GameManager.master_value)
	change_bus_value("Music", GameManager.music_value)
	change_bus_value("SFX", GameManager.sfx_value)
	change_bus_value("Dialog", GameManager.dialog_value)
	bus_toggle_bool_mute("Master", GameManager.master_mute)
	bus_toggle_bool_mute("Music", GameManager.music_mute)
	bus_toggle_bool_mute("SFX", GameManager.sfx_mute)
	bus_toggle_bool_mute("Dialog", GameManager.dialog_mute)
