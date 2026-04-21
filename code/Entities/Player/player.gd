class_name Player extends CharacterBody2D
# --- Textures Directionnelles ---
@export var tex_bas: Texture2D
@export var tex_haut: Texture2D
@export var tex_droite: Texture2D
@export var tex_bas_droite: Texture2D
@export var tex_haut_droite: Texture2D

# --- Noeuds enfants ---
@onready var interact_ray: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D # Ajout de la référence au Sprite2D

# --- Movement speeds ---
@export var normal_speed: float = 150
@export var crawl_speed: float = 50
@export var sprint_speed: float = 200
@export var interact_distance: float = 10

# --- Movement smoothing ---
@export var acceleration: float = 10.0

# --- Effet de Profondeur (Perspective) ---
@export var scale_min: float = 0.5 # Taille tout au fond
@export var scale_max: float = 1.0 # Taille devant l'écran
@export var y_min: float = 100.0   # Coordonnée Y du fond (à ajuster)
@export var y_max: float = 670.0   # Coordonnée Y du devant (à ajuster)

# --- Inventory ---
@export var inventory: Inventory

# --- Animation ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- Jump Settings ---
@export var tile_size: float = 64.0 # Taille d'une case en pixels (à ajuster selon ton jeu)
@export var jump_height: float = 30.0 # Hauteur visuelle du saut (en pixels)
@export var jump_duration: float = 0.35 # Durée de l'animation de saut en secondes

# --- State machine ---
enum State { NORMAL, CRAWLING, SPRINT, JUMPING }
var current_state: State = State.NORMAL

# --- Remember last direction for idle ---
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# 1. Initialisation de l'inventaire
	inventory.use_item.connect(use_item)
	
	# 2. Initialisation de l'image du joueur (Ton code)
	if tex_bas and sprite:
		sprite.texture = tex_bas



func _physics_process(delta: float) -> void:
	if current_state == State.JUMPING:
		#_update_depth_scale() 
		return
	if Input.is_action_just_pressed("jump"):
		attempt_jump()
		return
		
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
		State.CRAWLING: active_speed = crawl_speed
		State.SPRINT: active_speed = sprint_speed

	# --- Input direction ---
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Save last direction if moving
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
		if interact_ray:
			interact_ray.target_position = direction.normalized() * interact_distance
		# On met à jour l'animation et la direction du sprite seulement si le joueur bouge
		if sprite:
			_update_sprite_direction(direction)

	if anim:
		update_animation(direction)

	# --- Movement ---
	var desired_velocity = direction * active_speed
	velocity = velocity.lerp(desired_velocity, acceleration * delta)

	move_and_slide()



# 2. Fonction pour gérer le Sprite et les directions
func _update_sprite_direction(dir: Vector2) -> void:
	# --- Gérer le miroir (Gauche/Droite) ---
	# Si le joueur va vers la gauche (x négatif), on inverse l'image horizontalement
	if dir.x < 0:
		sprite.flip_h = true
	# S'il va vers la droite (x positif), on remet l'image à l'endroit
	elif dir.x > 0:
		sprite.flip_h = false
		
	# --- Déterminer l'image selon l'angle ---
	if dir.y < -0.5 and abs(dir.x) < 0.5:
		# En haut pur
		if tex_haut: sprite.texture = tex_haut
	elif dir.y > 0.5 and abs(dir.x) < 0.5:
		# En bas pur
		if tex_bas: sprite.texture = tex_bas
	elif dir.y < -0.5 and abs(dir.x) >= 0.5:
		# Diagonale Haut (le flip_h s'occupe de savoir si c'est gauche ou droite)
		if tex_haut_droite: sprite.texture = tex_haut_droite
	elif dir.y > 0.5 and abs(dir.x) >= 0.5:
		# Diagonale Bas
		if tex_bas_droite: sprite.texture = tex_bas_droite
	elif abs(dir.x) >= 0.5 and abs(dir.y) <= 0.5:
		# Sur le côté pur
		if tex_droite: sprite.texture = tex_droite


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

# --- MÉCANIQUE DE SAUT ---

func attempt_jump() -> void:
	if last_direction == Vector2.ZERO:
		return
		
	# Destination calcul
	var jump_vector = last_direction * (tile_size * 2)
	var target_global_position = global_position + jump_vector
	
	# Check landing
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target_global_position
	
	# Change the number depending of the layer of the map (wall and hole)
	query.collision_mask = 1 
	
	var result = space_state.intersect_point(query)
	
	# If lading point is a wall or a hole
	if result.size() > 0:
		print("Impossible Jump : more than one case")
		return
		
	# If possible jump
	execute_jump(target_global_position)


func execute_jump(target_pos: Vector2) -> void:
	current_state = State.JUMPING
	
	var move_tween = create_tween()
	# Move carractere toward destination
	move_tween.tween_property(self, "global_position", target_pos, jump_duration).set_trans(Tween.TRANS_LINEAR)
		
	# At the end, retake a normal state
	move_tween.tween_callback(func():
		current_state = State.NORMAL
	)
	
	# An other tween for the visual effect
	if sprite:
		var sprite_original_y = sprite.position.y
		var arc_tween = create_tween()
				
		# Sprite arise
		arc_tween.tween_property(sprite, "position:y", sprite_original_y - jump_height, jump_duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# Sprite go back down
		arc_tween.tween_property(sprite, "position:y", sprite_original_y, jump_duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
