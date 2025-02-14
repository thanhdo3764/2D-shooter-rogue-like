extends Base_Weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	DAMAGE = 100
	RELOAD_SPEED_SEC = 1.0
	WEIGHT = 100
	RATE_OF_FIRE = 1
	MAX_AMMO = 5
	AMMO_COUNT = MAX_AMMO
	BULLET_SPEED = 5000
	BULLET =  preload("res://weapons/Bullet.tscn")
