extends Control

var is_closing = false

func _ready():
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE)
	
	if $VBoxContainer:
		# On élargit le conteneur pour accueillir toute la ligne
		$VBoxContainer.custom_minimum_size = Vector2(900, 0)
		$VBoxContainer.offset_left = -450
		$VBoxContainer.offset_right = 450
	
	build_ui()

func build_ui():
	# Nettoyer les enfants existants
	for child in $VBoxContainer.get_children():
		child.queue_free()
		
	for i in range(1, 4):
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 20)
		
		var info = SaveManager.get_slot_info(i)
		var is_empty = info.is_empty()
		
		# Label d'information
		var label = create_themed_label()
		if is_empty:
			label.text = "Slot " + str(i) + " - Empty"
		else:
			var chap = info.get("chapter", "Unknown")
			var lvl = str(info.get("level", "?"))
			var date = info.get("last_saved", "").split("T")[0]
			label.text = "Slot " + str(i) + " : " + chap + " (Lv " + lvl + ") - " + date
		hbox.add_child(label)
		
		# Bouton Sauvegarder
		var btn_save = create_themed_button("Save")
		btn_save.pressed.connect(func(): _on_save_pressed(i))
		hbox.add_child(btn_save)
		
		# Bouton Charger
		var btn_load = create_themed_button("Load")
		btn_load.disabled = is_empty
		if is_empty:
			btn_load.add_theme_color_override("font_disabled_color", Color(0.3, 0.3, 0.3, 1))
		btn_load.pressed.connect(func(): _on_load_pressed(i))
		hbox.add_child(btn_load)
		
		# Bouton Supprimer
		var btn_delete = create_themed_button("Delete")
		btn_delete.disabled = is_empty
		if is_empty:
			btn_delete.add_theme_color_override("font_disabled_color", Color(0.3, 0.3, 0.3, 1))
		btn_delete.pressed.connect(func(): _on_delete_pressed(i))
		hbox.add_child(btn_delete)
		
		$VBoxContainer.add_child(hbox)
		
	# Espace
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	$VBoxContainer.add_child(spacer)
	
	# Bouton Retour
	var back_btn = create_themed_button("Back")
	back_btn.custom_minimum_size = Vector2(400, 60)
	back_btn.pressed.connect(_on_back_pressed)
	$VBoxContainer.add_child(back_btn)

func create_themed_label() -> Label:
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(450, 60)
	return lbl

func create_themed_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.flat = true
	btn.add_theme_color_override("font_hover_color", Color(0.7, 0.7, 0.7, 1))
	btn.add_theme_color_override("font_pressed_color", Color(0.4, 0.4, 0.4, 1))
	btn.add_theme_color_override("font_focus_color", Color(0.9, 0.9, 0.9, 1))
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_font_size_override("font_size", 22)
	btn.custom_minimum_size = Vector2(150, 60)
	return btn

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu_with_animation()

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

func _on_save_pressed(slot_id: int):
	SaveManager.save_game(slot_id)
	build_ui()

func _on_load_pressed(slot_id: int):
	SaveManager.load_game(slot_id)
	close_menu_with_animation()

func _on_delete_pressed(slot_id: int):
	SaveManager.delete_save(slot_id)
	build_ui()
