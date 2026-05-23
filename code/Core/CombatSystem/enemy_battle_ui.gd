class_name EnemyBattleUI
extends VBoxContainer

@onready var name_label: Label = $NameLabel
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var sprite: TextureRect = $Sprite
@onready var hp_text: Label = $HPText


@onready var anim_container: Control = $Container 
@onready var Shield_anim: AnimatedSprite2D = $Container/Shield_anim
@onready var shield: AnimatedSprite2D = $Container/shield

var enemy_max_hp: int = 0

func setup(enemy_name: String, max_hp: int, enemy_id: String) -> void:
	enemy_max_hp = max_hp
	name_label.text = enemy_name
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	hp_text.text = str(max_hp) + " / " + str(max_hp)
	for child in $Container.get_children():
		if child is AnimatedSprite2D:
			if child.name == enemy_id:
				child.show()
				child.play("default")
			else:
				child.hide()
				child.stop()

func update_hp(new_hp: int) -> void:
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", float(new_hp), 0.3)
	hp_text.text = str(new_hp) + " / " + str(enemy_max_hp)
	
	if new_hp <= 0:
		# here we manage the death animation
		modulate.a = 0.3

func enable_shield() -> void:
	if shield:
		shield.show()
		shield.play("idle_shield") # Shield intact

func disable_shield() -> void:
	if shield:
		shield.stop()
		shield.hide()

func play_shield_break() -> void:
	disable_shield()
	if Shield_anim :
		Shield_anim.show()
		Shield_anim.set_frame_and_progress(0, 0.0)
		Shield_anim.play("shield")
		await Shield_anim.animation_finished
		Shield_anim.hide()
	
