extends Area2D

var SPEED: int
var DIRECTION : Vector2

# for bullet collision with enemies
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("bullet") # for on enemy hit

func set_bullet(position, target_position, speed) -> void:
	SPEED = speed
	global_position = position
	rotation_degrees = rad_to_deg(global_position.angle_to_point(target_position))
	DIRECTION = position.direction_to(target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += DIRECTION * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		#DEBUG
		print("bullet hit ", body.name)
		if body.has_method("take_damage"):
			body.take_damage(5) # TODO change damage number to weapon's damage
		queue_free()
