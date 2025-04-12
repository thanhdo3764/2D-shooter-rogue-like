extends Node2D

var tilemap: TileMap = null

@export var world_size: Vector2 = Vector2(640, 360)   
@export var minimap_size: Vector2 = Vector2(120, 67.5)      
@export var tile_size: int = 32                         
@export var overlay_color: Color = Color(1, 0, 0, 0.5)     

func _ready():
	# Retrieve the tilemap from the global LevelManager.
	if LevelManager.current_tilemap:
		tilemap = LevelManager.current_tilemap
		print("CollisionOverlay.gd: Got tilemap ", tilemap.name, " from LevelManager.")
	else:
		push_warning("CollisionOverlay.gd: No tilemap found in LevelManager!")
	z_index = 100 
	call_deferred("update")  # Force a deferred update so _draw() is called after _ready().

func _draw():
	if tilemap == null:
		print("CollisionOverlay.gd: No TileMap assigned; nothing to draw.")
		return

	# For debugging, print the number of used cells.
	var used_cells = tilemap.get_used_cells(true)
	print("CollisionOverlay.gd: Used cells count: ", used_cells.size())
	
	# Loop through each used cell.
	for cell in used_cells:
		var tile_id = tilemap.get_cell(cell.x, cell.y)
		# Empty cells return -1.
		if tile_id != -1 and tile_is_collidable(tile_id):
			# Convert cell coordinate to a world position.
			var world_pos = cell * tile_size
			# Map world position to minimap coordinates.
			var minimap_pos = Vector2(
				(world_pos.x / world_size.x) * minimap_size.x,
				(world_pos.y / world_size.y) * minimap_size.y
			)
			# Calculate the drawn tile's size in the minimap.
			var minimap_tile_w = (tile_size / world_size.x) * minimap_size.x
			var minimap_tile_h = (tile_size / world_size.y) * minimap_size.y
			# Draw the rectangle for the collidable tile.
			draw_rect(Rect2(minimap_pos, Vector2(minimap_tile_w, minimap_tile_h)), overlay_color, true)

func tile_is_collidable(tile_id) -> bool:
	return tile_id != 0
