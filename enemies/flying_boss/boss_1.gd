extends StaticBody2D

enum bossState {
	FLY_IDLE,		# idle flying movement
	FLY_RAMPAGE,	# flying movement for when health is low
	ATTACK_BULLET,	# emitting bullets in a pattern
	ATTACK_BEAM,	# da laser beam
}

@export var fire_rate : float = 0.6
@export var hp : int = 50
@onready var main_node = get_tree().get_root().get_node("Main")
@onready var player_node = main_node.get_node("Player")
@onready var animation = $AnimationPlayer
@onready var state_timer = $StateTimer
@onready var shoot_timer = $ShootTimer

const bullet_prefab = preload("res://enemies/flying_boss/bullet.tscn")

var state = bossState.FLY_IDLE

func _ready() -> void:
	print(main_node)
	# Might not need to set the wait time manually
	shoot_timer.wait_time = fire_rate

func _physics_process(delta: float) -> void:
	match state:
		bossState.FLY_IDLE:
			if !animation.is_playing():
				animation.play("Idle")
				
			# state change
			# TODO: state change when hp is low
			if state_timer.is_stopped():
				# swtich to a random attack state (equal chance)
				#if randf() > 0.5:
					#state = bossState.ATTACK_BULLET
				#else:
					#state = bossState.ATTACK_BEAM
				
				# only switch to bullet attack for now
				state = bossState.ATTACK_BULLET
				state_timer.start()
				# TODO: position snaps back to origin when stopping animation, might replace animplayer with tween
				animation.stop()
			
		bossState.ATTACK_BULLET:
			# start shooting
			if shoot_timer.is_stopped():
				shoot_timer.start()
			
			# state change
			# TODO: state change when hp is low
			if state_timer.is_stopped():
				state = bossState.FLY_IDLE
				state_timer.start()
				shoot_timer.stop()
				
		bossState.ATTACK_BEAM:
			pass # unimplemented
			
		bossState.FLY_RAMPAGE:
			pass # unimplemented
			
	# TODO: take appropriate action when boss dies
	if hp <= 0:
		pass
		
func _on_shoot_timer_timeout() -> void:
	if state == bossState.ATTACK_BULLET:
		shoot_bullet()
		#print("BOSS SHOOTING AT: ", get_player_dir())

# NOTE: this could be moved to a projectileEmitter node, might not need to depending on whether behavior is shared with the other boss
# creates new bullet node and adds it to the root node
func shoot_bullet() -> void:
	var bullet = bullet_prefab.instantiate()
	bullet.position = self.global_position
	bullet.direction = get_player_dir()
	# i'm manually connecting the bullet signal to the player here, this feels really janky but idk what else to do
	bullet.connect("hit_bullet", player_node._on_bullet_hit)
	main_node.add_child(bullet)
	
# returns the normalized direction vector from the boss to the player
func get_player_dir() -> Vector2:
	return self.global_position.direction_to(player_node.global_position).normalized()
