class_name EnemyBattleUI
extends VBoxContainer

@onready var name_label: Label = $NameLabel
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var sprite: TextureRect = $Sprite

func setup(enemy_name: String, max_hp: int, texture: Texture2D) -> void:
	name_label.text = enemy_name
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	if texture:
		sprite.texture = texture

func update_hp(new_hp: int) -> void:
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", float(new_hp), 0.3)
	
	if new_hp <= 0:
		# here we manage the death animation
		modulate.a = 0.3
