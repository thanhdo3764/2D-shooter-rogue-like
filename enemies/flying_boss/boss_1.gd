extends StaticBody2D

enum bossState {
	FLY_IDLE,		# idle flying movement
	ATTACK_SPREAD,	# emitting bullets in a pattern
	ATTACK_BEAM,	# da laser beam
	FLY_RAMPAGE,	# flying movement for when health is low
}

@onready var player = $"../Player"
@onready var animation = $AnimationPlayer
@onready var state_timer = $StateTimer

var state = bossState.FLY_IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player)

func _physics_process(delta: float) -> void:
	match state:
		bossState.FLY_IDLE:
			if !animation.is_playing():
				animation.play("Idle")
				
			# state change
			if state_timer.is_stopped():
				# swtich to a random attack state (equal chance)
				if randf() > 0.5:
					state = bossState.ATTACK_SPREAD
				else:
					state = bossState.ATTACK_BEAM
				state_timer.start()
				# TODO: position snaps back to origin when stopping animation, apply animation position?
				animation.stop()
	print(state)
		
#func get_player_dir() -> Vector2:
	#return 
