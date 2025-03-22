extends Node2D

var sounds: Dictionary

func _ready() -> void:
	for node in get_children():
		sounds[node.name] = node
	randomize()

func play(name: String) -> void:
	sounds[name].play()
	
func stop(name: String) -> void:
	sounds[name].stop()
	
func set_pitch(name: String, pitch: float) -> void:
	sounds[name].pitch_scale = pitch
	
func play_vary_pitch(name: String, range: float) -> void:
	var original_pitch = sounds[name].pitch_scale
	var node = sounds[name]
	node.pitch_scale = randf_range(1 - range, 1 + range)
	node.play()
	# wait until the sound has finished playing to reset its pitch
	await node.finished
	node.pitch_scale = original_pitch
