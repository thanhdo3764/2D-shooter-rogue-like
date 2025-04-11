extends Control

@onready var animation = $AnimationPlayer

func level_begin():
	animation.play_backwards("fade")
	await animation.animation_finished
	
func level_finished():
	animation.play("fade")
	await animation.animation_finished
