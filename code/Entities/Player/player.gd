class_name Player extends CharacterBody2D


# --- Movement speeds ---
@export var normal_speed: float = 150
@export var crawl_speed: float = 50
@export var sprint_speed: float = 200
@export var interact_distance: float = 10

# --- Movement smoothing ---
@export var acceleration: float = 10.0

# --- Inventory ---
@export var inventory: Inventory

# --- Animation ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- State machine ---
enum State { NORMAL, CRAWLING, SPRINT }
var current_state: State = State.NORMAL

# --- Remember last direction for idle ---
var last_direction: Vector2 = Vector2.DOWN


func _ready():
	inventory.use_item.connect(use_item)


func _physics_process(delta: float) -> void:

	# --- State handling ---
	if Input.is_action_pressed("crawl"):
		current_state = State.CRAWLING
	elif Input.is_action_pressed("sprint"):
		current_state = State.SPRINT
	else:
		current_state = State.NORMAL

	# --- Speed selection ---
	var active_speed: float = normal_speed
	match current_state:
		State.CRAWLING:
			active_speed = crawl_speed
		State.SPRINT:
			active_speed = sprint_speed

	# --- Input direction ---
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Save last direction if moving
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()

	update_animation(direction)

	# --- Movement ---
	var desired_velocity = direction * active_speed
	velocity = velocity.lerp(desired_velocity, acceleration * delta)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("climb"):
		print("Le joueur essaie d'interagir")


func use_item(item: InventoryItem) -> void:
	item.use(self)


func update_animation(direction: Vector2) -> void:
	var is_idle = direction.length() < 0.1
	var dir_to_use = last_direction if is_idle else direction

	# calculate angle
	var angle = int(snapped(rad_to_deg(dir_to_use.angle()), 45))

	var anim_name = ""

	# match animation
	match angle:
		0: 
			anim_name = "right"
		45: 
			anim_name = "right" 
		90: 
			anim_name = "down"
		135: 
			anim_name = "left"
		180, -180: 
			anim_name = "left"
		-135: 
			anim_name = "up_left"
		-90: 
			anim_name = "up"
		-45: 
			anim_name = "up_right"

	# idle if player is not moving anymore
	if is_idle:
		anim.play("idle_" + anim_name)
	else:
		anim.play(anim_name)


	# Ajuster la vitesse de l'animation selon l'état
	match current_state:
		State.CRAWLING:
			anim.speed_scale = 0.7  # Ralentit l'anim
		State.SPRINT:
			anim.speed_scale = 1.5  # Accélère l'anim
		State.NORMAL:
			anim.speed_scale = 1.0  # Vitesse normale
