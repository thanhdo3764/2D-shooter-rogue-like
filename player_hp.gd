extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var health_bar = $HealthBar
@onready var shield_bar = $ShieldBar

var latest_health: int
var latest_shield: int

func _ready() -> void:
	if player:
		latest_health = player.HEALTH
		latest_shield = player.SHIELD
		
		health_bar.value = latest_health
		shield_bar.value = latest_shield

func _process(_delta) -> void:
	if player:
		if player.HEALTH != latest_health:
			health_bar.value = player.HEALTH
			latest_health = player.HEALTH
			
		if player.SHIELD != latest_shield:
			shield_bar.value = player.SHIELD
			latest_shield = player.SHIELD
