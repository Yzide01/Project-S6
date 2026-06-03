class_name CombatManager
extends Control

signal action_selected(action_name: String)
signal intro_terminee
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

# --- AI for fight ---
var combat_turn_count: int = 0
var current_level_id: int = 1

signal answer_selected(is_correct: bool)

@onready var quiz_panel: Panel = $BottomUI/QuizPanel
@onready var question_text: Label = $BottomUI/QuizPanel/QuestionText
@onready var answers_container: VBoxContainer = $BottomUI/QuizPanel/AnswersContainer

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
	add_to_group("combat_manager")
	_reset_menu()
	
	attack_button.pressed.connect(_on_attack_pressed)
	run_button.pressed.connect(_on_run_pressed)
	percussion_button.pressed.connect(_on_percussion_pressed)
	vent_button.pressed.connect(_on_vent_pressed)
	corde_button.pressed.connect(_on_corde_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	call_deferred("_check_test_mode")

func _check_test_mode(level: int = 1) -> void:
	current_level_id = level
	if active_enemies.is_empty():
		var horde: Array[BaseEnemy] = []
		var intro_message = ""

		# --- LEVEL 1 : The Whisper alone ---
		if level >= 1:
			intro_message = "You only have your Strings, this attack doesn't deal much damage, but it lets you thin out the crowd—and who knows, maybe it'll scare them off\nThe Whisper is a fragile minion, but its silence is deadly."
			horde.append(_create_enemy_data("Whisper", 20, 1))

		# --- LEVEL 2 : We ADD the Silencer ---
		if level >= 2:
			intro_message = "You unlocked Percussions! Use Thunder Strike to shatter shields or deal heavy damage.\nWatch out for the Dampener. It looks sturdy and soundproof; I probably wouldn't do much damage to it, especially not while it has its shield up. But it looks slow to me, so I shouldn't take too much damage."
			horde.append(_create_enemy_data("Dampener", 40, 2))

		# --- LEVEL 3 : We ADD the Devourer ---
		if level >= 3:
			intro_message = "The final trial! You must face all three types of enemies at once. Use your Strings, Percussions, and your newly unlocked Winds to secure victory!"
			horde.append(_create_enemy_data("Devourer", 25, 3))

		# We launch the combat

		var unlocked_skills: Array[String] = ["corde"]
		if level >= 2:
			unlocked_skills.append("percussion")
		if level >= 3:
			unlocked_skills.append("vent")

		# We launch the combat
		start_encounter(horde, unlocked_skills, intro_message, level)
# Utility function to prevent code repetition during instance creation.
func _create_enemy_data(nom: String, hp: int, rank: int) -> BaseEnemy:
	var e = BaseEnemy.new()
	e.enemy_name = nom
	e.max_hp = hp
	e.rank = rank
	return e

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		intro_terminee.emit()
		
func start_encounter(horde: Array[BaseEnemy], skills: Array[String], intro_text: String, level_id: int = 1) -> void:
	available_skills = skills
	intro_message = intro_text
	active_enemies.clear()
	player_hp = player_max_hp
	player_resisting = 1.0
	player_silenced = false
	combat_turn_count = 0
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	update_ui()
	
	for child in enemy_container.get_children():
		child.queue_free()
	
	for enemy_data in horde:
		var enemy_ui = enemy_ui_scene.instantiate() as EnemyBattleUI
		enemy_container.add_child(enemy_ui)
		enemy_ui.setup(enemy_data.enemy_name, enemy_data.max_hp, enemy_data.enemy_name)
		
		if enemy_data.rank == 2:
			enemy_ui.enable_shield()
		
		active_enemies.append({
			"name": enemy_data.enemy_name,
			"hp": enemy_data.max_hp,
			"max_hp": enemy_data.max_hp,
			"stunned": false,
			"has_shield": enemy_data.rank == 2,
			"rank": enemy_data.rank,
			"ui_node": enemy_ui
		})
		
	# We hide all backgrounds
	$Backgrounds/level1.hide()
	$Backgrounds/level2.hide()
	$Backgrounds/level3.hide()
	# We display the right background
	if level_id == 1: $Backgrounds/level1.show()
	elif level_id == 2: $Backgrounds/level2.show()
	elif level_id == 3: $Backgrounds/level3.show()
		
	start_battle()

# --- fight loop ---
			# break
		# end_battle(true)
		# end_battle(false)

# --- fight loop ---# --- fight loop ---
func start_battle() -> void:
	if intro_message != "":
		var dark_bg = ColorRect.new()
		dark_bg.color = Color(0, 0, 0, 1.0)
		dark_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(dark_bg)
		
		var big_intro = Label.new()
		big_intro.text = "Silence minions are approaching...\n\n" + intro_message + "\n\n[ Click or press Space to continue ]"
		big_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		big_intro.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		big_intro.autowrap_mode = TextServer.AUTOWRAP_WORD
		big_intro.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		big_intro.offset_left = 100
		big_intro.offset_right = -100
		
		dark_bg.add_child(big_intro)
		
		dark_bg.modulate.a = 0.0
		var tween_in = create_tween()
		tween_in.tween_property(dark_bg, "modulate:a", 1.0, 0.5)
		await tween_in.finished
		
		await intro_terminee
		
		var tween_out = create_tween()
		tween_out.tween_property(dark_bg, "modulate:a", 0.0, 1.0)
		await tween_out.finished
		
		dark_bg.queue_free() 
	
	if get_alive_enemies_count() > 1:
		await display_text("A group of Silence Minions appears!")
	else:
		await display_text("A Silence Minion appears!")
	
	while player_hp > 0 and get_alive_enemies_count() > 0 and not escaped:
		await player_turn()
		
		if get_alive_enemies_count() <= 0 or escaped:
			break
			
		await enemy_turn()
		
	if escaped:
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
			var success = await ask_question("percussion", target.rank)
			
			if success:
				await display_text("Correct! The Bard uses Thunder Strike on " + target.name + "!")
				
				if target.has_shield:
					await display_text("The enemy's shield shatters!")
					target.has_shield = false
					
					if target.ui_node.has_method("play_shield_break"):          
						target.ui_node.play_shield_break()
					
				else:
					target.hp = max(0, target.hp - 15)
					await display_text(target.name + " loses 15 HP.")
					target.ui_node.update_hp(target.hp)
			else:
				await display_text("Wrong answer! The Bard hesitates and misses the tempo...")
				
		"vent":
			var target = get_first_alive_enemy()
			var success = await ask_question("vent", target.rank)
			
			if success:
				await display_text("Correct! The Bard sings a protective melody!")
				player_resisting += 0.5
				await display_text("Defense increased.")
			else:
				await display_text("Wrong answer! The Bard runs out of breath...")
				
		"corde":
			var target = get_first_alive_enemy()
			var success = await ask_question("corde", target.rank)
			
			if success:
				await display_text("Correct! The Bard plays a Distracting Melody! It hits EVERYONE!")
				for enemy in active_enemies:
					if enemy.hp > 0:
						if !enemy.has_shield:
							enemy.hp = max(0, enemy.hp - 5)
							enemy.ui_node.update_hp(enemy.hp)
							if randf() > 0.5:
								enemy.stunned = true
								await display_text(enemy.name + " is scared!")
							await display_text(enemy.name + " loses 5 HP.")
			else:
				await display_text("Wrong answer! The strings are out of tune...")
						
		"run":
			await display_text("You run away...")
			escaped = true 
			return

	update_ui()

# --- Enemy turn ---
func enemy_turn() -> void:
	combat_turn_count += 1
	
	for enemy in active_enemies:
		if enemy.hp <= 0:
			continue
			
		if enemy.stunned:
			await display_text(enemy.name + " is trembling with fear and passes their turn.")
			enemy.stunned = false
			continue
		
		var chosen_attack = get_utility_ai_decision(enemy)
		
		match chosen_attack:
			"white_noise":
				await display_text(enemy.name + " launches White Noise!")
				var degats = int(7 / player_resisting)
				if enemy.rank == 2: degats = int(3 / player_resisting)
				elif enemy.rank == 3: degats = int(12 / player_resisting)
					
				player_hp = max(0, player_hp - degats)
				update_ui()
				animate_player_damage()
				await display_text("You lose " + str(degats) + " HP.")
				
			"mute":
				await display_text(enemy.name + " casts Mute!")
				if randf() > 0.7:
					player_silenced = true
					await display_text("The Bard's voice is muffled!")
				else:
					await display_text("The Bard resists the silence.")
					
			"absolute_void":
				await display_text(enemy.name + " channels Absolute Void!")
				await display_text("The colors are being sucked away...")
				var degats = int(25 / player_resisting)
				player_hp = max(0, player_hp - degats)
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
		get_tree().paused = false 
		
		get_tree().reload_current_scene()

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
	
	if questions_list.is_empty():
		return true
	
	var question = questions_list.pick_random()
	
	question_text.text = question["q"]
	
	for child in answers_container.get_children():
		child.queue_free()
		
	for i in range(question["opts"].size()):
		var btn = Button.new()
		btn.text = question["opts"][i]
		var is_correct = (i == question["ans"])
		btn.pressed.connect(func(): answer_selected.emit(is_correct))
		answers_container.add_child(btn)
		
	quiz_panel.show()
	var success = await self.answer_selected
	quiz_panel.hide()
	
	if success:
		questions_list.erase(question)
	
	return success

func choose_target() -> Dictionary:
	if get_alive_enemies_count() == 1:
		return get_first_alive_enemy()
		
	info_text.text = "Choose a target!"

	question_text.text = "Select an enemy to attack:"

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
	

# --- AI ---

func get_utility_ai_decision(enemy: Dictionary) -> String:
	var best_action = "white_noise"
	var highest_score = -1.0
	
	var actions_scores = {}
	
	if enemy.rank >= 1:
		actions_scores["white_noise"] = evaluate_white_noise(enemy)
	if enemy.rank >= 2:
		actions_scores["mute"] = evaluate_mute(enemy)
	if enemy.rank >= 3:
		actions_scores["absolute_void"] = evaluate_absolute_void(enemy)
		
	for action in actions_scores:
		var score = actions_scores[action]
		score += randf_range(-5.0, 5.0)
		
		if score > highest_score:
			highest_score = score
			best_action = action
			
	return best_action

func evaluate_white_noise(enemy: Dictionary) -> float:
	var score = 50.0 

	if player_hp <= 15:
		score += 45.0
		
	return score

func evaluate_mute(enemy: Dictionary) -> float:
	var score = 0.0
	
	if not player_silenced:
		score = 80.0 
	else:
		score = 0.0 
		
	return score

func evaluate_absolute_void(enemy: Dictionary) -> float:
	var score = 0.0
	
	if combat_turn_count > 0 and combat_turn_count % 3 == 0:
		score = 100.0
		
	elif player_silenced:
		score = 85.0 
		
	return score
