# LevelControl.gd
extends Node

@export var enemies: Array[Node]
@export var porsche_node: Node2D 

var all_enemies_dead: bool = false
var final_level_time: float = 0.0 
var current_level_time: float = 0.0

var pause_menu_scene: PackedScene = preload("res://Scenes/PauseScreen/pause.tscn")
var pause_menu_instance: CanvasLayer = null # To hold the instantiated pause menu

func _ready():
	current_level_time = 0.0
	enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.enemy_died.connect(_on_enemy_died)
		
	if porsche_node:
		porsche_node.level_finished.connect(_on_porsche_level_finished)
	else:
		print("Error: neni porsche brokie")
	set_process_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float):
	# Akumulujeme čas POUZE, pokud hra NENÍ pauznutá
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
	get_tree().paused = true # Pause the game physics and _process functions
	
	if pause_menu_instance == null:		
		pause_menu_instance = pause_menu_scene.instantiate()
		get_tree().get_root().add_child(pause_menu_instance)		
		# Connect signals from the pause menu instance
		pause_menu_instance.resume_game.connect(_unpause_game)
		pause_menu_instance.restart_game.connect(_restart_game)
		pause_menu_instance.quit_game.connect(_quit_game)
		$Label.visible = false

	else:
		pause_menu_instance.visible = true # 
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	

func _unpause_game():
	get_tree().paused = false 
	if pause_menu_instance != null:
		pause_menu_instance.queue_free() 
		pause_menu_instance = null
		_on_enemy_died() 



func _restart_game():
	_unpause_game() 
	get_tree().reload_current_scene()

func _quit_game():
	_unpause_game() 
	get_tree().change_scene_to_file("res://Scenes/Main/control.tscn")
