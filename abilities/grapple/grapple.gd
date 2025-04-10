extends Node2D

var GRAPPLER_SPEED = 500
var GRAPPLER_MAX_DISTANCE = 400
@onready var COOLDOWN = $Cooldown
var PLAYER

func execute(player: Player) -> void:
	PLAYER = player
	var root = get_node("/root")
	if root.has_node("Grappler") or not COOLDOWN.is_stopped(): return
	COOLDOWN.start()
	var grappler = load("res://abilities/grapple/grappler.tscn").instantiate()
	grappler.grappler_collided.connect(_on_grappler_collided)
	grappler.set_grappler(player.global_position, get_global_mouse_position(), GRAPPLER_SPEED, GRAPPLER_MAX_DISTANCE)
	root.add_child(grappler)
	
func _on_grappler_collided(pos) -> void:
	var direction = PLAYER.position.direction_to(pos)
	PLAYER.STATE = PLAYER.PlayerState.JUMPING
	PLAYER.velocity = direction * PLAYER.SPEED * 2
	if direction.y <= 0:
		PLAYER.velocity.y = min(PLAYER.JUMP_POWER, PLAYER.velocity.y)
	
