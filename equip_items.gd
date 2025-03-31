extends Node

var weapon = 0
var equipment = 0
var modifier = 0
var bank = 1000
var money = 0
var cart = 0

var w_prices = [0, 500]
var e_prices = [0, 500]
var m_prices = [1000, 0, 0]

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
	
func _equip_modifier(index: int):
	modifier = index

func _get_cart_() -> int:
	cart = 0
	if weapon != 0:
		cart += e_prices[weapon-1]
	if equipment != 0:
		cart += e_prices[equipment-1]
	if modifier != 0:
		cart += m_prices[modifier-1]
	return cart

func _add_bank() -> int:
	bank += money
	money = 0
	return bank

func _sub_bank() -> int:
	bank -= e_prices[weapon-1]
	bank -= e_prices[equipment-1]
	if modifier != 0:
		bank -= m_prices[modifier-1]
	return bank
	
