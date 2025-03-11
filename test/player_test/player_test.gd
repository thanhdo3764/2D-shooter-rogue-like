# GdUnit generated TestSuite
class_name PlayerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://player/player.gd'

# Black Box Unit Test
func test_receives_input_fast() -> void:
	var runner := scene_runner("res://scenes/tutorial_level.tscn")
	var start;
	var end;
	
	await await_millis(1000)
	start = Time.get_ticks_msec()
	runner.simulate_action_press("jump")
	await runner.await_input_processed()
	end = Time.get_ticks_msec()
	assert_int(end-start).is_less(100)
	
	await await_millis(1000)
	start = Time.get_ticks_msec()
	runner.simulate_action_press("move_left")
	await runner.await_input_processed()
	end = Time.get_ticks_msec()
	assert_int(end-start).is_less(100)
	
	await await_millis(1000)
	start = Time.get_ticks_msec()
	runner.simulate_action_press("move_right")
	await runner.await_input_processed()
	end = Time.get_ticks_msec()
	assert_int(end-start).is_less(100)
	await await_millis(1000)
	
	await await_millis(1000)
	start = Time.get_ticks_msec()
	runner.simulate_action_press("left_click")
	await runner.await_input_processed()
	end = Time.get_ticks_msec()
	assert_int(end-start).is_less(100)
	await await_millis(1000)
	
	await await_millis(1000)
	start = Time.get_ticks_msec()
	runner.simulate_action_press("move_down")
	await runner.await_input_processed()
	end = Time.get_ticks_msec()
	assert_int(end-start).is_less(100)
	await await_millis(1000)
	
	
