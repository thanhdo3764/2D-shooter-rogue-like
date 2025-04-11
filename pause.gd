extends CanvasLayer

var in_level: bool = false
var latest_bank
var latest_money

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"/root/Pause".layer = 10
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if latest_bank != EquipItems.bank:
		latest_bank = EquipItems.bank
		get_node("Inventory_Window/Bank").text = "Bank: $" + str(EquipItems.bank)
	if latest_money != EquipItems.money:
		latest_money = EquipItems.money
		get_node("Inventory_Window/Money").text = "Money Held: $" + str(EquipItems.money)
	
func _input(event):
	if event.is_action_pressed("pause") and in_level == true:
		_toggle_pause()

func _toggle_pause() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	$Panel.visible = !is_paused
	$Buttons.visible = !is_paused
	if $Inventory_Window.visible == true:
		$Inventory_Window.visible = false
	

func _on_quit_pressed() -> void:
	$Quit_Confirm.visible = true
	
func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed() -> void:
	$Quit_Confirm.visible = false

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_inventory_pressed() -> void:
	$Inventory_Window.visible = true
	if EquipItems.weapon == 1:
		get_node("Inventory_Window/Weapon").text = "Weapon: Pistol"
		$Inventory_Window/Pistol.visible = true
	if EquipItems.weapon == 2:
		get_node("Inventory_Window/Weapon").text = "Weapon: Sniper"
		$Inventory_Window/Sniper.visible = true
		
	if EquipItems.equipment == 1:
		get_node("Inventory_Window/Equipment").text = "Equipment:\nDouble Jump"
	if EquipItems.equipment == 2:
		get_node("Inventory_Window/Equipment").text = "Equipment:\nGrapple Hook"
		
	if EquipItems.modifier == 1:
		get_node("Inventory_Window/Modifier").text = "Modifier:\n2x Money"
	if EquipItems.modifier == 2:
		get_node("Inventory_Window/Modifier").text = "Modifier:\n2x Health\n0.5x Money"
	if EquipItems.modifier == 3:
		get_node("Inventory_Window/Modifier").text = "Modifier:\n2x Damage\n0.5x Health"

func _on_close_pressed() -> void:
	$Inventory_Window.visible = false
