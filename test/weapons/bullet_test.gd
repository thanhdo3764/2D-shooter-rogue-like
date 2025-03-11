# GdUnit generated TestSuite
class_name BulletTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://weapons/bullet.gd'

# Integration Test: Base_Weapon and Bullet
func test_bullet() -> void:
	var runner := scene_runner("res://scenes/tutorial_level.tscn")
	await await_millis(1000)
	
	var mouse_pos = Vector2(200, 200)
	
	runner.simulate_mouse_move(mouse_pos)
	await runner.await_input_processed()
	
	var pistol = runner.find_child("Pistol")
	var muzzle = pistol.find_child("Muzzle")
	var direction = (muzzle.global_position).direction_to(mouse_pos).normalized()
	
	var root_child_count = get_node("/root").get_child_count()
	
	runner.simulate_action_press("left_click")
	await runner.await_input_processed()
	await await_millis(4000)
	
	var bullet = get_node("/root").get_child(root_child_count)
	assert_int(bullet.SPEED).is_equal(pistol.BULLET_SPEED)
	assert_bool(bullet.DIRECTION.normalized().is_equal_approx(direction)).is_true()
	
	
