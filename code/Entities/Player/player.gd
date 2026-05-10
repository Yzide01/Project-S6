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

# --- Pseudo-3D Jump Settings ---
@export var jump_force: float = 250.0  # Force verticale initiale du saut (axe Z)
@export var gravity_z: float = 800.0   # Gravité sur l'axe Z
@export var low_obstacle_layer: int = 2 # Numéro de la couche des obstacles bas

var z_height: float = 0.0              # Hauteur actuelle du joueur (0 = au sol)
var z_velocity: float = 0.0            # Vitesse actuelle sur l'axe Z
var base_sprite_y: float = 0.0         # Position de base du sprite
var base_anim_y: float = 0.0           # Position de base de l'animation

var current_floor_z: float = 0.0       # Hauteur du sol sous les pieds
var overlapping_terrains: Array = []   # Liste des Area2D (TerrainZone) actuelles

var spawn_position: Vector2            # Position de respawn au début du niveau

# --- State machine ---
enum State { NORMAL, CRAWLING, SPRINT, JUMPING }
var current_state: State = State.NORMAL

# --- Remember last direction for idle ---
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	spawn_position = global_position # Sauvegarde de la position de départ
	
	# Par défaut, on s'assure que le joueur écoute bien les murs bas !
	set_collision_mask_value(low_obstacle_layer, true)
	# Le joueur écoute les signaux globaux du plugin de dialogue
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# 1. Initialisation de l'inventaire
	if inventory:
		inventory.use_item.connect(use_item)
	
	# 2. Initialisation de l'image du joueur (Ton code)
	if tex_bas and sprite:
		sprite.texture = tex_bas
		
	# Sauvegarder les positions de base pour le saut
	if sprite: base_sprite_y = sprite.position.y
	if anim: base_anim_y = anim.position.y

var is_in_dialogue: bool = false

func _on_dialogue_started():
	is_in_dialogue = true

func _on_dialogue_ended():
	is_in_dialogue = false

func _draw() -> void:
	# Dessine une petite ombre au sol sous le joueur
	var shadow_color = Color(0, 0, 0, 0.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 15.0, shadow_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _physics_process(delta: float) -> void:
	# On coupe les contrôles si un dialogue est ouvert
	if is_in_dialogue:
		velocity = Vector2.ZERO
		if anim:
			update_animation(Vector2.ZERO)
		return # On bloque les contrôles

	# Mettre à jour la hauteur simulée du sol en fonction des zones de terrain
	calculate_floor_z()

	if Input.is_action_just_pressed("jump") and z_height <= current_floor_z:
		attempt_jump()
		
	# Appliquer la gravité et la pseudo-3D
	apply_gravity(delta)
		
	# --- State handling ---
	# Impossible de changer de posture (crawl/sprint) si on est en l'air
	if z_height <= current_floor_z:
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

# --- MÉCANIQUE DE SAUT PSEUDO-3D ---

func attempt_jump() -> void:
	z_velocity = jump_force
	current_state = State.JUMPING
	
	# Désactive la collision avec les objets bas par-dessus lesquels on veut sauter
	# On évite de désactiver layer 1 (murs principaux généralement)
	set_collision_mask_value(low_obstacle_layer, false)

func apply_gravity(delta: float) -> void:
	if current_state == State.JUMPING or z_height > current_floor_z:
		# Application de la vélocité et gravité sur l'axe Z
		z_velocity -= gravity_z * delta
		z_height += z_velocity * delta
		
		# Condition d'atterrissage
		if z_height <= current_floor_z:
			z_height = current_floor_z
			z_velocity = 0.0
			
			if current_state == State.JUMPING:
				current_state = State.NORMAL
			
			# Réactive la collision de la couche basse UNIQUEMENT si on est au sol
			if current_floor_z <= 0.1:
				set_collision_mask_value(low_obstacle_layer, true)

				
		# Application du z_height sur le visuel (décale vers le haut)
		# Note: les ombres (s'il y en a) ne bougent pas, car on ne modifie que les variables Y des sprites
		if sprite:
			sprite.position.y = base_sprite_y - z_height
		if anim:
			anim.position.y = base_anim_y - z_height

# --- GESTION DU TERRAIN (PLATEAUX/ESCALIERS) ---

func calculate_floor_z() -> void:
	var target_floor_z = 0.0
	
	for area in overlapping_terrains:
		if area.get("is_stairs"):
			# Calcul de l'interpolation sur Y
			var stair_bottom_y = area.get("stair_bottom_y")
			var stair_top_y = area.get("stair_top_y")
			var zh_bottom = area.get("z_height_bottom")
			var zh_top = area.get("z_height_top")
			
			if stair_bottom_y != null and stair_top_y != null and zh_bottom != null and zh_top != null:
				var t = clamp(inverse_lerp(stair_bottom_y, stair_top_y, global_position.y), 0.0, 1.0)
				var interpolated_z = lerp(zh_bottom, zh_top, t)
				target_floor_z = max(target_floor_z, interpolated_z)
		else:
			# Plateau normal
			var t_z = area.get("terrain_z_height")
			if t_z != null:
				target_floor_z = max(target_floor_z, float(t_z))
				
	# --- AJOUT: Lecture de la hauteur depuis la TileMap (Custom Data) ---
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	# Vérifie les collisions sur le masque des obstacles bas (Layer 2)
	query.collision_mask = 1 << (low_obstacle_layer - 1)
	# Important: intersect_point détecte les Area et les Bodies
	var result = space_state.intersect_point(query)
	
	for res in result:
		var collider = res.collider
		# Pour Godot 4.3+ (TileMapLayer)
		if collider is TileMapLayer:
			var local_pos = collider.to_local(global_position)
			var map_pos = collider.local_to_map(local_pos)
			var tile_data = collider.get_cell_tile_data(map_pos)
			if tile_data:
				var z = tile_data.get_custom_data("terrain_z_height")
				if z != null:
					target_floor_z = max(target_floor_z, float(z))
		# Pour Godot 4.0 - 4.2 (TileMap)
		elif collider is TileMap:
			var local_pos = collider.to_local(global_position)
			var map_pos = collider.local_to_map(local_pos)
			for layer in collider.get_layers_count():
				var tile_data = collider.get_cell_tile_data(layer, map_pos)
				if tile_data:
					var z = tile_data.get_custom_data("terrain_z_height")
					if z != null:
						target_floor_z = max(target_floor_z, float(z))
	
	current_floor_z = target_floor_z
	
	# Si on atterrit ou qu'on descend d'un escalier de façon abrupte sans sauter
	if current_state != State.JUMPING and z_height < current_floor_z:
		z_height = current_floor_z

func _on_terrain_entered(area: Area2D) -> void:
	if area and not overlapping_terrains.has(area):
		overlapping_terrains.append(area)

func _on_terrain_exited(area: Area2D) -> void:
	if area and overlapping_terrains.has(area):
		overlapping_terrains.erase(area)


func _on_terrain_detector_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func respawn() -> void:
	# Réinitialiser la position
	global_position = spawn_position
	# Forcer le Z à repasser normal pour ne pas glitcher
	z_height = 0.0
	current_state = State.NORMAL
	set_collision_mask_value(low_obstacle_layer, true)
	# Si vous préférez recharger tout le niveau, décommentez la ligne du dessous :
	# get_tree().reload_current_scene()
