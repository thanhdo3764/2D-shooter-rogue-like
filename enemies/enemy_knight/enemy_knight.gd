extends CharacterBody2D


const GRAVITY = 1000
const SPEED = 100

enum State {sleep, wakeup, walk}
var current_state: State = State.sleep
var player: Node2D = null # reference to the player
#TODO @export var hp : int = TBD

# reference to collision shapes
@onready var sleep_collision = $SleepCollision
@onready var awake_collision = $AwakeCollision
@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea # Area2D for detecting when the player is near


func _ready():
	change_state(State.sleep)
	
	# detection signal when player enters the detection area
	if not detection_area.body_entered.is_connected(_on_detection):
		detection_area.body_entered.connect(_on_detection)
	
	# signal for when animations are finished
	if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	match current_state:
		State.sleep:
			enemy_sleep(delta)
		State.wakeup:
			pass
		State.walk:
			enemy_walk(delta)
	
	move_and_slide() 

# state manager
func change_state(new_state: State):
	if current_state == new_state:
		return  # prevent unnecessary transitions

	#DEBUG 0 = sleep, 1 = wakeup, 2 = walk
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
			
### state behaviors ###
func enemy_sleep(delta: float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
func enemy_wakeup():
	if current_state == State.sleep:
		change_state(State.wakeup)

func enemy_walk(delta: float):
	if player: # player's reference is obtained from _on_detection
		var direction = (player.global_position - global_position).normalized()
		var new_velocity_x = direction.x * SPEED
		#check direciton to flip sprite
		if velocity.x > 0:
			sprite.flip_h = false # face right
		elif velocity.x < 0:
			sprite.flip_h = true # face left

	
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
