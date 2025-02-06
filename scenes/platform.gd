extends StaticBody2D

var collision
var area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision = $CollisionShape2D
	area = $Area2D


func disable() -> void:
	area.set_deferred("monitoring", true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	collision.set_deferred("disabled", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	collision.set_deferred("disabled", false)
	area.set_deferred("monitoring", false)
