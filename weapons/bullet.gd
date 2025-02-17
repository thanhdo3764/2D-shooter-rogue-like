extends Area2D

var SPEED: int
var DIRECTION : Vector2

func set_bullet(position, target_position, speed) -> void:
	SPEED = speed
	global_position = position
	rotation_degrees = rad_to_deg(global_position.angle_to_point(target_position))
	DIRECTION = position.direction_to(target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += DIRECTION * SPEED * delta
	
