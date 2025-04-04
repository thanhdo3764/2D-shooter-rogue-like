extends CharacterBody2D
class_name base_enemy

const GRAVITY = 1000
@export var SPEED: int = 100
@export var hp: int = 30 

var player: Node2D = null
var DEFAULT_SCALE_X: float = 1.0
var flipped: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	DEFAULT_SCALE_X = scale.x
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("enemy")

func apply_gravity(delta:float):
	velocity.y += GRAVITY * delta

func move_towards_player():
	if player:
		var direction = (player.global_position - global_position).normalized()
		var new_velocity_x = direction.x * SPEED
		
		if velocity.x < 0 and not flipped:
			scale.x = -DEFAULT_SCALE_X
			flipped = !flipped
		if velocity.x > 0 and flipped:
			scale.x = -DEFAULT_SCALE_X
			flipped = !flipped

		velocity.x = new_velocity_x

func take_damage(damage: int):
	if hp <= 0:
		return
	hp -= damage
	print("Enemy took ", damage, " damage. HP:", hp)
	if hp <= 0:
		die()

func die():
	print("Enemy died!")
	on_death() # this calls will be overridden from the subclass
	await sprite.animation_finished
	queue_free()

# called when the enemy dies, where the subclass (specific enemy) can override this
# where state management is kept within the subclass
func on_death():
	pass
