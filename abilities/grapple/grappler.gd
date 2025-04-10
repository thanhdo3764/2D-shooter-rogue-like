extends CharacterBody2D

signal grappler_collided(pos)

var SPEED
var DIRECTION
var START_POS
var MAX_DISTANCE
var PLAYER
var LINE

func _ready() -> void:
	get_node("/root").add_child(LINE)

func set_grappler(player, target_position, speed, max) -> void:
	SPEED = speed
	PLAYER = player
	global_position = player.global_position
	START_POS = player.global_position
	rotation_degrees = rad_to_deg(START_POS.angle_to_point(target_position))
	DIRECTION = START_POS.direction_to(target_position)
	MAX_DISTANCE = max
	
	LINE = Line2D.new()
	LINE.add_point(global_position, 0)
	LINE.add_point(global_position, 1)
	LINE.set_width(1)


func _physics_process(delta: float) -> void:
	LINE.set_point_position(0, global_position)
	LINE.set_point_position(1, PLAYER.global_position)
	if (global_position-START_POS).length() > MAX_DISTANCE:
		queue_free()
		LINE.queue_free()
	else:
		if move_and_collide(DIRECTION*SPEED*delta) != null:
			grappler_collided.emit(global_position)
			queue_free()
			LINE.queue_free()
