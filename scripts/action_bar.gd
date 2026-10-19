class_name ActionBar
extends CanvasLayer

## RuneScape-style action bar: tab buttons along the bottom and a panel above
## them. main.gd decides what each panel shows and handles its actions.

signal tab_pressed(tab_name: String)
signal action_pressed(action_id: String)

const TABS := [
	{"name": "Skills", "key": "K"},
	{"name": "Inventory", "key": "I"},
	{"name": "Gear", "key": "G"},
	{"name": "House", "key": "H"},
	{"name": "Settings", "key": "Esc"},
]

const COL_PANEL := Color("1d1611")
const COL_BORDER := Color("8a6a3a")
const COL_BUTTON := Color("2e2218")
const COL_BUTTON_HOVER := Color("43321f")
const COL_BUTTON_ACTIVE := Color("65472a")
const COL_BUTTON_DISABLED := Color("241b14")
const COL_TRACK := Color("120d09")
const COL_TEXT := Color("f1e4c8")
const COL_MUTED := Color("b3a27c")
const COL_ACCENT := Color("d9a94e")

var bar_buttons := {}      # tab name -> Button
var panel: PanelContainer
var title_label: Label
var rows_box: VBoxContainer
var active_tab := ""
var _last_key := ""


func _ready() -> void:
	# The full-screen root ignores the mouse so clicks outside the UI reach the game.
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	_place_bottom_center(bar, -12)
	root.add_child(bar)
	for tab in TABS:
		var button := Button.new()
		button.text = "%s  [%s]" % [tab["name"], tab["key"]]
		button.custom_minimum_size = Vector2(150, 44)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 16)
		_style_button(button, false)
		button.pressed.connect(_on_tab_pressed.bind(tab["name"]))
		bar.add_child(button)
		bar_buttons[tab["name"]] = button

	panel = PanelContainer.new()
	panel.visible = false
	panel.add_theme_stylebox_override("panel", _box(COL_PANEL, COL_BORDER, 3, 8, 16))
	_place_bottom_center(panel, -72)
	root.add_child(panel)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(500, 0)
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)

	var header := HBoxContainer.new()
	column.add_child(header)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", COL_ACCENT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.focus_mode = Control.FOCUS_NONE
	_style_button(close_button, false)
	close_button.pressed.connect(_on_action_pressed.bind("close"))
	header.add_child(close_button)

	column.add_child(HSeparator.new())

	rows_box = VBoxContainer.new()
	rows_box.add_theme_constant_override("separation", 10)
	column.add_child(rows_box)


func show_panel(tab: String, rows: Array) -> void:
	# Only rebuild when the content changes, so buttons aren't recreated mid-click.
	var key := JSON.stringify([tab, rows])
	if panel.visible and key == _last_key:
		return
	_last_key = key
	panel.visible = true
	title_label.text = tab
	_set_active(tab)
	for child in rows_box.get_children():
		rows_box.remove_child(child)
		child.queue_free()
	for row in rows:
		rows_box.add_child(_build_row(row))


func hide_panel() -> void:
	_last_key = ""
	panel.visible = false
	_set_active("")


func _build_row(data: Dictionary) -> Control:
	if data.has("section"):
		var heading := Label.new()
		heading.text = str(data["section"]).to_upper()
		heading.add_theme_font_size_override("font_size", 14)
		heading.add_theme_color_override("font_color", COL_BORDER)
		return heading

	if data.has("note"):
		var note := Label.new()
		note.text = str(data["note"])
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.add_theme_color_override("font_color", COL_MUTED)
		return note

	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 4)

	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 12)
	block.add_child(line)

	var name_label := Label.new()
	name_label.text = str(data.get("name", ""))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(name_label)

	var value_label := Label.new()
	value_label.text = str(data.get("value", ""))
	value_label.add_theme_color_override("font_color", COL_MUTED)
	line.add_child(value_label)

	if data.has("button"):
		var button := Button.new()
		button.text = str(data["button"])
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = not bool(data.get("enabled", true))
		_style_button(button, false)
		button.pressed.connect(_on_action_pressed.bind(str(data.get("action", ""))))
		line.add_child(button)

	if data.has("progress"):
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 10)
		bar.value = clampf(float(data["progress"]), 0.0, 1.0) * 100.0
		bar.add_theme_stylebox_override("background", _box(COL_TRACK, COL_BORDER, 1, 3, 0))
		bar.add_theme_stylebox_override("fill", _box(COL_ACCENT, COL_ACCENT, 0, 3, 0))
		block.add_child(bar)

	return block


func _set_active(tab: String) -> void:
	active_tab = tab
	for tab_name in bar_buttons:
		_style_button(bar_buttons[tab_name], tab_name == tab)


func _style_button(button: Button, active: bool) -> void:
	var base := COL_BUTTON_ACTIVE if active else COL_BUTTON
	button.add_theme_stylebox_override("normal", _box(base, COL_BORDER, 2, 6, 8))
	button.add_theme_stylebox_override("hover", _box(COL_BUTTON_HOVER, COL_ACCENT, 2, 6, 8))
	button.add_theme_stylebox_override("pressed", _box(COL_BUTTON_ACTIVE, COL_ACCENT, 2, 6, 8))
	button.add_theme_stylebox_override("disabled", _box(COL_BUTTON_DISABLED, Color("3d3024"), 2, 6, 8))
	button.add_theme_stylebox_override("focus", _box(base, COL_BORDER, 2, 6, 8))
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


func _place_bottom_center(ctrl: Control, bottom_offset: float) -> void:
	ctrl.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ctrl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ctrl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	ctrl.offset_bottom = bottom_offset


func _on_tab_pressed(tab: String) -> void:
	tab_pressed.emit(tab)


func _on_action_pressed(action_id: String) -> void:
	action_pressed.emit(action_id)
