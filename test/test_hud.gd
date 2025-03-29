extends GdUnitTestSuite

class_name TestSuite

var minimap: Minimap
var player_hp: PlayerHP
var score: Score

# Runs before each test to prevent orphan nodes
func before_test() -> void:
	minimap = Minimap.new()
	player_hp = PlayerHP.new()
	score = Score.new()
	
	add_child(minimap)
	add_child(player_hp)
	add_child(score)

# Runs after each test to clean up nodes
func after_test() -> void:
	minimap.queue_free()
	player_hp.queue_free()
	score.queue_free()

# Black-box unit test #1
func test_minimap_position_update() -> void:
	"""
	Tests Minimap's position update function.
	Ensures the minimap updates correctly when the player moves.
	"""
	if minimap.has_method("set_position"):
		var previous_position = minimap.position
		minimap.set_position(Vector2(100, 100))
		var new_position = minimap.position
		assert_that(new_position).is_not_equal(previous_position)
		assert_that(new_position.x).is_equal(100)
		assert_that(new_position.y).is_equal(100)
		
		assert_that(new_position.x <= 200).is_true()
	else:
		push_error("Error with set_position method")

# Black-box unit test #2
func test_minimap_visibility_toggle() -> void:
	"""
	Tests Minimap's visibility toggle function.
	Ensures the minimap correctly hides and shows.
	"""
	if minimap.has_method("set_visible") and minimap.has_method("is_visible"):
		minimap.set_visible(false)
		assert_that(minimap.is_visible()).is_false()
		
		minimap.set_visible(true)
		assert_that(minimap.is_visible()).is_true()
	else:
		push_error("Error with visibility methods")

# White-box unit test #1
func test_player_hp_damage() -> void:
	"""
	Achieves full branch coverage for take_damage().
	Ensures health is reduced correctly and does not go below zero.
	"""
	if player_hp.has_method("set_health") and player_hp.has_method("get_health"):
		player_hp.set_health(50)
		player_hp.take_damage(20)
		assert_that(player_hp.get_health()).is_equal(30)
		
		player_hp.take_damage(50)
		assert_that(player_hp.get_health()).is_equal(0) 
		
		player_hp.take_damage(-10)
		assert_that(player_hp.get_health()).is_equal(0)
	else:
		push_error("Error with set_health or get_health methods")

# White-box unit test #2
func test_player_hp_heal() -> void:
	"""
	Achieves full branch coverage for heal().
	Ensures health is increased correctly and does not exceed max health.
	"""
	if player_hp.has_method("set_health") and player_hp.has_method("get_health") and player_hp.has_method("heal"):
		player_hp.set_health(30)
		player_hp.heal(20)
		assert_that(player_hp.get_health()).is_equal(50)
		
		player_hp.heal(100)
		assert_that(player_hp.get_health()).is_equal(100)
	else:
		push_error("Error with heal method")

# Integration test #1
func test_player_hp_and_score_integration() -> void:
	"""
	Tests PlayerHP and Score working together.
	Ensures that when the player dies, the score resets properly.
	"""
	if player_hp.has_method("set_health") and player_hp.has_method("get_health") and score.has_method("set_score") and score.has_method("get_score"):
		player_hp.set_health(10)
		score.set_score(500)
		
		player_hp.take_damage(20)
		assert_that(player_hp.get_health()).is_equal(0)
		assert_that(score.get_score()).is_equal(0)
		
		score.set_score(-100)
		assert_that(score.get_score()).is_greater_or_equal(0)
	else:
		push_error("Error with PlayerHP and or Score methods")
