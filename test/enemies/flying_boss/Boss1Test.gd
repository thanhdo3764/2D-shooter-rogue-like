# GdUnit generated TestSuite
class_name Boss1Test
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://enemies/flying_boss/boss_1.gd'

# ----- Black box unit test -----
func test_do_state_change() -> void:
	var runner = scene_runner("res://scenes/level.tscn")
	var boss = runner.invoke("get_node", "Boss1")
	
	# transition to either attack state after idle
	assert_int(boss.do_state_change(boss.BossState.FLY_IDLE)).is_in(
		[boss.BossState.ATTACK_BULLET, boss.BossState.ATTACK_BEAM]
	)
	
	# transition to idle state after attack
	assert_int(boss.do_state_change(boss.BossState.ATTACK_BULLET)).is_equal(boss.BossState.FLY_IDLE)
	assert_int(boss.do_state_change(boss.BossState.ATTACK_BEAM)).is_equal(boss.BossState.FLY_IDLE)
	
	# return -1 on an invalid state
	assert_int(boss.do_state_change(1234)).is_equal(-1)

# ----- White box unit test -----
# 100% statement coverage

#func do_hp_check() -> void:
	#if hp <= 0:
		#emit_signal("killed", self)
		#queue_free()
	#elif hp <= BOSS_MAX_HP * RAMPAGE_HEALTH_THRESHOLD and !rampage_enabled:
		#move_anim.speed_scale = RAMPAGE_MOVEMENT_SPEED
		#shoot_timer.wait_time = fire_rate * 0.5
		#rampage_enabled = true

func test_do_hp_check_zero() -> void:
	var runner = scene_runner("res://scenes/level.tscn")
	var boss = runner.invoke("get_node", "Boss1")
	
	# test first branch, when hp is 0 free the boss
	boss.hp = 0
	boss.do_hp_check()
	
	await runner.simulate_frames(30)
	assert_bool(is_instance_valid(boss)).is_equal(false)
	
func test_do_hp_check_below_threshold() -> void:
	var runner = scene_runner("res://scenes/level.tscn")
	var boss = runner.invoke("get_node", "Boss1")
	
	# test second branch, when hp is below threshhold
	boss.hp = (boss.BOSS_MAX_HP * boss.RAMPAGE_HEALTH_THRESHOLD) / 2
	boss.do_hp_check()
	
	assert_bool(is_instance_valid(boss)).is_equal(true)
	assert_float(boss.move_anim.speed_scale).is_equal_approx(boss.RAMPAGE_MOVEMENT_SPEED, 0.0001)
	# make sure the boss is firing bullets more quickly than it was, regardless of the exact value
	assert_float(boss.shoot_timer.wait_time).is_less(boss.fire_rate)
	assert_bool(boss.rampage_enabled).is_equal(true)
