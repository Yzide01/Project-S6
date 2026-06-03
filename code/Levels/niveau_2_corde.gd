extends Node2D

@export var battle_scene_packed: PackedScene

@onready var book_page = $decoration/BookPage
@onready var piano = $decoration/Piano
@onready var exit = $Exit
@onready var interact_exit = $Exit/Interactable
@onready var spirit_sprite = $Spirit 

@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
var current_battle_scene: Node = null
var has_spoken_about_zone: bool = false
var page_collected: bool = false
@onready var inventory: Inventory = preload("res://Core/InventorySystem/playerInventory.tres")
@onready var vial: InventoryItem = preload("res://Core/InventorySystem/items/Vial.tres")

func _ready() -> void:
	if piano:
		piano.victory.connect(_victory)
		
	if exit:
		exit.start_level_combat.connect(_on_exit_interacted_for_combat)
		
	if spirit_sprite:
		spirit_sprite.hide()
		spirit_sprite.modulate.a = 0.0

# --- PIANO VICTORY ---
func _victory():
	if book_page:
		book_page.victory()
		
		await book_page.page_picked
		page_collected = true
		
			
		await get_tree().create_timer(2).timeout
		
		await _play_dialogue_async("page_collected")
		
		exit.unlock()

var won = false

# --- WHEN PLAYER CLICKS EXIT ---
func _on_exit_interacted_for_combat() -> void:
	if won == true:
		SceneManager.changer_niveau("res://Levels/niveau1_percussion.tscn")
		return
	if page_collected:
		await start_combat(1)

func start_combat(niveau_id: int) -> void:
	if not is_inside_tree(): return
	
	get_tree().paused = true
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	
	current_battle_scene = battle_scene_packed.instantiate()
	current_battle_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	ui_layer.add_child(current_battle_scene)
	
	current_battle_scene._check_test_mode(niveau_id)
	
	await current_battle_scene.tree_exited
	
	if is_instance_valid(ui_layer):
		ui_layer.queue_free()
	
	current_battle_scene = null
	
	if not is_inside_tree() or is_queued_for_deletion():
		return
	
	get_tree().paused = false

	exit.hide()

	if interact_exit:
		interact_exit.is_interactable = false

	var p = get_tree().get_first_node_in_group("Player")
	if p: p.set_physics_process(false)
	
	if spirit_sprite:
		spirit_sprite.show()
		var tw = create_tween()
		tw.tween_property(spirit_sprite, "modulate:a", 1.0, 0.5)
		await tw.finished
	
	await _play_dialogue_async("reconnaissance")
	
	if inventory and vial:
		inventory.insert(vial)
		
	if spirit_sprite:
		var tw2 = create_tween()
		tw2.tween_property(spirit_sprite, "modulate:a", 0.0, 0.5)
		await tw2.finished
		spirit_sprite.hide()
	if p: p.set_physics_process(true)
	won = true
	exit.show()

	if interact_exit:
		interact_exit.is_interactable = true
	

# --- EXPLORATION ZONE ---
func _on_exploration_zone_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.is_in_group("Player")) and not has_spoken_about_zone:
		has_spoken_about_zone = true
		_play_dialogue("explore_zone")


# --- DIALOGUE FUNCTIONS ---

# --- DIALOGUE FUNCTIONS ---

func _play_dialogue(section_name: String):
	var diag_path = "res://Dialogues/Level2/level2.dialogue"
	var dialogue_res = load(diag_path)
	
	if dialogue_res:
		DialogueManager.show_example_dialogue_balloon(dialogue_res, section_name)
	else:
		push_error("Dialogue introuvable: ", diag_path)

func _play_dialogue_async(section_name: String):
	var diag_path = "res://Dialogues/Level2/level2.dialogue"
	var dialogue_res = load(diag_path)
	
	if dialogue_res:
		DialogueManager.show_example_dialogue_balloon(dialogue_res, section_name)
		await DialogueManager.dialogue_ended
	else:
		push_error("Dialogue introuvable: ", diag_path)

# --- LEVEL STATE SAVE MANAGEMENT ---
func get_level_state() -> Dictionary:
	return {
		"page_collected": page_collected,
		"won": won
	}

func restore_level_state(state: Dictionary) -> void:
	page_collected = state.get("page_collected", false)
	won = state.get("won", false)
	
	if not page_collected:
		if inventory:
			for slot in inventory.slots:
				if slot and slot.item and slot.item.name == "Partition":
					slot.item = null
					slot.amount = 0
			inventory.updated.emit()
	
	if page_collected:
		if exit: exit.unlock()
		if book_page: book_page.queue_free()
		
	if won:
		if exit: exit.show()
		if interact_exit: interact_exit.is_interactable = true
