# GdUnit generated TestSuite
class_name LevelTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://scenes/level.gd'

# ----- Integration test -----
func test_door_open_on_boss_killed() -> void:
	var runner = scene_runner("res://scenes/level.tscn")
	var boss = runner.invoke("get_node", "Boss1")
	var exit_door = runner.invoke("get_node", "ExitDoor")
	
	boss.hp = 0
	await runner.simulate_frames(30)
	
	# with current level setup, boss should be the only enemy in the list
	assert_int(len(runner.get_property("active_enemies"))).is_equal(0)
	# check if the door is open
	assert_bool(exit_door.enabled).is_equal(true)
	assert_int(exit_door.sprite.frame).is_equal(1)
	
	
