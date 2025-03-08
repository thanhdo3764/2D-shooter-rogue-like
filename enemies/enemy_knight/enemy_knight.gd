extends base_enemy

enum State {sleep, wakeup, walk, dead}
var current_state: State = State.sleep

# reference to collision shapes
@onready var detection_area: Area2D = $DetectionArea
@onready var sleep_collision = $SleepCollision
@onready var awake_collision = $AwakeCollision

func _ready():
	super()
	change_state(State.sleep)

	if detection_area and not detection_area.body_entered.is_connected(_on_detection):
		detection_area.body_entered.connect(_on_detection)

	# signal for when animations are finished
	if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
		
	match current_state:
		State.sleep:
			enemy_sleep(delta)
		State.wakeup:
			pass
		State.walk:
			move_towards_player()
	
	move_and_slide() 

# state manager
func change_state(new_state: State):
	if current_state == new_state:
		return  # prevent unnecessary transitions

	#DEBUG 0 = sleep, 1 = wakeup, 2 = walk, 3 = dead
	print("current state: ", current_state, " transitioning to ", new_state)

	current_state = new_state
	update_collision_shape()

	match new_state:
		State.sleep:
			sprite.play("sleep")
			velocity.x = 0
		State.wakeup:
			sprite.play("wakeup")
		State.walk:
			sprite.play("walk")
		State.dead:
			sprite.play("death")
			
### state behaviors ###
func enemy_sleep(delta: float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
func enemy_wakeup():
	if current_state == State.sleep:
		change_state(State.wakeup)
		
func take_damage(damage: int):
	if current_state == State.dead:
		return
		
	hp -= damage
	print("Enemy took ", damage, " damage. HP:", hp)


	if hp <= 0:
		emit_signal("died")
		die()

func die():
	if current_state == State.dead:
		return
	print("Enemy died!")
	change_state(State.dead)
	sprite.play("death")
	await sprite.animation_finished
	queue_free()
	
# changes hit/collision box/shape based on the current state
func update_collision_shape():
	sleep_collision.visible = current_state == State.sleep
	sleep_collision.disabled = current_state != State.sleep
	awake_collision.visible = current_state != State.sleep
	awake_collision.disabled = current_state == State.sleep
		
func _on_animation_finished():
	#DEBUG
	print("animation finished: ", sprite.get_animation())
	
	if current_state == State.wakeup:
		change_state(State.walk)

#triggers the enemy to change state to wakeup when the player's collision is in the detection area
func _on_detection(body):
	if body.is_in_group("player") and current_state == State.sleep:
		player = body # stores the player's reference
		enemy_wakeup()

#TODO attacking functions
