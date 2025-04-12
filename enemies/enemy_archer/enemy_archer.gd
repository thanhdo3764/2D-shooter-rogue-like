extends base_enemy

enum State {idle, walk, aim, attack, dead}
var current_state: State = State.idle

@export var arrow: PackedScene
var attack_cooldown: float = 1
var can_attack: bool = true
var player_in_range: bool = false

@onready var attack_timer: Timer = $AttackTimer
@onready var detection_area: Area2D = $DetectionArea


func _ready():
	super()
	change_state(State.idle)
	
	# player enters detection
	if not detection_area.body_entered.is_connected(_on_detection):
		detection_area.body_entered.connect(_on_detection)
	
	# player leaves detection
	if not detection_area.body_exited.is_connected(_on_detection):
		detection_area.body_exited.connect(_on_detection_exit)
	
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)
		
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)
	
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	match current_state:
		State.idle:
			if player_in_range and can_attack:
				change_state(State.aim)
		State.walk:
			move_towards_player()
			if player_in_range and can_attack:
				change_state(State.aim)
		State.aim:
			velocity.x = 0
			if can_attack:
				change_state(State.attack)
		State.attack:
			velocity.x = 0

	move_and_slide() 

func change_state(new_state:State):
	if current_state == new_state:
		return
		
	current_state = new_state
	match new_state:
		State.idle:
			sprite.play("idle")
		State.walk:
			sprite.play("walk")
		State.aim:
			sprite.play("idle")
		State.attack:
			sprite.play("attack")
		State.dead:
			sprite.play("death")

func _on_animation_finished():
	if current_state == State.attack:
		shoot_arrow()
		can_attack = false
		attack_timer.start(attack_cooldown)

		if player_in_range:
			change_state(State.aim)
		else:
			change_state(State.walk)

func _on_attack_timer_timeout():
	can_attack = true
	if player and current_state != State.attack and detection_area.has_overlapping_bodies():
		change_state(State.aim)
	else:
		change_state(State.walk)
	
func shoot_arrow() -> void:
	var arrow = arrow.instantiate()
	arrow.global_position = self.global_position
	arrow.set_target(player.global_position)
	get_tree().current_scene.add_child(arrow)
	
	# uses _on_bullet_hit and in turn it's damage as well
	arrow.connect("hit_arrow", Callable(player, "_on_bullet_hit"))

func _on_detection(body):
	if body.is_in_group("player"):
		player = body
		player_in_range = true
		
		if can_attack:
			change_state(State.aim)
		else:
			change_state(State.walk)

func _on_detection_exit(body):
	if body == player:
		player_in_range = false
		change_state(State.walk)
		
func on_death():
	EquipItems.money += 50
	if current_state == State.dead:
		return
	print("Enemy archer died")
	change_state(State.dead)

func grappled_to_position(pos):
	if current_state == State.dead:
		return
	change_state(State.idle)
	var direction = global_position.direction_to(pos)
	velocity = direction * 500
	await get_tree().create_timer(0.5).timeout
	if current_state != State.dead:
		change_state(State.walk)
