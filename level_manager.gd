extends Node

@onready var scene_tree = get_tree()

const LEVEL_PATH = "res://scenes/levels/"

var boss_level = preload(LEVEL_PATH + "boss_level.tscn")
var enemy_levels = [
	preload(LEVEL_PATH + "enemy_level1.tscn"),
]
 
# NOTE: how many levels until a boss stage. Checkpoint will follow after the boss is defeated
var boss_interval = 3
var current_level = 0

@onready var scene_transition = $FadeTransition

func next_room() -> void:
	current_level += 1
	
	await scene_transition.level_finished()
	if current_level % boss_interval == 0:
		change_scene(boss_level)
	else:
		change_scene(enemy_levels.pick_random())
	await scene_transition.level_begin()
		
func change_scene(scene: PackedScene) -> void:
	scene_tree.call_deferred("change_scene_to_packed", scene)
