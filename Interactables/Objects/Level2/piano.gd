extends Node2D

@export var partitions_requises: int = 3
var partitions_actuelles: int = 0
var is_locked: bool = true
signal victory
@onready var interactable_area = $Interactable
@onready var audio_player = $AudioStreamPlayer2D
@onready var book_page = $BookPage
@onready var inventory: Inventory = preload("res://Core/InventorySystem/playerInventory.tres")
var finished = false

const DIALOGUE_FILE = preload("res://Dialogues/Level2/level2.dialogue")

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Inspect the piano"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	if is_locked:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "piano_inactive")
	elif finished:
		pass
	else:
		finished = true
		delete_sheets()
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "piano_active")
		
		interactable_area.is_interactable = false
		if audio_player:
			audio_player.play()
		await DialogueManager.dialogue_ended
		await get_tree().create_timer(1.0).timeout
		victory.emit()

func ajouter_partition() -> void:
	partitions_actuelles += 1
	
	if partitions_actuelles == 1:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "find_fragment_1")
	elif partitions_actuelles == 2:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "find_fragment_2")
	elif partitions_actuelles >= partitions_requises:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "find_fragment_3")
		unlock()

func unlock() -> void:
	is_locked = false
	if interactable_area:
		interactable_area.interact_name = "Play the melody"

func delete_sheets():
	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]
		if slot.item and slot.item.name == "Partition":
			slot.amount -= 3 
			if slot.amount <= 0:
				slot.item = null
				slot.amount = 0
			inventory.updated.emit()
			break
