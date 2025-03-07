extends Node

var weapon = 0
var equipment = 0
var bank = 1000
var money = 0
var cart = 0

var w_prices = [200, 500]
var e_prices = [200, 500]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _equip_weapon(index: int):
	weapon = index
	
func _equip_equipment(index: int):
	equipment = index

func _get_cart_() -> int:
	cart = 0
	if weapon != 0:
		cart += e_prices[weapon-1]
	if equipment != 0:
		cart += e_prices[equipment-1]
	return cart

func _get_bank() -> int:
	bank -= e_prices[weapon-1]
	bank -= e_prices[equipment-1]
	return bank
	
