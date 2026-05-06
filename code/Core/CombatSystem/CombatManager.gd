class_name CombatManager
extends Control

signal action_selected(action_name: String)
var escaped: bool = false
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
@onready var player_hp_text: Label = $PlayerHPBar/PlayerHPText

# --- Fight variables ---
var player_max_hp: int = 100
var player_hp: int = 55
var player_resisting: float = 1.0

var player_silenced: bool = false

var active_enemies: Array[Dictionary] = []

var available_skills: Array[String] = []
var intro_message: String = ""
signal target_selected(enemy_index: int)

signal answer_selected(is_correct: bool)

@onready var quiz_panel: Panel = $BottomUI/QuizPanel
@onready var question_text: Label = $BottomUI/QuizPanel/QuestionText
@onready var answers_container: VBoxContainer = $BottomUI/QuizPanel/AnswersContainer

# La base de données de tes questions (bien rangée !)
var quiz_data = {
	"corde": {
		1: [
			{"q": "To get a lower (bass) sound, the string must be...", "opts": ["Longer", "Shorter"], "ans": 0},
			{"q": "A very short string produces a sound that is...", "opts": ["High-pitched", "Deep", "Silent"], "ans": 0},
			{"q": "True or False: Changing a string's length changes its note.", "opts": ["True", "False"], "ans": 0}
		],
		2: [
			{"q": "If you cut a string's length in half, the sound becomes...", "opts": ["Higher", "Lower", "It stays the same"], "ans": 0},
			{"q": "Slow and wide waves correspond to which type of sound?", "opts": ["Bass", "Treble"], "ans": 0},
			{"q": "The faster a string vibrates, the _______ the pitch.", "opts": ["Higher", "Lower"], "ans": 0}
		],
		3: [
			{"q": "What is the scientific term for the number of vibrations per second?", "opts": ["Frequency", "Amplitude", "Velocity"], "ans": 0}
		]
	},
	"percussion": {
		1: [
			{"q": "Which object naturally produces the deepest sound?", "opts": ["A large drum", "A small triangle"], "ans": 0},
			{"q": "True or False: Percussion instruments must be struck to create sound.", "opts": ["True", "False"], "ans": 0},
			{"q": "A small bell produces a sound that is _______ than a large bass drum.", "opts": ["Higher", "Lower"], "ans": 0}
		],
		2: [
			{"q": "To break a shield, the vibration should be...", "opts": ["Slow and powerful", "Fast and weak", "Silent"], "ans": 0},
			{"q": "If a drum skin is tightened, the pitch becomes...", "opts": ["Higher", "Lower", "Deeper"], "ans": 0},
			{"q": "Which material resonates best to break the Silence?", "opts": ["Metal", "Wood", "Cotton"], "ans": 0}
		],
		3: [
			{"q": "Which physical phenomenon allows a strike to make an enemy tremble?", "opts": ["Resonance", "Combustion", "Gravity"], "ans": 0}
		]
	},
	"vent": {
		1: [
			{"q": "In a flute, what is actually vibrating to create the sound?", "opts": ["The air inside", "The wood/metal body", "The player's fingers"], "ans": 0},
			{"q": "To play a louder note, the Bard must increase...", "opts": ["Air pressure (Breath)", "Finger speed"], "ans": 0},
			{"q": "True or False: A very long wind instrument produces a high-pitched sound.", "opts": ["True", "False"], "ans": 1}
		],
		2: [
			{"q": "By covering holes on a flute, you make the air column...", "opts": ["Longer", "Shorter"], "ans": 0},
			{"q": "A short air column vibrates _______ than a long one.", "opts": ["Faster", "Slower"], "ans": 0},
			{"q": "What protects the Bard from enemy shockwaves?", "opts": ["Air pressure", "String length", "Drum weight"], "ans": 0}
		],
		3: [
			{"q": "What is the technique called when you blow harder to reach a higher octave?", "opts": ["Overblowing (Octaviation)", "Muting", "Distortion"], "ans": 0}
		]
	}
}


func _ready() -> void:
	_reset_menu()
	
	attack_button.pressed.connect(_on_attack_pressed)
	run_button.pressed.connect(_on_run_pressed)
	percussion_button.pressed.connect(_on_percussion_pressed)
	vent_button.pressed.connect(_on_vent_pressed)
	corde_button.pressed.connect(_on_corde_pressed)
	back_button.pressed.connect(_on_back_pressed)
	

func start_encounter(horde: Array[BaseEnemy], skills: Array[String], intro_text: String) -> void:
	available_skills = skills
	intro_message = intro_text
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
	if intro_message != "":
		await display_text(intro_message)
		await get_tree().create_timer(3).timeout
	
	if get_alive_enemies_count() > 1:
		await display_text("A group of Silence Minions appears!")
	else:
		await display_text("A Silence Minion appears!")
	
	# Ajout de "and not escaped"
	while player_hp > 0 and get_alive_enemies_count() > 0 and not escaped:
		await player_turn()
		
		# On arrête tout si les ennemis sont morts OU si on a fui
		if get_alive_enemies_count() <= 0 or escaped:
			break
			
		await enemy_turn()
		
	if escaped:
		# Si on a fui, on détruit juste la scène de combat pour retourner au jeu
		queue_free()
	elif player_hp > 0:
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
			var target = await choose_target()
			# Le jeu se met en pause et affiche le QCM de percussions
			var success = await ask_question("percussion", target.rank)
			
			if success:
				await display_text("Correct! The Bard uses Thunder Strike on " + target.name + "!")
				if target.has_shield:
					await display_text("The enemy's shield shatters!")
					target.has_shield = false
				else:
					target.hp -= 15
					await display_text(target.name + " loses 15 HP.")
					target.ui_node.update_hp(target.hp)
			else:
				await display_text("Wrong answer! The Bard hesitates and misses the tempo...")
				
		"vent":
			var target = get_first_alive_enemy()
			# On utilise le rang d'un ennemi pour la difficulté de la question de vent
			var success = await ask_question("vent", target.rank)
			
			if success:
				await display_text("Correct! The Bard sings a protective melody!")
				player_resisting += 0.5
				await display_text("Defense increased.")
			else:
				await display_text("Wrong answer! The Bard runs out of breath...")
				
		"corde":
			var target = get_first_alive_enemy()
			# On utilise le rang d'un ennemi pour la difficulté de la question de cordes
			var success = await ask_question("corde", target.rank)
			
			if success:
				await display_text("Correct! The Bard plays a Distracting Melody! It hits EVERYONE!")
				for enemy in active_enemies:
					if enemy.hp > 0:
						if !enemy.has_shield:
							enemy.hp -= 5
							enemy.ui_node.update_hp(enemy.hp)
							if randf() > 0.5:
								enemy.stunned = true
								await display_text(enemy.name + " is scared!")
							await display_text(enemy.name + " loses 5 HP.")
			else:
				await display_text("Wrong answer! The strings are out of tune...")
						
		"run":
			await display_text("You run away...")
			escaped = true # Assure-toi d'avoir ajouté 'var escaped: bool = false' tout en haut du script !
			return # On quitte le tour immédiatement pour ne pas crasher

	update_ui()
#
## --- Player turn ---
#func player_turn() -> void:
	#if player_silenced:
		#await display_text("The Bard is silenced and cannot play music this turn!")
		#player_silenced = false
		#return
	#
	#await display_text("What should the Bard do?")
	#
	#attack_button.show()
	#run_button.show()
	#
	#var chosen_action = await self.action_selected 
	#_reset_menu()
	#
	#match chosen_action:
		#"percussion":
			#var target = get_first_alive_enemy()
			#await display_text("The Bard uses Thunder Strike on " + target.name + "!")
			#if target.has_shield:
				#await display_text("The enemy's shield shatters!")
				#target.has_shield = false
			#else:
				#target.hp -= 15
				#await display_text(target.name + " loses 15 HP.")
				#target.ui_node.update_hp(target.hp)
				#
		#"vent":
			#await display_text("The Bard sings a protective melody!")
			#player_resisting += 0.5
			#await display_text("Defense increased.")
			#
		#"corde":
			#await display_text("The Bard plays a Distracting Melody! It hits EVERYONE!")
			#for enemy in active_enemies:
				#if enemy.hp > 0:
					#if !enemy.has_shield:
						#enemy.hp -= 5
						#enemy.ui_node.update_hp(enemy.hp)
						#if randf() > 0.5:
							#enemy.stunned = true
							#await display_text(enemy.name + " is scared!")
						#await display_text(enemy.name + " loses 5 HP.")
						#
		#"run":
			#await display_text("You run away...")
			#escaped = true
			#return
#
	#update_ui()

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
	if player_hp_text:
		player_hp_text.text = str(player_hp) + " / " + str(player_max_hp)

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

	back_button.show()
	info_text.text = "Choose an instrument:"
	
	if "percussion" in available_skills:
		percussion_button.show()
	if "vent" in available_skills:
		vent_button.show()
	if "corde" in available_skills:
		corde_button.show()

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
	
	
func ask_question(category: String, rank: int) -> bool:
	var questions_list = quiz_data[category][rank]
	var question = questions_list.pick_random()
	
	question_text.text = question["q"]
	
	# On nettoie les vieux boutons
	for child in answers_container.get_children():
		child.queue_free()
		
	# On génère les boutons de réponses
	for i in range(question["opts"].size()):
		var btn = Button.new()
		btn.text = question["opts"][i]
		var is_correct = (i == question["ans"])
		# Quand on clique, ça envoie le signal avec True ou False
		btn.pressed.connect(func(): answer_selected.emit(is_correct))
		answers_container.add_child(btn)
		
	quiz_panel.show()
	var success = await self.answer_selected # On met le code en pause jusqu'au clic !
	quiz_panel.hide()
	
	return success

func choose_target() -> Dictionary:
	if get_alive_enemies_count() == 1:
		return get_first_alive_enemy()
		
	info_text.text = "Choose a target!"

	for child in answers_container.get_children():
		child.queue_free()

	for i in range(active_enemies.size()):
		var enemy = active_enemies[i]
		if enemy.hp > 0:
			var btn = Button.new()
			btn.text = enemy.name
			btn.set_meta("index", i)
			btn.pressed.connect(func(): target_selected.emit(btn.get_meta("index")))
			answers_container.add_child(btn)
			
	quiz_panel.show()
	var chosen_index = await self.target_selected
	quiz_panel.hide()
	
	return active_enemies[chosen_index]
