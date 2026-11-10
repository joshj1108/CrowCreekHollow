extends SceneTree

# Draws every component of the shared UI theme (scripts/ui_theme.gd) in each of its states, on one 1280 by 720
# sheet, for reviewing the visual language (UI-OVERHAUL-001). Hover, pressed and focus can't be held on a real
# control in a still, so each state is drawn with the theme's own stylebox and font colour for that state;
# focus is drawn over normal, as Godot draws it. Not headless (it needs a renderer):
#   godot --path . -s tools/ui_theme_gallery.gd -- out=art/style_tests/x.png [scale=0.5]

const STATES := ["normal", "hover", "pressed", "focus", "disabled"]
const STATE_FONT := {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color",
	"focus": "font_focus_color", "disabled": "font_disabled_color"}
var theme: Theme


func _initialize() -> void:
	var opt := {"scale": "1"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	theme = UiTheme.get_theme()

	var page := Control.new()
	page.theme = theme
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(page)
	var bg := ColorRect.new()
	bg.color = Color("0e0a07")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 18)
	page.add_child(margin)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 26)
	margin.add_child(cols)

	# Left: the state table.
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 10)
	cols.add_child(left)
	var title := Label.new()
	title.theme_type_variation = "DisplayTitle"
	title.text = "Crow Creek Hollow UI"
	left.add_child(title)
	var sub := Label.new()
	sub.theme_type_variation = "Subtitle"
	sub.text = "UI-OVERHAUL-001 Phase 2: the refined shared theme, every component and state"
	left.add_child(sub)
	left.add_child(HSeparator.new())
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	left.add_child(grid)
	grid.add_child(_caption(""))
	for s in STATES:
		grid.add_child(_caption(s.capitalize() if s != "focus" else "Focused"))
	for row in [["Primary button", "Button", "Build"], ["Secondary button", "SecondaryButton", "Back"],
			["Tab, inactive", "TabInactive", "Decor"], ["Tab, active", "TabActive", "Workshop"],
			["List entry", "ListEntry", "Smokehouse"]]:
		grid.add_child(_caption(row[0]))
		for s in STATES:
			grid.add_child(_swatch(row[1], s, row[2]))

	# Phase 2: inventory slots in each state, each with a picture and its count.
	left.add_child(_caption("Inventory slots: empty, occupied, hover, picked, focused, picked + focused, unavailable"))
	var slot_row := HBoxContainer.new()
	slot_row.add_theme_constant_override("separation", 16)
	for spec in [["SlotEmpty", "normal", "", ""], ["Slot", "normal", "turnip", "28"], ["Slot", "hover", "egg", "3"],
			["SlotSelected", "normal", "egg", "4"], ["Slot", "focus", "fish_t", "2"], ["SlotSelected", "focus", "bandage", "1"],
			["SlotLocked", "normal", "seed", "0"]]:
		slot_row.add_child(_slot_swatch(spec[0], spec[1], spec[2], spec[3]))
	left.add_child(slot_row)

	left.add_child(HSeparator.new())
	var misc := HBoxContainer.new()
	misc.add_theme_constant_override("separation", 22)
	left.add_child(misc)
	# Tooltip.
	var tip_box := VBoxContainer.new()
	tip_box.add_child(_caption("Tooltip"))
	var tip := PanelContainer.new()
	tip.add_theme_stylebox_override("panel", theme.get_stylebox("panel", "TooltipPanel"))
	var tip_text := Label.new()
	tip_text.theme_type_variation = "Hint"
	tip_text.add_theme_color_override("font_color", theme.get_color("font_color", "TooltipLabel"))
	tip_text.add_theme_font_size_override("font_size", theme.get_font_size("font_size", "TooltipLabel"))
	tip_text.text = "Workshop: 2 ready to do"
	tip.add_child(tip_text)
	tip_box.add_child(tip)
	misc.add_child(tip_box)
	# Badges on tabs.
	var badge_box := VBoxContainer.new()
	badge_box.add_child(_caption("Notification badges"))
	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 18)
	for pair in [["Animals", false, 2], ["Tax", true, 1]]:
		var b := Button.new()
		b.theme_type_variation = "TabInactive"
		b.text = pair[0]
		b.custom_minimum_size = Vector2(110, 34)
		b.focus_mode = Control.FOCUS_NONE
		UiTheme.add_badge(b, pair[2], pair[1])
		badges.add_child(b)
	badge_box.add_child(badges)
	misc.add_child(badge_box)
	# Key glyphs.
	var glyph_box := VBoxContainer.new()
	glyph_box.add_child(_caption("Footer prompts"))
	var glyphs := HBoxContainer.new()
	glyphs.add_theme_constant_override("separation", 6)
	for pair in [["A", "Select"], ["B", "Close"], ["LB RB", "Tabs"]]:
		var g := Label.new()
		g.theme_type_variation = "KeyGlyph"
		g.text = pair[0]
		glyphs.add_child(g)
		var h := Label.new()
		h.theme_type_variation = "Hint"
		h.text = pair[1] + "  "
		glyphs.add_child(h)
	glyph_box.add_child(glyphs)
	misc.add_child(glyph_box)

	var misc2 := HBoxContainer.new()
	misc2.add_theme_constant_override("separation", 22)
	left.add_child(misc2)
	# Meter.
	var meter_box := VBoxContainer.new()
	meter_box.custom_minimum_size = Vector2(200, 0)
	meter_box.add_child(_caption("Progress bar"))
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(200, 10)
	bar.value = 62
	meter_box.add_child(bar)
	misc2.add_child(meter_box)
	# Typography roles.
	var type_box := VBoxContainer.new()
	type_box.add_child(_caption("Type roles: display, body, numbers"))
	var d := Label.new()
	d.theme_type_variation = "DisplayHeading"
	d.text = "The Homestead"
	type_box.add_child(d)
	var body := Label.new()
	body.text = "A stone room dug under the house."
	type_box.add_child(body)
	var n := Label.new()
	n.theme_type_variation = "NumberLabel"
	n.add_theme_font_size_override("font_size", 16)
	n.text = "700 coins   12 / 30   09:45"
	type_box.add_child(n)
	misc2.add_child(type_box)
	# Scrollbar.
	var scroll_box := VBoxContainer.new()
	scroll_box.add_child(_caption("Scrollbar"))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(150, 96)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	var lines := VBoxContainer.new()
	for i in 12:
		var l := Label.new()
		l.text = "Line %d" % (i + 1)
		lines.add_child(l)
	scroll.add_child(lines)
	scroll_box.add_child(scroll)
	misc2.add_child(scroll_box)

	# Right: the parchment description panel and the confirmation dialog.
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 14)
	cols.add_child(right)
	right.add_child(_caption("Description panel (parchment, ink text)"))
	var desc := PanelContainer.new()
	desc.theme_type_variation = "DescriptionPanel"
	desc.custom_minimum_size = Vector2(380, 0)
	var dbox := VBoxContainer.new()
	dbox.add_theme_constant_override("separation", 6)
	desc.add_child(dbox)
	for pair in [["InkHeading", "Cellar room"], ["InkBody", "A stone room dug under the house. Keeps every crop."],
			["InkMuted", "NEEDS"], ["InkGood", "[x]  Carpentry 5"], ["InkWarn", "[  ]  700 coins  (have 0)"]]:
		var l := Label.new()
		l.theme_type_variation = pair[0]
		l.text = pair[1]
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dbox.add_child(l)
	var ink_bar := ProgressBar.new()
	ink_bar.theme_type_variation = "InkProgress"
	ink_bar.show_percentage = false
	ink_bar.custom_minimum_size = Vector2(0, 10)
	ink_bar.value = 40
	dbox.add_child(ink_bar)
	right.add_child(desc)
	right.add_child(_caption("Confirmation dialog (No focused)"))
	var dialog := UiTheme.confirm_dialog("Quit to the main menu?", "Progress since you last slept is lost.", "Yes, quit", "No")
	right.add_child(dialog)

	for i in 8:
		await process_frame
	# The focus ring on the dialog's No, the real thing on a real button.
	(dialog.get_meta("no") as Button).grab_focus()
	for i in 4:
		await process_frame
	var img := root.get_texture().get_image()
	var s := float(opt["scale"])
	if s != 1.0:
		img.resize(int(img.get_width() * s), int(img.get_height() * s), Image.INTERPOLATE_NEAREST)
	var out := str(opt.get("out", "art/style_tests/ui_gallery.png"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + out.get_base_dir()))
	img.save_png("res://" + out)
	print("saved ", out)
	quit()


func _caption(text: String) -> Label:
	var l := Label.new()
	l.theme_type_variation = "Hint"
	l.text = text
	return l


# One component in one state, drawn with that state's stylebox and font colour (focus over normal).
func _swatch(type: String, state: String, text: String) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(120, 38)
	var box := PanelContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(box)
	var sb: StyleBox = theme.get_stylebox("normal" if state == "focus" else state, type)
	box.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var key: String = STATE_FONT[state]
	l.add_theme_color_override("font_color", theme.get_color(key, type) if theme.has_color(key, type) else theme.get_color("font_color", type))
	box.add_child(l)
	if type == "TabActive":
		UiTheme.mark_active_tab(holder)
	if state == "focus":
		var ring := Panel.new()
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.add_theme_stylebox_override("panel", theme.get_stylebox("focus", type))
		ring.set_anchors_preset(Control.PRESET_FULL_RECT)
		holder.add_child(ring)
	return holder


# One inventory slot in one state: its frame (focus over its own normal), a picture and its count.
func _slot_swatch(type: String, state: String, icon_kind: String, count: String) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(68, 68)
	var frame := Panel.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sb: StyleBox = theme.get_stylebox("panel", type) if type == "SlotEmpty" else theme.get_stylebox("normal" if state == "focus" else state, type)
	frame.add_theme_stylebox_override("panel", sb)
	holder.add_child(frame)
	if icon_kind != "":
		var icon := ActionBar.RecipeIcon.new()
		icon.kind = icon_kind
		icon.tint = Color({"turnip": "8fd16b", "egg": "f2ead2", "fish_t": "b8b04a", "bandage": "e8e0d0", "seed": "e8c440"}[icon_kind])
		icon.set_anchors_preset(Control.PRESET_CENTER)
		icon.offset_left = -22
		icon.offset_top = -25
		icon.offset_right = 22
		icon.offset_bottom = 19
		icon.modulate = Color(1, 1, 1, 0.4) if type == "SlotLocked" else Color.WHITE
		holder.add_child(icon)
		var n := Label.new()
		n.theme_type_variation = "SlotCount"
		n.text = count
		n.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		n.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		n.grow_vertical = Control.GROW_DIRECTION_BEGIN
		n.offset_right = -6
		n.offset_bottom = -2
		if type == "SlotLocked":
			n.add_theme_color_override("font_color", UiTheme.MUTED)
		holder.add_child(n)
	if state == "focus":
		var ring := Panel.new()
		ring.add_theme_stylebox_override("panel", theme.get_stylebox("focus", type))
		ring.set_anchors_preset(Control.PRESET_FULL_RECT)
		holder.add_child(ring)
	return holder
