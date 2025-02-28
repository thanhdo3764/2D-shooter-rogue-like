extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Bank").text = "Bank: $" + str(EquipItems.bank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_confirm_pressed() -> void:
	if (EquipItems.weapon != 0) and (EquipItems.equipment != 0):
		$Select_Confirm.visible = true
	else:
		$Must_Select.visible = true
		$Select_Confirm.visible = false

func _on_yes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")
	

func _on_okay_pressed() -> void:
	$Must_Select.visible = false

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
