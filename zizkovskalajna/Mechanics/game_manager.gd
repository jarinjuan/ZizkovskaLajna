extends Node

var max_unlocked_level
var ammo: int
var original_ammo_count
var last_level_time: float = 0.0
var last_level_played
var last_scene
var current_level

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func _ready():
	Save_Load.load_data()
	max_unlocked_level = Save_Load.data["max_unlocked_level"]
	print(Save_Load.data["max_unlocked_level"])
	return
	
func set_max_unlocked_level():
	print(max_unlocked_level)
	max_unlocked_level = max_unlocked_level + 1
	print(max_unlocked_level)
	
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
	Save_Load.save_data()
	get_tree().quit()
