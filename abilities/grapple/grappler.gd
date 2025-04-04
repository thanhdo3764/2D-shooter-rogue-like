extends CharacterBody2D

signal grappler_collided(pos)

var SPEED
var DIRECTION
var START_POS
var MAX_DISTANCE

func set_grappler(start_position, target_position, speed, max) -> void:
	SPEED = speed
	global_position = start_position
	START_POS = start_position
	rotation_degrees = rad_to_deg(start_position.angle_to_point(target_position))
	DIRECTION = start_position.direction_to(target_position)
	MAX_DISTANCE = max

func _physics_process(delta: float) -> void:
	if (global_position-START_POS).length() > MAX_DISTANCE:
		queue_free()
	else:
		if move_and_collide(DIRECTION*SPEED*delta) != null:
			grappler_collided.emit(global_position)
			queue_free()
