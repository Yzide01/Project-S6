class_name TerrainZone
extends Area2D

@export_category("Terrain Settings")
## Cocher cette case s'il s'agit d'un escalier. Laisse décoché si c'est un simple plateau.
@export var is_stairs: bool = false

@export_group("Plateau (Si is_stairs est FAUX)")
## Hauteur du sol plat. Ex: 50.0 pour un plateau de hauteur 50.
@export var terrain_z_height: float = 50.0

@export_group("Escaliers (Si is_stairs est VRAI)")
## La coordonnée Y du monde où l'escalier est "en bas" (sol de base).
@export var stair_bottom_y: float = 200.0
## La coordonnée Y du monde où l'escalier est "en haut" (sur le plateau).
@export var stair_top_y: float = 150.0
## Hauteur virtuelle (z_height) au bas de l'escalier (ex: 0.0)
@export var z_height_bottom: float = 0.0
## Hauteur virtuelle (z_height) en haut de l'escalier (ex: 50.0)
@export var z_height_top: float = 50.0
