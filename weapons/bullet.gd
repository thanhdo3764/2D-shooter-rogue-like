extends Area2D

var SPEED: int
var DIRECTION : Vector2

func set_bullet(transformation, target_position, speed) -> void:
	SPEED = speed
	transform = transformation
	DIRECTION = position.direction_to(target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += DIRECTION * SPEED * delta
	
