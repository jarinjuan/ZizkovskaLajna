# LevelControl.gd
extends Node

@export var enemies: Array[Node]
@export var porsche_node: Node2D 

var all_enemies_dead: bool = false
var final_level_time: float = 0.0 
var current_level_time: float = 0.0
var max_unlocked = GameManager.max_unlocked_level
var pause_menu_scene: PackedScene = preload("res://Scenes/PauseScreen/pause.tscn")
var pause_menu_instance: CanvasLayer = null # To hold the instantiated pause menu
var active_ammo_ui = false


func _ready():
	Audio.stop_audio_stream(Audio.lvlc_music)
	current_level_time = 0.0
	enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.enemy_died.connect(_on_enemy_died)
		
	var current_scene_path = get_tree().current_scene.scene_file_path
	GameManager.set_current_level_path(current_scene_path)	
	
	if porsche_node:
		porsche_node.level_finished.connect(_on_porsche_level_finished)
	else:
		print("Error: neni porsche brokie")
	set_process_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float):
	if not get_tree().paused:
		current_level_time += delta

func _on_enemy_died():
	if enemies.all(func(e): return e.is_dead):
		all_enemies_dead = true
		show_go_to_car_hint()

func show_go_to_car_hint():
	$Label.visible = true


func _on_porsche_level_finished():
	final_level_time = current_level_time
	GameManager.set_last_level_time(final_level_time)
	GameManager.set_max_unlocked_level(GameManager.current_level)
	GameManager.skip_dialog = false
	Ui.close_ammo()
	var level_completed_scene = load("res://Scenes/CompleteLvl/levelCompleted.tscn")
	get_tree().change_scene_to_packed(level_completed_scene)


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			_unpause_game()
		else:
			_pause_game()

func _pause_game():
	if not Ui.dialog_playing:
		get_tree().paused = true
		if Ui.is_active_ammo() == true:
			Ui.close_ammo()
			active_ammo_ui = true
		if pause_menu_instance == null:		
			pause_menu_instance = pause_menu_scene.instantiate()
			get_tree().get_root().add_child(pause_menu_instance)		
			pause_menu_instance.resume_game.connect(_unpause_game)
			pause_menu_instance.restart_game.connect(_restart_game)
			pause_menu_instance.quit_game.connect(_quit_game)
			$Label.visible = false

		else:
			pause_menu_instance.visible = true # 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	

func _unpause_game():
	if not Ui.dialog_playing: 
		get_tree().paused = false 
		if active_ammo_ui:
			Ui.show_ammo()
			active_ammo_ui = false
		if pause_menu_instance != null:
			pause_menu_instance.queue_free() 
			pause_menu_instance = null
			_on_enemy_died() 



func _restart_game():
	_unpause_game() 
	Ui.close_dialog()
	get_tree().reload_current_scene()

func _quit_game():
	_unpause_game()
	Ui.close_ammo()
	Audio.play_audio_stream(Audio.background_music)
	Ui.close_dialog()
	GameManager.skip_dialog = false
	get_tree().change_scene_to_file("res://Scenes/Main/control.tscn")
