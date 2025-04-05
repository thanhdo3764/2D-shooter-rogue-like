extends CharacterBody2D
class_name Player
signal hit

@export var HEALTH: int = 100
@export var MAX_HEALTH: int = 100
@export var SHIELD: int = 0
@export var MAX_SHIELD: int = 100

@export var SHIELD_REGEN_DELAY: float = 3.0
@export var SHIELD_REGEN_RATE: float = 3.0
var SHIELD_REGEN_TIMER := 0.0
var IS_SHIELD_REGENERATING := false

@export var SCORE: int = 0

@export var SPEED: int = 250
@export var SLIDE_SPEED: int = 500
@export var ACCELERATION_H: int = 800
@export var GRAVITY: int = 2500
@export var JUMP_POWER: int = -700

@onready var slide_timer: Timer = $Slide_Timer
@onready var slide_cooldown: Timer = $Slide_Cooldown
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var raycast: RayCast2D = $RayCast2D

var screen_size: Vector2

var WEAPON_LOAD
var weapon
var ability

var can_double_jump: bool = true

enum PlayerState {
	STANDING,
	FALLING,
	JUMPING,
	RUNNING,
	SLIDING,
}

var STATE: PlayerState = PlayerState.STANDING

var multiplier = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	set_process(true)
	WEAPON_LOAD = preload("res://weapons/Pistol.tscn")
  
	if EquipItems.weapon == 1:
		WEAPON_LOAD = preload("res://weapons/Pistol.tscn")
	elif EquipItems.weapon == 2:
		WEAPON_LOAD = preload("res://weapons/Sniper.tscn")
	else: 
		WEAPON_LOAD = preload("res://weapons/Pistol.tscn")

	if EquipItems.modifier == 2:
		HEALTH = 200
		MAX_HEALTH = 200
	elif EquipItems.modifier == 3:
		HEALTH = 50
		MAX_HEALTH = 50
		
	weapon = WEAPON_LOAD.instantiate()
	add_child(weapon)
	weapon.position = $Weapon_Spawn.position
	
	ability = load_ability("grapple")
	screen_size = get_viewport_rect().size

	add_to_group("player") # for the HUD and enemy detection
	
func _process(delta: float) -> void:
	if SHIELD < MAX_SHIELD and not IS_SHIELD_REGENERATING:
		SHIELD_REGEN_TIMER += delta
		if SHIELD_REGEN_TIMER >= SHIELD_REGEN_DELAY:
			IS_SHIELD_REGENERATING = true
	elif IS_SHIELD_REGENERATING:
		SHIELD = min(SHIELD + SHIELD_REGEN_RATE * delta * 20, MAX_SHIELD)
		if SHIELD >= MAX_SHIELD:
			IS_SHIELD_REGENERATING = false
			SHIELD_REGEN_TIMER = 0.0

	
func _physics_process(delta: float) -> void:
	$AnimatedSprite2D.set_speed_scale(1)
	if is_on_floor() and EquipItems.equipment == 1: can_double_jump = true
	
	match STATE:
		PlayerState.STANDING:
			handle_standing(delta)
			$AnimatedSprite2D.play("idle")
		PlayerState.FALLING:
			handle_falling(delta)
			$AnimatedSprite2D.play("walk")
		PlayerState.JUMPING:
			$AnimatedSprite2D.play("walk")
			handle_jumping(delta)
		PlayerState.RUNNING:
			handle_running(delta)
			$AnimatedSprite2D.play("walk")
		PlayerState.SLIDING:
			handle_sliding(delta)
			$AnimatedSprite2D.set_speed_scale(1 / slide_timer.get_wait_time())
			$AnimatedSprite2D.play("evade")
	
	if Input.is_action_just_pressed("use_ability"):
		ability.execute(self)
		
	try_fall_through_platform()
	apply_gravity(delta)
	
	# move the player
	var previously_on_floor = is_on_floor()
	move_and_slide() # Make collision with the floor
	
	# if the player has just fell off a platform, start the coyote timer
	if previously_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
	
	position = position.clamp(Vector2.ZERO, screen_size)
	$AnimatedSprite2D.flip_h = (get_global_mouse_position() - global_position).x < 0

func apply_gravity(delta: float) -> void:
	if STATE == PlayerState.FALLING:
		velocity.y += 1.25 * GRAVITY * delta # More gravity when falling for smoothness
	else:
		velocity.y += GRAVITY * delta 

func execute_jump(multiplier:float) -> void:
	STATE = PlayerState.JUMPING
	velocity.y = multiplier*JUMP_POWER


func handle_sliding(delta: float) -> void:
	if not slide_timer.is_stopped():
		# Super jump
		if Input.is_action_pressed("jump"):
			slide_cooldown.start()
			execute_jump(1.3)
		elif velocity.x != 0:
			velocity.x = SLIDE_SPEED * sign(velocity.x)
	else:
		slide_cooldown.start()
		velocity.x = SPEED * sign(velocity.x)
		if is_on_floor():
			STATE = PlayerState.STANDING if velocity.x == 0 else PlayerState.RUNNING
		elif velocity.y > 0:
			STATE = PlayerState.FALLING
		

func handle_standing(delta: float) -> void:
	if not is_on_floor():
		STATE = PlayerState.FALLING
	elif Input.is_action_pressed("jump"):
		execute_jump(1.0)
	else:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0 or velocity.x != 0:
			STATE = PlayerState.RUNNING
			velocity.x = move_toward(velocity.x, direction*SPEED, ACCELERATION_H*delta)
	


func handle_air_horizontal_input(delta: float) -> void:
	var speed = SPEED
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction == 0:
		direction = sign(velocity.x)
		speed = abs(velocity.x)
		
	velocity.x = move_toward(velocity.x, direction*speed, ACCELERATION_H * delta)

		
func handle_falling(delta: float) -> void:
	if is_on_floor():
		STATE = PlayerState.STANDING if velocity.x == 0 else PlayerState.RUNNING
	else:
		handle_air_horizontal_input(delta)
	
	if Input.is_action_pressed("jump") and coyote_timer.time_left > 0:
		execute_jump(1.0)
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
	if !is_on_floor():
		STATE = PlayerState.FALLING
	elif Input.is_action_pressed("jump"):
		execute_jump(1.0)
	elif Input.is_action_pressed("shift") and slide_cooldown.is_stopped():
		slide_timer.start()
		STATE = PlayerState.SLIDING
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
		

func _on_body_entered(body: Node2D) -> void:
	hide() # Player will disappear after being hit
	hit.emit() # Emits a signal
	$CollisionShape2D.set_deferred("disabled", true) # Waits to safely disable collision

# called once whenever the player is hit by a bullet.
# TODO: even though Ground is on a diff collision layer, the bullet still emits. fix
func _on_bullet_hit() -> void:
	take_damage(5)
		
func _on_beam_hit() -> void:
	take_damage(3)
	

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	

func load_ability(name:String):
	var scene_node = load("res://abilities/"+name+"/"+name+".tscn").instantiate()
	add_child(scene_node)
	return scene_node

func _on_money_timer_timeout() -> void:
	if EquipItems.modifier == 1:
		multiplier = 2
	if EquipItems.modifier == 2:
		multiplier = 0.5
		
	if HEALTH > 0:
		SCORE += (5 * multiplier)
		

		
func _on_death() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	
	#Restart shield regeneration
	IS_SHIELD_REGENERATING = false
	SHIELD_REGEN_TIMER = 0.0
	
	# First deplete shield
	if SHIELD > 0:
		var shield_damage = min(amount, SHIELD)
		SHIELD -= shield_damage
		AudioManager.play_vary_pitch("player_hit", 0.1)
		amount -= shield_damage

	# Then apply leftover damage to health
	if amount > 0:
		AudioManager.play_vary_pitch("player_hit", 0.1)
		HEALTH = max(HEALTH - amount, 0)
		
	if HEALTH == 0:
		_on_death()

func heal(amount: int) -> void:
	if amount <= 0 or HEALTH == MAX_HEALTH:
		return
		
	HEALTH = min(HEALTH + amount, MAX_HEALTH)
