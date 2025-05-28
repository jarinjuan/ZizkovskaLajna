extends Resource

class_name Save_Data

func _init():
	Save_Load.load_data()
	max_unlocked_level = Save_Load.max_unlocked_level

var max_unlocked_level
