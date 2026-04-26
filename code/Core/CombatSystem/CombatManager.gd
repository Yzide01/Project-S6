class_name CombatManager
extends Control

signal action_selected(action_name: String)

@onready var info_text: Label = $BottomUI/InfoText

# Main menu
@onready var attack_button: Button = $BottomUI/AttackButton
@onready var run_button: Button = $BottomUI/RunButton

# Attack menu
@onready var percussion_button: Button = $BottomUI/PercussionButton
@onready var vent_button: Button = $BottomUI/VentButton
@onready var corde_button: Button = $BottomUI/CordeButton
@onready var back_button: Button = $BottomUI/Back

@onready var enemy_container: HBoxContainer = $EnemyContainer
@export var enemy_ui_scene: PackedScene

@onready var player_visual: TextureRect = $PlayerVisual

# HP bar
@onready var player_hp_bar: TextureProgressBar = $PlayerHPBar

# --- Fight variables ---
var player_max_hp: int = 100
var player_hp: int = 55
var player_resisting: float = 1.0

var player_silenced: bool = false

var active_enemies: Array[Dictionary] = []

func _ready() -> void:
	_reset_menu()
	
	attack_button.pressed.connect(_on_attack_pressed)
	run_button.pressed.connect(_on_run_pressed)
	percussion_button.pressed.connect(_on_percussion_pressed)
	vent_button.pressed.connect(_on_vent_pressed)
	corde_button.pressed.connect(_on_corde_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# --- DÉBUT DU TEST EN ISOLATION ---
	
	var whisper_data = load("res://Entities/Enemies/whisper.tres")
	var dampener_data = load("res://Entities/Enemies/dampener.tres")
	
	# 4. Lancement du combat
	if whisper_data and dampener_data:
		print("Lancement du combat de test...")
		start_encounter([whisper_data, dampener_data])
	else:
		print("ERREUR : Les fichiers d'ennemis sont introuvables. Vérifie les chemins.")
		
	# --- FIN DU TEST EN ISOLATION ---

func start_encounter(horde: Array[BaseEnemy]) -> void:
	active_enemies.clear()
	player_hp = player_max_hp
	player_resisting = 1.0
	player_silenced = false
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	update_ui()
	
	for child in enemy_container.get_children():
		child.queue_free()
	
	for enemy_data in horde:
		var enemy_ui = enemy_ui_scene.instantiate() as EnemyBattleUI
		enemy_container.add_child(enemy_ui)
		enemy_ui.setup(enemy_data.enemy_name, enemy_data.max_hp, enemy_data.texture)
		
		active_enemies.append({
			"name": enemy_data.enemy_name,
			"hp": enemy_data.max_hp,
			"max_hp": enemy_data.max_hp,
			"stunned": false,
			"has_shield": enemy_data.rank >= 2,
			"rank": enemy_data.rank,
			"ui_node": enemy_ui
		})
		
	start_battle()

# --- fight loop ---
func start_battle() -> void:
	if get_alive_enemies_count() > 1:
		await display_text("A group of Silence Minions appears!")
	else:
		await display_text("A Silence Minion appears!")
	
	while player_hp > 0 and get_alive_enemies_count() > 0:
		await player_turn()
		
		if get_alive_enemies_count() <= 0:
			break
			
		await enemy_turn()
		
	if player_hp > 0:
		await display_text("Victory! Music is back in the spotlight.")
		end_battle(true)
	else:
		var tween = create_tween()
		tween.tween_property(player_visual, "modulate:a", 0.0, 1.0)
		await display_text("Defeat... Silence has engulfed you.")
		end_battle(false)

# --- Player turn ---
func player_turn() -> void:
	if player_silenced:
		await display_text("The Bard is silenced and cannot play music this turn!")
		player_silenced = false
		return
	
	await display_text("What should the Bard do?")
	
	attack_button.show()
	run_button.show()
	
	var chosen_action = await self.action_selected 
	_reset_menu()
	
	match chosen_action:
		"percussion":
			var target = get_first_alive_enemy()
			await display_text("The Bard uses Thunder Strike on " + target.name + "!")
			if target.has_shield:
				await display_text("The enemy's shield shatters!")
				target.has_shield = false
			else:
				target.hp -= 15
				await display_text(target.name + " loses 15 HP.")
				target.ui_node.update_hp(target.hp)
				
		"vent":
			await display_text("The Bard sings a protective melody!")
			player_resisting += 0.5
			await display_text("Defense increased.")
			
		"corde":
			await display_text("The Bard plays a Distracting Melody! It hits EVERYONE!")
			for enemy in active_enemies:
				if enemy.hp > 0:
					if !enemy.has_shield:
						enemy.hp -= 5
						enemy.ui_node.update_hp(enemy.hp)
						if randf() > 0.5:
							enemy.stunned = true
							await display_text(enemy.name + " is scared!")
						await display_text(enemy.name + " loses 5 HP.")
						
		"run":
			await display_text("You run away...")
			player_hp = 0

	update_ui()

# --- Enemy turn ---
func enemy_turn() -> void:
	for enemy in active_enemies:
		if enemy.hp <= 0:
			continue
			
		if enemy.stunned:
			await display_text(enemy.name + " is trembling with fear and passes their turn.")
			enemy.stunned = false
			continue
		
		var possible_attacks = []
		if enemy.rank >= 1:
			possible_attacks.append("white_noise")
		if enemy.rank >= 2:
			possible_attacks.append("mute")
		if enemy.rank >= 3:
			possible_attacks.append("absolute_void")
			
		var chosen_attack = possible_attacks.pick_random()
		
		match chosen_attack:
			"white_noise":
				await display_text(enemy.name + " launches White Noise!")
				var degats = int(7 / player_resisting)
				if enemy.rank == 2:
					degats = int(3 / player_resisting)
				player_hp -= degats
				update_ui()
				animate_player_damage()
				await display_text("You lose " + str(degats) + " HP.")
				
			"mute":
				await display_text(enemy.name + " casts Mute!")
				if randf() > 0.3:
					player_silenced = true
					await display_text("The Bard's voice is muffled!")
				else:
					await display_text("The Bard resists the silence.")
					
			"absolute_void":
				await display_text(enemy.name + " channels Absolute Void!")
				await display_text("The colors are being sucked away...")
				var degats = int(25 / player_resisting)
				player_hp -= degats
				update_ui()
				animate_player_damage()
				await display_text("You lose a massive " + str(degats) + " HP.")
		
		if player_hp <= 0:
			break

# --- Utilities ---
func update_ui() -> void:
	var tween = create_tween()
	tween.tween_property(player_hp_bar, "value", float(player_hp), 0.3)

func get_alive_enemies_count() -> int:
	var count = 0
	for enemy in active_enemies:
		if enemy.hp > 0:
			count += 1
	return count

func get_first_alive_enemy() -> Dictionary:
	for enemy in active_enemies:
		if enemy.hp > 0:
			return enemy
	return active_enemies[0]

func animate_player_damage() -> void:
	var tween = create_tween()
	tween.tween_property(player_visual, "modulate", Color.RED, 0.1)
	tween.tween_property(player_visual, "modulate", Color.WHITE, 0.1)
	tween.set_loops(2)
	
func end_battle(player_won: bool) -> void:
	await get_tree().create_timer(1.0).timeout 
	
	if player_won:
		queue_free()
	else:
		get_tree().reload_current_scene()

# --- Display ---
func display_text(text_to_show: String) -> void:
	info_text.text = text_to_show
	await get_tree().create_timer(1.5).timeout

# --- Buttons ---
func _on_percussion_pressed(): action_selected.emit("percussion")
func _on_vent_pressed(): action_selected.emit("vent")
func _on_corde_pressed(): action_selected.emit("corde")
func _on_run_pressed(): action_selected.emit("run")
	
func _on_attack_pressed() -> void:
	attack_button.hide()
	run_button.hide()
	percussion_button.show()
	vent_button.show()
	corde_button.show()
	back_button.show()
	info_text.text = "Choose an instrument:"

func _on_back_pressed() -> void:
	_reset_menu()
	await display_text("What should the Bard do?")

func _reset_menu() -> void:
	percussion_button.hide()
	vent_button.hide()
	corde_button.hide()
	back_button.hide()
	attack_button.hide()
	run_button.hide()
