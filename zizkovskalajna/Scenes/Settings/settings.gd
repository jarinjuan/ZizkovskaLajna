extends Control

@onready var input_button_scene = preload("res://Scenes/Settings/input_button.tscn")
@onready var action_list = $TabContainer/Control/ScrollContainer/VBoxContainer

var is_remaping = false
var action_to_remap = null
var remaping_button = null

var input_actions = {
	"move_up": "Move up",
	"move_down": "Move down",
	"move_right": "Move right",
	"move_left": "Move left",
	"mouse_right": "Special action",
	"fire":  "Attack",
	"reset": "Reset"
}

func _ready():
	create_action_list()
	$TabContainer/Volume/VBoxContainer/Master/HSlider.value = GameManager.master_value
	$TabContainer/Volume/VBoxContainer/Music/HSlider.value = GameManager.music_value
	$TabContainer/Volume/VBoxContainer/SFX/HSlider.value = GameManager.sfx_value
	$TabContainer/Volume/VBoxContainer/Dialog/HSlider.value = GameManager.dialog_value
	$TabContainer/Volume/VBoxContainer/Master/CheckBox.button_pressed = GameManager.master_mute
	$TabContainer/Volume/VBoxContainer/Music/CheckBox.button_pressed = GameManager.music_mute
	$TabContainer/Volume/VBoxContainer/SFX/CheckBox.button_pressed = GameManager.sfx_mute
	$TabContainer/Volume/VBoxContainer/Dialog/CheckBox.button_pressed = GameManager.dialog_mute

func volume_master_changed(value: float) -> void:
	$TabContainer/Volume/VBoxContainer/Master/Value.text = str(int($TabContainer/Volume/VBoxContainer/Master/HSlider.value * 100))
	Audio.change_bus_value("Master", $TabContainer/Volume/VBoxContainer/Master/HSlider.value)
	GameManager.master_value = $TabContainer/Volume/VBoxContainer/Master/HSlider.value
	slider_wait()

func volume_music_changed(value: float) -> void:
	$TabContainer/Volume/VBoxContainer/Music/Value.text = str(int($TabContainer/Volume/VBoxContainer/Music/HSlider.value * 100))
	Audio.change_bus_value("Music", $TabContainer/Volume/VBoxContainer/Music/HSlider.value)
	GameManager.music_value = $TabContainer/Volume/VBoxContainer/Music/HSlider.value
	slider_wait()

func volume_sfx_changed(value: float) -> void:
	$TabContainer/Volume/VBoxContainer/SFX/Value.text = str(int($TabContainer/Volume/VBoxContainer/SFX/HSlider.value * 100))
	Audio.change_bus_value("SFX", $TabContainer/Volume/VBoxContainer/SFX/HSlider.value)
	GameManager.sfx_value = $TabContainer/Volume/VBoxContainer/SFX/HSlider.value
	slider_wait()


func volume_dialog_changed(value: float) -> void:
	$TabContainer/Volume/VBoxContainer/Dialog/Value.text = str(int($TabContainer/Volume/VBoxContainer/Dialog/HSlider.value * 100))
	Audio.change_bus_value("Dialog", $TabContainer/Volume/VBoxContainer/Dialog/HSlider.value)
	GameManager.dialog_value = $TabContainer/Volume/VBoxContainer/Dialog/HSlider.value
	slider_wait()


func master_toggle(toggled_on: bool) -> void:
	Audio.bus_toggle_bool_mute("Master", toggled_on)
	GameManager.master_mute = toggled_on

func music_toggle(toggled_on: bool) -> void:
	Audio.bus_toggle_bool_mute("Music", toggled_on)
	GameManager.music_mute = toggled_on

func sfx_toggle(toggled_on: bool) -> void:
	Audio.bus_toggle_bool_mute("SFX", toggled_on)
	GameManager.sfx_mute = toggled_on


func dialog_toggle(toggled_on: bool) -> void:
	Audio.bus_toggle_bool_mute("Dialog", toggled_on)
	GameManager.dialog_mute = toggled_on

func slider_wait():
	await get_tree().create_timer(0.2).timeout


func back() -> void:
	get_tree().change_scene_to_file(GameManager.last_scene)

func create_action_list():
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("action")
		var input_label = button.find_child("key")
		
		action_label.text = input_actions[action]
		
		var event = InputMap.action_get_events(action)
		if event.size() > 0:
			input_label.text = event[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(input_button_pressed.bind(button, action))
	

func input_button_pressed(button, action):
	if not is_remaping:
		is_remaping = true
		action_to_remap = true
		action_to_remap = action
		remaping_button = button
		button.find_child("key").text = "Press key to bind"

func _input(event):
	if is_remaping:
		if(
			event is InputEventKey ||
			(event is InputEventMouseButton && event.pressed)
		):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_action_list(remaping_button, event)
			
			is_remaping = false
			action_to_remap = null
			remaping_button = null
			
			accept_event()

func update_action_list(button, event):
	button.find_child("key").text = event.as_text().trim_suffix(" (Physical)")
