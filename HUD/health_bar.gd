extends TextureProgressBar

@export var player: Node

func update_health():
	if player:
		# Set the progress bar value to the player's health
		self.value = player.health
