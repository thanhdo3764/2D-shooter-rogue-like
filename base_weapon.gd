extends Node2D
class_name Base_Weapon

@export var MAX_AMMO: int
@export var BULLET_SPEED: int
@export var RELOAD_SPEED_SEC: float
@export var WEIGHT: int
@export var SHOOT_SPEED_SEC: float
@export var DAMAGE: int
var AMMO_COUNT: int
var BULLET = preload("res://weapons/Bullet.tscn")

var IS_SHOOTING: bool = false

@onready var _shoot_timer = $ShootTimer
@onready var _reload_timer = $ReloadTimer

var DEFAULT_SCALE_X: float = scale.x

func _ready() -> void:
	_shoot_timer.set_wait_time(SHOOT_SPEED_SEC)
	_shoot_timer.set_one_shot(true)
	_reload_timer.set_wait_time(RELOAD_SPEED_SEC)
	_reload_timer.set_one_shot(true)
	_reload_timer.timeout.connect(_refill_ammo)

func shoot_weapon() -> void:
	if not _shoot_timer.is_stopped():
		return
	
	AMMO_COUNT -= 1

	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("shooting")
	var projectile = BULLET.instantiate()
	projectile.set_bullet($Muzzle.global_position, get_global_mouse_position(), BULLET_SPEED)
	get_node("/root").add_child(projectile)
	
	_shoot_timer.start(SHOOT_SPEED_SEC)
	
func reload() -> void:
	if AMMO_COUNT < MAX_AMMO:
		$AnimatedSprite2D.set_speed_scale(1/RELOAD_SPEED_SEC)
		$AnimatedSprite2D.play("reloading")
		_reload_timer.start(RELOAD_SPEED_SEC)
		
		
func _refill_ammo() -> void:
	$AnimatedSprite2D.set_speed_scale(1)
	AMMO_COUNT = MAX_AMMO
	
	
func display_weapon() -> void:
	if (get_global_mouse_position() - global_position).x < 0:
		scale.x = -DEFAULT_SCALE_X
		rotation_degrees = rad_to_deg(global_position.angle_to_point(get_global_mouse_position()) + PI)
	else:
		scale.x = DEFAULT_SCALE_X
		rotation_degrees = rad_to_deg(global_position.angle_to_point(get_global_mouse_position()))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	display_weapon()
	if not _reload_timer.is_stopped():
		return
	
	if AMMO_COUNT <= 0 or Input.is_action_pressed("r"):
		reload()
		return
	
	if Input.is_action_pressed("left_click"):
		shoot_weapon()
		
	
