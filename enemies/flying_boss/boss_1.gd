extends Area2D

enum bossState {
	FLY_IDLE,		# idle flying movement
	FLY_RAMPAGE,	# flying movement for when health is low
	ATTACK_BULLET,	# emitting bullets in a pattern
	ATTACK_BEAM,	# da laser beam
}

@export var fire_rate : float = 0.6
@export var hp : int = 100
@onready var main_node = get_tree().get_root().get_node("Main")
@onready var player_node = main_node.get_node("Player")

# TODO: can't play multiple animations with one node. So consolidate both animations into an animationtree instead of using 2
@onready var move_anim = $MoveAnim
@onready var hurt_anim = $HurtAnim

@onready var state_timer = $StateTimer
@onready var shoot_timer = $ShootTimer

const bullet_prefab = preload("res://enemies/flying_boss/bullet.tscn")
const beam_prefab = preload("res://enemies/flying_boss/beam.tscn")
signal killed

var state = bossState.FLY_IDLE
var active_beam : Node2D = null

func _ready() -> void:
	print(main_node)
	# Might not need to set the wait time manually
	shoot_timer.wait_time = fire_rate

func _physics_process(delta: float) -> void:
	match state:
		bossState.FLY_IDLE:
			if !move_anim.is_playing():
				move_anim.play("Idle")
				
			# state change
			# TODO: state change when hp is low
			if state_timer.is_stopped():
				# swtich to a random attack state (equal chance)
				if randf() > 0.5:
					state = bossState.ATTACK_BULLET
				else:
					state = bossState.ATTACK_BEAM
				state_timer.start()
				move_anim.stop()
			
		bossState.ATTACK_BULLET:
			# start shooting
			if shoot_timer.is_stopped():
				shoot_timer.start()
				
			# state change
			if state_timer.is_stopped():
				state = bossState.FLY_IDLE
				state_timer.start()
				shoot_timer.stop()
				
		bossState.ATTACK_BEAM:
			# don't create a new beam if there's already one
			if active_beam == null:
				shoot_beam()
				
			# state change
			if state_timer.is_stopped():
				active_beam = null
				state = bossState.FLY_IDLE
				state_timer.start()
			
		bossState.FLY_RAMPAGE:
			pass # unimplemented
			
	if hp <= 0:
		despawn()
		
func _on_shoot_timer_timeout() -> void:
	if state == bossState.ATTACK_BULLET:
		shoot_bullet()

func _on_area_entered(area: Area2D) -> void:
	# NOTE: assumes the only thing that can collide with the boss is the player bullets, based on collision layers
	# should change to using signals instead
	hp -= 10
	hurt_anim.play("Hurt")
	print("BOSS HP: ", hp)
		
func shoot_bullet() -> void:
	var bullet = bullet_prefab.instantiate()
	bullet.position = self.global_position
	bullet.direction = get_player_dir()
	# i'm manually connecting the bullet signal to the player here, this feels really janky but idk what else to do
	bullet.connect("hit_bullet", player_node._on_bullet_hit)
	main_node.add_child(bullet)

func shoot_beam() -> void:
	var beam = beam_prefab.instantiate()
	beam.position = self.global_position
	beam.direction = get_player_dir()
	main_node.add_child(beam)
	active_beam = beam

# returns the normalized direction vector from the boss to the player
func get_player_dir() -> Vector2:
	return self.global_position.direction_to(player_node.global_position).normalized()

func despawn() -> void:
	emit_signal("killed", self)
	queue_free()
