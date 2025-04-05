extends CanvasLayer

var in_level: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"/root/Pause".layer = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("pause") and in_level == true:
		_toggle_pause()

func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	$Panel.visible = !is_paused
	$Buttons.visible = !is_paused
	

func _on_quit_pressed() -> void:
	$Quit_Confirm.visible = true
	
func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed() -> void:
	$Quit_Confirm.visible = false

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_inventory_pressed() -> void:
	pass # Replace with function body.
