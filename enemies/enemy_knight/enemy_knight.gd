extends CharacterBody2D


const GRAVITY = 1000
const SPEED = 1500

enum State {sleep, wakeup, walk}
@export var current_state: State
@export var direction : Vector2 = Vector2.LEFT
#TODO
#@export var hp : int = TBD

# reference to collision shapes
@onready var sleep_collision = $SleepCollision
@onready var awake_collision = $AwakeCollision
@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea # Area2D for detecting when the player is near


func _ready():
	current_state = State.sleep
	update_collision_shape()
	
	#TODO detection signal

func _physics_process(delta: float) -> void:
	enemy_gravity(delta)

	match current_state:
		State.sleep:
			enemy_sleep(delta)
		State.wakeup:
			enemy_wakeup()
		State.walk:
			enemy_walk(delta)
	
	move_and_slide() 

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta
	
func enemy_sleep(delta: float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	if sprite.animation != "sleep":
		sprite.play("sleep") #ensures its in the sleep animation
	
func enemy_wakeup():
	if current_state != State.wakeup:
		current_state = State.wakeup
		sprite.play("wakeup") #switches into and plays wakeup animation
	
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

func enemy_walk(delta: float):
	velocity.x = direction.x * SPEED * delta
	if sprite.animation != "walk":
		sprite.play("walk")
	
# changes hit/collision box/shape based on the current state
func update_collision_shape():
	if current_state == State.sleep:
		sleep_collision.disabled = false
		sleep_collision.visible = true
		awake_collision.disabled = true
		awake_collision.visible = false
	elif current_state == State.wakeup or current_state == State.walk:
		sleep_collision.disabled = true
		sleep_collision.visible= false
		awake_collision.disabled = false
		awake_collision.visible = true
		
func _on_animation_finished():
	if sprite.animation == "wakeup":
		current_state=State.walk
		update_collision_shape()

#TODO triggers the enemy to change state to wakeup when the player's collision is in the detection area
#func _on_detection():
	#if player and current_state == State.sleep:
		#enemy_wakeup()
		
#TODO attacking functions
