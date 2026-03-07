extends CharacterBody2D

# --- Noeuds enfants ---
@onready var interact_ray: RayCast2D = $RayCast2D

# --- Vitesses de déplacement ---
@export var normal_speed: float = 200.0
@export var crawl_speed: float = 100.0
@export var sprint_speed: float = 300.0
@export var interact_distance: float = 100.0

# --- Machine à états simple ---
enum State {NORMAL, CRAWLING, SPRINT}
var current_state: State = State.NORMAL

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("crawl"):
		current_state = State.CRAWLING
	elif Input.is_action_pressed("sprint"):
		current_state = State.SPRINT
	else:
		current_state = State.NORMAL

	var active_speed: float = normal_speed
	match current_state:
		State.CRAWLING:
			active_speed = crawl_speed
		State.SPRINT:
			active_speed = sprint_speed

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		interact_ray.target_position = direction.normalized() * interact_distance
	
	velocity = direction * active_speed
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
	
	# --- TOUCHES DE TEST ---
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				InventoryManager.add_item("Fiole_Test", 1)
			KEY_2:

				InventoryManager.use_item("Fiole_Test", self)
			KEY_F5:

				SaveManager.save_game()
			KEY_F9:
				SaveManager.load_game()
