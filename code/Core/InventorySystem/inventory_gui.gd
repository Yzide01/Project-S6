extends Control

signal opened
signal closed

var isOpen : bool = false

@onready var inventory: Inventory = preload("res://Core/InventorySystem/playerInventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready() -> void:
	update()
	close()
	
func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

func open():
	visible = true
	isOpen = true
	opened.emit()

func close():
	visible = false
	isOpen = false
	closed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if isOpen:
			close()
		else:
			open()
