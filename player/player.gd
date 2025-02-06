extends CharacterBody2D
signal hit

@export var SPEED = 100
@export var ACCELERATION_H = 300
@export var GRAVITY = 1000
@export var JUMP_POWER = -300
var screen_size
var raycast

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	raycast = $RayCast2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump") && is_on_floor(): velocity.y = JUMP_POWER
	try_fall_through_platform()
	velocity.y = velocity.y + GRAVITY * delta # Make player fall
	apply_horizontal_movement(delta)
	move_and_slide() # Make collision with the floor
	try_walk_animation()
	update_position(delta)
	
	
			

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
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
		
		
func apply_horizontal_movement(delta:float) -> void:
	# Get the next velocity.x value
	if is_on_floor():
		var direction = Input.get_axis("move_left", "move_right") * SPEED
		# Instantly change direction when on floor
		if direction * velocity.x < 0: velocity.x = 0
		else:
			velocity.x = move_toward(velocity.x, direction, ACCELERATION_H * delta)
	else:
		var direction = Input.get_axis("move_left", "move_right") * SPEED
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction, ACCELERATION_H * delta)

func _on_body_entered(body: Node2D) -> void:
	hide() # Player will disappear after being hit
	hit.emit() # Emits a signal
	$CollisionShape2D.set_deferred("disabled", true) # Waits to safely disable collision
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
