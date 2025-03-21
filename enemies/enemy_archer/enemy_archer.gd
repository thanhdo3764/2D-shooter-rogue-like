extends base_enemy

enum State {idle, aim, hit, attack, dead}
var current_state: State = State.idle

@export var arrow: PackedScene
var attack_cooldown: float = 2.0
var detection_range: float = 500
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	super()
	change_state(State.idle)
	
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)

func change_state(new_state:State):
	if current_state == new_state:
		return
		
	current_state = new_state
	match new_state:
		State.idle:
			sprite.play("idle")
		State.hit:
			sprite.play("hit")
		State.attack:
			sprite.play("attack")
		State.dead:
			sprite.play("death")
	
func archer_idle(delta: float):
	if player and global_position.distance_to(player.global_position) < detection_range:
		change_state(State.aim)
	
func _on_attack_timer_timeout():
	if current_state == State.aim:
		change_state(State.attack)

func archer_shoot(delta: float):
	shoot_arrow()
	shoot_timer.start(attack_cooldown)
	change(State.aim)
	
func shoot_arrow():
	if arrow_scene and player:
		

func _on_detection(body):
	if body.is_in_group("player") and current_state == State.idle:
		player = body
		change_state(State.aim)
