extends StaticBody2D

enum bossState {
	FLY_IDLE,		# idle flying movement
	FLY_RAMPAGE,	# flying movement for when health is low
	ATTACK_SPREAD,	# emitting bullets in a pattern
	ATTACK_BEAM		# da laser beam
}

@onready var player = $"../Player"
var state = bossState.FLY_IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player)

func _physics_process(delta: float) -> void:
	match state:
		bossState.FLY_IDLE:
			pass
		
#func get_player_dir() -> Vector2:
	#return 
