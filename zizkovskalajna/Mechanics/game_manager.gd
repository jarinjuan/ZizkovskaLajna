extends Node

var max_unlocked_level
var ammo: int

func _notification(what):
	if what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	
	Save_Load.data["max_unlocked_level"]

func _ready():
	Save_Load.load_data()
	max_unlocked_level = Save_Load.data["max_unlocked_level"]
	return
