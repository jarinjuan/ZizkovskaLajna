extends Node

var max_unlocked_level
var ammo: int
var original_ammo_count
var last_level_time: float = 0.0
var last_level_played
var last_scene
var current_level

var master_value
var master_mute
var music_value
var music_mute
var sfx_value
var sfx_mute
var dialog_value
var dialog_mute

var input_map

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func _ready():
	Save_Load.load_data()
	max_unlocked_level = Save_Load.data["max_unlocked_level"]
	master_value = Save_Load.data["master_value"]
	master_mute = Save_Load.data["master_mute"]
	music_value = Save_Load.data["music_value"]
	music_mute = Save_Load.data["music_mute"]
	sfx_value = Save_Load.data["sfx_value"]
	sfx_mute = Save_Load.data["sfx_mute"]
	dialog_value = Save_Load.data["dialog_value"]
	dialog_mute = Save_Load.data["dialog_mute"]
	input_map = Save_Load.data["input_map"]
	apply_keybinds(input_map)
	Audio.audio_setup()
	#print(Save_Load.data["max_unlocked_level"])
	print("ok")
	return
	
func set_max_unlocked_level(current_level: int):
	if max_unlocked_level < current_level + 1:
		max_unlocked_level = current_level + 1
	
func set_last_level_time(time: float):
	last_level_time = time
	
func get_last_level_time() -> float:
	return last_level_time

func set_current_level_path(path: String) -> void:
	current_level = get_current_level_number(path)
	
func get_current_level_number(path: String) -> int:
	var filename = path.get_file().get_basename()
	var parts = filename.split("_")
	if parts.size() > 1:
		return int(parts[1])
	return -1
	
func quit_game():
	Save_Load.data["max_unlocked_level"] = max_unlocked_level
	Save_Load.data["master_value"] = master_value
	Save_Load.data["master_mute"] = master_mute
	Save_Load.data["music_value"] = music_value
	Save_Load.data["music_mute"] = music_mute
	Save_Load.data["sfx_value"] = sfx_value
	Save_Load.data["sfx_mute"] = sfx_mute
	Save_Load.data["dialog_value"] = dialog_value
	Save_Load.data["dialog_mute"] = dialog_mute
	update_input_map_from_inputmap()
	Save_Load.data["input_map"] = input_map
	Save_Load.save_data()
	get_tree().quit()

func update_input_map_from_inputmap():
	input_map = {}
	for action in Save_Load.deafult_map.keys():
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var e = events[0]
			if e is InputEventKey:
				input_map[action] = e.physical_keycode
			elif e is InputEventMouseButton:
				input_map[action] = -e.button_index  # negative = mouse

func apply_keybinds(bindings: Dictionary):
	for action in bindings.keys():
		if not InputMap.has_action(action):
			continue

		# Remove all previous input events
		for ev in InputMap.action_get_events(action):
			InputMap.action_erase_event(action, ev)

		var code = bindings[action]
		var event
		if code < 0:
			event = InputEventMouseButton.new()
			event.button_index = -code
			event.pressed = true
		else:
			event = InputEventKey.new()
			event.physical_keycode = code
			event.pressed = true

		InputMap.action_add_event(action, event)
