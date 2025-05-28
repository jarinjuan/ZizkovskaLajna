extends Resource

class_name Save_Load
const SAVE_FILE = "user://saves//saves.json"
const SECURITY_KEY = "VYSERSIOKO"

func _init():
	load_data()

static var max_unlocked_level = 0

static func save_data(dataInput: Save_Data):
	var file = FileAccess.open_encrypted_with_pass(SAVE_FILE, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		Log.write_log("Couldnt open file for saves", Log.MessageLevel.ERROR)
		return
	
	var data = {
		"player_data":{
			"maxUnlockedLevel": dataInput.max_unlocked_level
		}
	}
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
	return

static func load_data():
	if !FileAccess.file_exists(SAVE_FILE):
		Log.write_log("Youre trying to load when thers no save", Log.MessageLevel.WARNING)
		return
		
	var file = FileAccess.open_encrypted_with_pass(SAVE_FILE,FileAccess.READ,SECURITY_KEY)
	if file == null:
		Log.write_log("Error while opening file" + error_string(FileAccess.get_open_error()), Log.MessageLevel.ERROR)
		return
		
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	
	max_unlocked_level = data.player_data.max_unlocked_level
