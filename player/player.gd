extends CharacterBody2D
signal hit

@export var HEALTH: int = 100
@export var MAX_HEALTH: int = 100
@export var SHIELD: int = 50
@export var MAX_SHIELD: int = 100

@export var SCORE: int = 0

@export var SPEED: int = 250
@export var ACCELERATION_H: int = 800
@export var GRAVITY: int = 2500
@export var JUMP_POWER: int = -700

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var raycast: RayCast2D = $RayCast2D

var screen_size: Vector2

var WEAPON_LOAD
var weapon

enum PlayerState {
	STANDING,
	FALLING,
	JUMPING,
	RUNNING,
}

var STATE: PlayerState = PlayerState.STANDING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if EquipItems.weapon == 1:
		WEAPON_LOAD = preload("res://weapons/Pistol.tscn")
		
	if EquipItems.weapon == 2:
		WEAPON_LOAD = preload("res://weapons/Sniper.tscn")
	
	weapon = WEAPON_LOAD.instantiate()
	add_child(weapon)
	weapon.position = $Weapon_Spawn.position
	screen_size = get_viewport_rect().size

	add_to_group("player") # for the HUD
	print("Player has $" + str(EquipItems._get_bank()) + " in their Bank.")

	
func _physics_process(delta: float) -> void:
	# handle jumping
	match STATE:
		PlayerState.STANDING:
			handle_standing(delta)
		PlayerState.FALLING:
			handle_falling(delta)
		PlayerState.JUMPING:
			handle_jumping(delta)
		PlayerState.RUNNING:
			handle_running(delta)
	
	# apply gravity
	try_fall_through_platform()
	velocity.y += GRAVITY * delta # Make player fall
	
	# move the player
	var previously_on_floor = is_on_floor()
	move_and_slide() # Make collision with the floor
	
	# if the player has just fell off a platform, start the coyote timer
	if previously_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
	
	position = position.clamp(Vector2.ZERO, screen_size)
	try_walk_animation()


func handle_standing(delta: float) -> void:
	if not is_on_floor():
		STATE = PlayerState.FALLING
		return
	
	var direction = Input.get_axis("move_left", "move_right") * SPEED
	if direction != 0:
		STATE = PlayerState.RUNNING
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_H*delta)
	elif Input.is_action_pressed("jump"):
		STATE = PlayerState.JUMPING
		velocity.y = JUMP_POWER


func handle_air_horizontal_input(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right") * SPEED
	
	if direction == 0:
		direction = velocity.x

	velocity.x = move_toward(velocity.x, direction, ACCELERATION_H * delta)

		
func handle_falling(delta: float) -> void:
	if is_on_floor():
		STATE = PlayerState.STANDING if velocity.x == 0 else PlayerState.RUNNING
	else:
		handle_air_horizontal_input(delta)
	
	if Input.is_action_pressed("jump") and coyote_timer.time_left > 0:
		STATE = PlayerState.JUMPING
		velocity.y = JUMP_POWER
		# stop the coyote timer to prevent repeated jumps
		if not coyote_timer.is_stopped():
			coyote_timer.stop()


func handle_jumping(delta: float) -> void:
	if is_on_floor():
		STATE = PlayerState.STANDING if velocity.x == 0 else PlayerState.RUNNING
	elif velocity.y > 0:
		STATE = PlayerState.FALLING
	else:
		if Input.is_action_just_released("jump"):
			if velocity.y < JUMP_POWER / 1.5:
				velocity.y = velocity.y / 2

		handle_air_horizontal_input(delta)
	

func handle_running(delta: float) -> void:
	if velocity.x == 0:
		STATE = PlayerState.STANDING
	if velocity.y > 0:
		STATE = PlayerState.FALLING
	elif Input.is_action_pressed("jump"):
		STATE = PlayerState.JUMPING
		velocity.y = JUMP_POWER
	else:
		var direction = Input.get_axis("move_left", "move_right") * SPEED
		
		if direction * velocity.x < 0: # Change directions quicker
			velocity.x = move_toward(velocity.x, direction, 4 * ACCELERATION_H * delta)
		else:
			velocity.x = move_toward(velocity.x, direction, ACCELERATION_H * delta)


func try_fall_through_platform() -> void:
	if raycast.is_colliding():
		var collision = raycast.get_collider()
		# The platform scene must have a func disable()
		if collision.has_method("disable") and Input.is_action_pressed("move_down"):
			collision.disable()


func try_walk_animation() -> void:
	if velocity.length() > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop()
	
	$AnimatedSprite2D.flip_h = (get_global_mouse_position() - global_position).x < 0
		

func _on_body_entered(body: Node2D) -> void:
	hide() # Player will disappear after being hit
	hit.emit() # Emits a signal
	$CollisionShape2D.set_deferred("disabled", true) # Waits to safely disable collision

# called once whenever the player is hit by a bullet.
# TODO: even though Ground is on a diff collision layer, the bullet still emits. fix
func _on_bullet_hit() -> void:
	HEALTH -= 50
	if HEALTH == 0:
		_on_death()
	print("BULLET OW!!")
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_money_timer_timeout() -> void:
	if HEALTH > 0:
		EquipItems.money += 5
		print(EquipItems.money)
		
func _on_death() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
