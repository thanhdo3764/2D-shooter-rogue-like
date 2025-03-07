extends SubViewportContainer

@onready var minimap_viewport = $MinimapViewport
@onready var player_icon = $MinimapViewport/MinimapWorld/PlayerIcon
@onready var player = get_tree().get_first_node_in_group("player")

@export var world_size: Vector2 = Vector2(640, 360)  # Game world size
@export var minimap_size: Vector2 = Vector2(160, 90)  # Minimap size

var latest_position: Vector2

func _ready():
	if player:
		latest_position = player.position
		update_minimap_position()
	else:
		print_debug("Player not found")

func _process(_delta):
	if player and player.position != latest_position:
		latest_position = player.position
		update_minimap_position()

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
