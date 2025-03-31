extends Area2D

var speed: int = 200
var damage: int = 2
var direction:Vector2

func set_target(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		emit_signal("hit_arrow")
		despawn()

func despawn() -> void:
	queue_free()
