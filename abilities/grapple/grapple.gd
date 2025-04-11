extends Node2D

var GRAPPLER_SPEED = 1000
var GRAPPLER_MAX_DISTANCE = 250
@onready var COOLDOWN = $Cooldown
var PLAYER

func execute(player: Player) -> void:
	PLAYER = player
	var root = get_node("/root")
	if root.has_node("Grappler") or not COOLDOWN.is_stopped(): return
	COOLDOWN.start()
	var grappler = load("res://abilities/grapple/grappler.tscn").instantiate()
	grappler.set_grappler(player, get_global_mouse_position(), GRAPPLER_SPEED, GRAPPLER_MAX_DISTANCE)
	root.add_child(grappler)
	
	
	
