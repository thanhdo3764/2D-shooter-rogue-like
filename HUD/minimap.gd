extends SubViewportContainer

@onready var minimap_viewport = $MinimapViewport
@onready var minimap_world = $MinimapViewport/MinimapWorld
@onready var player_icon = $MinimapViewport/MinimapWorld/PlayerIcon
@onready var enemy_icon = $MinimapViewport/MinimapWorld/EnemyIcon
@onready var player = get_tree().get_first_node_in_group("player")

@export var enemy_icon_scene: PackedScene
@export var world_size: Vector2 = Vector2(640, 360)  # Game world size
@export var minimap_size: Vector2 = Vector2(160, 90)  # Minimap size

var latest_position: Vector2
var enemy_icons = {}  # Dictionary to track minimap icons for each enemy

func _ready():
	set_process_input(true)
	if player:
		latest_position = player.position
		update_minimap_position()
	else:
		print_debug("Player not found")

func _process(_delta):
	if player and player.position != latest_position:
		latest_position = player.position
		update_minimap_position()
	
	update_enemy_minimap_positions()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_minimap"):
		visible = not visible

func update_minimap_position():
	if not player:
		print_debug("Player not found")
		return

	var minimap_pos = Vector2(
		(player.position.x / world_size.x) * minimap_size.x,
		(player.position.y / world_size.y) * minimap_size.y
	)

	minimap_pos.clamp(Vector2.ZERO, minimap_size)
	player_icon.position = minimap_pos

func update_enemy_minimap_positions():
	var valid_enemies = get_tree().get_nodes_in_group("enemies")

	# Remove icons for enemies that no longer exist
	for enemy in enemy_icons.keys():
		if not is_instance_valid(enemy) or enemy not in valid_enemies:
			enemy_icons[enemy].queue_free()
			enemy_icons.erase(enemy)

	# Update positions for remaining enemies
	for enemy in valid_enemies:
		if not enemy_icons.has(enemy):
			var icon_instance = enemy_icon_scene.instantiate()
			minimap_world.add_child(icon_instance)
			enemy_icons[enemy] = icon_instance  

		var minimap_icon = enemy_icons[enemy]
		var minimap_pos = Vector2(
			(enemy.position.x / world_size.x) * minimap_size.x,
			(enemy.position.y / world_size.y) * minimap_size.y
		)
		minimap_pos = minimap_pos.clamp(Vector2.ZERO, minimap_size)
		minimap_icon.position = minimap_pos
