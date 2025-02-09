extends Node2D
class_name Base_Weapon

@export var max_ammo: int
@export var bullet_speed: int
@export var reload_speed_sec: float
@export var weight: int
@export var rate_of_fire: float
@export var damage: int

var ammo_count: int
var bullet = preload("res://weapons/Bullet.tscn")

func _ready() -> void:
	pass

func shoot_weapon() -> void:
	var projectile = bullet.instantiate()
	projectile.set_bullet(global_position, get_global_mouse_position(), bullet_speed)
	get_node("/root").add_child(projectile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
