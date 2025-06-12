extends CanvasLayer

@onready var time_display_label: Label = $LabelTime
var max_unlocked = GameManager.max_unlocked_level

func _ready():
		var elapsed_time = GameManager.get_last_level_time()
		GameManager.max_unlocked_level = max_unlocked + 1
		display_formatted_time(elapsed_time)





func display_formatted_time(time_in_seconds: float):
	var minutes = int(time_in_seconds / 60)
	var seconds = fmod(time_in_seconds, 60)
	var milliseconds = int(fmod(time_in_seconds * 1000, 1000))
	time_display_label.text = "Time: %02d:%02d.%03d" % [minutes, seconds, milliseconds]
