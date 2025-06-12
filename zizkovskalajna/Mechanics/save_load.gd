extends Resource

class_name Save_Load

const SAVE_PATH = "user://saves/"
const SAVE_FILE = SAVE_PATH + "save.json"

#In here you define whats store in save file and its deafult values
#If you want to get or store some data you can acces it with |Save_Load.data["key"]|
#But if you want to get it you have to load it firts or when store it save after with functions
const data_deafult = {
	"max_unlocked_level": 1
}

static var data = {}

static func save_data():
	var dir = DirAccess.open("user://")
	dir.make_dir_recursive(SAVE_PATH)
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		Log.write_log("Couldnt open file for saves", Log.MessageLevel.ERROR)
		return
	
	if data == {}:
		data = data_deafult
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
	return

static func load_data():
	if !FileAccess.file_exists(SAVE_FILE):
		Log.write_log("Youre trying to load when thers no save", Log.MessageLevel.WARNING)
		data = data_deafult
		print(0)
		return
		
	var file = FileAccess.open(SAVE_FILE,FileAccess.READ)
	if file == null:
		data = data_deafult
		Log.write_log("Error while opening file" + error_string(FileAccess.get_open_error()), Log.MessageLevel.ERROR)
		print(1)
		return
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error_code = json.parse(content)
	if error_code != OK:
		Log.write_log("JSON parse error: " + json.get_error_message(), Log.MessageLevel.ERROR)
		data = data_deafult.duplicate(true)
		print(2)
		return
	
	var parsed_data = json.get_data()
	if typeof(parsed_data) != TYPE_DICTIONARY:
		Log.write_log("Parsed data is not a dictionary!", Log.MessageLevel.ERROR)
		data = data_deafult.duplicate(true)
		print(3)
		return

	data = parsed_data
