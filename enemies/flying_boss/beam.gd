extends Area2D

# NOTE: superclass for bullet and beam?
var lifetime : int = 4
var damage : int = 2
var speed  : int = 100
var direction : Vector2

var life = 0

func _ready() -> void:
	global_rotation = direction.angle() - PI/2

func _physics_process(delta: float) -> void:
	scale.y += speed * delta
	life += delta
	if life >= lifetime:
		despawn()

func despawn() -> void:
	queue_free()
