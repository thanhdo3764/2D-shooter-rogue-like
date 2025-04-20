extends Area2D

var lifetime : int
var damage : int = 2
var speed  : int = 250
var direction : Vector2

@onready var damage_timer = $DamageTimer
signal hit_beam
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

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("hit_beam")
		damage_timer.start()
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	emit_signal("hit_beam")
