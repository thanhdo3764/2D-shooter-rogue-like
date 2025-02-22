extends Node

var weapon = 0
var equipment = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(weapon, equipment)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _equip_weapon(index: int):
	weapon = index
	print(weapon)
	
func _equip_equipment(index: int):
	equipment = index
	print(equipment)
