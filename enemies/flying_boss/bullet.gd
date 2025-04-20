extends Area2D

# NOTE: combine functionality with Thanh's bullet node
var lifetime : int = 5
var damage : int = 2
var speed  : int = 175
var direction : Vector2

signal hit_bullet
var life = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	life += delta
	if life >= lifetime:
		despawn()

func _on_body_entered(body: Node2D) -> void:
	# temporary fix for bullets colliding with the ground, even when the collision mask is set correctly
	if body.name == "Player":
		emit_signal("hit_bullet")
		despawn()
	
func despawn() -> void:
	queue_free()
