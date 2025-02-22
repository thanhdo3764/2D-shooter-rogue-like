extends SubViewportContainer

@onready var minimap_viewport = $MinimapViewport
@onready var player_icon = $MinimapViewport/MinimapWorld/PlayerIcon
@onready var player = null  # Reference to player

@export var world_size: Vector2 = Vector2(640, 360)  # Game world size
@export var minimap_size: Vector2 = Vector2(160, 90)  # Minimap size

func _ready():
	print("✅ Minimap Loaded!")

func _process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player:
			print("🎮 Player detected:", player.name)

	if player:
		# Adjust offsets based on where the player starts in the world
		var world_origin = Vector2(0, 0)

		# Convert player world position to minimap coordinates
		var minimap_pos = Vector2(
			((player.position.x - world_origin.x) / (world_size.x - world_origin.x)) * minimap_size.x,
			((player.position.y - world_origin.y) / (world_size.y - world_origin.y)) * minimap_size.y
		)

		# Clamp position so the icon never leaves the minimap
		minimap_pos.x = clamp(minimap_pos.x, 0, minimap_size.x)
		minimap_pos.y = clamp(minimap_pos.y, 0, minimap_size.y)

		# Apply corrected position to player icon
		player_icon.position = minimap_pos

		# Debugging output
		print("Player World Position:", player.position)
		print("Minimap Icon Position (Corrected):", player_icon.position)
