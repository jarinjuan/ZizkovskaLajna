# LevelControl.gd
extends Node

@export var enemies: Array[Node]
@export var porsche_node: Node2D 

var all_enemies_dead: bool = false
var final_level_time: float = 0.0 
var start_time_msec: int = 0


func _ready():
	enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.enemy_died.connect(_on_enemy_died)
		
	start_time_msec = Time.get_ticks_msec()
	if porsche_node:
		porsche_node.level_finished.connect(_on_porsche_level_finished)
	else:
		print("Error: neni porsche brokie")

func _on_enemy_died():
	if enemies.all(func(e): return e.is_dead):
		all_enemies_dead = true
		show_go_to_car_hint()

func show_go_to_car_hint():
	$Label.visible = true


func _on_porsche_level_finished():
	var end_time_msec = Time.get_ticks_msec() 
	final_level_time = float(end_time_msec - start_time_msec) / 1000.0 
	GameManager.set_last_level_time(final_level_time)
	var level_completed_scene = load("res://Scenes/CompleteLvl/levelCompleted.tscn")
	get_tree().change_scene_to_packed(level_completed_scene)
