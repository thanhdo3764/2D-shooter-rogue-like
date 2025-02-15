extends TextureProgressBar

@export var player: Node

func update_shield():
	if player:
		# Set the progress bar value to the player's shield
		self.value = player.SHIELD  
