extends CharacterBody2D

enum BossState {
	FLY_IDLE,		# flying movement
	ATTACK_BULLET,	# emitting bullets in a pattern
	ATTACK_BEAM,	# da laser beam
}
const RAMPAGE_MOVEMENT_SPEED = 2
const RAMPAGE_HEALTH_THRESHOLD = 0.5
const BOSS_MAX_HP = 500

@onready var health_bar = $EnemyHealthBar

# base fire rate
@export var fire_rate : float = 0.6
@export var move_distance: int = 500

# TODO: can't play multiple animations with one node. So consolidate both animations into an animationtree instead of using 2
@onready var hurt_anim = $HurtAnim
@onready var state_timer = $StateTimer
@onready var shoot_timer = $ShootTimer
@onready var collision_shape = $CollisionShape2D
@onready var main_node = get_tree().get_root().get_node("Main")

const bullet_prefab = preload("res://enemies/flying_boss/bullet.tscn")
const beam_prefab = preload("res://enemies/flying_boss/beam.tscn")
signal killed

var player_node: Node2D
var origin_pos: Vector2 = Vector2.ZERO
var state: BossState = BossState.FLY_IDLE
var hp : int = BOSS_MAX_HP
# likelihood of a bullet arc starts at 10%, increases when in rampage
var arc_chance: float = 0.1
var active_beam : Node2D = null
var rampage_enabled: bool = false
var idle_speed = 300
var idle_direction = Vector2.RIGHT

func _ready() -> void:
	if main_node:
		player_node = main_node.get_node("Player")
	origin_pos = global_position
	shoot_timer.wait_time = fire_rate
	AudioManager.play("flyingboss_idle")
	
	add_to_group("enemies") # HUD
	add_to_group("enemy") # For bullet collision
	health_bar.visible = false

func _physics_process(delta: float) -> void:
	if state == BossState.FLY_IDLE:
		if position.x > origin_pos.x + move_distance/2:
			idle_direction = Vector2.LEFT
		elif position.x < origin_pos.x - move_distance/2:
			idle_direction = Vector2.RIGHT
		position += idle_direction * idle_speed * delta
		
func do_hp_check() -> void:
	if hp <= 0:
		despawn()
	elif hp <= BOSS_MAX_HP * RAMPAGE_HEALTH_THRESHOLD and !rampage_enabled:
		idle_speed *= RAMPAGE_MOVEMENT_SPEED
		shoot_timer.wait_time = fire_rate * 0.5
		AudioManager.set_pitch("flyingboss_idle", 1.5)
		arc_chance = 0.25
		rampage_enabled = true

# takes a state, and return the next state
func do_state_change(current: BossState) -> BossState:
	match current:
		BossState.FLY_IDLE:
			AudioManager.stop("flyingboss_idle")
			if randf() > 0.4:
				shoot_timer.start()
				return BossState.ATTACK_BULLET
			else:
				shoot_beam()
				return BossState.ATTACK_BEAM
				
		BossState.ATTACK_BULLET:
			shoot_timer.stop()
			AudioManager.play("flyingboss_idle")
			return BossState.FLY_IDLE
			
		BossState.ATTACK_BEAM:
			active_beam = null
			AudioManager.play("flyingboss_idle")
			return BossState.FLY_IDLE
	return -1

# shoots an arc of bullets at the player, angle given is the arc angle
func shoot_bullet_arc(dir: Vector2, angle: float, count: int) -> void:
	for i in range(count):
		shoot_bullet(dir.rotated(i * (angle / (count - 1)) - angle/2))

func shoot_bullet(dir: Vector2) -> void:
	var bullet = bullet_prefab.instantiate()
	bullet.position = self.global_position
	bullet.direction = dir
	bullet.connect("hit_bullet", player_node._on_bullet_hit)
	main_node.add_child(bullet)

func shoot_beam() -> void:
	var beam = beam_prefab.instantiate()
	beam.position = self.global_position
	beam.direction = get_player_dir()
	beam.lifetime = state_timer.wait_time
	beam.connect("hit_beam", player_node._on_beam_hit)
	main_node.add_child(beam)
	active_beam = beam
	AudioManager.play("flyingboss_shoot")

# returns the normalized direction vector from the boss to the player
func get_player_dir() -> Vector2:
	return self.global_position.direction_to(player_node.global_position).normalized()

func despawn() -> void:
	EquipItems.money += 500
	emit_signal("killed", self)
	AudioManager.stop("flyingboss_idle")
	AudioManager.set_pitch("flyingboss_idle", 1)
	queue_free()
	
func take_damage(amt: int) -> void:
	if hp < BOSS_MAX_HP:
		health_bar.visible = true
	hurt_anim.play("Hurt")
	health_bar.update_health(hp, BOSS_MAX_HP)
	hp -= amt
	do_hp_check()

func _on_state_timer_timeout() -> void:
	state = do_state_change(state)

func _on_shoot_timer_timeout() -> void:
	if state == BossState.ATTACK_BULLET:
		AudioManager.play("flyingboss_shoot")
		var direction = get_player_dir().rotated(randf_range(-PI/16, PI/16))
		if randf() > arc_chance:
			shoot_bullet(direction)
		else:
			shoot_bullet_arc(direction, PI/2.5, 5)
