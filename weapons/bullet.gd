extends CharacterBody2D

var DAMAGE
var SPEED: int
var DIRECTION : Vector2

# for bullet collision with enemies
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("bullet") # for on enemy hit

func set_bullet(position, target_position, speed, damage) -> void:
	SPEED = speed
	global_position = position
	rotation_degrees = rad_to_deg(global_position.angle_to_point(target_position))
	DIRECTION = position.direction_to(target_position)
	DAMAGE = damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var kinematic_collision = move_and_collide(DIRECTION*SPEED*delta)
	if kinematic_collision != null:
		queue_free()
		var collider = kinematic_collision.get_collider()
		if collider.is_in_group("enemy"):
			print("bullet hit ", collider.name)
			if collider.has_method("take_damage"):
				collider.take_damage(DAMAGE) # TODO change damage number to weapon's damage
