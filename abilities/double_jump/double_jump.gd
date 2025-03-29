extends Node2D

func _ready() -> void:
	var event = InputEventKey.new()
	event.set_physical_keycode(KEY_W)
	InputMap.action_add_event("use_ability", event)

func execute(player: Player) -> void:
	if player.can_double_jump and not player.is_on_floor():
		var direction = Input.get_axis("move_left", "move_right")
		if direction != sign(player.velocity.x) and direction != 0:
			player.velocity.x = 0
		player.execute_jump(1.0)
		player.can_double_jump = false
		
