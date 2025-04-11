extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EquipItems.weapon = 0
	EquipItems.equipment = 0
	EquipItems.cart = 0
	get_node("Bank").text = "Bank: $" + str(EquipItems.bank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_confirm_pressed() -> void:
	if EquipItems.cart > EquipItems.bank:
		$Not_Enough.visible = true
	
	if EquipItems.cart <= EquipItems.bank:
		if (EquipItems.weapon == 0) or (EquipItems.equipment == 0):
			$Must_Select.visible = true
			$Select_Confirm.visible = false
		if (EquipItems.weapon != 0) and (EquipItems.equipment != 0):
			$Select_Confirm.visible = true

func _on_yes_pressed() -> void:
	LevelManager.next_room()
	Pause.in_level = true

func _on_okay_pressed() -> void:
	$Must_Select.visible = false
	
func _on_okay_2_pressed() -> void:
	$Not_Enough.visible = false

func _on_no_pressed() -> void:
	$Select_Confirm.visible = false

func _on_weapons_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	var weapons = ["Pistol", "Sniper Rifle"]
	print("Player Selected: ", weapons[index])
	
	EquipItems._equip_weapon(index+1)
	get_node("Cart").text = "-$" + str(EquipItems._get_cart_())


func _on_equipment_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	var equipment = ["Double Jump", "Grapple Hook"]
	print("Player Selected: ", equipment[index])
	
	EquipItems._equip_equipment(index+1)
	get_node("Cart").text = "-$" + str(EquipItems._get_cart_())


func _on_modifiers_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	EquipItems._equip_modifier(index+1)
	get_node("Cart").text = "-$" + str(EquipItems._get_cart_())
