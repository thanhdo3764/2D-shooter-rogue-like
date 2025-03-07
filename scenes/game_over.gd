extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	$Quit_Confirm.visible = true


func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	$Quit_Confirm.visible = false
