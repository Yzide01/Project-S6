extends CharacterBody2D

# --- Noeuds enfants ---
@onready var interact_ray: RayCast2D = $RayCast2D

# --- Vitesses de déplacement ---
@export var normal_speed: float = 300.0
@export var crawl_speed: float = 200.0
@export var sprint_speed: float = 400.0
@export var interact_distance: float = 100.0

# --- Fluidité du mouvement ---
@export var acceleration: float = 10.0

# --- Machine à états simple ---
enum State {NORMAL, CRAWLING, SPRINT}
var current_state: State = State.NORMAL


func _physics_process(delta: float) -> void:

	# --- Gestion des états ---
	if Input.is_action_pressed("crawl"):
		current_state = State.CRAWLING
	elif Input.is_action_pressed("sprint"):
		current_state = State.SPRINT
	else:
		current_state = State.NORMAL

	# --- Choix de la vitesse ---
	var active_speed: float = normal_speed
	match current_state:
		State.CRAWLING:
			active_speed = crawl_speed
		State.SPRINT:
			active_speed = sprint_speed

	# --- Direction du joueur ---
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# --- Direction du raycast pour interaction ---
	if direction != Vector2.ZERO:
		interact_ray.target_position = direction.normalized() * interact_distance

	# --- Vitesse cible ---
	var desired_velocity = direction * active_speed

	# --- Déplacement fluide ---
	velocity = velocity.lerp(desired_velocity, acceleration * delta)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("climb"):
		print("Le joueur essaie de grimper ou d'interagir")

	if event.is_action_pressed("interact"):
		interact_ray.force_raycast_update()
		if interact_ray.is_colliding():
			var target = interact_ray.get_collider()
			if target is InteractableObject:
				print("Objet interactif détecté !")
				target.interact(self)
		else:
			print("Il n'y a rien devant moi.")
