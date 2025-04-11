extends base_enemy

enum State {sleep, wakeup, walk, dead, attack}
var current_state: State = State.sleep

# reference to collision shapes
@onready var detection_area: Area2D = $DetectionArea
@onready var sleep_collision = $SleepCollision
@onready var awake_collision = $AwakeCollision
@onready var attack_hitbox: Area2D = $AttackHitBox
@onready var attack_trigger: Area2D = $AttackTriggerArea
var attack_cooldown := 2.0
var can_attack := true
var has_hit_player := false

func _ready():
	add_to_group("enemies") # HUD
	
	super()
	change_state(State.sleep)

	if detection_area and not detection_area.body_entered.is_connected(_on_detection):
		detection_area.body_entered.connect(_on_detection)

	# signal for when animations are finished
	if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)
			
	if not attack_trigger.body_entered.is_connected(_on_attack_triggered_entered):
		attack_trigger.body_entered.connect(_on_attack_triggered_entered)
		
	if not attack_hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered):
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
		
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
		
	match current_state:
		State.sleep:
			enemy_sleep(delta)
		State.wakeup:
			pass
		State.walk:
			move_towards_player()
		State.attack:
			enemy_attack(delta)
	
	move_and_slide() 

# state manager
func change_state(new_state: State):
	if current_state == new_state:
		return  # prevent unnecessary transitions

	#DEBUG 0 = sleep, 1 = wakeup, 2 = walk, 3 = dead
	#print("enemy_knight current state: ", current_state, " transitioning to ", new_state)

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
		State.attack:
			sprite.play("attack")
			attack_hitbox.set_deferred("monitoring", true)
			has_hit_player = false
			
### state behaviors ###
func enemy_sleep(delta: float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
func enemy_wakeup():
	if current_state == State.sleep:
		change_state(State.wakeup)
		
func enemy_attack(delta: float):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED * 1.2  # knight charges forward

func on_death():
	EquipItems.money += 25
	if current_state == State.dead:
		return
	print("Enemy knight died")
	change_state(State.dead)
	
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
		
	elif current_state == State.attack:
		attack_hitbox.set_deferred("monitoring", false)
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
		change_state(State.walk)

#triggers the enemy to change state to wakeup when the player's collision is in the detection area
func _on_detection(body):
	if body.is_in_group("player") and current_state == State.sleep:
		player = body # stores the player's reference
		enemy_wakeup()

# attacking functions
func _on_attack_triggered_entered(body):
	if body.is_in_group("player") and can_attack and current_state == State.walk:
		change_state(State.attack)

		
func _on_attack_hitbox_body_entered(body):
	print("hitbox collided with: ", body.name)
	if has_hit_player:
		print("already hit player with attack")
		return

	if body.is_in_group("player") and not has_hit_player:
		print("player is in attack hitbox")
		if body.has_method("take_damage"):
			body.take_damage(10)
			print("player took 10 damage")
			has_hit_player = true

func grappled_to_position(pos):
	if current_state == State.dead: return
	change_state(State.sleep)
	var direction = global_position.direction_to(pos)
	velocity = direction * 500
	await get_tree().create_timer(0.5).timeout
	if current_state != State.dead: change_state(State.walk)
