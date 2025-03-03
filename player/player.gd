extends CharacterBody2D
signal hit

@export var HEALTH: int = 100
@export var MAX_HEALTH: int = 100
@export var SHIELD: int = 50
@export var MAX_SHIELD: int = 100

@export var SPEED: int = 100
@export var ACCELERATION_H: int = 475
@export var GRAVITY: int = 1000
@export var JUMP_POWER: int = -310

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var raycast: RayCast2D = $RayCast2D

var screen_size: Vector2

var WEAPON_LOAD
var weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if EquipItems.weapon == 0:
		WEAPON_LOAD = preload("res://weapons/Pistol.tscn")
		
	if EquipItems.weapon == 1:
		WEAPON_LOAD = preload("res://weapons/Sniper.tscn")
	
	weapon = WEAPON_LOAD.instantiate()
	add_child(weapon)
	weapon.position = $Weapon_Spawn.position
	screen_size = get_viewport_rect().size

	add_to_group("player") # for the HUD

func _physics_process(delta: float) -> void:
	# handle jumping
	if Input.is_action_pressed("jump") and (is_on_floor() or coyote_timer.time_left > 0):
		velocity.y = JUMP_POWER
		# stop the coyote timer to prevent repeated jumps
		if not coyote_timer.is_stopped():
			coyote_timer.stop()
			
	# jump cutoff
	if Input.is_action_just_released("jump"):
		# if the key is released when we're still early into the jump (higher negative value), reduce the velocity to make the jump shorter
		if velocity.y < JUMP_POWER / 1.5:
			velocity.y = velocity.y / 2
	
	# apply gravity
	try_fall_through_platform()
	velocity.y = velocity.y + GRAVITY * delta # Make player fall
	
	# move the player
	var previously_on_floor = is_on_floor()
	apply_horizontal_movement(delta)
	move_and_slide() # Make collision with the floor
	
	# if the player has just fell off a platform, start the coyote timer
	if previously_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
	
	update_position(delta)
	try_walk_animation()

func update_position(delta:float) -> void:
	position += velocity * delta # Delta is the amount of time it took for the prev frame to complete
	position = position.clamp(Vector2.ZERO, screen_size) # Clamp makes it so we can't leave the screen


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
		
		
func apply_horizontal_movement(delta:float) -> void:
	var direction = Input.get_axis("move_left", "move_right") * SPEED
	# Keep moving in same direction if in the air and no input
	if not is_on_floor() and direction == 0:
		direction = velocity.x
	# Instantly change direction when on floor
	elif direction * velocity.x < 0 and is_on_floor():
		direction = 0
		
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_H * delta)

func _on_body_entered(body: Node2D) -> void:
	hide() # Player will disappear after being hit
	hit.emit() # Emits a signal
	$CollisionShape2D.set_deferred("disabled", true) # Waits to safely disable collision

# called once whenever the player is hit by a bullet.
# TODO: even though Ground is on a diff collision layer, the bullet still emits. fix
func _on_bullet_hit() -> void:
	print("BULLET OW!!")
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
