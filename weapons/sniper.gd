extends Base_Weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	DAMAGE = 30
	if EquipItems.modifier == 3:
		DAMAGE = DAMAGE * 2
	
	RELOAD_SPEED_SEC = 2
	WEIGHT = 100
	SHOOT_SPEED_SEC = 0.5
	MAX_AMMO = 5
	AMMO_COUNT = MAX_AMMO
	BULLET_SPEED = 2500
	BULLET =  preload("res://weapons/Bullet.tscn")
