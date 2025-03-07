extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var score_label = $ScoreLabel

var latest_score: int

func _ready() -> void:
	if player:
		latest_score = player.SCORE
		score_label.text = "Score: " + str(latest_score)
	else:
		print_debug("Player not found")

func _process(delta: float) -> void:
	if player and player.SCORE != latest_score:
		latest_score = player.SCORE
		score_label.text = "Score: " + str(latest_score)
