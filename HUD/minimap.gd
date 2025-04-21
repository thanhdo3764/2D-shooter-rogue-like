extends SubViewportContainer

enum MinimapMode { FULL, NO_ENEMIES, ICONLESS, OFF }
var mode : MinimapMode = MinimapMode.FULL

@onready var minimap_background := $MinimapBackground
@onready var minimap_viewport   = $MinimapViewport
@onready var minimap_world      = $MinimapViewport/MinimapWorld
@onready var player_icon        = $MinimapViewport/MinimapWorld/PlayerIcon
@onready var dummy_enemy_icon   = $MinimapViewport/MinimapWorld/EnemyIcon
@onready var player             = get_tree().get_first_node_in_group("player")

@export var enemy_icon_scene    : PackedScene
@export var world_size          : Vector2 = Vector2(640, 360)
@export var minimap_size        : Vector2 = Vector2(120, 67.5)

@export var player_icon_scale   : Vector2 = Vector2(0.4, 0.4)
@export var enemy_icon_scale    : Vector2 = Vector2(0.4, 0.4)

var latest_position : Vector2
var enemy_icons     : Dictionary = {}

func _ready() -> void:
	set_process_input(true)                       
	if player:
		latest_position = player.position
		update_minimap_position()
	_apply_mode() 
	update_minimap_texture()                                

func _process(_delta: float) -> void:
	if mode == MinimapMode.OFF:
		return                                    

	if player and player.position != latest_position:
		latest_position = player.position
		update_minimap_position()

	if mode in [MinimapMode.FULL, MinimapMode.NO_ENEMIES]:
		update_enemy_minimap_positions()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_minimap"):
		mode = (mode + 1) % 4         
		_apply_mode()

func update_minimap_texture():
	var lvl = get_tree().current_scene
	if not lvl:
		minimap_background.texture = null
		return

	var tex : Texture2D = lvl.get("minimap_image")
	minimap_background.texture = tex

# ——————————————————————————————————————————————
#  Mode application
# ——————————————————————————————————————————————
func _apply_mode() -> void:
	match mode:
		MinimapMode.FULL:
			_show_minimap(true)
			player_icon.visible = true
			_set_enemy_icons(true)

		MinimapMode.NO_ENEMIES:
			_show_minimap(true)
			player_icon.visible = true
			_set_enemy_icons(false)

		MinimapMode.ICONLESS:
			_show_minimap(true)
			player_icon.visible = false
			_set_enemy_icons(false)

		MinimapMode.OFF:
			_show_minimap(false)

func _show_minimap(visible: bool) -> void:
	self.visible = visible
	minimap_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if visible else SubViewport.UPDATE_DISABLED

func _set_enemy_icons(show: bool) -> void:
	for icon in enemy_icons.values():
		icon.visible = show

# ——————————————————————————————————————————————
#  Position updates
# ——————————————————————————————————————————————
func update_minimap_position() -> void:
	if not player:
		print_debug("Player not found")
		return

	var minimap_pos = Vector2(
		(player.position.x / world_size.x) * minimap_size.x,
		(player.position.y / world_size.y) * minimap_size.y
	).clamp(Vector2.ZERO, minimap_size)

	player_icon.position = minimap_pos
	player_icon.scale    = player_icon_scale

func update_enemy_minimap_positions() -> void:
	var valid_enemies = get_tree().get_nodes_in_group("enemies")

	# Remove stale icons
	for enemy in enemy_icons.keys():
		if not is_instance_valid(enemy) or enemy not in valid_enemies:
			enemy_icons[enemy].queue_free()
			enemy_icons.erase(enemy)

	# Add/update
	for enemy in valid_enemies:
		if not enemy_icons.has(enemy):
			var icon_instance = enemy_icon_scene.instantiate()
			minimap_world.add_child(icon_instance)
			icon_instance.scale = enemy_icon_scale
			enemy_icons[enemy] = icon_instance

		var icon = enemy_icons[enemy]
		var pos = Vector2(
			(enemy.position.x / world_size.x) * minimap_size.x,
			(enemy.position.y / world_size.y) * minimap_size.y
		).clamp(Vector2.ZERO, minimap_size)

		icon.position = pos
		icon.scale    = enemy_icon_scale
