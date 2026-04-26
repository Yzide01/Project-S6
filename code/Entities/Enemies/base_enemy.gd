class_name BaseEnemy
extends Resource

@export var enemy_name: String = "Sbire Inconnu"
@export var max_hp: int = 30

@export var texture: Texture2D

# rank to determine enemy level and then capacities
@export_range(1, 3) var rank: int = 1
