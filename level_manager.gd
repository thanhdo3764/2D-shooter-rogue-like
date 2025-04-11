extends Node

@onready var scene_tree = get_tree()

const LEVEL_PATH = "res://scenes/levels/"

var boss_level = preload(LEVEL_PATH + "boss_level.tscn")
var enemy_levels = [
	preload(LEVEL_PATH + "enemy_level1.tscn"),
]
 
var current_level: int = 1
# NOTE: how many levels until a boss stage. Checkpoint will follow after the boss is defeated
var boss_interval: int = 3

func _ready() -> void:
	pass # Replace with function body.

func next_room() -> void:
	current_level += 1
	if current_level % boss_interval == 0:
		change_scene(boss_level)
	else:
		change_scene(enemy_levels.pick_random())

func change_scene(scene: PackedScene) -> void:
	scene_tree.call_deferred("change_scene_to_packed", scene)
