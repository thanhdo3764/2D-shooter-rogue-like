extends Area2D

var enabled = false
signal door_entered

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass

func toggle_door() -> void:
	enabled = !enabled
	$AnimatedSprite2D.frame = enabled

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enabled:
		emit_signal("door_entered")
