extends CanvasLayer

func _ready():
	hide()

func _unhandled_input(event: InputEvent) -> void:
	# --- Ouverture / Fermeture ---
	if event.is_action_pressed("toggle_inventory"):
		visible = !visible

	# --- Utilisation de la Hotbar ---
	# On ne permet l'utilisation que si l'inventaire est fermé
	if not visible and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				use_equipped_item(0)
			KEY_2:
				use_equipped_item(1)
			KEY_3:
				use_equipped_item(2)

# Lit la case d'équipement et déclenche l'effet
func use_equipped_item(slot_index: int) -> void:
	var equip_slots = equipement_grid.get_children()
	
	if slot_index < equip_slots.size():
		var target_slot = equip_slots[slot_index]
		
		if target_slot.is_used:
			for child in target_slot.get_children():
				if child.has_method("_init_sprite") and child.item_data != null:
					print("Utilisation de : ", child.item_data.item_name)
					
					child.item_data.use(self) 
					
					# Destruction si consommable
					if child.item_data.is_consumable:
						child.queue_free()
						target_slot._free_slot()
					break
		else:
			print("Rien d'équipé dans l'emplacement ", slot_index + 1)


const INVENTORY_OBJECT = preload("res://inventory_object.tscn")

@onready var inventory_grid = $control_inventory/inventory_grid
@onready var equipement_grid = $control_inventory/equipement_grid

func add_item_to_empty_slot(item_type: int) -> bool:

	for slot in inventory_grid.get_children():
		if not slot.is_used:
			var new_item = INVENTORY_OBJECT.instantiate()
			new_item.type = item_type # On lui donne son type pour le sprite
			
			slot.add_child(new_item)
			
			new_item.position = slot.get_child(1).position 
			new_item.current_slot = slot
			
			slot._use_slot()
			
			print("Objet de type ", item_type, " ajouté à l'inventaire !")
			return true
			
	print("L'inventaire est plein !")
	return false
