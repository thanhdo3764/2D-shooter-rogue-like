extends Control

@export var player: Node
@onready var health_bar = $HealthBar
@onready var shield_bar = $ShieldBar

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	if player:
		setup_bars()
	else:
		print("Player not found! Waiting for level scene...")

func _process(_delta) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player:
			print("Player found! Initializing UI...")
			setup_bars()
	elif player:
		health_bar.value = player.HEALTH
		shield_bar.value = player.SHIELD

func setup_bars() -> void:
	health_bar.player = player
	shield_bar.player = player
	health_bar.value = player.HEALTH
	health_bar.max_value = player.MAX_HEALTH
	shield_bar.value = player.SHIELD
	shield_bar.max_value = player.MAX_SHIELD
