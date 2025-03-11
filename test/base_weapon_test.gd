# GdUnit generated TestSuite
class_name BaseWeaponTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://base_weapon.gd'

# White Box Unit Test: Statement Coverage
func test_shoot_weapon_pistol() -> void:
	# Create a pistol instance
	var pistol = preload("res://weapons/Pistol.tscn")
	var pistol_instance = pistol.instantiate()
	add_child(pistol_instance)
	# Variables for testing
	var old_ammo_count = pistol_instance.AMMO_COUNT
	var old_root_child_count = get_node("/root").get_child_count()
	# Test that the shoot timer is stopped
	assert_bool(pistol_instance._shoot_timer.is_stopped()).is_true()
	
	pistol_instance.shoot_weapon()
	# The shoot timer should be on
	assert_bool(pistol_instance._shoot_timer.is_stopped()).is_false()
	# Test that AMMO_COUNT decrements by 1
	assert_int(pistol_instance.AMMO_COUNT).is_equal(old_ammo_count-1)
	# Test that a child node was created
	assert_int(get_node("/root").get_child_count()).is_equal(old_root_child_count+1)
	# Test that the newest node is a bullet
	var projectile_object = get_node("/root").get_child(old_root_child_count)
	assert_bool(projectile_object is Bullet).is_true()
	
	assert_int(projectile_object.SPEED).is_equal(pistol_instance.BULLET_SPEED)
	pistol_instance.free()
	
	#func shoot_weapon() -> void:
		#if not _shoot_timer.is_stopped():
			#return
		#
		#AMMO_COUNT -= 1
#
		#$AnimatedSprite2D.stop()
		#$AnimatedSprite2D.play("shooting")
		#var projectile = BULLET.instantiate()
		#projectile.set_bullet($Muzzle.global_position, get_global_mouse_position(), BULLET_SPEED)
		#get_node("/root").add_child(projectile)
		#
		#_shoot_timer.start(SHOOT_SPEED_SEC)
	#
	#func reload() -> void:
		#if AMMO_COUNT < MAX_AMMO:
			#$AnimatedSprite2D.set_speed_scale(1/RELOAD_SPEED_SEC)
			#$AnimatedSprite2D.play("reloading")
			#_reload_timer.start(RELOAD_SPEED_SEC)
		#
		#
	#func _refill_ammo() -> void:
		#$AnimatedSprite2D.set_speed_scale(1)
		#AMMO_COUNT = MAX_AMMO
	
func test_reload() -> void:
	# remove this line and complete your test
	var pistol = preload("res://weapons/Pistol.tscn")
	var pistol_instance = pistol.instantiate()
	add_child(pistol_instance)
	var max_ammo = pistol_instance.MAX_AMMO
	
	assert_int(max_ammo).is_greater(0)
	assert_int(pistol_instance.AMMO_COUNT).is_equal(max_ammo)
	
	pistol_instance.reload()
	assert_int(pistol_instance.AMMO_COUNT).is_equal(max_ammo)
	
	pistol_instance.shoot_weapon()
	assert_int(pistol_instance.AMMO_COUNT).is_equal(max_ammo-1)
	pistol_instance.reload()
	await await_millis(pistol_instance.RELOAD_SPEED_SEC*1200)
	assert_int(pistol_instance.AMMO_COUNT).is_equal(max_ammo)
	
	pistol_instance.AMMO_COUNT = 1
	pistol_instance.shoot_weapon()
	await await_millis(pistol_instance.RELOAD_SPEED_SEC*1200)
	assert_int(pistol_instance.AMMO_COUNT).is_equal(max_ammo)
	
