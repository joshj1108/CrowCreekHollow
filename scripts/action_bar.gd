class_name ActionBar
extends CanvasLayer

## The game's menu. Opening a section shows a full-screen menu like a console game: the
## sections down the left, the current section's options on the right, and the controls in
## the footer. Sections open from their keys or from the list. main.gd decides what each
## section shows and handles its actions.

signal tab_pressed(tab_name: String)
var menu_frame: PanelContainer
# Sections in these menus fold away, so a long list shows only its headings until one is opened.
const COLLAPSIBLE_TABS := ["Settings"]
const HINT_DEFAULT := "Click a section or press its key to switch   ·   B to close   ·   Esc for Settings"
const HINT_SETTINGS := "Click a section or press its key to switch   ·   B or Esc to close"
var hint_label: Label
const ALWAYS_OPEN_SECTIONS := ["Game"]   # sections that never fold, so their options are always visible
var collapsed_sections := {}   # "tab|section" -> true while folded (folded is the default)
var _last_tab := ""
var _last_rows: Array = []
var _focus_section := ""       # a header to focus after it folds or unfolds
signal action_pressed(action_id: String)

const TABS := [
	{"name": "Skills", "key": "K"},
	{"name": "Inventory", "key": "I"},
	{"name": "Gear", "key": "G"},
	{"name": "Craft", "key": "C"},
	{"name": "Quests", "key": "Q"},
	{"name": "House", "key": "H"},
	{"name": "Buildings", "key": "U"},
	{"name": "Achievements", "key": "J"},
	{"name": "Settings", "key": "Esc"},
]

const SUBTITLES := {
	"Skills": "How far you have come",
	"Inventory": "What you carry",
	"Gear": "What you wear and hold",
	"Craft": "Make, cook, and build",
	"Quests": "What the farm asks of you",
	"House": "Keep it standing",
	"Buildings": "The workshop, the coop, and the barn",
	"Coop": "Hens and their feed",
	"Barn": "Livestock",
	"Well": "Water for the farm",
	"Achievements": "Things you have done",
	"Settings": "Time is paused while you are here",
}

const COL_DIM := Color(0.0, 0.0, 0.0, 0.62)
const COL_FRAME := Color("151009")
const COL_SIDE := Color("0e0a07")
const COL_CARD := Color("231a12")
const COL_NAV_ACTIVE := Color("3a2a18")
const COL_NAV_HOVER := Color("2a1e13")
const COL_BORDER := Color("8a6a3a")
const COL_BUTTON := Color("2e2218")
const COL_BUTTON_HOVER := Color("43321f")
const COL_BUTTON_ACTIVE := Color("65472a")
const COL_BUTTON_DISABLED := Color("241b14")
const COL_TRACK := Color("120d09")
const COL_TEXT := Color("f1e4c8")
const COL_MUTED := Color("b3a27c")
const COL_ACCENT := Color("d9a94e")
const COL_SHORT := Color("d0705a")   # a cost or level the player does not meet yet

var nav_buttons := {}      # tab name -> Button in the menu's section list
var panel: Control         # the full-screen menu; visible only while a panel is open
var menu_button: Button    # small corner button that opens the menu when it is closed
var last_section := "Skills"  # the last menu section shown, so the Menu button can return to it
var title_label: Label
var subtitle_label: Label
var scroll: ScrollContainer
var rows_box: VBoxContainer
var active_tab := ""
var _last_key := ""


func _ready() -> void:
	# The full-screen root ignores the mouse so clicks outside the UI reach the game.
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# A small corner button for mouse players. It reopens the last section shown.
	menu_button = Button.new()
	menu_button.text = "Menu"
	menu_button.focus_mode = Control.FOCUS_NONE
	menu_button.custom_minimum_size = Vector2(96, 34)
	menu_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	menu_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	menu_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
	menu_button.offset_left = -112
	menu_button.offset_top = -44
	menu_button.offset_right = -16
	menu_button.offset_bottom = -10
	menu_button.add_theme_font_size_override("font_size", 15)
	_style_button(menu_button, false)
	menu_button.pressed.connect(_on_menu_pressed)
	root.add_child(menu_button)

	panel = _build_menu()
	root.add_child(panel)


func _build_menu() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false

	var dim := ColorRect.new()
	dim.color = COL_DIM
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dim)

	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", _box(COL_FRAME, COL_BORDER, 2, 10, 0))
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.grow_horizontal = Control.GROW_DIRECTION_BOTH
	frame.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.add_child(frame)
	menu_frame = frame
	_fit_frame()
	get_viewport().size_changed.connect(_fit_frame)

	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 0)
	frame.add_child(split)

	# Left: the sections.
	var side := PanelContainer.new()
	side.add_theme_stylebox_override("panel", _box(COL_SIDE, COL_SIDE, 0, 10, 14))
	side.custom_minimum_size = Vector2(230, 0)
	split.add_child(side)
	var nav := VBoxContainer.new()
	nav.add_theme_constant_override("separation", 4)
	side.add_child(nav)
	var brand := Label.new()
	brand.text = "HALLOWVALE"
	brand.add_theme_font_size_override("font_size", 13)
	brand.add_theme_color_override("font_color", COL_BORDER)
	nav.add_child(brand)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 10)
	nav.add_child(gap)
	for tab in TABS:
		if tab["name"] == "Settings":
			nav.add_child(HSeparator.new())
		var button := Button.new()
		button.text = "%s     %s" % [tab["name"], tab["key"]]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 42)
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(_on_tab_pressed.bind(tab["name"]))
		nav.add_child(button)
		nav_buttons[tab["name"]] = button

	# Right: the section itself.
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side_name in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side_name, 24)
	split.add_child(margin)

	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 12)
	margin.add_child(main)

	var header := HBoxContainer.new()
	main.add_child(header)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", COL_ACCENT)
	titles.add_child(title_label)
	subtitle_label = Label.new()
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", COL_MUTED)
	titles.add_child(subtitle_label)
	main.add_child(HSeparator.new())

	# The options scroll, so long lists like crafting don't run off the screen.
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(scroll)
	rows_box = VBoxContainer.new()
	rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_box.add_theme_constant_override("separation", 8)
	scroll.add_child(rows_box)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	main.add_child(footer)
	var hints := Label.new()
	hints.text = HINT_DEFAULT
	hints.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hints.add_theme_font_size_override("font_size", 13)
	hints.add_theme_color_override("font_color", COL_MUTED)
	hint_label = hints
	footer.add_child(hints)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(120, 36)
	back.focus_mode = Control.FOCUS_ALL
	_style_button(back, false)
	back.pressed.connect(_on_action_pressed.bind("close"))
	footer.add_child(back)
	return overlay


# The menu is 1000 by 600 when the window allows, and shrinks to fit a smaller window.
func _fit_frame() -> void:
	var view := get_viewport().get_visible_rect().size
	menu_frame.custom_minimum_size = Vector2(minf(1000.0, view.x - 40.0), minf(600.0, view.y - 40.0))


func show_panel(tab: String, rows: Array) -> void:
	# Only rebuild when the content changes, so buttons aren't recreated mid-click.
	var key := JSON.stringify([tab, rows, collapsed_sections])
	if panel.visible and key == _last_key:
		return
	# Hold the rebuild while the mouse button is down, so a press can finish on the button it started on.
	if panel.visible and _pointer_held:
		return
	_last_key = key
	_last_tab = tab
	_last_rows = rows
	panel.visible = true
	menu_button.visible = false
	for section in TABS:
		if section["name"] == tab:
			last_section = tab
	if tab != active_tab:
		scroll.scroll_vertical = 0
	title_label.text = tab
	if hint_label != null:
		hint_label.text = HINT_SETTINGS if tab == "Settings" else HINT_DEFAULT
	subtitle_label.text = str(SUBTITLES.get(tab, ""))
	_set_active(tab)
	for child in rows_box.get_children():
		rows_box.remove_child(child)
		child.queue_free()
	for row in _with_folds(tab, rows):
		rows_box.add_child(_build_row(row))
	# Highlight the first usable button so a gamepad can reach it.
	call_deferred("_focus_first_button")


func hide_panel() -> void:
	_last_key = ""
	panel.visible = false
	menu_button.visible = true
	_set_active("")


# Turns each section of a collapsible menu into a header that shows its item count. The items
# are only included while the section is open.
func _with_folds(tab: String, rows: Array) -> Array:
	if not COLLAPSIBLE_TABS.has(tab):
		return rows
	var out: Array = []
	var i := 0
	while i < rows.size():
		var row: Dictionary = rows[i]
		if not row.has("section"):
			out.append(row)
			i += 1
			continue
		var group: Array = []
		var j := i + 1
		while j < rows.size() and not rows[j].has("section"):
			group.append(rows[j])
			j += 1
		var items := 0
		for item in group:
			if not item.has("note"):
				items += 1
		if ALWAYS_OPEN_SECTIONS.has(str(row["section"])):
			out.append(row)
			out.append_array(group)
			i = j
			continue
		var key := "%s|%s" % [tab, str(row["section"])]
		var folded := bool(collapsed_sections.get(key, true))
		out.append({"section_toggle": str(row["section"]), "key": key, "count": items, "folded": folded})
		if not folded:
			out.append_array(group)
		i = j
	return out


func _toggle_section(key: String) -> void:
	collapsed_sections[key] = not bool(collapsed_sections.get(key, true))
	_focus_section = key
	_last_key = ""
	show_panel(_last_tab, _last_rows)


func _find_toggle(node: Node, key: String) -> Button:
	for child in node.get_children():
		var button := child as Button
		if button != null and button.has_meta("toggle_key") and str(button.get_meta("toggle_key")) == key:
			return button
		var found := _find_toggle(child, key)
		if found != null:
			return found
	return null


func _focus_first_button() -> void:
	if _focus_section != "":
		var header := _find_toggle(rows_box, _focus_section)
		_focus_section = ""
		if header != null:
			header.grab_focus()
			return
	var button := _first_enabled_button(rows_box)
	if button != null:
		button.grab_focus()


func _first_enabled_button(node: Node) -> Button:
	for child in node.get_children():
		var button := child as Button
		if button != null and not button.disabled:
			return button
		var found := _first_enabled_button(child)
		if found != null:
			return found
	return null


func _build_row(data: Dictionary) -> Control:
	if data.has("tabs"):
		return _build_tabs(data)
	if data.has("split"):
		return _build_split(data["split"])
	if data.has("grid"):
		return _build_grid(data)
	if data.has("section_toggle"):
		var toggle := Button.new()
		var sign_text := "+" if bool(data["folded"]) else "-"
		toggle.text = "%s  %s   (%d)" % [sign_text, str(data["section_toggle"]).to_upper(), int(data["count"])]
		toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
		toggle.focus_mode = Control.FOCUS_ALL
		toggle.custom_minimum_size = Vector2(0, 34)
		_style_button(toggle, false)
		toggle.set_meta("toggle_key", str(data["key"]))
		toggle.pressed.connect(_toggle_section.bind(str(data["key"])))
		var toggle_space := MarginContainer.new()
		toggle_space.add_theme_constant_override("margin_top", 10)
		toggle_space.add_child(toggle)
		return toggle_space
	if data.has("section"):
		var heading := Label.new()
		heading.text = str(data["section"]).to_upper()
		heading.add_theme_font_size_override("font_size", 13)
		heading.add_theme_color_override("font_color", COL_ACCENT)
		var spaced := MarginContainer.new()
		spaced.add_theme_constant_override("margin_top", 10)
		spaced.add_child(heading)
		return spaced
	if data.has("note") and not data.has("name"):
		var note := Label.new()
		note.text = str(data["note"])
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.add_theme_font_size_override("font_size", 14)
		note.add_theme_color_override("font_color", COL_MUTED)
		return note
	return _build_card(data)


# One option: a name, a value, an optional button, and an optional progress bar.
func _build_card(data: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _box(COL_CARD, COL_CARD, 0, 8, 12))
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 6)
	card.add_child(block)

	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 14)
	block.add_child(line)

	# A struck name is a finished item, such as a completed quest. It is drawn dimmed with a line through it.
	var name_control: Control
	if bool(data.get("struck", false)):
		var rich := RichTextLabel.new()
		rich.bbcode_enabled = true
		rich.fit_content = true
		rich.scroll_active = false
		rich.text = "[s]%s[/s]" % str(data.get("name", ""))
		rich.add_theme_font_size_override("normal_font_size", 16)
		rich.add_theme_color_override("default_color", COL_MUTED)
		name_control = rich
	else:
		var name_label := Label.new()
		name_label.text = str(data.get("name", ""))
		name_label.add_theme_font_size_override("font_size", 16)
		name_control = name_label
	name_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(name_control)

	# Short values sit beside the name. Long ones, such as a tip's text, wrap on their own line
	# so the card never grows wider than the menu.
	var value_label := Label.new()
	value_label.text = str(data.get("value", ""))
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", COL_MUTED)
	if value_label.text.length() > 60:
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		block.add_child(value_label)
	else:
		line.add_child(value_label)

	if data.has("button"):
		var button := Button.new()
		button.text = str(data["button"])
		button.custom_minimum_size = Vector2(120, 34)
		button.focus_mode = Control.FOCUS_ALL
		button.disabled = not bool(data.get("enabled", true))
		_style_button(button, false)
		button.pressed.connect(_on_action_pressed.bind(str(data.get("action", ""))))
		line.add_child(button)

	if data.has("note"):
		var note := Label.new()
		note.text = str(data["note"])
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.add_theme_font_size_override("font_size", 14)
		note.add_theme_color_override("font_color", COL_MUTED)
		block.add_child(note)

	if data.has("progress"):
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 8)
		bar.value = clampf(float(data["progress"]), 0.0, 1.0) * 100.0
		bar.add_theme_stylebox_override("background", _box(COL_TRACK, COL_TRACK, 0, 4, 0))
		bar.add_theme_stylebox_override("fill", _box(COL_ACCENT, COL_ACCENT, 0, 4, 0))
		block.add_child(bar)
	return card


# A row of sub-tab buttons. The active one is highlighted; each button sends its action.
func _build_tabs(data: Dictionary) -> Control:
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", 8)
	for tab in data["tabs"]:
		var button := Button.new()
		button.text = str(tab["name"])
		button.custom_minimum_size = Vector2(120, 36)
		button.focus_mode = Control.FOCUS_ALL
		_style_button(button, str(tab["id"]) == str(data.get("active", "")))
		button.pressed.connect(_on_action_pressed.bind(str(tab.get("action", ""))))
		holder.add_child(button)
	return holder


# A grid of item slots, like a bag or equipment panel. Each cell is a dict:
# color (hex, optional), label, tip, count (optional), empty, or locked.
func _build_grid(data: Dictionary) -> Control:
	var grid := GridContainer.new()
	grid.columns = int(data.get("columns", 5))
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for cell in data["grid"]:
		grid.add_child(_build_cell(cell))
	return grid


func _build_cell(cell: Dictionary) -> Control:
	var empty := bool(cell.get("empty", false))
	var locked := bool(cell.get("locked", false))
	var filled := not empty and not locked
	var bg := COL_BUTTON_DISABLED
	if filled:
		bg = Color(str(cell.get("color", "8a6a3a")))
	var panel_box := PanelContainer.new()
	panel_box.custom_minimum_size = Vector2(78, 78)
	panel_box.tooltip_text = str(cell.get("tip", ""))
	panel_box.add_theme_stylebox_override("panel", _box(bg, COL_BORDER if filled else Color("3d3024"), 2, 6, 3))

	var label := Label.new()
	label.text = str(cell.get("label", ""))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", COL_TEXT if filled else COL_MUTED)
	panel_box.add_child(label)

	if cell.has("count"):
		var count := Label.new()
		count.text = str(cell["count"])
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count.add_theme_font_size_override("font_size", 13)
		count.add_theme_color_override("font_color", COL_ACCENT)
		panel_box.add_child(count)
	return panel_box


# The recipe grid on the left and the picked recipe's details on the right.
func _build_split(data: Dictionary) -> Control:
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", 16)
	holder.alignment = BoxContainer.ALIGNMENT_BEGIN
	var grid := _build_recipes({"recipes": data["recipes"], "columns": data.get("columns", 4)})
	holder.add_child(grid)
	if not data.get("detail", {}).is_empty():
		holder.add_child(_build_detail(data["detail"]))
	return holder


# Recipe tiles: a drawn picture of each item with its name. Picking one shows its details below.
# Each recipe dict: key, name, icon, tint (hex), enabled, selected, action.
func _build_recipes(data: Dictionary) -> Control:
	var grid := GridContainer.new()
	grid.columns = int(data.get("columns", 5))
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for recipe in data["recipes"]:
		grid.add_child(_build_recipe_tile(recipe))
	return grid


func _build_recipe_tile(recipe: Dictionary) -> Control:
	var selected := bool(recipe.get("selected", false))
	var lit := bool(recipe.get("enabled", false)) or selected
	var tile := Button.new()
	tile.custom_minimum_size = Vector2(88, 98)
	tile.focus_mode = Control.FOCUS_ALL
	tile.tooltip_text = str(recipe.get("name", ""))
	tile.clip_contents = true
	var base := COL_BUTTON_ACTIVE if selected else COL_BUTTON
	tile.add_theme_stylebox_override("normal", _box(base, COL_ACCENT if selected else COL_BORDER, 2, 8, 4))
	tile.add_theme_stylebox_override("hover", _box(COL_BUTTON_HOVER, COL_ACCENT, 2, 8, 4))
	tile.add_theme_stylebox_override("pressed", _box(COL_BUTTON_ACTIVE, COL_ACCENT, 2, 8, 4))
	tile.add_theme_stylebox_override("focus", _box(base, COL_ACCENT, 2, 8, 4))
	tile.pressed.connect(_on_action_pressed.bind(str(recipe.get("action", ""))))

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 4)
	tile.add_child(box)

	var icon := RecipeIcon.new()
	icon.kind = str(recipe.get("icon", ""))
	icon.tint = Color(str(recipe.get("tint", "6b4a3a")))
	icon.custom_minimum_size = Vector2(56, 56)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.modulate = Color(1, 1, 1, 1) if lit else Color(1, 1, 1, 0.45)
	box.add_child(icon)

	var name_label := Label.new()
	name_label.text = str(recipe.get("name", ""))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", COL_TEXT if lit else COL_MUTED)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(name_label)
	return tile


# The details of the picked recipe: the picture, what it does, what it costs, and the button to make it.
func _build_detail(recipe: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(280, 0)
	card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	card.add_theme_stylebox_override("panel", _box(COL_CARD, COL_BORDER, 1, 8, 14))
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 10)
	card.add_child(block)

	var icon := RecipeIcon.new()
	icon.kind = str(recipe.get("icon", ""))
	icon.tint = Color(str(recipe.get("tint", "6b4a3a")))
	icon.custom_minimum_size = Vector2(96, 96)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	block.add_child(icon)

	var title := Label.new()
	title.text = str(recipe.get("name", ""))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 19)
	block.add_child(title)

	var desc := Label.new()
	desc.text = str(recipe.get("desc", ""))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", COL_MUTED)
	block.add_child(desc)

	var level_text := str(recipe.get("level_text", ""))
	if level_text != "":
		var level := Label.new()
		level.text = level_text
		level.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		level.add_theme_font_size_override("font_size", 13)
		level.add_theme_color_override("font_color", COL_TEXT if bool(recipe.get("level_ok", true)) else COL_SHORT)
		block.add_child(level)

	if not recipe.get("costs", []).is_empty():
		var costs := VBoxContainer.new()
		costs.add_theme_constant_override("separation", 4)
		block.add_child(costs)
		for cost in recipe["costs"]:
			var have := int(cost["have"])
			var need := int(cost["need"])
			var line := HBoxContainer.new()
			var what := Label.new()
			what.text = str(cost["label"])
			what.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			what.add_theme_font_size_override("font_size", 14)
			what.add_theme_color_override("font_color", COL_TEXT if have >= need else COL_SHORT)
			line.add_child(what)
			var count := Label.new()
			count.text = "%d / %d" % [have, need]
			count.add_theme_font_size_override("font_size", 14)
			count.add_theme_color_override("font_color", COL_ACCENT if have >= need else COL_SHORT)
			line.add_child(count)
			costs.add_child(line)

	if recipe.has("button"):
		var button := Button.new()
		button.text = str(recipe.get("button", "Make"))
		button.custom_minimum_size = Vector2(0, 40)
		button.focus_mode = Control.FOCUS_ALL
		button.disabled = not bool(recipe.get("enabled", false)) or str(recipe.get("action", "")) == ""
		_style_button(button, false)
		button.pressed.connect(_on_action_pressed.bind(str(recipe.get("action", ""))))
		block.add_child(button)
	return card


func _set_active(tab: String) -> void:
	active_tab = tab
	for tab_name in nav_buttons:
		_style_nav(nav_buttons[tab_name], tab_name == tab)


# The section list: the active section gets a gold edge and a lighter fill.
func _style_nav(button: Button, active: bool) -> void:
	var base: Color = COL_NAV_ACTIVE if active else Color(0.0, 0.0, 0.0, 0.0)
	var normal := _box(base, COL_ACCENT, 0, 6, 10)
	normal.border_width_left = 4 if active else 0
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", _box(COL_NAV_HOVER, COL_NAV_HOVER, 0, 6, 10))
	button.add_theme_stylebox_override("pressed", _box(COL_NAV_HOVER, COL_NAV_HOVER, 0, 6, 10))
	button.add_theme_stylebox_override("focus", _box(COL_NAV_HOVER, COL_ACCENT, 1, 6, 10))
	button.add_theme_color_override("font_color", COL_ACCENT if active else COL_TEXT)


func _style_button(button: Button, active: bool) -> void:
	var base: Color = COL_BUTTON_ACTIVE if active else COL_BUTTON
	button.add_theme_stylebox_override("normal", _box(base, COL_BORDER, 2, 6, 8))
	button.add_theme_stylebox_override("hover", _box(COL_BUTTON_HOVER, COL_ACCENT, 2, 6, 8))
	button.add_theme_stylebox_override("pressed", _box(COL_BUTTON_ACTIVE, COL_ACCENT, 2, 6, 8))
	button.add_theme_stylebox_override("disabled", _box(COL_BUTTON_DISABLED, Color("3d3024"), 2, 6, 8))
	button.add_theme_stylebox_override("focus", _box(base, COL_ACCENT, 2, 6, 8))
	button.add_theme_color_override("font_color", COL_TEXT)
	button.add_theme_color_override("font_disabled_color", COL_MUTED)


func _box(bg: Color, border: Color, border_width: int, radius: int, margin: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	return sb


var _pointer_held := false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pointer_held = event.pressed


func _on_menu_pressed() -> void:
	tab_pressed.emit(last_section)


func _on_tab_pressed(tab: String) -> void:
	tab_pressed.emit(tab)


func _on_action_pressed(action_id: String) -> void:
	action_pressed.emit(action_id)


# A small drawn picture for a recipe, made from shapes so it needs no image files.
# kind picks the drawing; tint is the item's main color.
class RecipeIcon extends Control:
	var kind := ""
	var tint := Color("6b4a3a")
	var _org := Vector2.ZERO
	var _sz := 1.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _pt(x: float, y: float) -> Vector2:
		return _org + Vector2(x, y) * _sz

	func _poly(pairs: Array) -> PackedVector2Array:
		var out := PackedVector2Array()
		for pair in pairs:
			out.append(_pt(pair[0], pair[1]))
		return out

	# An ellipse as a polygon, centred on (cx, cy) with radii rx and ry.
	func _ellipse(cx: float, cy: float, rx: float, ry: float) -> PackedVector2Array:
		var out := PackedVector2Array()
		for i in range(24):
			var a := TAU * float(i) / 24.0
			out.append(_pt(cx + cos(a) * rx, cy + sin(a) * ry))
		return out

	func _rock() -> PackedVector2Array:
		return _poly([[0.12, 0.7], [0.25, 0.3], [0.55, 0.15], [0.88, 0.35], [0.82, 0.78], [0.45, 0.88]])

	func _draw() -> void:
		_sz = minf(size.x, size.y)
		_org = (size - Vector2(_sz, _sz)) * 0.5
		var light := tint.lightened(0.3)
		var dark := tint.darkened(0.45)
		var metal := Color("b9b4a6")
		match kind:
			"sword":
				draw_colored_polygon(_poly([[0.5, 0.02], [0.58, 0.12], [0.58, 0.62], [0.42, 0.62], [0.42, 0.12]]), metal)
				draw_line(_pt(0.3, 0.64), _pt(0.7, 0.64), dark, 0.09 * _sz)
				draw_line(_pt(0.5, 0.66), _pt(0.5, 0.9), dark, 0.1 * _sz)
				draw_circle(_pt(0.5, 0.94), 0.05 * _sz, light)
			"shield":
				var outline := _poly([[0.2, 0.1], [0.8, 0.1], [0.8, 0.5], [0.5, 0.92], [0.2, 0.5]])
				draw_colored_polygon(outline, tint)
				outline.append(outline[0])
				draw_polyline(outline, dark, 0.04 * _sz)
				draw_line(_pt(0.5, 0.2), _pt(0.5, 0.8), light, 0.06 * _sz)
			"hat":
				draw_rect(Rect2(_pt(0.3, 0.18), Vector2(0.4, 0.4) * _sz), tint)
				draw_rect(Rect2(_pt(0.3, 0.5), Vector2(0.4, 0.08) * _sz), dark)
				draw_rect(Rect2(_pt(0.12, 0.58), Vector2(0.76, 0.12) * _sz), light)
			"shirt":
				draw_colored_polygon(_poly([[0.32, 0.12], [0.42, 0.08], [0.58, 0.08], [0.68, 0.12], [0.92, 0.3], [0.8, 0.46], [0.7, 0.38], [0.7, 0.92], [0.3, 0.92], [0.3, 0.38], [0.2, 0.46], [0.08, 0.3]]), tint)
				draw_arc(_pt(0.5, 0.1), 0.1 * _sz, 0.0, PI, 10, dark, 0.04 * _sz)
			"pants":
				draw_rect(Rect2(_pt(0.18, 0.1), Vector2(0.64, 0.22) * _sz), tint)
				draw_colored_polygon(_poly([[0.18, 0.3], [0.48, 0.3], [0.44, 0.92], [0.22, 0.92]]), tint)
				draw_colored_polygon(_poly([[0.52, 0.3], [0.82, 0.3], [0.78, 0.92], [0.56, 0.92]]), tint)
				draw_line(_pt(0.18, 0.32), _pt(0.82, 0.32), dark, 0.03 * _sz)
			"boots":
				draw_colored_polygon(_poly([[0.28, 0.1], [0.5, 0.1], [0.5, 0.62], [0.88, 0.7], [0.9, 0.86], [0.28, 0.86]]), tint)
				draw_rect(Rect2(_pt(0.28, 0.82), Vector2(0.62, 0.07) * _sz), dark)
			"pendant":
				draw_arc(_pt(0.5, 0.12), 0.38 * _sz, PI * 0.2, PI * 0.8, 16, metal, 0.04 * _sz)
				draw_circle(_pt(0.5, 0.62), 0.16 * _sz, tint)
				draw_arc(_pt(0.5, 0.62), 0.16 * _sz, 0.0, TAU, 24, light, 0.03 * _sz)
				draw_circle(_pt(0.5, 0.62), 0.06 * _sz, light)
			"bracer":
				draw_rect(Rect2(_pt(0.08, 0.36), Vector2(0.84, 0.28) * _sz), tint)
				draw_rect(Rect2(_pt(0.08, 0.36), Vector2(0.84, 0.04) * _sz), light)
				for x in [0.2, 0.5, 0.8]:
					draw_circle(_pt(x, 0.5), 0.035 * _sz, light)
			"bow":
				draw_arc(_pt(0.78, 0.5), 0.5 * _sz, PI * 0.5, PI * 1.5, 24, tint, 0.07 * _sz)
				draw_line(_pt(0.78, 0.0), _pt(0.78, 1.0), light, 0.02 * _sz)
			"arrow":
				draw_line(_pt(0.12, 0.88), _pt(0.84, 0.16), light, 0.05 * _sz)
				draw_colored_polygon(_poly([[0.94, 0.06], [0.58, 0.14], [0.86, 0.42]]), metal)
				draw_colored_polygon(_poly([[0.08, 0.92], [0.12, 0.6], [0.4, 0.88]]), tint)
			"bowl":
				var bowl := PackedVector2Array()
				for i in range(17):
					var a := PI * float(i) / 16.0
					bowl.append(_pt(0.5, 0.42) + Vector2(cos(a), sin(a)) * 0.42 * _sz)
				draw_colored_polygon(bowl, tint)
				draw_rect(Rect2(_pt(0.08, 0.42), Vector2(0.84, 0.06) * _sz), light)
				draw_line(_pt(0.4, 0.2), _pt(0.36, 0.06), light, 0.03 * _sz)
				draw_line(_pt(0.6, 0.2), _pt(0.64, 0.06), light, 0.03 * _sz)
			"axe":
				draw_line(_pt(0.3, 0.92), _pt(0.62, 0.22), light, 0.07 * _sz)
				draw_colored_polygon(_poly([[0.56, 0.16], [0.92, 0.3], [0.78, 0.52], [0.5, 0.42]]), metal)
			"pick":
				draw_line(_pt(0.22, 0.92), _pt(0.76, 0.26), light, 0.07 * _sz)
				draw_polyline(_poly([[0.06, 0.4], [0.5, 0.1], [0.94, 0.4]]), metal, 0.09 * _sz)
			"lantern":
				draw_arc(_pt(0.5, 0.34), 0.14 * _sz, PI, TAU, 12, dark, 0.03 * _sz)
				draw_rect(Rect2(_pt(0.3, 0.36), Vector2(0.4, 0.5) * _sz), dark)
				draw_circle(_pt(0.5, 0.6), 0.14 * _sz, Color("e8c060"))
				draw_colored_polygon(_poly([[0.22, 0.38], [0.5, 0.12], [0.78, 0.38]]), tint)
			"pack":
				draw_arc(_pt(0.5, 0.3), 0.18 * _sz, PI, TAU, 12, dark, 0.04 * _sz)
				draw_rect(Rect2(_pt(0.2, 0.3), Vector2(0.6, 0.62) * _sz), tint)
				draw_rect(Rect2(_pt(0.2, 0.3), Vector2(0.6, 0.2) * _sz), light)
				draw_line(_pt(0.2, 0.62), _pt(0.8, 0.62), dark, 0.03 * _sz)
			"hoe":
				draw_line(_pt(0.3, 0.95), _pt(0.7, 0.12), tint, 0.06 * _sz)
				draw_colored_polygon(_poly([[0.5, 0.12], [0.92, 0.2], [0.86, 0.42], [0.5, 0.36]]), metal)
			"crop":
				draw_line(_pt(0.5, 0.95), _pt(0.5, 0.45), dark, 0.05 * _sz)
				draw_colored_polygon(_ellipse(0.32, 0.36, 0.2, 0.12), light)
				draw_colored_polygon(_ellipse(0.68, 0.34, 0.2, 0.12), light)
				draw_colored_polygon(_ellipse(0.5, 0.66, 0.24, 0.22), tint)
			"fish":
				draw_colored_polygon(_ellipse(0.42, 0.5, 0.36, 0.22), tint)
				draw_colored_polygon(_poly([[0.72, 0.5], [0.98, 0.25], [0.98, 0.75]]), dark)
				draw_circle(_pt(0.24, 0.45), 0.04 * _sz, dark)
			"jar":
				draw_rect(Rect2(_pt(0.3, 0.12), Vector2(0.4, 0.12) * _sz), metal)
				draw_rect(Rect2(_pt(0.22, 0.22), Vector2(0.56, 0.7) * _sz), tint)
				draw_rect(Rect2(_pt(0.3, 0.45), Vector2(0.4, 0.2) * _sz), light)
			"seed":
				draw_colored_polygon(_ellipse(0.5, 0.62, 0.3, 0.28), tint)
				draw_colored_polygon(_poly([[0.4, 0.4], [0.6, 0.4], [0.5, 0.2]]), dark)
				draw_circle(_pt(0.42, 0.62), 0.04 * _sz, light)
				draw_circle(_pt(0.58, 0.66), 0.04 * _sz, light)
			"log":
				draw_rect(Rect2(_pt(0.2, 0.32), Vector2(0.6, 0.36) * _sz), tint)
				draw_circle(_pt(0.2, 0.5), 0.18 * _sz, light)
				draw_circle(_pt(0.2, 0.5), 0.08 * _sz, dark)
			"fiber":
				for x in [0.2, 0.4, 0.6, 0.8]:
					draw_line(_pt(x, 0.9), _pt(x + 0.1, 0.1), tint, 0.05 * _sz)
			"resin":
				draw_colored_polygon(_ellipse(0.5, 0.56, 0.36, 0.3), tint)
				draw_circle(_pt(0.4, 0.44), 0.08 * _sz, light)
			"stone":
				draw_colored_polygon(_rock(), tint)
				draw_line(_pt(0.3, 0.45), _pt(0.5, 0.6), dark, 0.03 * _sz)
			"ore":
				draw_colored_polygon(_rock(), tint)
				for sparkle in [[0.4, 0.5], [0.6, 0.62], [0.5, 0.36]]:
					draw_circle(_pt(sparkle[0], sparkle[1]), 0.05 * _sz, light)
			"bar":
				draw_colored_polygon(_poly([[0.12, 0.62], [0.28, 0.34], [0.72, 0.34], [0.88, 0.62], [0.72, 0.74], [0.28, 0.74]]), tint)
				draw_line(_pt(0.3, 0.42), _pt(0.7, 0.42), light, 0.04 * _sz)
			_:
				draw_circle(_pt(0.5, 0.5), 0.3 * _sz, tint)

