extends Node2D

var is_solved: bool = false

@onready var wheel = $wheel
@onready var altar_door = $altar

func _ready() -> void:
	# L'autel est bloqué au début
	if altar_door and altar_door.has_node("Interactable"):
		var int_comp = altar_door.get_node("Interactable")
		int_comp.interact_name = "Bridge unsafe. Fix the air pressure first."
		int_comp.is_interactable = false

	# On écoute les signaux de la roue
	if wheel:
		wheel.pressure_stabilized.connect(_on_pressure_stable)
		wheel.pressure_destabilized.connect(_on_pressure_unstable)

	_play_intro_dialogue()

func _play_intro_dialogue():
	print("--- INTRO SEQUENCE ---")
	print("Wind Spirit: 'Guardian, we must reach the altar. Those floating drums can act as a bridge, but they are held up by air currents from the chasm.'")
	print("Wind Spirit: 'That wooden wheel acts as a manual bellows. But human arms grow tired, and the rhythm breaks. Manual pressure is too chaotic to hold your weight.'")
	print("Wind Spirit: 'You must find a way to use the mountain's internal water flow. If you connect the water to the mechanism, its constant weight will push the air perfectly evenly. This is the secret of the Hydraulis!'")

func _on_pressure_unstable():
	# Si le joueur repasse en mode manuel ou éteint, on rebloque la fin
	if altar_door and altar_door.has_node("Interactable"):
		var int_comp = altar_door.get_node("Interactable")
		int_comp.interact_name = "Bridge unsafe. Fix the air pressure first."
		int_comp.is_interactable = false
		int_comp.interact = func(): pass
		
	if is_solved:
		is_solved = false
		print("Wind Spirit: 'The pressure is chaotic again! The drums are wobbling!'")

func _on_pressure_stable():
	if not is_solved:
		is_solved = true
		_play_victory_sequence()

func _play_victory_sequence():
	print("--- VICTORY SEQUENCE ---")
	print("*The floating drums align perfectly, supported by a flawless pillar of stable air.*")
	print("Wind Spirit: 'Incredible! By using the water, gravity pulls down with a constant force, pushing the air up with perfectly stable pressure. The bridge is safe to cross!'")
	
	print("--- SERIOUS GAME PANEL UI ---")
	print("Concept Validated: The Hydraulis & Stable Pressure")
	print("Before electric motors, generating a constant flow of air was incredibly difficult. Manual bellows fluctuated with human fatigue. The ancient 'Hydraulis' solved this by using a column of water: the constant weight of the water guarantees perfectly stable air pressure!")
	
	# On débloque l'autel pour finir le niveau
	if altar_door and altar_door.has_node("Interactable"):
		var int_comp = altar_door.get_node("Interactable")
		int_comp.is_interactable = true
		int_comp.interact_name = "Enter the Altar"
		int_comp.interact = func(): print("Level 4 Complete! Moving to Level 5...")
