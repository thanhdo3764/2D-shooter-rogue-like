extends Node2D

var GRAPPLER_SPEED = 250
var GRAPPLER_MAX_DISTANCE = 100

func execute(player: Player) -> void:
	var grappler = load("res://abilities/grapple/grappler.tscn").instantiate()
	grappler.set_grappler(player.global_position, get_global_mouse_position(), GRAPPLER_SPEED, GRAPPLER_MAX_DISTANCE)
	get_node("/root").add_child(grappler)
