class_name RoadInterlude
extends CanvasLayer

## CCH-ORIGIN-001: "The Road to Crow Creek Hollow", the opening interlude a new game plays before October 1.
## It runs before the farm is built, so no in-game time passes while it is read; main.gd builds the farm the
## usual way once the player goes in at the door. The words come from RoadScript; the choices go to an
## OriginState record.
##
## Pages are read at the player's pace: nothing is timed and a page shows whole at once. Continue (A, Space,
## Enter or a click) goes on; Back (B, Backspace or the Back button) returns to the page before, all the way to
## the start, with earlier answers marked. Choosing a different answer drops any answers that came after it, so
## the record never mixes two roads. Esc or Start pauses. Until the door, every step is written to the save slot
## as a small "on the road" record (SaveSystem.write_interlude), so quitting resumes on the same page.

signal finished(record: Dictionary)

const C_INK := Color("2a1d12")
const C_INK_SOFT := Color("46331f")
const C_GOLD := Color("d8b050")
const C_IVORY := Color("e8dcc0")
const C_MUTED := Color("b8a682")
const CARD_W := 760.0
const TEXT_SIZE := 19

var slot_path := ""
var save_name := ""
var sound: Callable          # plays a sound effect by name, from main.gd (may be empty in tests)
var choices: Dictionary = {}
var order: Array = []
var index := 0
var steps: Array = []
var paused := false
var done := false
var pad := false             # the last device was a gamepad, so the prompts show its buttons

var root: Control
var back_layer: Backdrop
var front_layer: Backdrop
var act_label: Label
var card: PanelContainer
var body: VBoxContainer
var footer: HBoxContainer
var pause_panel: Control
var pause_box: VBoxContainer
var black: ColorRect
var _fade: Tween


func _init(record: Dictionary, path: String, name_of_save: String) -> void:
	var r := OriginState.sanitize(record) if not record.is_empty() else OriginState.fresh()
	if r["status"] != "in_progress":
		r = OriginState.fresh()
	choices = (r["choices"] as Dictionary).duplicate()
	order = (r["order"] as Array).duplicate()
	slot_path = path
	save_name = name_of_save
	steps = RoadScript.sequence(choices)
	index = clampi(int(r.get("pos", 0)), 0, steps.size() - 1)


func _ready() -> void:
	layer = 20
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = UiTheme.get_theme()
	add_child(root)
	back_layer = Backdrop.new()
	front_layer = Backdrop.new()
	for b in [back_layer, front_layer]:
		b.set_anchors_preset(Control.PRESET_FULL_RECT)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(b)

	var title := Label.new()
	title.text = "The Road to Crow Creek Hollow"
	title.add_theme_color_override("font_color", C_MUTED)
	title.add_theme_font_size_override("font_size", 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.position.y = 22
	root.add_child(title)
	act_label = Label.new()
	act_label.theme_type_variation = "DisplayTitle"
	act_label.add_theme_color_override("font_color", C_GOLD)
	act_label.add_theme_font_size_override("font_size", 26)
	act_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	act_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	act_label.position.y = 42
	root.add_child(act_label)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.offset_top = 70
	center.offset_bottom = -40
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	card = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiTheme.parchment(40, 30))
	card.custom_minimum_size = Vector2(CARD_W, 0)
	center.add_child(card)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	card.add_child(body)

	footer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 22)
	footer.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	footer.position.y = -34
	root.add_child(footer)

	_build_pause()
	root.move_child(footer, -1)   # the prompts stay bright over the pause menu's shade
	black = ColorRect.new()
	black.color = Color(0, 0, 0, 1)
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(black)
	_show(false)
	# The road fades up from black, as the title's choice hands over to it.
	var t := create_tween()
	t.tween_property(black, "color:a", 0.0, 0.6)


# --- Steps --------------------------------------------------------------------------------------------------

func current() -> Dictionary:
	return steps[index]


func record() -> Dictionary:
	return {"v": OriginState.V, "status": "in_progress", "choices": choices.duplicate(), "order": order.duplicate(), "pos": index}


func _show(animate := true) -> void:
	var step := current()
	act_label.text = str(step["act"])
	if front_layer.scene != str(step["scene"]):
		back_layer.scene = front_layer.scene
		back_layer.queue_redraw()
		front_layer.scene = str(step["scene"])
		front_layer.queue_redraw()
		if animate:
			front_layer.modulate.a = 0.0
			create_tween().tween_property(front_layer, "modulate:a", 1.0, 0.7)
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	for line in step.get("lines", []):
		body.add_child(_paragraph(str(line)))
	var focus_to: Control = null
	var back_ok := index > 0
	match str(step["kind"]):
		"page":
			focus_to = _nav_row(back_ok, "Continue", _advance)
		"choice":
			var prompt := Label.new()
			prompt.text = str(step["prompt"])
			prompt.add_theme_color_override("font_color", Color("4a2c12"))
			prompt.add_theme_font_size_override("font_size", 20)
			prompt.theme_type_variation = "DisplayTitle"
			prompt.add_theme_constant_override("outline_size", 0)
			if not step.get("lines", []).is_empty():
				body.add_child(_rule())
			body.add_child(prompt)
			var chosen := str(choices.get(step["key"], ""))
			for o in step["options"]:
				var id := str(o["id"])
				var b := _button(("•  " if id == chosen else "") + str(o["text"]), func() -> void: _choose(str(step["key"]), id))
				b.alignment = HORIZONTAL_ALIGNMENT_LEFT
				b.set_meta("option", id)
				if id == chosen:
					b.add_theme_color_override("font_color", C_GOLD)
					b.add_theme_color_override("font_focus_color", C_GOLD)
					b.add_theme_color_override("font_hover_color", C_GOLD)
				body.add_child(b)
				if focus_to == null or id == chosen:
					focus_to = b
			if chosen != "":
				body.add_child(_note("Your earlier answer is marked. Choosing another changes the road from here."))
			if back_ok:
				_nav_row(true, "", Callable())
		"arrive":
			body.add_child(_rule())
			body.add_child(_note("Once you go in, the road behind you is kept as you chose it."))
			focus_to = _nav_row(back_ok, "Go in", _arrive)
	_refresh_footer()
	if animate:
		card.modulate.a = 0.0
		create_tween().tween_property(card, "modulate:a", 1.0, 0.18)
	if focus_to != null:
		focus_to.grab_focus.call_deferred()
	_save_progress()


# Back and the forward button side by side; returns the forward button (or Back when there is none).
func _nav_row(back_ok: bool, forward: String, on_forward: Callable) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_END
	body.add_child(row)
	var first: Control = null
	if back_ok:
		var back := _button("Back", _back, "SecondaryButton")
		back.custom_minimum_size = Vector2(130, 40)
		row.add_child(back)
		first = back
	if forward != "":
		var go := _button(forward, on_forward)
		go.custom_minimum_size = Vector2(170, 40)
		row.add_child(go)
		first = go
	return first


func _advance() -> void:
	if paused or done or index >= steps.size() - 1:
		return
	index += 1
	_play("page_settle")
	_show()


func _back() -> void:
	if paused or done or index == 0:
		return
	index -= 1
	_play("page_lift")
	_show()


# Choosing again keeps the answers after this one only when the answer is the same; a different answer
# drops them, because the road after it is no longer the same road.
func _choose(key: String, id: String) -> void:
	if paused or done:
		return
	if str(choices.get(key, "")) != id:
		var at := order.find(key)
		if at >= 0:
			for k in order.slice(at):
				choices.erase(k)
			order = order.slice(0, at)
		choices[key] = id
		order.append(key)
		steps = RoadScript.sequence(choices)
	index = mini(index + 1, steps.size() - 1)
	_play("page_settle")
	_show()


func _arrive() -> void:
	if paused or done:
		return
	done = true
	_play("door")
	var r := record()
	r["status"] = "complete"
	r.erase("pos")
	r["day"] = 1
	var t := create_tween()
	t.tween_property(black, "color:a", 1.0, 0.8)
	t.tween_callback(func() -> void: finished.emit(OriginState.sanitize(r)))


# After the farm is built behind the black, it fades in and the interlude is gone. on_done runs at the end.
func reveal(on_done: Callable) -> void:
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in [card, act_label, footer]:
		c.visible = false
	back_layer.visible = false
	front_layer.visible = false
	var t := create_tween()
	t.tween_property(black, "color:a", 0.0, 1.0)
	t.tween_callback(func() -> void:
		on_done.call()
		queue_free())


func _save_progress() -> void:
	if slot_path != "" and not done:
		SaveSystem.write_interlude(slot_path, save_name, record())


# --- Input --------------------------------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	var was := pad
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5):
		pad = true
	elif event is InputEventKey or (event is InputEventMouseButton and event.pressed):
		pad = false
	if was != pad:
		_refresh_footer()


func _unhandled_input(event: InputEvent) -> void:
	if done:
		return
	var pause_key: bool = (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE) \
		or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
	var back_key: bool = (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_BACKSPACE) \
		or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B)
	if paused:
		if pause_key or back_key:
			get_viewport().set_input_as_handled()
			set_paused(false)
		return
	if pause_key:
		get_viewport().set_input_as_handled()
		set_paused(true)
	elif back_key:
		get_viewport().set_input_as_handled()
		_back()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_progress()


# --- Pause --------------------------------------------------------------------------------------------------

func _build_pause() -> void:
	pause_panel = ColorRect.new()
	(pause_panel as ColorRect).color = Color(0.02, 0.015, 0.01, 0.78)
	pause_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_panel.visible = false
	root.add_child(pause_panel)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_panel.add_child(center)
	var frame := PanelContainer.new()
	frame.theme_type_variation = "DialogPanel"
	center.add_child(frame)
	pause_box = VBoxContainer.new()
	pause_box.add_theme_constant_override("separation", 10)
	pause_box.custom_minimum_size = Vector2(360, 0)
	frame.add_child(pause_box)
	var heading := Label.new()
	heading.text = "Paused"
	heading.theme_type_variation = "DisplayTitle"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_box.add_child(heading)
	var hint := Label.new()
	hint.text = "Your place on the road is kept."
	hint.add_theme_color_override("font_color", C_MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_box.add_child(hint)
	for pair in [["Resume", func() -> void: set_paused(false)],
			["Quit to title", func() -> void: _leave(false)],
			["Quit game", func() -> void: _leave(true)]]:
		var b := _button(str(pair[0]), pair[1])
		b.custom_minimum_size = Vector2(360, 42)
		pause_box.add_child(b)


func set_paused(on: bool) -> void:
	paused = on
	pause_panel.visible = on
	if on:
		_save_progress()
		(pause_box.get_child(2) as Control).grab_focus.call_deferred()
	else:
		_show(false)
	_refresh_footer()


func _leave(quit: bool) -> void:
	_save_progress()
	done = true
	if quit:
		get_tree().quit()
	else:
		get_tree().call_deferred("reload_current_scene")


# --- Pieces -------------------------------------------------------------------------------------------------

func _paragraph(text: String) -> Control:
	if text.begins_with("!"):
		var sign := text.substr(1)
		var is_sign := sign == sign.to_upper()
		var slip := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("2a1f15") if is_sign else Color("b49c6e")
		sb.border_color = Color("6b5340") if is_sign else Color("5a4026")
		sb.set_border_width_all(2)
		sb.set_content_margin_all(12)
		slip.add_theme_stylebox_override("panel", sb)
		var l := Label.new()
		l.text = sign
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.theme_type_variation = "DisplayTitle"
		l.add_theme_font_size_override("font_size", 22 if is_sign else 18)
		l.add_theme_color_override("font_color", C_IVORY if is_sign else C_INK)
		l.add_theme_constant_override("outline_size", 0)
		slip.add_child(l)
		return slip
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(CARD_W - 80, 0)
	label.add_theme_font_size_override("font_size", TEXT_SIZE)
	label.add_theme_color_override("font_color", C_INK)
	label.add_theme_constant_override("line_spacing", 3)
	return label


func _note(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(CARD_W - 80, 0)
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", C_INK_SOFT)
	return l


func _rule() -> Control:
	var r := ColorRect.new()
	r.color = Color(0.29, 0.2, 0.12, 0.35)
	r.custom_minimum_size = Vector2(0, 2)
	return r


func _button(text: String, on_press: Callable, variation := "") -> Button:
	var b := Button.new()
	b.text = text
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(0, 40)
	b.add_theme_font_size_override("font_size", 18)
	if variation != "":
		b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_ALL
	if on_press.is_valid():
		b.pressed.connect(on_press)
	return b


func _refresh_footer() -> void:
	if footer == null:
		return
	for child in footer.get_children():
		footer.remove_child(child)
		child.queue_free()
	var prompts := []
	if paused:
		prompts = [["A" if pad else "Enter", "Select"], ["B" if pad else "Esc", "Resume"]]
	else:
		var kind := str(current()["kind"])
		prompts.append(["A" if pad else "Space", {"page": "Continue", "choice": "Choose", "arrive": "Go in"}[kind]])
		if index > 0:
			prompts.append(["B" if pad else "Backspace", "Back"])
		prompts.append(["Start" if pad else "Esc", "Pause"])
	for p in prompts:
		var pair := HBoxContainer.new()
		pair.add_theme_constant_override("separation", 6)
		var glyph := Label.new()
		glyph.text = str(p[0])
		glyph.theme_type_variation = "KeyGlyph"
		glyph.custom_minimum_size = Vector2(26, 24)
		glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pair.add_child(glyph)
		var words := Label.new()
		words.text = str(p[1])
		words.add_theme_color_override("font_color", C_IVORY)
		words.add_theme_font_size_override("font_size", 15)
		pair.add_child(words)
		footer.add_child(pair)


func _play(name: String) -> void:
	if sound.is_valid():
		sound.call(name)


# The prompt glyphs on show, for the tests.
func footer_text() -> String:
	var parts := []
	for pair in footer.get_children():
		if pair.is_queued_for_deletion():
			continue
		parts.append("%s %s" % [(pair.get_child(0) as Label).text, (pair.get_child(1) as Label).text])
	return ", ".join(parts)


# --- The backdrop -------------------------------------------------------------------------------------------
# A quiet painted scene behind the page, drawn in code from flat shapes in the muted palette: the room the
# player is leaving (a window's grey light, a table, the things of that scene), then the road (a dusk sky over
# hills and the tree line) and the farm gate. No new art; the writing carries the scene.

class Backdrop extends Control:
	var scene := ""
	var t := 0.0

	func _process(delta: float) -> void:
		if scene in ["fuel", "ridge", "gate", "door"]:
			t += delta
			queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		if scene == "":
			draw_rect(Rect2(0, 0, w, h), Color("0d0a07"))
			return
		if scene in ["fuel", "ridge", "gate", "door"]:
			_road(w, h)
		else:
			_room(w, h)
		# A soft vignette, so the page in the middle holds the eye.
		for i in 6:
			var a := 0.07 * (6 - i)
			var m := i * 26.0
			draw_rect(Rect2(m, m, w - m * 2, h - m * 2), Color(0, 0, 0, a), false, 26.0)

	func _room(w: float, h: float) -> void:
		var light: Color = {"rent": Color("8d96a0"), "workroom": Color("a08860"), "shelf": Color("8a8f98"),
			"photograph": Color("98a090"), "closing_date": Color("9a9a90"), "boxes": Color("8a8478"),
			"case": Color("7f7a70")}.get(scene, Color("8b929a"))
		draw_rect(Rect2(0, 0, w, h), Color("221a13"))
		# Wallboards and the floor.
		for x in range(0, int(w), 58):
			draw_line(Vector2(x, 0), Vector2(x, h * 0.72), Color("1b140e"), 2.0)
		draw_rect(Rect2(0, h * 0.72, w, h * 0.28), Color("17110c"))
		draw_line(Vector2(0, h * 0.72), Vector2(w, h * 0.72), Color("0f0b08"), 4.0)
		# The window on the left, its grey daylight falling across the floor.
		var win := Rect2(w * 0.06, h * 0.16, w * 0.13, h * 0.3)
		draw_rect(win.grow(8), Color("120d09"))
		draw_rect(win, light.darkened(0.35))
		draw_rect(Rect2(win.position, Vector2(win.size.x, win.size.y * 0.5)), light.darkened(0.2))
		draw_line(Vector2(win.get_center().x, win.position.y), Vector2(win.get_center().x, win.end.y), Color("120d09"), 5.0)
		draw_line(Vector2(win.position.x, win.get_center().y), Vector2(win.end.x, win.get_center().y), Color("120d09"), 5.0)
		var pool := PackedVector2Array([Vector2(win.position.x, h * 0.72), Vector2(win.end.x, h * 0.72),
			Vector2(win.end.x + w * 0.12, h), Vector2(win.position.x + w * 0.02, h)])
		draw_colored_polygon(pool, Color(light, 0.08))
		# The table on the right, and what lies on it.
		var top := h * 0.62
		draw_rect(Rect2(w * 0.74, top, w * 0.22, 14), Color("3a2a1c"))
		draw_rect(Rect2(w * 0.76, top + 14, 10, h * 0.22), Color("2b1f15"))
		draw_rect(Rect2(w * 0.93, top + 14, 10, h * 0.22), Color("2b1f15"))
		var paper := Color("b9a98a")
		match scene:
			"notice":
				draw_rect(Rect2(w * 0.8, top - 4, 46, 6), paper)
			"rent":
				draw_rect(Rect2(w * 0.78, top - 4, 40, 6), paper)
				draw_rect(Rect2(w * 0.84, top - 4, 40, 6), paper.darkened(0.15))
			"workroom":
				draw_circle(Vector2(w * 0.88, top - 30), 60, Color(0.85, 0.6, 0.3, 0.06))
				draw_rect(Rect2(w * 0.875, top - 26, 6, 26), Color("2b1f15"))
				draw_rect(Rect2(w * 0.86, top - 40, 32, 16), Color("6b5340"))
				for i in 4:
					draw_line(Vector2(w * 0.73, h * 0.2 + i * 34), Vector2(w * 0.97, h * 0.2 + i * 34), Color("3a2a1c"), 6.0)
			"shelf":
				draw_line(Vector2(w * 0.74, h * 0.36), Vector2(w * 0.96, h * 0.36), Color("3a2a1c"), 7.0)
				draw_rect(Rect2(w * 0.75, h * 0.36 - 30, 18, 30), Color("4a3828"))
				draw_rect(Rect2(w * 0.86, h * 0.36 - 5, 44, 4), Color("2e2318"))   # the mark where things stood
				draw_rect(Rect2(w * 0.8, top - 30, 54, 30), Color("5a4630"))
			"photograph":
				draw_rect(Rect2(w * 0.81, top - 6, 40, 30).grow(3), Color("d8ccb0"))
				draw_rect(Rect2(w * 0.81, top - 6, 40, 30), Color("4a4a40"))
				draw_rect(Rect2(w * 0.81, top + 8, 40, 16), Color("3a4030"))
			"closing_date":
				var cal := Rect2(w * 0.8, h * 0.18, 96, 84)
				draw_rect(cal, Color("a89878"))
				for r in 4:
					for col in 5:
						draw_rect(Rect2(cal.position + Vector2(8 + col * 17, 18 + r * 16), Vector2(12, 10)), Color("8a7a5c"))
				draw_arc(cal.position + Vector2(8 + 4 * 17 + 6, 18 + 2 * 16 + 5), 11, 0, TAU, 20, Color("8a2e1c"), 2.0)
				draw_rect(Rect2(w * 0.83, top - 3, 20, 4), Color("8a8070"))
			"boxes":
				for b in [Rect2(w * 0.3, h * 0.66, 90, 70), Rect2(w * 0.38, h * 0.7, 110, 60), Rect2(w * 0.62, h * 0.68, 80, 64)]:
					draw_rect(b, Color("4a3826"))
					draw_line(b.position + Vector2(0, 10), b.position + Vector2(b.size.x, 10), Color("3a2a1c"), 3.0)
			"case":
				var cs := Rect2(w * 0.4, h * 0.74, 200, 60)
				draw_rect(cs, Color("3b2417"))
				draw_rect(Rect2(cs.position + Vector2(0, -26), Vector2(cs.size.x, 26)), Color("2b1a10"))
				draw_rect(Rect2(cs.get_center() - Vector2(14, 34), Vector2(28, 8)), Color("8a6a3a"))

	func _road(w: float, h: float) -> void:
		var dusk := scene in ["gate", "door"]
		var sky_top := Color("2a3038") if not dusk else Color("262832")
		var sky_low := Color("6a6a68") if not dusk else Color("5a5248")
		for i in 24:
			var f := i / 23.0
			draw_rect(Rect2(0, h * 0.62 * f, w, h * 0.62 / 23.0 + 1), sky_top.lerp(sky_low, f))
		var drift := sin(t * 0.08) * 12.0
		# Far hills, then nearer ones.
		_hills(w, h * 0.5, 40.0, 0.006, Color("3a3e40"), drift * 0.4)
		_hills(w, h * 0.58, 30.0, 0.011, Color("2a2c2a"), drift)
		draw_rect(Rect2(0, h * 0.62, w, h * 0.38), Color("1a1a16"))
		match scene:
			"fuel":
				# The road running off, and a lit pump by it.
				draw_colored_polygon(PackedVector2Array([Vector2(w * 0.45, h * 0.62), Vector2(w * 0.55, h * 0.62),
					Vector2(w * 0.9, h), Vector2(w * 0.1, h)]), Color("26241f"))
				draw_circle(Vector2(w * 0.86, h * 0.52), 70, Color(0.9, 0.7, 0.35, 0.07))
				draw_rect(Rect2(w * 0.855, h * 0.5, 6, h * 0.14), Color("141210"))
				draw_rect(Rect2(w * 0.845, h * 0.5, 22, 10), Color("c9a050"))
			"ridge":
				_trees(w, h * 0.64, 1.0, drift * 1.6)
				draw_rect(Rect2(w * 0.9, h * 0.58, 6, h * 0.1), Color("141210"))
				draw_rect(Rect2(w * 0.865, h * 0.56, 74, 22), Color("3a2a1c"))
			"gate", "door":
				_trees(w, h * 0.6, 1.2, drift * 0.8)
				# The farmhouse roof between the trees, a dim window, and the fence and gate.
				var hx := w * 0.82
				draw_colored_polygon(PackedVector2Array([Vector2(hx - 90, h * 0.5), Vector2(hx, h * 0.4), Vector2(hx + 90, h * 0.5)]), Color("15120f"))
				draw_rect(Rect2(hx - 80, h * 0.5, 160, h * 0.12), Color("1d1915"))
				draw_rect(Rect2(hx + 40, h * 0.39, 14, 30), Color("15120f"))
				if scene == "door":
					draw_rect(Rect2(hx - 14, h * 0.53, 28, h * 0.09), Color("3a2e20"))
				for i in 9:
					var px := w * 0.05 + i * 46.0
					draw_rect(Rect2(px, h * 0.66, 6, 34), Color("2b241c"))
				draw_line(Vector2(w * 0.05, h * 0.68), Vector2(w * 0.05 + 8 * 46 + 6, h * 0.68), Color("2b241c"), 4.0)
				draw_line(Vector2(w * 0.05, h * 0.72), Vector2(w * 0.05 + 8 * 46 + 6, h * 0.72), Color("2b241c"), 4.0)

	func _hills(w: float, base: float, amp: float, freq: float, col: Color, shift: float) -> void:
		var pts := PackedVector2Array()
		pts.append(Vector2(0, size.y))
		for i in 41:
			var x := w * i / 40.0
			pts.append(Vector2(x, base - amp * (0.6 + 0.4 * sin((x + shift) * freq) * cos((x + shift) * freq * 0.37))))
		pts.append(Vector2(w, size.y))
		draw_colored_polygon(pts, col)

	func _trees(w: float, base: float, scale: float, shift: float) -> void:
		var x := -40.0 + fmod(shift, 37.0)
		var i := 0
		while x < w + 40:
			var tall := (60.0 + float((i * 37) % 50)) * scale
			draw_colored_polygon(PackedVector2Array([Vector2(x - 16 * scale, base), Vector2(x, base - tall), Vector2(x + 16 * scale, base)]), Color("121411"))
			x += 22.0 + float((i * 13) % 19)
			i += 1
