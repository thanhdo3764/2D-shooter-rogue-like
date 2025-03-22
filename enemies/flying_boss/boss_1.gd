extends Area2D

enum BossState {
	FLY_IDLE,		# flying movement
	ATTACK_BULLET,	# emitting bullets in a pattern
	ATTACK_BEAM,	# da laser beam
}
const RAMPAGE_MOVEMENT_SPEED = 2
const RAMPAGE_HEALTH_THRESHOLD = 0.5
const BOSS_MAX_HP = 100

@export var fire_rate : float = 0.6

# TODO: can't play multiple animations with one node. So consolidate both animations into an animationtree instead of using 2
@onready var move_anim = $MoveAnim
@onready var hurt_anim = $HurtAnim
@onready var state_timer = $StateTimer
@onready var shoot_timer = $ShootTimer
@onready var main_node = get_tree().get_root().get_node("Main")
var player_node: Node2D

const bullet_prefab = preload("res://enemies/flying_boss/bullet.tscn")
const beam_prefab = preload("res://enemies/flying_boss/beam.tscn")
signal killed

var state: BossState = BossState.FLY_IDLE
var hp : int = BOSS_MAX_HP
var active_beam : Node2D = null
var rampage_enabled: bool = false

func _ready() -> void:
	if main_node:
		player_node = main_node.get_node("Player")
	shoot_timer.wait_time = fire_rate
	do_idle_movement()
	
	add_to_group("enemies") # HUD

func _physics_process(delta: float) -> void:
	# TODO: Fix animation timing when rampage is enabled during flying
	do_hp_check()
		
func do_hp_check() -> void:
	if hp <= 0:
		despawn()
		player_node.SCORE += 100
	elif hp <= BOSS_MAX_HP * RAMPAGE_HEALTH_THRESHOLD and !rampage_enabled:
		move_anim.speed_scale = RAMPAGE_MOVEMENT_SPEED
		shoot_timer.wait_time = fire_rate * 0.5
		AudioManager.set_pitch("flyingboss_idle", 1.5)
		rampage_enabled = true

# takes a state, and return the next state
func do_state_change(current: BossState) -> BossState:
	match current:
		BossState.FLY_IDLE:
			move_anim.stop()
			AudioManager.stop("flyingboss_idle")
			if randf() > 0.5:
				shoot_timer.start()
				return BossState.ATTACK_BULLET
			else:
				shoot_beam()
				return BossState.ATTACK_BEAM
				
		BossState.ATTACK_BULLET:
			shoot_timer.stop()
			do_idle_movement()
			return BossState.FLY_IDLE
			
		BossState.ATTACK_BEAM:
			active_beam = null
			do_idle_movement()
			return BossState.FLY_IDLE
			
	return -1

func do_idle_movement() -> void:
	move_anim.play("Idle")
	AudioManager.play("flyingboss_idle")

func shoot_bullet() -> void:
	AudioManager.play("flyingboss_shoot")
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
	AudioManager.stop("flyingboss_idle")
	queue_free()
	
func update_hp(new: int) -> void:
	hp = new

func _on_state_timer_timeout() -> void:
	state = do_state_change(state)

func _on_shoot_timer_timeout() -> void:
	if state == BossState.ATTACK_BULLET:
		shoot_bullet()

func _on_area_entered(area: Area2D) -> void:
	# NOTE: assumes the only thing that can collide with the boss is the player bullets, based on collision layers
	# should change to using signals instead
	hp -= 10
	hurt_anim.play("Hurt")
	print("BOSS HP: ", hp)
