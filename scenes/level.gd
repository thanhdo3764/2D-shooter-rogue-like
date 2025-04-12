extends Node2D

enum LevelType {
	ENEMIES_BASIC,
	PLATFORMING,
	BOSS1,
}

@export var level_type: LevelType
@export var entrance_door: Node2D = null
@export var exit_door: Node2D = null
@export var active_enemies: Array[Node2D]

func _ready() -> void:
	# connect exit door signal (entrance door is non-functional and just for looks)
	if exit_door:
		exit_door.connect("door_entered", self._on_exit_door_entered)
	if level_type == LevelType.PLATFORMING:
		exit_door.toggle_door()
		
	# connect enemy kill signals
	for enemy in active_enemies:
		if enemy.has_signal("killed"):
			enemy.connect("killed", self._on_enemy_killed)
	
	print("Level.gd: _ready() called for ", self.name)
	# Use the exact node name as seen in the editor.
	var ground_tilemap = get_node("GroundTilemap")
	if ground_tilemap:
		print("Level.gd: Found tilemap: ", ground_tilemap.name)
		LevelManager.set_current_tilemap(ground_tilemap)
	else:
		push_error("Level.gd: Error – 'GroundTilemap' not found in this level!")

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
