extends CanvasLayer

var current_page : int = 1
var wave_color : Color = Color(0.75, 0.6, 0.3, 1.0) 
var wave_thickness : float = 2.0

var book_content = {
	1: {
		"level_title": "THE AWAKENING",
		"is_intro": true,
		"left_lesson": "INTRODUCTION",
		"left_text": "The world has fallen silent. Silence has devoured the echoes. Use this grimoire to master the laws of vibration and awaken the Spirits of Music.",
		"img_left": "res://Assets/Book/montagne.png",
		"right_lesson": "THE LAW OF LENGTH",
		"use_strings": true, 
		"txt_long": "[b]Low Frequencies[/b]\nA long string vibrates slowly.",
		"txt_med": "[b]Harmonic Balance[/b]\nMedium length creates melodic pitches.",
		"txt_short": "[b]High Frequencies[/b]\nA small string vibrates rapidly."
	},
	2: {
		"level_title": "HARMONIC RATIOS",
		"is_intro": false,
		"left_lesson": "THE PIANO",
		"left_text": "A piano is a forest of strings. By striking the keys, you trigger hammers that bring mathematical ratios to life.",
		"img_left": "res://Assets/Book/piano_mechanism.png", 
		"right_lesson": "PYTHAGOREAN MONOCHORD",
		"use_strings": false, 
		"right_text": "By dividing a string in half (1/2), you create an Octave. By dividing it at 2/3, you find the Perfect Fifth.",
		"img_right": "res://Assets/Book/monocorde.png"
	},
	3: {
		"level_title": "RESONANT GEOMETRY",
		"is_intro": false,
		"left_lesson": "VIBRATING SURFACES",
		"left_text": "When a surface vibrates, the air around it vibrates too to form sound waves. The vibration frequency depends on the object's overall mass.\n\nAn example of using this phenomenon is the 'Chladni' plate, where dust dances into sacred patterns.",
		"img_left": "res://Assets/Book/sable.png",
		"right_lesson": "CHLADNI PATTERNS",
		"use_strings": false, 
		"right_text": "Lower frequencies create simple forms. Higher ones create intricate webs. These patterns translate sound into visible form.",
		"img_right": "res://Assets/Book/sable2.png",
		"is_large_r": true 
	},
	4: {
		"level_title": "THE HEARTBEAT",
		"is_intro": false,
		"left_lesson": "DRUM RESONANCE",
		"left_text": "A drum is a trapped storm. The tighter the skin, the faster the strike, the higher the shout. The true power lies in the hollow body—the void where the sound grows and gains its weight.",
		"img_left": "res://Assets/Book/tambour.png",
		"right_lesson": "THE FIRST RHYTHM",
		"use_strings": false, 
		"right_text": "Legends say the first bards didn't sing; they mimicked the heartbeat of the world. In the Great Silence, these drums were the only way to remind the soul it was alive.",
		"img_right": "res://Assets/Book/barde tambour.png",
		"is_large_r": true 
	}
}

func _ready():
	await get_tree().process_frame
	update_view()

func _process(_delta):
	if self.visible and book_content[current_page].get("use_strings", false):
		_redraw_all_waves()

func _unhandled_input(event):
	if not self.visible: return
	if event.is_action_pressed("ui_right") and current_page < book_content.size():
		current_page += 1
		update_view()
	if event.is_action_pressed("ui_left") and current_page > 1:
		current_page -= 1
		update_view()

func update_view():
	var title_l = find_child("TitleLabel", true, false)
	var text_l = find_child("RichTextLabelLecon", true, false)
	var img_l = find_child("IllustrationLeft", true, false)
	var text_r = find_child("RichTextLabelArchive", true, false) 
	var img_r = find_child("IllustrationRight", true, false)
	var container_cordes = find_child("ContainerCordes", true, false)

	if book_content.has(current_page):
		var data = book_content[current_page]
		
		if title_l: title_l.text = "LEVEL " + str(current_page) + " - " + data["level_title"]

		if text_l: 
			text_l.fit_content = true
			# CORRECTION ICI : Pas de "Lesson 1" pour l'introduction
			if data.get("is_intro", false):
				text_l.text = "[center][b]" + data["left_lesson"] + "[/b][/center]\n\n" + data["left_text"]
			else:
				text_l.text = "[center][b]LESSON " + str(current_page) + ": " + data["left_lesson"] + "[/b][/center]\n\n" + data["left_text"]
		
		if img_l:
			img_l.texture = load(data["img_left"])
			_apply_img_settings(img_l, false)

		if data["use_strings"]:
			if img_r: img_r.hide()
			if text_r: text_r.hide()
			if container_cordes: container_cordes.show()
			_setup_strings_ui(data)
			_setup_waves()
		else:
			if container_cordes: container_cordes.hide()
			if text_r:
				text_r.show()
				text_r.fit_content = true
				text_r.text = "[center][b]" + data["right_lesson"] + "[/b][/center]\n" + data["right_text"]
			if img_r:
				img_r.show()
				img_r.texture = load(data["img_right"])
				_apply_img_settings(img_r, data.get("is_large_r", false))

func _apply_img_settings(img_node: TextureRect, is_large: bool):
	if img_node:
		var target_height = 280 if is_large else 160
		img_node.custom_minimum_size = Vector2(0, target_height)
		img_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# FORCE : Fill et Expand pour compenser les erreurs de scène
		img_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if is_large:
			img_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		else:
			img_node.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func _setup_strings_ui(data):
	var l_long = find_child("LabelLong", true, false)
	var l_med = find_child("LabelMed", true, false)
	var l_short = find_child("LabelShort", true, false)
	if l_long: l_long.text = "[center][b]LESSON 1: " + data["right_lesson"] + "[/b][/center]\n\n" + data["txt_long"]
	if l_med: l_med.text = data["txt_med"]
	if l_short: l_short.text = data["txt_short"]

func _setup_waves():
	_connect_wave("TextureLongue", 6.0, 0.05)
	_connect_wave("TextureMoyenne", 4.0, 0.12)
	_connect_wave("TexturePetite", 2.0, 0.3)

func _connect_wave(node_name, amp, freq):
	var node = find_child(node_name, true, false)
	if node:
		if node.is_connected("draw", _on_draw_wave): node.draw.disconnect(_on_draw_wave)
		node.draw.connect(_on_draw_wave.bind(node, amp, freq))

func _on_draw_wave(node, amp, freq):
	var time = Time.get_ticks_msec() * 0.01
	var points = PackedVector2Array()
	var y_off = node.size.y / 2.0
	for x in range(0, int(node.size.x), 2):
		var y = amp * sin((x + time) * freq)
		points.append(Vector2(x, y_off + y))
	node.draw_polyline(points, wave_color, wave_thickness)

func _redraw_all_waves():
	for n in ["TextureLongue", "TextureMoyenne", "TexturePetite"]:
		var node = find_child(n, true, false)
		if node: node.queue_redraw()
