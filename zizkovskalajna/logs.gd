extends Node
class_name Log

enum MessageLevel { INFO, ERROR, WARNING }

const ERROR_PATH = "user://logs/error.log"
const WARNING_PATH = "user://logs/warning.log"
const INFO_PATH = "user://logs/info.log"

const MAX_LOG_LINES = 1000

##Writes log to a file based on level
##
##Levels are- WARNING, ERROR, INFO
static func write_log(message: String, level: MessageLevel):
	var file_path
	
	match level:
		MessageLevel.INFO:
			file_path = INFO_PATH
		MessageLevel.ERROR:
			file_path = ERROR_PATH
		MessageLevel.WARNING:
			file_path = WARNING_PATH
	
	var dir := DirAccess.open("user://logs")
	if not dir:
		DirAccess.make_dir_recursive_absolute("user://logs")

	var time = Time.get_datetime_dict_from_system()
	var log_time = "[%02d.%02d.%d %02d:%02d:%02d]" % [time.day, time.month, time.year, time.hour, time.minute, time.second]
	var full_message = "%s %s\n" % [log_time, message]

	var lines: Array = []
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		while not file.eof_reached():
			lines.append(file.get_line())
		file.close()

	lines.append(full_message.strip_edges())

	if lines.size() > MAX_LOG_LINES:
		lines.pop_front()

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	for line in lines:
		file.store_line(line)
	file.close()
