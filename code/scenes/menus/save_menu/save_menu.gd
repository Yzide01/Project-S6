extends Control

func _ready():
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE)
	
	update_ui()
	
	if $VBoxContainer.has_node("Slot1Button"):
		$VBoxContainer/Slot1Button.pressed.connect(func(): _on_slot_pressed(1))
		$VBoxContainer/Slot1Button.grab_focus()
	if $VBoxContainer.has_node("Slot2Button"):
		$VBoxContainer/Slot2Button.pressed.connect(func(): _on_slot_pressed(2))
	if $VBoxContainer.has_node("Slot3Button"):
		$VBoxContainer/Slot3Button.pressed.connect(func(): _on_slot_pressed(3))
	if $VBoxContainer.has_node("BackButton"):
		$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func update_ui():
	for i in range(1, 4):
		var btn = $VBoxContainer.get_node_or_null("Slot" + str(i) + "Button")
		if btn:
			var info = SaveManager.get_slot_info(i)
			if info.is_empty():
				btn.text = "Emplacement " + str(i) + " - Vide"
			else:
				var chap = info.get("chapter", "Inconnu")
				var lvl = str(info.get("level", "?"))
				var date = info.get("last_saved", "").split("T")[0] # Simple date formatting
				btn.text = "Emplacement " + str(i) + " - " + chap + " (Nv " + lvl + ") - " + date

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

var mode: String = "save"

func _on_slot_pressed(slot_id: int):
	if mode == "save":
		SaveManager.save_game(slot_id)
		update_ui() # Mettre à jour l'affichage directement
	elif mode == "load":
		SaveManager.load_game(slot_id)
		
	# close_menu_with_animation() # Commented out as in original if they want it to stay open, or maybe uncomment it? Let's leave it uncommented so the menu closes.
	close_menu_with_animation()
