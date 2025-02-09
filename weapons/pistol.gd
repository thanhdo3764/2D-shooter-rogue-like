extends Base_Weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	damage = 10
	reload_speed_sec = 1.0
	weight = 0
	rate_of_fire = 0.5
	max_ammo = 12
	ammo_count = max_ammo
	bullet_speed = 1000
	bullet =  preload("res://weapons/Bullet.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click"): shoot_weapon()
