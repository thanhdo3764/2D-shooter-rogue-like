extends GutTest

var shop_scene = preload("res://scenes/shop.tscn")
var shop

var player_scene = preload("res://player/player.tscn")
var player

func before_each():
	EquipItems.weapon = 0
	EquipItems.equipment = 0
	EquipItems.cart = 0
	EquipItems.bank = 1000
	
	shop = shop_scene.instantiate()
	add_child(shop)
	
	player = player_scene.instantiate()
	add_child(player)
	
func after_each():
	shop.queue_free()
	player.queue_free()

# black box unit test
func test_equip_pistol_blackbox():
	assert_eq(EquipItems.weapon, 0, "Weapon should start at 0.")
	assert_eq(EquipItems.equipment, 0, "Equipment should start at 0.")
	
	shop._on_weapons_list_item_clicked(0, Vector2(0,0), 0)
	shop._on_equipment_list_item_clicked(1, Vector2(0,0), 0)
	
	assert_eq(EquipItems.weapon, 1, "Weapon should be set to 1.")
	assert_eq(EquipItems.equipment, 2, "Equipment should be set to 2.")
	
	var pistol = player.get_node_or_null("Pistol")
	assert_not_null(pistol, "Player should have the pistol equipped.")
	remove_child(pistol)
	
# black box unit test
func test_equip_sniper_blackbox():
	shop._on_weapons_list_item_clicked(1, Vector2(0,0), 0)
	shop._on_equipment_list_item_clicked(0, Vector2(0,0), 0)
	
	assert_eq(EquipItems.weapon, 2, "Weapon should be set to 2.")
	assert_eq(EquipItems.equipment, 1, "Equipment should be set to 1.")
	
	var sniper = player.get_node_or_null("Sniper")
	assert_not_null(sniper, "Player should have the sniper equipped.")
	remove_child(sniper)
	
# white box unit test
# tests if the value of the selected items matches the value contained in the cart variable.
# ensures coverage by:
	# executing each line in _get_cart().
	# testing both conditions in true and false states.
	# testing multiple paths (no items selected, weapon selected but no equipment and vice-versa,
		# and both weapon and equipment selected).
# Function Tested:
	#func _get_cart_() -> int:
		#cart = 0
		#if weapon != 0:
			#cart += e_prices[weapon-1]
		#if equipment != 0:
			#cart += e_prices[equipment-1]
		#return cart
func test_get_cart():
	EquipItems.weapon = 0
	EquipItems.equipment = 0
	assert_eq(EquipItems._get_cart_(), 0, "Cart should be 0 when no items are selected.")

	EquipItems.weapon = 1
	EquipItems.equipment = 0
	assert_eq(EquipItems._get_cart_(), 0, "Cart should be 0 for weapon index 1.")
	
	EquipItems.weapon = 0
	EquipItems.equipment = 1
	assert_eq(EquipItems._get_cart_(), 0, "Cart should be 0 for equipment index 1.")

	EquipItems.weapon = 2
	EquipItems.equipment = 0
	assert_eq(EquipItems._get_cart_(), 500, "Cart should be 500 for weapon index 2.")
	
	EquipItems.weapon = 0
	EquipItems.equipment = 2
	assert_eq(EquipItems._get_cart_(), 500, "Cart should be 500 for equipment index 2.")

	EquipItems.weapon = 2
	EquipItems.equipment = 2
	assert_eq(EquipItems._get_cart_(), 1000, "Cart should be 1000 for weapon 2 and equipment 2.")
	
	
# integration test
# Units Tested:
	# _on_confirm_pressed() in shop.gd
	# _get_cart() in equip_items.gd
func test_shop_cart_integration():
	shop._on_confirm_pressed()
	assert_true(shop.get_node("Must_Select").visible, "Should show 'Must Select' message.")
	
	EquipItems.bank = 500
	
	shop._on_weapons_list_item_clicked(1, Vector2(0,0), 0)
	shop._on_equipment_list_item_clicked(1, Vector2(0,0), 0)
	
	shop._on_confirm_pressed()
	
	assert_true(shop.get_node("Not_Enough").visible, "Should show 'Not Enough Funds' message.")
	
	shop._on_weapons_list_item_clicked(0, Vector2(0,0), 0)
	
	shop._on_confirm_pressed()
	
	assert_true(shop.get_node("Select_Confirm").visible, "Should show 'Are You Sure' message.")
