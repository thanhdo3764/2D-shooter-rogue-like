extends Control

@export var player: Node
@onready var health_bar = $HealthBar
@onready var shield_bar = $ShieldBar

func _ready() -> void:
	if player == null:
		# Auto-detect the player node
		player = get_tree().get_first_node_in_group("player")
	if player:
		health_bar.player = player
		shield_bar.player = player
		# Initialize progress bars
		health_bar.value = player.health
		health_bar.max_value = player.max_health
		shield_bar.value = player.shield
		shield_bar.max_value = player.max_shield
	else:
		print("Player node not found!")

func _process(_delta) -> void:
	if player:
		health_bar.value = player.health
		shield_bar.value = player.shield
