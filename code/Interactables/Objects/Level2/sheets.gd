extends Node2D

@onready var interactable_area = $Interactable
@onready var sprite = $Sprite2D
# Load the inventory and the item
@onready var inventory: Inventory = preload("res://Core/InventorySystem/playerInventory.tres")
@onready var partition_item: InventoryItem = preload("res://Core/InventorySystem/items/Partition.tres")


func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Pick up sheet music" 
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	sprite.visible = false
	var piano = get_tree().get_first_node_in_group("Piano")
	
	if piano:
		piano.ajouter_partition()
		# Le dialogue spécifique au fragment (1, 2 ou 3) 
		# sera géré par le piano pour être plus centralisé.
	inventory.insert(partition_item)
	
	# 2. Your existing code to make it disappear (e.g., queue_free(), or erasing the tile)
	
	queue_free()
