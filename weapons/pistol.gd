extends Base_Weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	DAMAGE = 10
	RELOAD_SPEED_SEC = 1
	WEIGHT = 0
	SHOOT_SPEED_SEC = 0.2
	MAX_AMMO = 12
	AMMO_COUNT = MAX_AMMO
	BULLET_SPEED = 1000
	BULLET =  preload("res://weapons/Bullet.tscn")
	
