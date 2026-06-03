class_name Player extends CharacterBody2D
# --- Textures Directionnelles ---
@export var tex_bas: Texture2D
@export var tex_haut: Texture2D
@export var tex_droite: Texture2D
@export var tex_bas_droite: Texture2D
@export var tex_haut_droite: Texture2D

# --- Noeuds enfants ---
@onready var interact_ray: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

# --- Movement speeds ---
@export var normal_speed: float = 150
@export var crawl_speed: float = 50
@export var sprint_speed: float = 200
@export var interact_distance: float = 10

# --- Movement smoothing ---
@export var acceleration: float = 10.0

# --- Effet de Profondeur (Perspective) ---
@export var scale_min: float = 0.5
@export var scale_max: float = 1.0
@export var y_min: float = 100.0
@export var y_max: float = 670.0

# --- Inventory ---
@export var inventory: Inventory

# --- Animation ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- Pseudo-3D Jump Settings ---
@export var jump_force: float = 250.0
@export var gravity_z: float = 800.0
@export var low_obstacle_layer: int = 2

var z_height: float = 0.0
var z_velocity: float = 0.0
var base_sprite_y: float = 0.0
var base_anim_y: float = 0.0

var current_floor_z: float = 0.0
var overlapping_terrains: Array = []

var spawn_position: Vector2

# --- State machine ---
enum State { NORMAL, CRAWLING, SPRINT, JUMPING }
var current_state: State = State.NORMAL

# --- Remember last direction for idle ---
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	spawn_position = global_position
	
	# Restore saved position if needed
	if SaveManager.restore_player_position:
		global_position = Vector2(SaveManager.loaded_player_x, SaveManager.loaded_player_y)
		SaveManager.restore_player_position = false
	
	set_collision_mask_value(low_obstacle_layer, true)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	if inventory:
		inventory.use_item.connect(use_item)
	
	if tex_bas and sprite:
		sprite.texture = tex_bas
		
	if sprite: base_sprite_y = sprite.position.y
	if anim: base_anim_y = anim.position.y

var is_in_dialogue: bool = false

func _on_dialogue_started():
	is_in_dialogue = true

func _on_dialogue_ended():
	is_in_dialogue = false

func _draw() -> void:
	var shadow_color = Color(0, 0, 0, 0.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, 15.0, shadow_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _physics_process(delta: float) -> void:
	# Disables player movement inputs when a dialogue sequence is active.
	if is_in_dialogue:
		velocity = Vector2.ZERO
		if anim:
			update_animation(Vector2.ZERO)
		return

	# Updates the simulated ground height based on active terrain zones.
	calculate_floor_z()

	if Input.is_action_just_pressed("jump") and z_height <= current_floor_z:
		attempt_jump()
		
	# Applies gravity and pseudo-3D calculations for jump mechanics.
	apply_gravity(delta)
		
	# --- State handling ---
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
		if sprite:
			_update_sprite_direction(direction)

	if anim:
		update_animation(direction)

	# --- Movement ---
	var desired_velocity = direction * active_speed
	velocity = velocity.lerp(desired_velocity, acceleration * delta)

	move_and_slide()



func _update_sprite_direction(dir: Vector2) -> void:
	if dir.x < 0:
		sprite.flip_h = true
	elif dir.x > 0:
		sprite.flip_h = false
		
	if dir.y < -0.5 and abs(dir.x) < 0.5:
		if tex_haut: sprite.texture = tex_haut
	elif dir.y > 0.5 and abs(dir.x) < 0.5:
		if tex_bas: sprite.texture = tex_bas
	elif dir.y < -0.5 and abs(dir.x) >= 0.5:
		if tex_haut_droite: sprite.texture = tex_haut_droite
	elif dir.y > 0.5 and abs(dir.x) >= 0.5:
		if tex_bas_droite: sprite.texture = tex_bas_droite
	elif abs(dir.x) >= 0.5 and abs(dir.y) <= 0.5:
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


	match current_state:
		State.CRAWLING:
			anim.speed_scale = 0.7
		State.SPRINT:
			anim.speed_scale = 1.5
		State.NORMAL:
			anim.speed_scale = 1.0

# --- PSEUDO-3D JUMP MECHANIC ---

func attempt_jump() -> void:
	z_velocity = jump_force
	current_state = State.JUMPING
	
	set_collision_mask_value(low_obstacle_layer, false)

func apply_gravity(delta: float) -> void:
	if current_state == State.JUMPING or z_height > current_floor_z:
		z_velocity -= gravity_z * delta
		z_height += z_velocity * delta
		
		if z_height <= current_floor_z:
			z_height = current_floor_z
			z_velocity = 0.0
			
			if current_state == State.JUMPING:
				current_state = State.NORMAL
			
			if current_floor_z <= 0.1:
				set_collision_mask_value(low_obstacle_layer, true)

				
		if sprite:
			sprite.position.y = base_sprite_y - z_height
		if anim:
			anim.position.y = base_anim_y - z_height

# --- TERRAIN MANAGEMENT (PLATEAUS/STAIRS) ---

func calculate_floor_z() -> void:
	var target_floor_z = 0.0
	
	for area in overlapping_terrains:
		if area.get("is_stairs"):
			var stair_bottom_y = area.get("stair_bottom_y")
			var stair_top_y = area.get("stair_top_y")
			var zh_bottom = area.get("z_height_bottom")
			var zh_top = area.get("z_height_top")
			
			if stair_bottom_y != null and stair_top_y != null and zh_bottom != null and zh_top != null:
				var t = clamp(inverse_lerp(stair_bottom_y, stair_top_y, global_position.y), 0.0, 1.0)
				var interpolated_z = lerp(zh_bottom, zh_top, t)
				target_floor_z = max(target_floor_z, interpolated_z)
		else:
			var t_z = area.get("terrain_z_height")
			if t_z != null:
				target_floor_z = max(target_floor_z, float(t_z))
				
	# --- AJOUT: Lecture de la hauteur depuis la TileMap (Custom Data) ---
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1 << (low_obstacle_layer - 1)
	var result = space_state.intersect_point(query)
	
	for res in result:
		var collider = res.collider
		if collider is TileMapLayer:
			var local_pos = collider.to_local(global_position)
			var map_pos = collider.local_to_map(local_pos)
			var tile_data = collider.get_cell_tile_data(map_pos)
			if tile_data:
				var z = tile_data.get_custom_data("terrain_z_height")
				if z != null:
					target_floor_z = max(target_floor_z, float(z))
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
	
	if current_state != State.JUMPING and z_height < current_floor_z:
		z_height = current_floor_z

func _on_terrain_entered(area: Area2D) -> void:
	if area and not overlapping_terrains.has(area):
		overlapping_terrains.append(area)

func _on_terrain_exited(area: Area2D) -> void:
	if area and overlapping_terrains.has(area):
		overlapping_terrains.erase(area)


func _on_terrain_detector_area_entered(area: Area2D) -> void:
	pass

func respawn() -> void:
	global_position = spawn_position
	z_height = 0.0
	current_state = State.NORMAL
	set_collision_mask_value(low_obstacle_layer, true)
