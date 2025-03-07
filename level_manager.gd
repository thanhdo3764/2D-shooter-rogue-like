extends Node

@onready var scene_tree = get_tree()
const level_scene = preload("res://scenes/level.tscn")

var current_level: int = 0

# NOTE: how many levels until a boss stage. Checkpoint will follow after the boss is defeated
var boss_interval: int = 4

func _ready() -> void:
	pass # Replace with function body.

func next_room() -> void:
	current_level += 1
	if current_level % boss_interval == 0:
		pass
	change_scene(level_scene)

func change_scene(scene: PackedScene) -> void:
	scene_tree.call_deferred("change_scene_to_packed", scene)
