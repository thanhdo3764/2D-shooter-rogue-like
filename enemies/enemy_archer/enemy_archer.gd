extends base_enemy

enum State {idle, walk, aim, hit, attack, dead}
var current_state: State = State.idle

@export var arrow: PackedScene
var attack_cooldown: float = 2.0
@onready var attack_timer: Timer = $AttackTimer
@onready var detection_area: Area2D = $DetectionArea


func _ready():
	super()
	change_state(State.idle)
	
	if detection_area and not detection_area.body_entered.is_connected(_on_detection):
		detection_area.body_entered.connect(_on_detection)
	
	#if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		#attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	match current_state:
		State.idle:
			archer_idle(delta)
		State.walk:
			move_towards_player()

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
		State.hit:
			sprite.play("hit")
		State.attack:
			sprite.play("attack")
		State.dead:
			sprite.play("death")
	
func archer_idle(delta: float):
	pass
	
func _on_attack_timer_timeout():
	if current_state == State.aim:
		change_state(State.attack)

#func archer_shoot(delta: float):
	#shoot_arrow()
	#shoot_timer.start(attack_cooldown)
	#change(State.aim)
	
func shoot_arrow() -> void:
	var arrow = arrow.instantiate()
	arrow.global_position = self.global_position
	arrow.set_target(player.global_position)
	get_tree().current_scene.add_child(arrow)
	arrow.connect("hit_arrow", player._on_bullet_hit())

func on_death():
	if current_state == State.dead:
		return
	print("Enemy archer died")
	change_state(State.dead)

func _on_detection(body):
	if body.is_in_group("player") and current_state == State.idle:
		player = body
		change_state(State.walk)
