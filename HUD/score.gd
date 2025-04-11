extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var score_label = $ScoreLabel

var latest_score: int

func _ready() -> void:
	if player:
		latest_score = EquipItems.money
		score_label.text = "Earned: $" + str(latest_score)
	else:
		print_debug("Player not found")

func _process(delta: float) -> void:
	if player and EquipItems.money != latest_score:
		latest_score = EquipItems.money
		score_label.text = "Earned: $" + str(latest_score)
