extends Node2D

@onready var porte: InteractableObject = $String_Door 
@onready var corde1 = $string_1 
@onready var corde2 = $string_2
@onready var corde3 = $string_3
@onready var corde4 = $string_4
@onready var audio_player = $String_Door/AudioStreamPlayer2D


# La nouvelle combinaison secrète
var combinaison_secrete: Array[int] = [1, 3, 2, 4] 
var sequence_jouee: Array[int] = [] 

# Variable pour empêcher le joueur de spammer la porte pendant que l'indice joue
var is_playing_hint: bool = false

func _ready() -> void:
	if porte:
		porte.is_interactable = true # La porte DOIT être interactable pour donner l'indice !
		porte.is_locked = true       # Mais elle est verrouillée
		porte.is_open = false
		porte.hint_requested.connect(_on_door_hint_requested) # On écoute la porte
		porte._update_door_state() 

	if corde1: corde1.corde_jouee.connect(_on_corde_jouee)
	if corde2: corde2.corde_jouee.connect(_on_corde_jouee)
	if corde3: corde3.corde_jouee.connect(_on_corde_jouee)
	if corde4: corde4.corde_jouee.connect(_on_corde_jouee)

func _on_corde_jouee(note_id: int) -> void:
	if is_playing_hint:
		return # On ignore les clics si l'indice est en train d'être joué
		
	sequence_jouee.append(note_id)
	var index_courant = sequence_jouee.size() - 1
	
	if sequence_jouee[index_courant] != combinaison_secrete[index_courant]:
		print("Fausse note ! On recommence.")
		sequence_jouee.clear() 
		return
		
	if sequence_jouee.size() == combinaison_secrete.size():
		print("Mélodie correcte ! Ouverture de la porte...")
		_ouvrir_la_porte()


func _ouvrir_la_porte() -> void:
	if porte:
		porte.is_locked = false # On déverrouille le cadenas de l'énigme
		
		# --- LA MODIFICATION EST ICI ---
		# Au lieu de simuler une interaction, on FORCE la porte à s'ouvrir :
		porte.is_open = true 
		porte._update_door_state() 
		# -------------------------------
		
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
	sequence_jouee.clear() # On réinitialise la tentative du joueur pour éviter les bugs
	audio_player.play()
	is_playing_hint = false
