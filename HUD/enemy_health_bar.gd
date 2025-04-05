extends TextureProgressBar

func _ready():
	# Initialize the health bar to start full
	value = max_value

# Call this function to update the health bar's value
func update_health(current_health: int, max_health: int) -> void:
	max_value = max_health
	value = current_health
