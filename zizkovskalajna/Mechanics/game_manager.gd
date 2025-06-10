extends Node

var max_unlocked_level
var ammo: int
var original_ammo_count
var last_level_time: float = 0.0

func _notification(what):
	if what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	
	Save_Load.data["max_unlocked_level"]

func _ready():
	Save_Load.load_data()
	max_unlocked_level = Save_Load.data["max_unlocked_level"]
	return
	
func set_last_level_time(time: float):
	last_level_time = time
	
func get_last_level_time() -> float:
	return last_level_time
