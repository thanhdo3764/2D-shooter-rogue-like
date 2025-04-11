extends Node

@onready var scene_tree = get_tree()

# NOTE: how many levels are in a dungeon. The dungeon will end with a boss stage, then reset
const dungeon_length = 4
const LEVEL_PATH = "res://scenes/levels/"

var boss_level = preload(LEVEL_PATH + "boss_level.tscn")
var enemy_levels = [
	preload(LEVEL_PATH + "enemy_level1.tscn"),
	preload(LEVEL_PATH + "enemy_level2.tscn"),
]
var platforming_levels = [
	preload(LEVEL_PATH + "platforming_level1.tscn"),
]

var main_menu_scene = preload("res://scenes/main_menu.tscn")
var game_over_scene = preload("res://scenes/game_over.tscn")
var shop_scene = preload("res://scenes/shop.tscn")

var dungeon_levels = []
var current_level = 0
var transition_active = false
var rng = RandomNumberGenerator.new()

@onready var scene_transition = $FadeTransition

func _ready() -> void:
	generate_dungeon()

func next_room() -> void:
	transition_active = true
	await scene_transition.level_finished() # fade in
	
	change_scene(dungeon_levels[current_level % dungeon_length])
	if current_level != 0 and current_level % dungeon_length == 0:
		generate_dungeon()
	
	await scene_transition.level_begin() # fade out
	current_level += 1
	transition_active = false

func game_over() -> void:
	change_scene(game_over_scene)


func generate_dungeon() -> void:
	print("NEW DUNGEON")
	dungeon_levels = []
	
	# fill level queue with random enemy levels
	for i in range(dungeon_length):
		dungeon_levels.append(enemy_levels.pick_random())
	
	# replace one enemy level with platforming level, and the last one with the boss level
	dungeon_levels[rng.randi_range(0, dungeon_length - 2)] = platforming_levels.pick_random()
	dungeon_levels[dungeon_length - 1] = boss_level

func change_scene(scene: PackedScene) -> void:
	scene_tree.call_deferred("change_scene_to_packed", scene)
