extends Area2D

var speed: int = 200
var damage: int = 25
var direction:Vector2
var lifetime: int = 5
var life: int = 0

signal hit_arrow

func set_target(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	life += delta 
	if life >= lifetime:
		despawn()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("hit_arrow") #signal will connect with _on_bullet_hit function
		despawn()

func despawn() -> void:
	queue_free()
