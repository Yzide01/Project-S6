extends Control

func _ready():
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE)
	
	if $VBoxContainer.has_node("Slot1Button"):
		$VBoxContainer/Slot1Button.pressed.connect(func(): _on_slot_pressed(1))
		$VBoxContainer/Slot1Button.grab_focus()
	if $VBoxContainer.has_node("Slot2Button"):
		$VBoxContainer/Slot2Button.pressed.connect(func(): _on_slot_pressed(2))
	if $VBoxContainer.has_node("Slot3Button"):
		$VBoxContainer/Slot3Button.pressed.connect(func(): _on_slot_pressed(3))
	if $VBoxContainer.has_node("BackButton"):
		$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu_with_animation()

var is_closing = false

func close_menu_with_animation():
	if is_closing:
		return
	is_closing = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15).set_trans(Tween.TRANS_SINE)
	await tween.finished
	queue_free()

func _on_back_pressed():
	close_menu_with_animation()

func _on_slot_pressed(slot_id: int):
	# TODO: Appeler Load / Save ici via un EventManager ou SaveManager global
	print("Emplacement cliqué : ", slot_id)
	# close_menu_with_animation()
