extends Node

@onready var scene_tree = get_tree()

# NOTE: how many levels until a boss stage. Checkpoint will follow after the boss is defeated
const boss_interval = 3
const LEVEL_PATH = "res://scenes/levels/"

var boss_level = preload(LEVEL_PATH + "boss_level.tscn")
var enemy_levels = [
	preload(LEVEL_PATH + "enemy_level1.tscn"),
]
var main_menu_scene = preload("res://scenes/main_menu.tscn")
var game_over_scene = preload("res://scenes/game_over.tscn")
var shop_scene = preload("res://scenes/shop.tscn")

var current_level = 0
var transition_active = false

@onready var scene_transition = $FadeTransition

func next_room() -> void:
	transition_active = true
	current_level += 1
	
	await scene_transition.level_finished()
	if current_level % boss_interval == 0:
		change_scene(boss_level)
	else:
		change_scene(enemy_levels.pick_random())
	await scene_transition.level_begin()
	
	transition_active = false

func game_over() -> void:
	change_scene(game_over_scene)

func change_scene(scene: PackedScene) -> void:
	scene_tree.call_deferred("change_scene_to_packed", scene)
