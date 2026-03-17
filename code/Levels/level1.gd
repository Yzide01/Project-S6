extends Node2D

@onready var porte: InteractableObject = $String_Door 
@onready var corde1 = $string_1 
@onready var corde2 = $string_2
@onready var corde3 = $string_3
@onready var corde4 = $string_4
@onready var audio_player_door = $String_Door/AudioStreamPlayer2D


# La combinaison secrète
var combinaison_secrete: Array[int] = [1, 3, 2, 4] 
var sequence_jouee: Array[int] = [] 

# Variable pour empêcher le joueur de spammer la porte pendant que l'indice joue
var is_playing_hint: bool = false

func _ready() -> void:
	if porte:
		porte.is_interactable = true
		porte.is_locked = true       
		porte.is_open = false
		porte.hint_requested.connect(_on_door_hint_requested) 
		porte._update_door_state() 

	if corde1: corde1.corde_jouee.connect(_on_corde_jouee)
	if corde2: corde2.corde_jouee.connect(_on_corde_jouee)
	if corde3: corde3.corde_jouee.connect(_on_corde_jouee)
	if corde4: corde4.corde_jouee.connect(_on_corde_jouee)

func _on_corde_jouee(note_id: int) -> void:
	# Si une animation (indice ou erreur) est en cours, on bloque les clics
	if is_playing_hint:
		return 
		
	# 1. On enregistre la note
	sequence_jouee.append(note_id)
	
	# 2. On allume TOUJOURS la corde que le joueur vient de toucher
	match note_id:
		1: if corde1: corde1.set_progressive_glow(true)
		2: if corde2: corde2.set_progressive_glow(true)
		3: if corde3: corde3.set_progressive_glow(true)
		4: if corde4: corde4.set_progressive_glow(true)
		
	# 3. On vérifie SI le joueur a fini d'entrer ses 4 notes
	if sequence_jouee.size() == combinaison_secrete.size():
		
		# On verrouille temporairement la porte et les cordes
		is_playing_hint = true 
		
		# On compare les deux tableaux directement
		if sequence_jouee == combinaison_secrete:
			print("Mélodie correcte ! Ouverture de la porte...")
			_ouvrir_la_porte()
		else:
			print("Mauvaise combinaison ! On efface tout.")
			# On attend une demi-seconde pour que le joueur voie sa 4ème corde s'allumer
			await get_tree().create_timer(0.6).timeout 
			
			# On éteint toutes les cordes et on vide la mémoire
			_reset_progressive_glows()
			sequence_jouee.clear()
			
		# On déverrouille pour qu'il puisse réessayer
		is_playing_hint = false

# Nouvelle fonction pour éteindre toutes les cordes d'un coup
func _reset_progressive_glows() -> void:
	if corde1: corde1.set_progressive_glow(false)
	if corde2: corde2.set_progressive_glow(false)
	if corde3: corde3.set_progressive_glow(false)
	if corde4: corde4.set_progressive_glow(false)

func _ouvrir_la_porte() -> void:
	if porte:
		porte.is_locked = false
		porte.is_open = true 
		porte._update_door_state() 
		
		# On désactive les cordes une fois terminé
		if corde1: corde1.is_interactable = false
		if corde2: corde2.is_interactable = false
		if corde3: corde3.is_interactable = false
		if corde4: corde4.is_interactable = false
		
		
# --- LA FONCTION DE L'INDICE ---
func _on_door_hint_requested() -> void:
	if is_playing_hint:
		return
		
	is_playing_hint = true
	sequence_jouee.clear() 
	
	# --- On éteint les cordes pour jouer l'indice proprement ---
	_reset_progressive_glows()
	
	# (Optionnel : On pourrait allumer les cordes une par une ici aussi)
	
	audio_player_door.play()
	
	# On attend la fin du son (environ 3 secondes ici pour l'exemple, à ajuster)
	await get_tree().create_timer(3.0).timeout
	is_playing_hint = false
