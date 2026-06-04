class_name TerrainZone
extends Area2D

@export_category("Terrain Settings")
@export var is_stairs: bool = false

@export_group("Plateau (Si is_stairs est FAUX)")
@export var terrain_z_height: float = 50.0

@export_group("Escaliers (Si is_stairs est VRAI)")
@export var stair_bottom_y: float = 200.0
@export var stair_top_y: float = 150.0
@export var z_height_bottom: float = 0.0
@export var z_height_top: float = 50.0
