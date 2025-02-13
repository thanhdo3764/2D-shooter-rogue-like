extends Area2D

var lifetime : int = 5
var damage : int = 2
var speed  : int = 50
var direction : Vector2

signal hit_bullet
var life = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	life += delta
	if life >= lifetime:
		despawn()

func _on_body_entered(body: Node2D) -> void:
	emit_signal("hit_bullet")
	despawn()
	
func despawn() -> void:
	queue_free()
