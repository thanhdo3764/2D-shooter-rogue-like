extends Node2D
class_name Base_Weapon

@export var MAX_AMMO: int
@export var BULLET_SPEED: int
@export var RELOAD_SPEED_SEC: float
@export var WEIGHT: int
@export var RATE_OF_FIRE: float
@export var DAMAGE: int

var AMMO_COUNT: int
var BULLET = preload("res://weapons/Bullet.tscn")

var IS_SHOOTING: bool = false

var DEFAULT_SCALE_X: float = scale.x

func _ready() -> void:
	pass

func shoot_weapon() -> void:
	if IS_SHOOTING: return
	IS_SHOOTING = true
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("shooting")
	var projectile = BULLET.instantiate()
	projectile.set_bullet($Muzzle.global_position, get_global_mouse_position(), BULLET_SPEED)
	get_node("/root").add_child(projectile)
	await get_tree().create_timer(RATE_OF_FIRE).timeout
	IS_SHOOTING = false

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		shoot_weapon()
	if (get_global_mouse_position() - global_position).x < 0:
		scale.x = -DEFAULT_SCALE_X
		rotation_degrees = rad_to_deg(global_position.angle_to_point(get_global_mouse_position()) + PI)
	else:
		scale.x = DEFAULT_SCALE_X
		rotation_degrees = rad_to_deg(global_position.angle_to_point(get_global_mouse_position()))
	
		
