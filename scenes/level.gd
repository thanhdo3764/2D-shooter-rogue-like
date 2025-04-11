extends Node2D

enum LevelType {
	ENEMIES, BOSS1, BOSS2,
}

@export var level_type: LevelType
@export var entrance_door: Node2D = null
@export var exit_door: Node2D = null
@export var active_enemies: Array[Node2D]

func _ready() -> void:
	# connect exit door signal (entrance door is non-functional and just for looks)
	if exit_door:
		exit_door.connect("door_entered", self._on_exit_door_entered)
	# connect enemy kill signals
	for enemy in active_enemies:
		if enemy.has_signal("killed"):
			enemy.connect("killed", self._on_enemy_killed)

func _on_exit_door_entered():
	LevelManager.next_room()

func _on_enemy_killed(enemy: Node2D):
	# TODO: refactor
	for i in range(len(active_enemies)):
		if active_enemies[i].name == enemy.name:
			active_enemies.remove_at(i)
			break
	if len(active_enemies) == 0 and exit_door.has_method("toggle_door"):
		exit_door.toggle_door()
