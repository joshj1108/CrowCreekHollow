class_name ActionBar
extends CanvasLayer

## The game's menu. Opening a section shows only that section, full screen: its options and a
## footer. Sections open from the section wheel (section_wheel.gd), never from a list of other
## sections, so a section on screen never offers a way to reach the others. main.gd decides what
## each section shows and handles its actions.

signal menu_pressed
var menu_frame: PanelContainer
const HINT_DEFAULT := "B or Esc to close   ·   Shift or the left stick opens the section wheel"
const HINT_SETTINGS := "B or Esc to close"
const HINT_BACK := "B or Esc to go back to the Pause menu"
var hint_label: Label
var _last_tab := ""
var _last_rows: Array = []
signal action_pressed(action_id: String)

const SUBTITLES := {
	"Skills": "How far you have come",
	"Inventory": "What you carry",
	"Gear": "What you wear and hold",
	"Craft": "Make, cook, and build",
	"Quests": "What the farm asks of you",
	"House": "Keep it standing",
	"Buildings": "Grow the homestead and make it yours",
	"Desk": "Post, bills, and a little peace",
	"Coop": "Hens and their feed",
	"Barn": "Livestock",
	"Well": "Water for the farm",
	"Achievements": "Things you have done",
	"Pause": "Time is paused while you are here",
	"Settings": "Saved at once, for every save slot",
	"Controls": "Keyboard, mouse and gamepad",
	"Diary": "What you have learned, and what to do next",
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
const COL_TEXT := Color("e8dcc0")
const COL_MUTED := Color("9a8a6a")
const COL_ACCENT := Color("d8b050")
const COL_SHORT := Color("d0705a")   # a cost or level the player does not meet yet

var panel: Control         # the full-screen menu; visible only while a panel is open
var menu_button: Button    # small corner button that opens the section wheel when no section is open
var title_label: Label
var subtitle_label: Label
var scroll: ScrollContainer
var rows_box: VBoxContainer
var grid_top: VBoxContainer       # a grid panel's tab strip, fixed above its list
var grid_body: HBoxContainer      # the scrolling list on the left, and side_scroll on the right
var side_column: VBoxContainer   # beside the list: the picked recipe's card, and its button pinned below
var side_scroll: ScrollContainer  # the card, which scrolls only when its text is longer than the column
var side_box: VBoxContainer
var side_foot: VBoxContainer      # the card's button (Make, Cook), always in view
const SIDE_WIDTH := 300
var active_tab := ""
var _last_key := ""

# The ledger layout. A panel whose rows carry {"tab": name} markers is split into tabs (LB/RB or Q/E),
# with a list of one-line entries on the left and the focused entry's details on the right.
# An entry is a row dict: name, plus optional status, status_kind (ok, short, done, info), value,
# about, needs ([{text, ok, have}]), note, progress, and button, action, enabled.
const COL_OK := Color("8fb069")
const LEDGER_DETAIL_WIDTH := 380
var ledger: VBoxContainer
var tab_strip: HBoxContainer
var list_scroll: ScrollContainer
var list_box: VBoxContainer
var detail_box: VBoxContainer
var prompt_bar: HBoxContainer
var close_button: Button
var ledger_tabs := {}             # panel -> the open tab's index, kept until the game closes
var _ledger_entries: Array = []   # the open tab's entries, in list order
var _ledger_pick := 0             # the focused entry
var _ledger_tab_count := 0      # tabs in the open panel, ledger or a grid panel's tab strip
var _grid_tabs := {}            # a grid panel's {"tabs", "active"} row, stepped by LB/RB or Q/E
var _pad_glyphs := false          # true once a gamepad was used last, so prompts show its buttons
var _pointer_last := false        # true when the last press came from the mouse
var _detail_button: Button        # the picked recipe's Make (Cook, Equip...) button in a grid panel
var _picked_action := ""          # the picked tile's action, for focus to return to
var _jump_key := ""               # a tile picked with A, Space or Enter: focus moves to its detail button
var _amounts := {}                # an amount entry's chosen count, by its amount_id, kept until the game closes
var _amount_hold := 0.0           # how long left or right has been held on an amount entry, for the repeat
const AMOUNT_REPEAT_DELAY := 0.35
const AMOUNT_REPEAT := 0.07

# The diary is a book: a spread of two pages, with a tab marker down its right edge for each section.
# A panel with a {"book": sections} row shows it; each section is {name, heading, pages}, and each page
# {title, text, new, done, gap, hand}. Left and right turn a spread (running on into the next section),
# LB/RB or Q/E jump between sections. The open place is kept until the game closes.
const PAPER := Color("c4ae84")
const PAPER_EDGE := Color("8f7a54")
const INK := Color("2b2016")
const INK_FADED := Color("6a573c")
const INK_RED := Color("8a3424")
const INK_HANDS := {"agnes": Color("3d2414"), "yours": Color("22303e")}
const LEATHER := Color("3b2417")
# Each section keeps its ribbon colour, whichever tabs are showing.
const RIBBONS := {"First day": Color("7a3a2c"), "The farm asks": Color("7a3a2c"), "Notes": Color("4f6b3a"),
	"Agnes Rook": Color("6b4a6a"), "The wood": Color("3a5a7a"), "The second year": Color("5a4a5e"), "Afterword": Color("8a6a3a")}
var book: HBoxContainer
var book_spread_box: HBoxContainer
var book_tabs: VBoxContainer
var book_sections: Array = []
var book_section := 0
var book_spread := 0


func _ready() -> void:
	# The full-screen root ignores the mouse so clicks outside the UI reach the game.
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# A small corner button for mouse players. It opens the section wheel.
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
	frame.add_theme_stylebox_override("panel", _skin(UiSkin.panel(14), _box(COL_FRAME, COL_BORDER, 2, 10, 0)))
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.grow_horizontal = Control.GROW_DIRECTION_BOTH
	frame.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.add_child(frame)
	menu_frame = frame
	_fit_frame()
	get_viewport().size_changed.connect(_fit_frame)

	# The section fills the frame. There is no list of other sections here.
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side_name in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side_name, 24)
	frame.add_child(margin)

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

	# A grid panel's tab strip stays put above the list.
	grid_top = VBoxContainer.new()
	main.add_child(grid_top)
	# The options scroll, so long lists like crafting don't run off the screen. A grid panel's detail card
	# (Craft's recipe and its Make button) sits beside the list instead, and stays in view while it scrolls.
	grid_body = HBoxContainer.new()
	grid_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_body.add_theme_constant_override("separation", 16)
	main.add_child(grid_body)
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	# Moving the gamepad's focus down the list scrolls it along.
	scroll.follow_focus = true
	grid_body.add_child(scroll)
	rows_box = VBoxContainer.new()
	rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows_box.add_theme_constant_override("separation", 8)
	scroll.add_child(rows_box)
	side_column = VBoxContainer.new()
	side_column.custom_minimum_size = Vector2(SIDE_WIDTH, 0)
	side_column.add_theme_constant_override("separation", 8)
	side_column.visible = false
	grid_body.add_child(side_column)
	side_scroll = ScrollContainer.new()
	side_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_column.add_child(side_scroll)
	side_box = VBoxContainer.new()
	side_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_scroll.add_child(side_box)
	side_foot = VBoxContainer.new()
	side_column.add_child(side_foot)
	main.add_child(_build_ledger_frame())
	main.add_child(_build_book_frame())

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	main.add_child(footer)
	prompt_bar = HBoxContainer.new()
	prompt_bar.add_theme_constant_override("separation", 18)
	prompt_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prompt_bar.alignment = BoxContainer.ALIGNMENT_BEGIN
	prompt_bar.visible = false
	footer.add_child(prompt_bar)
	var hints := Label.new()
	hints.text = HINT_DEFAULT
	hints.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hints.add_theme_font_size_override("font_size", 13)
	hints.add_theme_color_override("font_color", COL_MUTED)
	hint_label = hints
	footer.add_child(hints)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size = Vector2(120, 36)
	close.focus_mode = Control.FOCUS_ALL
	_style_button(close, false)
	close.pressed.connect(_on_action_pressed.bind("close"))
	footer.add_child(close)
	close_button = close
	return overlay


# The menu is 1000 by 600 when the window allows, and shrinks to fit a smaller window.
func _fit_frame() -> void:
	var view := get_viewport().get_visible_rect().size
	menu_frame.custom_minimum_size = Vector2(minf(1000.0, view.x - 40.0), minf(600.0, view.y - 40.0))


func show_panel(tab: String, rows: Array) -> void:
	# Only rebuild when the content changes, so buttons aren't recreated mid-click.
	var key := JSON.stringify([tab, rows])
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
	# A rebuild of the same tab keeps focus on the button that was pressed, so a gamepad can press + again.
	var keep_action := ""
	var focused := get_viewport().gui_get_focus_owner()
	if tab == active_tab and focused is Button and focused.has_meta("action"):
		keep_action = str(focused.get_meta("action"))
	var opening := tab != active_tab
	if opening:
		scroll.scroll_vertical = 0
		list_scroll.scroll_vertical = 0
		_ledger_pick = 0
	title_label.text = tab
	if hint_label != null:
		hint_label.text = HINT_BACK if tab in ["Settings", "Controls"] else (HINT_SETTINGS if tab == "Pause" else HINT_DEFAULT)
	subtitle_label.text = str(SUBTITLES.get(tab, ""))
	active_tab = tab
	_clear(rows_box)
	_clear(grid_top)
	_clear(side_box)
	_clear(side_foot)
	side_column.visible = false
	_detail_button = null
	_picked_action = ""
	var book_row := {}
	for row in rows:
		if row is Dictionary and row.has("book"):
			book_row = row
	book.visible = not book_row.is_empty()
	if book.visible:
		grid_body.visible = false
		ledger.visible = false
		prompt_bar.visible = true
		hint_label.visible = false
		close_button.focus_mode = Control.FOCUS_NONE
		_show_book(book_row["book"], opening)
		return
	var is_ledger := _has_tabs(rows)
	_grid_tabs = {}
	for row in rows:
		if not is_ledger and row is Dictionary and row.has("tabs"):
			_grid_tabs = row
	var prompted := is_ledger or not _grid_tabs.is_empty()
	grid_body.visible = not is_ledger
	ledger.visible = is_ledger
	prompt_bar.visible = prompted
	hint_label.visible = not prompted
	if not _grid_tabs.is_empty():
		_ledger_tab_count = _grid_tabs["tabs"].size()
		_refresh_prompts()
	close_button.focus_mode = Control.FOCUS_NONE if is_ledger else Control.FOCUS_ALL
	if is_ledger:
		_build_ledger(tab, rows)
		return
	for row in rows:
		if row.has("tabs"):
			grid_top.add_child(_build_tabs(row))
		elif row.has("split") and not row["split"].get("detail", {}).is_empty():
			# The grid scrolls on the left; its detail card stays on the right.
			rows_box.add_child(_centred(_build_split_grid(row["split"])))
			var card := _build_detail(row["split"]["detail"])
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.custom_minimum_size.x = 0
			side_box.add_child(card)
			# The button leaves the card for the foot of the column, so it never scrolls out of view.
			if _detail_button != null:
				_detail_button.get_parent().remove_child(_detail_button)
				side_foot.add_child(_detail_button)
			side_scroll.scroll_vertical = 0
			side_column.visible = true
		else:
			rows_box.add_child(_build_row(row))
	# Highlight the first usable button so a gamepad can reach it.
	call_deferred("_focus_first_button", keep_action)


func hide_panel() -> void:
	_last_key = ""
	panel.visible = false
	menu_button.visible = true
	active_tab = ""


func _focus_first_button(keep_action: String = "") -> void:
	# A recipe picked with A goes straight to its button, when that can be pressed.
	var jump := _jump_key
	_jump_key = ""
	if jump != "" and _jump_to_detail(jump):
		return
	if keep_action != "":
		var kept := _find_action_button(grid_body, keep_action)
		# A button that can't be pressed any more (the last fish cooked) hands focus back to its recipe.
		if kept == null and _picked_action != "":
			kept = _find_action_button(grid_body, _picked_action)
		if kept != null:
			kept.grab_focus()
			return
	var button := _first_enabled_button(rows_box)
	# A panel with nothing to press (the stand with nothing to sell) focuses Close, so B and A still work.
	if button == null and close_button.focus_mode != Control.FOCUS_NONE:
		button = close_button
	if button != null:
		button.grab_focus()


func _find_action_button(node: Node, action_id: String) -> Button:
	for child in node.get_children():
		var button := child as Button
		if button != null and _focusable(button) and str(button.get_meta("action", "")) == action_id:
			return button
		var found := _find_action_button(child, action_id)
		if found != null:
			return found
	return null


func _first_enabled_button(node: Node) -> Button:
	for child in node.get_children():
		var button := child as Button
		if button != null and _focusable(button):
			return button
		var found := _first_enabled_button(child)
		if found != null:
			return found
	return null


# A button the D-pad can land on: shown, pressable and in the focus path (tab buttons are not).
func _focusable(button: Button) -> bool:
	return not button.disabled and button.focus_mode != Control.FOCUS_NONE and button.is_visible_in_tree()


# A disabled button leaves the focus path, so the D-pad never stops on something that can't be pressed.
static func _set_enabled(button: Button, enabled: bool) -> void:
	button.disabled = not enabled
	button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE


func _build_row(data: Dictionary) -> Control:
	if data.has("tabs"):
		return _build_tabs(data)
	# Grid menus sit centred in the menu box. Lists keep their normal left-aligned rows.
	if data.has("split"):
		return _centred(_build_split(data["split"]))
	if data.has("grid"):
		return _centred(_build_grid(data))
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


# Centres a grid menu across the width of the menu box.
func _centred(content: Control) -> Control:
	var holder := CenterContainer.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.add_child(content)
	return holder


# One option: a name, a value, an optional button, and an optional progress bar.
func _build_card(data: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _skin(UiSkin.slot(false, 12), _box(COL_CARD, COL_CARD, 0, 8, 12)))
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

	# An optional second, small button sits before the main one, such as − beside +.
	if data.has("button2"):
		var less := Button.new()
		less.text = str(data["button2"])
		less.custom_minimum_size = Vector2(48, 34)
		less.focus_mode = Control.FOCUS_ALL
		_style_button(less, false)
		less.set_meta("action", str(data.get("action2", "")))
		less.pressed.connect(_on_action_pressed.bind(str(data.get("action2", ""))))
		line.add_child(less)
	if data.has("button"):
		var button := Button.new()
		button.text = str(data["button"])
		button.custom_minimum_size = Vector2(48 if data.has("button2") else 120, 34)
		_set_enabled(button, bool(data.get("enabled", true)))
		_style_button(button, false)
		button.set_meta("action", str(data.get("action", "")))
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
	holder.add_theme_constant_override("separation", 6)
	holder.alignment = BoxContainer.ALIGNMENT_CENTER
	holder.add_child(_device_glyph("Q", "LB"))
	for tab in data["tabs"]:
		var button := Button.new()
		button.text = str(tab["name"])
		button.custom_minimum_size = Vector2(120, 36)
		button.focus_mode = Control.FOCUS_NONE
		var open := str(tab["id"]) == str(data.get("active", ""))
		_style_button(button, open)
		if open:
			button.add_theme_color_override("font_color", COL_ACCENT)
		button.pressed.connect(_on_action_pressed.bind(str(tab.get("action", ""))))
		holder.add_child(button)
	holder.add_child(_device_glyph("E", "RB"))
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


# The grid on the left and the picked recipe's details on the right. A figure layout places
# each tile at its own spot in a body shape, and any tiles without a spot go in a row below.
func _build_split(data: Dictionary) -> Control:
	var holder := HBoxContainer.new()
	holder.add_theme_constant_override("separation", 16)
	holder.alignment = BoxContainer.ALIGNMENT_BEGIN
	holder.add_child(_build_split_grid(data))
	if not data.get("detail", {}).is_empty():
		holder.add_child(_build_detail(data["detail"]))
	return holder


# The tiles of a split: a body figure (Gear) or a grid of recipe tiles.
func _build_split_grid(data: Dictionary) -> Control:
	if data.get("figure", false):
		return _build_figure(data["recipes"])
	return _build_recipes({"recipes": data["recipes"], "columns": data.get("columns", 4)})


# Tiles are 72 pixels with 6 between them: a 3-by-5 figure, then a row of tools.
const FIGURE_TILE := 72
const FIGURE_GAP := 6


func _build_figure(recipes: Array) -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	var figure := Control.new()
	figure.custom_minimum_size = Vector2(3 * FIGURE_TILE + 2 * FIGURE_GAP, 5 * FIGURE_TILE + 4 * FIGURE_GAP)
	var loose: Array = []
	for recipe in recipes:
		if recipe.has("pos"):
			var spot: Vector2i = recipe["pos"]
			var placed := _build_recipe_tile(recipe, true)
			placed.position = Vector2(spot.x * (FIGURE_TILE + FIGURE_GAP), spot.y * (FIGURE_TILE + FIGURE_GAP))
			figure.add_child(placed)
		else:
			loose.append(recipe)
	column.add_child(figure)
	if not loose.is_empty():
		var heading := Label.new()
		heading.text = "TOOLBELT"
		heading.add_theme_font_size_override("font_size", 13)
		heading.add_theme_color_override("font_color", COL_ACCENT)
		column.add_child(heading)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", FIGURE_GAP)
		for recipe in loose:
			row.add_child(_build_recipe_tile(recipe, true))
		column.add_child(row)
	return column


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


func _build_recipe_tile(recipe: Dictionary, small: bool = false) -> Control:
	var selected := bool(recipe.get("selected", false))
	var lit := bool(recipe.get("enabled", false)) or selected
	var tile := Button.new()
	tile.custom_minimum_size = Vector2(FIGURE_TILE, FIGURE_TILE) if small else Vector2(88, 98)
	tile.focus_mode = Control.FOCUS_ALL
	tile.tooltip_text = str(recipe.get("name", ""))
	tile.clip_contents = true
	var base := COL_BUTTON_ACTIVE if selected else COL_BUTTON
	if UiSkin.slot(false) != null:
		tile.add_theme_stylebox_override("normal", UiSkin.slot(selected, 4))
		tile.add_theme_stylebox_override("hover", UiSkin.slot(true, 4))
		tile.add_theme_stylebox_override("pressed", UiSkin.slot(true, 4))
		tile.add_theme_stylebox_override("focus", UiSkin.slot(true, 4))
	else:
		tile.add_theme_stylebox_override("normal", _box(base, COL_ACCENT if selected else COL_BORDER, 2, 8, 4))
		tile.add_theme_stylebox_override("hover", _box(COL_BUTTON_HOVER, COL_ACCENT, 2, 8, 4))
		tile.add_theme_stylebox_override("pressed", _box(COL_BUTTON_ACTIVE, COL_ACCENT, 2, 8, 4))
		tile.add_theme_stylebox_override("focus", _box(base, COL_ACCENT, 2, 8, 4))
	tile.set_meta("action", str(recipe.get("action", "")))
	if selected:
		_picked_action = str(recipe.get("action", ""))
	tile.pressed.connect(_pick_tile.bind(str(recipe.get("action", "")), selected))

	# The picture and name sit inside the tile's frame, clear of its iron edge.
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 10.0
	box.offset_top = 8.0
	box.offset_right = -10.0
	box.offset_bottom = -10.0
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 4)
	tile.add_child(box)

	var icon := RecipeIcon.new()
	icon.kind = str(recipe.get("icon", ""))
	icon.tint = Color(str(recipe.get("tint", "6b4a3a")))
	icon.custom_minimum_size = Vector2(38, 38) if small else Vector2(48, 48)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.modulate = Color(1, 1, 1, 1) if lit else Color(1, 1, 1, 0.45)
	box.add_child(icon)

	var name_label := Label.new()
	name_label.text = str(recipe.get("name", ""))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Each line fits inside the frame: the text steps down a size or two for a long name, and past that
	# ends in an ellipsis.
	var room := tile.custom_minimum_size.x - 22.0
	var font := name_label.get_theme_font("font")
	var font_size := 10 if small else 12
	var widest := ""
	for line in name_label.text.split("
"):
		if line.length() > widest.length():
			widest = line
	while font_size > 9 and font.get_string_size(widest, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		font_size -= 1
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.custom_minimum_size.x = room
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	name_label.add_theme_font_size_override("font_size", font_size)
	name_label.add_theme_color_override("font_color", COL_TEXT if lit else COL_MUTED)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(name_label)
	# Inventory items show their name only while they are highlighted, so the pictures carry the list.
	if bool(recipe.get("names_on_focus", false)):
		name_label.visible = selected
		var show := func(on: bool) -> void:
			name_label.visible = on or selected
		tile.focus_entered.connect(show.bind(true))
		tile.focus_exited.connect(show.bind(false))
		tile.mouse_entered.connect(show.bind(true))
		tile.mouse_exited.connect(show.bind(false))
	return tile


# The details of the picked recipe: the picture, what it does, what it costs, and the button to make it.
func _build_detail(recipe: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(280, 0)
	card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	card.add_theme_stylebox_override("panel", _skin(UiSkin.slot(false, 14), _box(COL_CARD, COL_BORDER, 1, 8, 14)))
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

	if recipe.has("progress"):
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 8)
		bar.value = clampf(float(recipe["progress"]), 0.0, 1.0) * 100.0
		bar.add_theme_stylebox_override("background", _box(COL_TRACK, COL_TRACK, 0, 4, 0))
		bar.add_theme_stylebox_override("fill", _box(COL_ACCENT, COL_ACCENT, 0, 4, 0))
		block.add_child(bar)
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
		_set_enabled(button, bool(recipe.get("enabled", false)) and str(recipe.get("action", "")) != "")
		_style_button(button, false)
		# Its action keeps focus on it when the panel rebuilds after a press, so it can be pressed again.
		button.set_meta("action", str(recipe.get("action", "")))
		button.set_meta("key", str(recipe.get("key", "")))
		button.pressed.connect(_on_action_pressed.bind(str(recipe.get("action", ""))))
		block.add_child(button)
		_detail_button = button
	return card


# A tile is picked by its action ("craft_pick:<key>" and the like). With A, Space or Enter the highlight then
# moves to the picked recipe's button (Make, Cook), so a second press makes it; a click only picks, as the
# mouse can reach the button itself.
func _pick_tile(action_id: String, selected: bool) -> void:
	var key := action_id.substr(action_id.find(":") + 1)
	if _pointer_last:
		_on_action_pressed(action_id)
	elif selected:
		# Already picked, so the panel won't rebuild: move now.
		_jump_to_detail(key)
	else:
		_jump_key = key
		_on_action_pressed(action_id)


func _jump_to_detail(key: String) -> bool:
	if not is_instance_valid(_detail_button) or str(_detail_button.get_meta("key", "")) != key or not _focusable(_detail_button):
		return false
	_detail_button.grab_focus()
	return true


# --- The ledger layout --------------------------------------------------------

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _has_tabs(rows: Array) -> bool:
	for row in rows:
		if row is Dictionary and row.has("tab"):
			return true
	return false


# The tab strip above, then the entry list on the left and the detail page on the right.
func _build_ledger_frame() -> Control:
	ledger = VBoxContainer.new()
	ledger.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ledger.add_theme_constant_override("separation", 10)
	ledger.visible = false
	tab_strip = HBoxContainer.new()
	tab_strip.add_theme_constant_override("separation", 6)
	tab_strip.alignment = BoxContainer.ALIGNMENT_CENTER
	ledger.add_child(tab_strip)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	ledger.add_child(body)
	list_scroll = ScrollContainer.new()
	list_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll.follow_focus = true
	body.add_child(list_scroll)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_theme_constant_override("separation", 6)
	list_scroll.add_child(list_box)
	var page := PanelContainer.new()
	page.custom_minimum_size = Vector2(LEDGER_DETAIL_WIDTH, 0)
	page.add_theme_stylebox_override("panel", _box(Color("1b140d"), COL_BORDER, 2, 6, 16))
	body.add_child(page)
	detail_box = VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 8)
	page.add_child(detail_box)
	return ledger


func _build_ledger(panel_name: String, rows: Array) -> void:
	# Split the rows at each tab marker.
	var tabs: Array = []
	for row in rows:
		if row.has("tab"):
			tabs.append({"name": str(row["tab"]), "rows": []})
		elif not tabs.is_empty():
			tabs[-1]["rows"].append(row)
	_ledger_tab_count = tabs.size()
	var open := clampi(int(ledger_tabs.get(panel_name, 0)), 0, tabs.size() - 1)
	ledger_tabs[panel_name] = open

	_clear(tab_strip)
	tab_strip.visible = tabs.size() > 1
	tab_strip.add_child(_device_glyph("Q", "LB"))
	for i in tabs.size():
		var tab_button := Button.new()
		tab_button.text = str(tabs[i]["name"])
		tab_button.custom_minimum_size = Vector2(130, 36)
		tab_button.focus_mode = Control.FOCUS_NONE
		_style_button(tab_button, i == open)
		if i == open:
			tab_button.add_theme_color_override("font_color", COL_ACCENT)
		tab_button.pressed.connect(_open_ledger_tab.bind(i))
		tab_strip.add_child(tab_button)
	tab_strip.add_child(_device_glyph("E", "RB"))

	_clear(list_box)
	_ledger_entries = []
	var notes: Array = []
	for row in tabs[open]["rows"]:
		if row.has("section"):
			var heading := Label.new()
			heading.text = str(row["section"]).to_upper()
			heading.add_theme_font_size_override("font_size", 13)
			heading.add_theme_color_override("font_color", COL_ACCENT)
			list_box.add_child(heading)
		elif row.has("note") and not row.has("name"):
			notes.append(str(row["note"]))
		else:
			list_box.add_child(_build_entry(row, _ledger_entries.size()))
			_ledger_entries.append(row)
	# A tab with only notes (such as Folk before anyone is met) shows them as one entry, so something
	# still takes focus and a gamepad can read them on the detail page.
	if _ledger_entries.is_empty() and not notes.is_empty():
		var only := {"name": str(notes[0]), "about": "

".join(notes)}
		list_box.add_child(_build_entry(only, 0))
		_ledger_entries.append(only)
		notes = []
	# The tab's notes sit under its entries, small, instead of between them.
	for text in notes:
		var spaced := MarginContainer.new()
		spaced.add_theme_constant_override("margin_top", 6)
		spaced.add_child(_detail_text(str(text), COL_MUTED, 13))
		list_box.add_child(spaced)
	_wrap_entries()
	_ledger_pick = clampi(_ledger_pick, 0, maxi(0, _ledger_entries.size() - 1))
	_show_detail()
	_refresh_prompts()
	call_deferred("_focus_entry", _ledger_pick)


# Down from the last entry goes to the first, and up from the first to the last.
func _wrap_entries() -> void:
	var entries: Array = list_box.get_children().filter(func(c: Node) -> bool: return c is Button)
	if entries.size() < 2:
		return
	var first: Button = entries[0]
	var last: Button = entries[-1]
	first.focus_neighbor_top = first.get_path_to(last)
	last.focus_neighbor_bottom = last.get_path_to(first)


# One line: the name, then a coloured status on the right. The whole line takes focus.
func _build_entry(row: Dictionary, index: int) -> Control:
	var status: Array = _entry_status(row)
	var entry := Button.new()
	entry.custom_minimum_size = Vector2(0, 42)
	entry.focus_mode = Control.FOCUS_ALL
	entry.add_theme_stylebox_override("normal", _box(COL_CARD, Color("3d3024"), 1, 4, 0))
	entry.add_theme_stylebox_override("hover", _box(COL_NAV_HOVER, COL_BORDER, 1, 4, 0))
	entry.add_theme_stylebox_override("pressed", _box(COL_NAV_ACTIVE, COL_ACCENT, 2, 4, 0))
	var ring := _box(COL_NAV_ACTIVE, COL_ACCENT, 2, 4, 0)
	ring.draw_center = false
	entry.add_theme_stylebox_override("focus", ring)
	if row.has("action"):
		entry.set_meta("action", str(row["action"]))
	var line := HBoxContainer.new()
	line.set_anchors_preset(Control.PRESET_FULL_RECT)
	line.offset_left = 14
	line.offset_right = -14
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override("separation", 10)
	entry.add_child(line)
	var name_label := Label.new()
	name_label.text = str(row.get("name", ""))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", COL_MUTED if str(status[1]) == "done" else COL_TEXT)
	line.add_child(name_label)
	if str(status[0]) != "":
		var chip := Label.new()
		chip.text = str(status[0])
		chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chip.add_theme_font_size_override("font_size", 13)
		chip.add_theme_color_override("font_color", _kind_color(str(status[1])))
		line.add_child(chip)
		entry.set_meta("chip", chip)
	entry.focus_entered.connect(_pick_entry.bind(index))
	entry.pressed.connect(_press_entry.bind(index))
	if row.has("button2"):
		entry.gui_input.connect(_step_entry.bind(index, entry))
	return entry


# Left and right on a line with − and + press them, like a slider.
func _step_entry(event: InputEvent, index: int, entry: Button) -> void:
	var row: Dictionary = _ledger_entries[index]
	if event.is_action_pressed("ui_left"):
		_on_action_pressed(str(row.get("action2", "")))
		entry.accept_event()
	elif event.is_action_pressed("ui_right"):
		_on_action_pressed(str(row.get("action", "")))
		entry.accept_event()


# The status shown on an entry's line: its own, or what its button would do.
func _entry_status(row: Dictionary) -> Array:
	# An amount entry says what a press does: "Sell 3".
	if row.has("amount_max") and bool(row.get("enabled", true)):
		return ["%s %d" % [str(row["button"]), _amount(row)], "ok"]
	if row.has("status"):
		var kind := str(row.get("status_kind", ""))
		if kind == "" and row.has("button"):
			kind = "ok" if bool(row.get("enabled", true)) else "short"
		return [str(row["status"]), kind if kind != "" else "info"]
	if row.has("button"):
		if bool(row.get("enabled", true)):
			return [str(row["button"]), "ok"]
		# A short value, such as "0 held", says more than "Not yet".
		var short_value := str(row.get("value", ""))
		return [short_value if short_value != "" and short_value.length() <= 18 else "Not yet", "short"]
	var value := str(row.get("value", ""))
	return [value if value.length() <= 18 else "", "info"]


func _kind_color(kind: String) -> Color:
	match kind:
		"ok":
			return COL_OK
		"short":
			return COL_SHORT
		"done":
			return COL_MUTED
	return COL_ACCENT


func _pick_entry(index: int) -> void:
	if index == _ledger_pick and detail_box.get_child_count() > 0:
		return
	_ledger_pick = index
	_show_detail()


func _focus_entry(index: int) -> void:
	var entries: Array = []
	for child in list_box.get_children():
		if child is Button:
			entries.append(child)
	if index < entries.size():
		entries[index].grab_focus()


# A or Space on an entry presses its action. A click only picks it, so its details can be read first.
func _press_entry(index: int) -> void:
	if _pointer_last or index >= _ledger_entries.size():
		return
	var row: Dictionary = _ledger_entries[index]
	if str(row.get("action", "")) != "" and bool(row.get("enabled", true)):
		_on_action_pressed(_amount_action(row))


# --- Amount entries: left and right choose how many (Sell 3, Take 5), and the press does that many. ---
# A row with amount_max (and amount_id, which the choice is kept under) is one. Left from 1 goes round to
# all of them, and right from all back to 1. amount_values, when given, is what each count brings.

func _amount(row: Dictionary) -> int:
	return clampi(int(_amounts.get(str(row.get("amount_id", "")), 1)), 1, maxi(1, int(row["amount_max"])))


# The row's action with the chosen count on the end ("sell_food:perch:3").
func _amount_action(row: Dictionary) -> String:
	if not row.has("amount_max"):
		return str(row["action"])
	return "%s:%d" % [str(row["action"]), _amount(row)]


# Steps the focused amount entry's count, and redraws its status and detail page in place, so focus stays.
func _step_amount(step: int) -> void:
	if _ledger_pick >= _ledger_entries.size():
		return
	var row: Dictionary = _ledger_entries[_ledger_pick]
	if not row.has("amount_max") or not bool(row.get("enabled", true)):
		return
	var top := maxi(1, int(row["amount_max"]))
	var n := _amount(row) + step
	if n < 1:
		n = top
	elif n > top:
		n = 1
	_amounts[str(row["amount_id"])] = n
	var entries: Array = list_box.get_children().filter(func(c: Node) -> bool: return c is Button)
	if _ledger_pick < entries.size() and entries[_ledger_pick].has_meta("chip"):
		(entries[_ledger_pick].get_meta("chip") as Label).text = str(_entry_status(row)[0])
	_show_detail()
	_on_action_pressed("page_turn")


# Left and right on an amount entry, from any device, with a repeat while held. Polled, so the stick
# steps once per push rather than once per motion event.
func _poll_amount(delta: float) -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var on_amount: bool = ledger.visible and focused != null and list_box.is_ancestor_of(focused)
	on_amount = on_amount and _ledger_pick < _ledger_entries.size() and _ledger_entries[_ledger_pick].has("amount_max")
	if not on_amount:
		_amount_hold = 0.0
		return
	var dir := 0
	if Input.is_action_pressed("ui_left"):
		dir = -1
	elif Input.is_action_pressed("ui_right"):
		dir = 1
	if dir == 0:
		_amount_hold = 0.0
		return
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		_amount_hold = 0.0
		_step_amount(dir)
		return
	_amount_hold += delta
	if _amount_hold >= AMOUNT_REPEAT_DELAY:
		_amount_hold -= AMOUNT_REPEAT
		_step_amount(dir)


# The focused entry in full: what it is, what it needs (have or short), and its button.
func _show_detail() -> void:
	_clear(detail_box)
	if _ledger_entries.is_empty():
		return
	var row: Dictionary = _ledger_entries[clampi(_ledger_pick, 0, _ledger_entries.size() - 1)]
	detail_box.add_child(_detail_text(str(row.get("name", "")), COL_ACCENT, 20))
	var status: Array = _entry_status(row)
	if str(row.get("status", "")) != "":
		detail_box.add_child(_detail_text(str(status[0]), _kind_color(str(status[1])), 14))
	if str(row.get("about", "")) != "":
		detail_box.add_child(_detail_text(str(row["about"]), COL_TEXT, 15))
	var needs: Array = row.get("needs", [])
	if needs.is_empty():
		if str(row.get("value", "")) != "" and str(row.get("value", "")) != str(row.get("status", "")):
			detail_box.add_child(_detail_text(str(row["value"]), COL_TEXT, 15))
	else:
		detail_box.add_child(_detail_text("NEEDS", COL_MUTED, 12))
		for need in needs:
			var ok := bool(need.get("ok", false))
			# Plain ASCII boxes: the default font has no tick or cross.
			var text := "%s  %s" % ["[x]" if ok else "[  ]", str(need["text"])]
			if need.has("have") and not ok:
				text += "  (have %d)" % int(need["have"])
			detail_box.add_child(_detail_text(text, COL_OK if ok else COL_SHORT, 15))
	if row.has("progress"):
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 10)
		bar.value = clampf(float(row["progress"]), 0.0, 1.0) * 100.0
		bar.add_theme_stylebox_override("background", _box(COL_TRACK, COL_TRACK, 0, 4, 0))
		bar.add_theme_stylebox_override("fill", _box(COL_ACCENT, COL_ACCENT, 0, 4, 0))
		detail_box.add_child(bar)
	if str(row.get("note", "")) != "":
		detail_box.add_child(_detail_text(str(row["note"]), COL_MUTED, 13))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_box.add_child(spacer)
	if row.has("button"):
		var bottom := HBoxContainer.new()
		bottom.alignment = BoxContainer.ALIGNMENT_END
		bottom.add_theme_constant_override("separation", 8)
		detail_box.add_child(bottom)
		if row.has("amount_max") and bool(row.get("enabled", true)):
			# How many, with what they bring, then − and + for the mouse; left and right do the same.
			var n := _amount(row)
			var text := "%d of %d" % [n, int(row["amount_max"])]
			var values: Array = row.get("amount_values", [])
			if n <= values.size():
				text += ", for %d %s" % [int(values[n - 1]), str(row.get("amount_unit", ""))]
			detail_box.add_child(_detail_text(text, COL_ACCENT, 16))
			detail_box.move_child(detail_box.get_child(-1), bottom.get_index())
			bottom.add_child(_glyph("< >"))
			for step in [-1, 1]:
				var stepper := Button.new()
				stepper.text = "-" if step < 0 else "+"
				stepper.custom_minimum_size = Vector2(40, 38)
				stepper.focus_mode = Control.FOCUS_NONE
				_style_button(stepper, false)
				stepper.pressed.connect(_step_amount.bind(step))
				bottom.add_child(stepper)
		elif row.has("button2"):
			bottom.add_child(_glyph("< >"))
			var less := Button.new()
			less.text = str(row["button2"]).replace("−", "-")
			less.custom_minimum_size = Vector2(48, 38)
			less.focus_mode = Control.FOCUS_NONE
			_style_button(less, false)
			less.pressed.connect(_on_action_pressed.bind(str(row.get("action2", ""))))
			bottom.add_child(less)
		else:
			bottom.add_child(_device_glyph("Space", "A"))
		var button := Button.new()
		button.text = str(_entry_status(row)[0]) if row.has("amount_max") and bool(row.get("enabled", true)) else str(row["button"])
		button.custom_minimum_size = Vector2(48 if row.has("button2") else 140, 38)
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = not bool(row.get("enabled", true))
		_style_button(button, false)
		button.pressed.connect(_on_action_pressed.bind(_amount_action(row)))
		bottom.add_child(button)


func _detail_text(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _open_ledger_tab(index: int) -> void:
	if index == int(ledger_tabs.get(active_tab, 0)):
		return
	ledger_tabs[active_tab] = index
	_ledger_pick = 0
	list_scroll.scroll_vertical = 0
	_rebuild()


func _rebuild() -> void:
	_last_key = ""
	show_panel(_last_tab, _last_rows)


# A small boxed key or button name, drawn in code until the glyph art is made.
func _glyph(key_name: String) -> Control:
	var glyph := Label.new()
	glyph.text = key_name
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.custom_minimum_size = Vector2(26, 24)
	glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	glyph.add_theme_font_size_override("font_size", 12)
	glyph.add_theme_color_override("font_color", COL_TEXT)
	glyph.add_theme_stylebox_override("normal", _box(COL_BUTTON, COL_BORDER, 1, 4, 5))
	return glyph


# A glyph that names a keyboard key or a pad button, whichever was used last. It keeps both names, so a
# change of device relabels it in place (_swap_glyphs) instead of rebuilding the panel.
func _device_glyph(key_name: String, pad_name: String) -> Control:
	var glyph := _glyph(pad_name if _pad_glyphs else key_name)
	glyph.set_meta("names", [key_name, pad_name])
	return glyph


# Relabels every device glyph in the panel and redoes the footer. The panel isn't rebuilt, so the entry in
# focus keeps its focus and the press that changed device still reaches it.
func _swap_glyphs(node: Node) -> void:
	for child in node.get_children():
		if child is Label and child.has_meta("names"):
			(child as Label).text = str(child.get_meta("names")[1 if _pad_glyphs else 0])
		_swap_glyphs(child)


# The footer's button prompts, in the glyphs of whichever device was used last.
func _refresh_prompts() -> void:
	_clear(prompt_bar)
	var pad := _pad_glyphs
	var back := "Back" if active_tab in ["Settings", "Controls"] else "Close"
	var prompts: Array = [["A" if pad else "Space", "Select"], ["B" if pad else "Esc", back]]
	if book.visible:
		prompts = [["< >", "Turn page"], ["B" if pad else "Esc", back]]
	if _ledger_tab_count > 1:
		prompts.append(["LB RB" if pad else "Q E", "Tabs"])
	if not active_tab in ["Pause", "Settings", "Controls"]:
		prompts.append(["L3" if pad else "Shift", "Sections"])
	for prompt in prompts:
		var pair := HBoxContainer.new()
		pair.add_theme_constant_override("separation", 6)
		pair.add_child(_glyph(str(prompt[0])))
		var label := Label.new()
		label.text = str(prompt[1])
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", COL_MUTED)
		pair.add_child(label)
		prompt_bar.add_child(pair)


func _style_button(button: Button, active: bool) -> void:
	button.add_theme_color_override("font_color", COL_TEXT)
	button.add_theme_color_override("font_disabled_color", COL_MUTED)
	if UiSkin.style_button(button):
		# The active button (the open tab) wears the gold-edged look.
		if active:
			button.add_theme_stylebox_override("normal", UiSkin.button("hover"))
		return
	var base: Color = COL_BUTTON_ACTIVE if active else COL_BUTTON
	button.add_theme_stylebox_override("normal", _box(base, COL_BORDER, 2, 6, 8))
	button.add_theme_stylebox_override("hover", _box(COL_BUTTON_HOVER, COL_ACCENT, 2, 6, 8))
	button.add_theme_stylebox_override("pressed", _box(COL_BUTTON_ACTIVE, COL_ACCENT, 2, 6, 8))
	button.add_theme_stylebox_override("disabled", _box(COL_BUTTON_DISABLED, Color("3d3024"), 2, 6, 8))
	button.add_theme_stylebox_override("focus", _box(base, COL_ACCENT, 2, 6, 8))
	button.add_theme_color_override("font_color", COL_TEXT)
	button.add_theme_color_override("font_disabled_color", COL_MUTED)


# The skinned style when the UI art is there, otherwise the flat one.
func _skin(skinned: StyleBox, flat: StyleBox) -> StyleBox:
	return skinned if skinned != null else flat


func _box(bg: Color, border: Color, border_width: int, radius: int, margin: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	return sb


var _pointer_held := false


# The right stick scrolls the open menu, so long lists can be read without moving focus.
func _process(delta: float) -> void:
	if not panel.visible or scroll == null:
		return
	_poll_amount(delta)
	# Left and right (keys, D-pad or the left stick) turn the diary's pages.
	if book.visible:
		if Input.is_action_just_pressed("move_left"):
			_turn_page(-1)
		elif Input.is_action_just_pressed("move_right"):
			_turn_page(1)
	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		return
	var stick := Input.get_joy_axis(pads[0], JOY_AXIS_RIGHT_Y)
	if absf(stick) > 0.25:
		var target := list_scroll if ledger.visible else scroll
		target.scroll_vertical += int(stick * 900.0 * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pointer_held = event.pressed
	if event is InputEventMouseButton:
		_pointer_last = true
	elif event is InputEventKey or event is InputEventJoypadButton:
		_pointer_last = false
	# The prompts follow whichever of keyboard or gamepad was used last.
	var pad := event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5)
	if (pad or event is InputEventKey) and pad != _pad_glyphs:
		_pad_glyphs = pad
		if panel.visible and prompt_bar.visible:
			_swap_glyphs(panel)
			_refresh_prompts()
	if not panel.visible or not prompt_bar.visible:
		return
	# The mouse wheel turns the diary's pages too.
	if book.visible and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_turn_page(-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		get_viewport().set_input_as_handled()
		return
	if _ledger_tab_count < 2 or not event.is_pressed() or event.is_echo():
		return
	var step := 0
	if event is InputEventKey:
		if event.physical_keycode == KEY_Q:
			step = -1
		elif event.physical_keycode == KEY_E:
			step = 1
	elif event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			step = -1
		elif event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			step = 1
	if step == 0:
		return
	get_viewport().set_input_as_handled()
	if book.visible:
		_open_book_section(posmod(book_section + step, _ledger_tab_count))
		return
	if ledger.visible:
		_open_ledger_tab(posmod(int(ledger_tabs.get(active_tab, 0)) + step, _ledger_tab_count))
		return
	var tabs: Array = _grid_tabs["tabs"]
	var at := 0
	for i in tabs.size():
		if str(tabs[i]["id"]) == str(_grid_tabs.get("active", "")):
			at = i
	_on_action_pressed(str(tabs[posmod(at + step, tabs.size())].get("action", "")))


# --- The diary's book ------------------------------------------------------------

# The leather cover holding two pages either side of the spine, and the tab markers down its right edge.
func _build_book_frame() -> Control:
	book = HBoxContainer.new()
	book.size_flags_vertical = Control.SIZE_EXPAND_FILL
	book.add_theme_constant_override("separation", 0)
	book.visible = false
	var cover := PanelContainer.new()
	cover.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cover.add_theme_stylebox_override("panel", _box(LEATHER, COL_BORDER, 2, 8, 10))
	book.add_child(cover)
	book_spread_box = HBoxContainer.new()
	book_spread_box.add_theme_constant_override("separation", 0)
	cover.add_child(book_spread_box)
	book_tabs = VBoxContainer.new()
	book_tabs.add_theme_constant_override("separation", 6)
	var top := Control.new()
	top.custom_minimum_size = Vector2(0, 14)
	book_tabs.add_child(top)
	book.add_child(book_tabs)
	return book


func _show_book(sections: Array, opening: bool) -> void:
	book_sections = sections
	_ledger_tab_count = sections.size()
	# Opening the diary turns to the first page not read yet; otherwise it stays where it was left.
	if opening:
		for s in sections.size():
			var pages: Array = sections[s]["pages"]
			for p in pages.size():
				if bool(pages[p].get("new", false)):
					book_section = s
					book_spread = p / 2
					_build_book()
					return
	_build_book()


# Turns to the spread holding a section's page, e.g. for the capture tool.
func open_book_at(section: int, page: int) -> void:
	book_section = section
	book_spread = page / 2
	if book.visible:
		_build_book()


func _spreads(section: int) -> int:
	return maxi(1, ceili(float(book_sections[section]["pages"].size()) / 2.0))


func _build_book() -> void:
	if book_sections.is_empty():
		return
	book_section = clampi(book_section, 0, book_sections.size() - 1)
	book_spread = clampi(book_spread, 0, _spreads(book_section) - 1)
	var section: Dictionary = book_sections[book_section]
	var pages: Array = section["pages"]
	_clear(book_spread_box)
	for side in 2:
		var index := book_spread * 2 + side
		var page: Dictionary = pages[index] if index < pages.size() else {"blank": true}
		book_spread_box.add_child(_build_page(section, page, index, side))
		if side == 0:
			var spine := ColorRect.new()
			spine.color = Color("1e130b")
			spine.custom_minimum_size = Vector2(6, 0)
			book_spread_box.add_child(spine)
	# The tab markers, after the spacer that lines them up with the pages' tops.
	while book_tabs.get_child_count() > 1:
		var old := book_tabs.get_child(1)
		book_tabs.remove_child(old)
		old.queue_free()
	for i in book_sections.size():
		book_tabs.add_child(_build_marker(i))
	_refresh_prompts()


# One page: the section's heading (left page only), the title with "new" or "done", a rule, the text, and
# the page number with a turn arrow at the outer corner. A torn-out page shows its stub and a faded number.
func _build_page(section: Dictionary, page: Dictionary, index: int, side: int) -> Control:
	var small := menu_frame.custom_minimum_size.y < 560.0
	var gap := bool(page.get("gap", false))
	var holder := PanelContainer.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sheet := _box(PAPER, PAPER_EDGE, 0, 0, 0)
	# Rounded on the outer corners only, so the two pages meet at the spine.
	for corner in ([CORNER_TOP_LEFT, CORNER_BOTTOM_LEFT] if side == 0 else [CORNER_TOP_RIGHT, CORNER_BOTTOM_RIGHT]):
		sheet.set_corner_radius(corner, 4)
	sheet.border_width_bottom = 3
	if gap:
		sheet.draw_center = false
		sheet.border_width_bottom = 0
		holder.add_child(TornPage.new(side, PAPER, PAPER_EDGE))
	holder.add_theme_stylebox_override("panel", sheet)
	var margin := MarginContainer.new()
	for side_name in ["margin_left", "margin_top", "margin_right"]:
		margin.add_theme_constant_override(side_name, 18 if small else 24)
	margin.add_theme_constant_override("margin_bottom", 6)
	# A torn-out page's words keep clear of the stub at the spine.
	if gap:
		margin.add_theme_constant_override("margin_right" if side == 0 else "margin_left", 48)
	holder.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6 if small else 10)
	margin.add_child(column)
	var ink: Color = INK_HANDS.get(str(page.get("hand", "")), INK)
	var faded := COL_MUTED if gap else INK_FADED
	column.add_child(_book_text(str(section.get("heading", section["name"])) if side == 0 else " ", faded, 12))
	if page.has("blank"):
		var filler := Control.new()
		filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
		column.add_child(filler)
	else:
		var title_line := HBoxContainer.new()
		title_line.add_theme_constant_override("separation", 10)
		var title := _book_text(str(page["title"]), COL_MUTED if gap else ink, 18 if small else 21)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_line.add_child(title)
		if bool(page.get("new", false)):
			title_line.add_child(_book_text("new", INK_RED, 13))
		elif bool(page.get("done", false)):
			title_line.add_child(_book_text("done", INK_FADED, 13))
		column.add_child(title_line)
		if not gap:
			var rule := ColorRect.new()
			rule.color = Color(PAPER_EDGE, 0.7)
			rule.custom_minimum_size = Vector2(0, 1)
			column.add_child(rule)
		# Long text scrolls rather than running off the page on a small window.
		var body_scroll := ScrollContainer.new()
		body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var body := _book_text(str(page["text"]), COL_MUTED if gap else ink, 14 if small else 16)
		body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body_scroll.add_child(body)
		column.add_child(body_scroll)
	var foot := HBoxContainer.new()
	column.add_child(foot)
	var step := -1 if side == 0 else 1
	var arrow := Button.new()
	arrow.text = "<" if side == 0 else ">"
	arrow.flat = true
	arrow.focus_mode = Control.FOCUS_NONE
	arrow.custom_minimum_size = Vector2(32, 26)
	arrow.add_theme_font_size_override("font_size", 18)
	arrow.add_theme_color_override("font_color", faded)
	arrow.add_theme_color_override("font_hover_color", INK_RED)
	arrow.add_theme_color_override("font_pressed_color", INK_RED)
	arrow.pressed.connect(_turn_page.bind(step))
	arrow.modulate.a = 1.0 if _can_turn(step) else 0.0
	arrow.disabled = not _can_turn(step)
	var number := _book_text("" if page.has("blank") else str(index + 1), faded, 12)
	number.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var balance := Control.new()
	balance.custom_minimum_size = arrow.custom_minimum_size
	foot.add_child(arrow if side == 0 else balance)
	foot.add_child(number)
	foot.add_child(balance if side == 0 else arrow)
	return holder


func _book_text(text: String, color: Color, font_size: int) -> Label:
	var label := _detail_text(text, color, font_size)
	label.add_theme_constant_override("line_spacing", 3)
	return label


# A tab marker: a ribbon off the cover's edge. The open one sticks out further, lit with a gold edge, and a
# section with a page not read yet has a red dot.
func _build_marker(i: int) -> Control:
	var section: Dictionary = book_sections[i]
	var open := i == book_section
	var ribbon: Color = RIBBONS.get(str(section["name"]), COL_BUTTON_ACTIVE)
	var marker := Button.new()
	marker.text = str(section["name"])
	marker.alignment = HORIZONTAL_ALIGNMENT_LEFT
	marker.focus_mode = Control.FOCUS_NONE
	marker.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	marker.custom_minimum_size = Vector2(136 if open else 120, 38)
	marker.add_theme_font_size_override("font_size", 14)
	marker.add_theme_color_override("font_color", COL_TEXT if open else Color(COL_TEXT, 0.7))
	marker.add_theme_color_override("font_hover_color", COL_TEXT)
	marker.add_theme_color_override("font_pressed_color", COL_TEXT)
	for state in ["normal", "hover", "pressed"]:
		var fill: Color = ribbon.lightened(0.12) if open or state != "normal" else ribbon.darkened(0.35)
		var sb := _box(fill, COL_ACCENT if open else ribbon.darkened(0.5), 2 if open else 1, 0, 0)
		sb.border_width_left = 0
		sb.set_corner_radius(CORNER_TOP_RIGHT, 6)
		sb.set_corner_radius(CORNER_BOTTOM_RIGHT, 6)
		sb.content_margin_left = 12
		sb.content_margin_right = 22
		marker.add_theme_stylebox_override(state, sb)
	marker.pressed.connect(_open_book_section.bind(i))
	var fresh := false
	for page in section["pages"]:
		fresh = fresh or bool(page.get("new", false))
	if fresh:
		var dot := Panel.new()
		dot.add_theme_stylebox_override("panel", _box(COL_SHORT, Color("f0c0a0"), 1, 4, 0))
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		dot.offset_left = -16
		dot.offset_right = -8
		dot.offset_top = -4
		dot.offset_bottom = 4
		marker.add_child(dot)
	return marker


func _open_book_section(index: int) -> void:
	if index == book_section:
		return
	book_section = index
	book_spread = 0
	_on_action_pressed("page_turn")
	_build_book()


# Whether a turn that way has anywhere to go: another spread, or the next (or previous) section.
func _can_turn(step: int) -> bool:
	if step < 0:
		return book_spread > 0 or book_section > 0
	return book_spread < _spreads(book_section) - 1 or book_section < book_sections.size() - 1


# Turns a spread. Past a section's last spread the book runs on into the next section's first.
func _turn_page(step: int) -> void:
	if book_sections.is_empty() or not _can_turn(step):
		return
	book_spread += step
	if book_spread < 0:
		book_section -= 1
		book_spread = _spreads(book_section) - 1
	elif book_spread >= _spreads(book_section):
		book_section += 1
		book_spread = 0
	_on_action_pressed("page_turn")
	_build_book()


# A page torn out of the diary: the stub left at the spine, its edge ragged, over the bare inside cover.
class TornPage extends Control:
	const RAGGED := [0.0, 7.0, 3.0, 9.0, 1.0, 6.0]
	var side := 0
	var paper: Color
	var edge: Color

	func _init(page_side: int, paper_color: Color, edge_color: Color) -> void:
		side = page_side
		paper = paper_color
		edge = edge_color
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("2a1a10"))
		var spine_x := size.x if side == 0 else 0.0
		var dir := -1.0 if side == 0 else 1.0
		var torn := PackedVector2Array()
		var y := 0.0
		var i := 0
		while y < size.y:
			torn.append(Vector2(spine_x + dir * (24.0 + RAGGED[i % RAGGED.size()]), y))
			y += 11.0
			i += 1
		torn.append(Vector2(spine_x + dir * 24.0, size.y))
		var stub := PackedVector2Array([Vector2(spine_x, 0.0)])
		stub.append_array(torn)
		stub.append(Vector2(spine_x, size.y))
		draw_colored_polygon(stub, paper.darkened(0.1))
		draw_polyline(torn, edge, 1.0)


func _on_menu_pressed() -> void:
	menu_pressed.emit()


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

	const OUTLINE := Color("1d1611")

	# A filled polygon with a dark outline, so shapes read clearly against each other.
	func _shape(pts: PackedVector2Array, color: Color) -> void:
		draw_colored_polygon(pts, color)
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, OUTLINE, 0.025 * _sz)

	# A filled rectangle with a dark outline.
	func _box(rect: Rect2, color: Color) -> void:
		draw_rect(rect, color)
		draw_rect(rect, OUTLINE, false, 0.025 * _sz)

	# A bowl with a rim band, the base of the cooked dishes.
	func _bowl_dish(col: Color) -> void:
		var pts := PackedVector2Array()
		for i in range(17):
			var a := PI * float(i) / 16.0
			pts.append(_pt(0.5, 0.42) + Vector2(cos(a), sin(a)) * 0.42 * _sz)
		_shape(pts, col)
		_box(Rect2(_pt(0.08, 0.42), Vector2(0.84, 0.06) * _sz), col.lightened(0.3))
	func _draw() -> void:
		_sz = minf(size.x, size.y)
		_org = (size - Vector2(_sz, _sz)) * 0.5
		# A soft shadow under each picture, so the items sit on something.
		draw_colored_polygon(_ellipse(0.5, 0.93, 0.3, 0.05), Color(0, 0, 0, 0.35))
		# SpriteCook icon art when there is some for this kind, drawn at a whole multiple of its 16 pixels so it
		# stays crisp; otherwise the picture is drawn from shapes below.
		var art := UiSkin.icon_rect(kind, tint)
		if art.size != Vector2.ZERO:
			var scale_px := maxf(1.0, floorf(_sz / 16.0))
			var side := 16.0 * scale_px
			draw_texture_rect_region(UiSkin.icons(), Rect2(_org + Vector2(_sz - side, _sz - side) * 0.5, Vector2(side, side)), art)
			return
		var light := tint.lightened(0.3)
		var dark := tint.darkened(0.45)
		var metal := Color("b9b4a6")
		match kind:
			"sword":
				_shape(_poly([[0.5, 0.02], [0.58, 0.12], [0.58, 0.62], [0.42, 0.62], [0.42, 0.12]]), metal)
				draw_line(_pt(0.3, 0.64), _pt(0.7, 0.64), dark, 0.09 * _sz)
				draw_line(_pt(0.5, 0.66), _pt(0.5, 0.9), dark, 0.1 * _sz)
				draw_circle(_pt(0.5, 0.94), 0.05 * _sz, light)
			"shield":
				var outline := _poly([[0.2, 0.1], [0.8, 0.1], [0.8, 0.5], [0.5, 0.92], [0.2, 0.5]])
				_shape(outline, tint)
				outline.append(outline[0])
				draw_polyline(outline, dark, 0.04 * _sz)
				draw_line(_pt(0.5, 0.2), _pt(0.5, 0.8), light, 0.06 * _sz)
			"hat":
				_box(Rect2(_pt(0.3, 0.18), Vector2(0.4, 0.4) * _sz), tint)
				_box(Rect2(_pt(0.3, 0.5), Vector2(0.4, 0.08) * _sz), dark)
				_box(Rect2(_pt(0.12, 0.58), Vector2(0.76, 0.12) * _sz), light)
			"shirt":
				_shape(_poly([[0.32, 0.12], [0.42, 0.08], [0.58, 0.08], [0.68, 0.12], [0.92, 0.3], [0.8, 0.46], [0.7, 0.38], [0.7, 0.92], [0.3, 0.92], [0.3, 0.38], [0.2, 0.46], [0.08, 0.3]]), tint)
				draw_arc(_pt(0.5, 0.12), 0.11 * _sz, 0.0, PI, 10, dark, 0.04 * _sz)
			"pants":
				_box(Rect2(_pt(0.18, 0.1), Vector2(0.64, 0.22) * _sz), tint)
				_shape(_poly([[0.18, 0.3], [0.48, 0.3], [0.44, 0.92], [0.22, 0.92]]), tint)
				_shape(_poly([[0.52, 0.3], [0.82, 0.3], [0.78, 0.92], [0.56, 0.92]]), tint)
				draw_line(_pt(0.18, 0.32), _pt(0.82, 0.32), dark, 0.03 * _sz)
			"boots":
				_shape(_poly([[0.28, 0.1], [0.5, 0.1], [0.5, 0.62], [0.88, 0.7], [0.9, 0.86], [0.28, 0.86]]), tint)
				_box(Rect2(_pt(0.28, 0.82), Vector2(0.62, 0.07) * _sz), dark)
			"pendant":
				draw_arc(_pt(0.5, 0.12), 0.38 * _sz, PI * 0.2, PI * 0.8, 16, metal, 0.04 * _sz)
				draw_circle(_pt(0.5, 0.62), 0.16 * _sz, tint)
				draw_arc(_pt(0.5, 0.62), 0.16 * _sz, 0.0, TAU, 24, light, 0.03 * _sz)
				draw_circle(_pt(0.5, 0.62), 0.06 * _sz, light)
			"feather":
				# A black crow feather on a slant, with a pale quill down its middle.
				_shape(_poly([[0.22, 0.86], [0.3, 0.55], [0.5, 0.28], [0.78, 0.1], [0.7, 0.38], [0.5, 0.62], [0.3, 0.8]]), tint)
				draw_line(_pt(0.16, 0.92), _pt(0.74, 0.16), Color("8a8494"), 0.03 * _sz)
			"bracer":
				_box(Rect2(_pt(0.08, 0.36), Vector2(0.84, 0.28) * _sz), tint)
				_box(Rect2(_pt(0.08, 0.36), Vector2(0.84, 0.04) * _sz), light)
				for x in [0.2, 0.5, 0.8]:
					draw_circle(_pt(x, 0.5), 0.035 * _sz, light)
			"bowl":
				var bowl := PackedVector2Array()
				for i in range(17):
					var a := PI * float(i) / 16.0
					bowl.append(_pt(0.5, 0.42) + Vector2(cos(a), sin(a)) * 0.42 * _sz)
				_shape(bowl, tint)
				_box(Rect2(_pt(0.08, 0.42), Vector2(0.84, 0.06) * _sz), light)
				draw_line(_pt(0.4, 0.2), _pt(0.36, 0.06), light, 0.03 * _sz)
				draw_line(_pt(0.6, 0.2), _pt(0.64, 0.06), light, 0.03 * _sz)
			"axe":
				draw_line(_pt(0.3, 0.92), _pt(0.62, 0.22), light, 0.07 * _sz)
				_shape(_poly([[0.56, 0.16], [0.92, 0.3], [0.78, 0.52], [0.5, 0.42]]), metal)
			"pick":
				draw_line(_pt(0.22, 0.92), _pt(0.76, 0.26), light, 0.07 * _sz)
				draw_polyline(_poly([[0.06, 0.4], [0.5, 0.1], [0.94, 0.4]]), metal, 0.09 * _sz)
			"lantern":
				draw_arc(_pt(0.5, 0.34), 0.14 * _sz, PI, TAU, 12, dark, 0.03 * _sz)
				_box(Rect2(_pt(0.3, 0.36), Vector2(0.4, 0.5) * _sz), dark)
				draw_circle(_pt(0.5, 0.6), 0.14 * _sz, Color("e8c060"))
				_shape(_poly([[0.22, 0.38], [0.5, 0.12], [0.78, 0.38]]), tint)
			"glove":
				_shape(_poly([[0.28, 0.45], [0.72, 0.45], [0.74, 0.92], [0.26, 0.92]]), tint)
				for x in [0.28, 0.42, 0.56]:
					_box(Rect2(_pt(x, 0.12), Vector2(0.12, 0.36) * _sz), tint)
				_shape(_poly([[0.72, 0.5], [0.9, 0.54], [0.9, 0.68], [0.72, 0.66]]), tint)
				_box(Rect2(_pt(0.26, 0.8), Vector2(0.48, 0.12) * _sz), dark)
			"rod":
				draw_line(_pt(0.18, 0.9), _pt(0.84, 0.12), tint, 0.06 * _sz)
				draw_line(_pt(0.84, 0.12), _pt(0.84, 0.6), light, 0.02 * _sz)
				draw_arc(_pt(0.8, 0.64), 0.06 * _sz, 0.0, PI, 8, metal, 0.03 * _sz)
			"bandage":
				_shape(_ellipse(0.5, 0.5, 0.36, 0.3), tint)
				draw_arc(_pt(0.5, 0.5), 0.17 * _sz, 0.0, TAU, 16, OUTLINE, 0.03 * _sz)
				_box(Rect2(_pt(0.43, 0.3), Vector2(0.14, 0.4) * _sz), Color("b23a3a"))
				_box(Rect2(_pt(0.3, 0.43), Vector2(0.4, 0.14) * _sz), Color("b23a3a"))
			"pack":
				draw_arc(_pt(0.5, 0.3), 0.18 * _sz, PI, TAU, 12, dark, 0.04 * _sz)
				_box(Rect2(_pt(0.2, 0.3), Vector2(0.6, 0.62) * _sz), tint)
				_box(Rect2(_pt(0.2, 0.3), Vector2(0.6, 0.2) * _sz), light)
				draw_line(_pt(0.2, 0.62), _pt(0.8, 0.62), dark, 0.03 * _sz)
			"trowel":
				draw_line(_pt(0.3, 0.95), _pt(0.52, 0.5), tint, 0.07 * _sz)
				_shape(_poly([[0.48, 0.5], [0.86, 0.14], [0.92, 0.28], [0.6, 0.6]]), metal)
			"hose":
				draw_arc(_pt(0.5, 0.5), 0.3 * _sz, 0.0, TAU * 0.85, 20, tint, 0.09 * _sz)
				_box(Rect2(_pt(0.7, 0.12), Vector2(0.16, 0.14) * _sz), metal)
			"hoe":
				draw_line(_pt(0.3, 0.95), _pt(0.7, 0.12), tint, 0.06 * _sz)
				_shape(_poly([[0.5, 0.12], [0.92, 0.2], [0.86, 0.42], [0.5, 0.36]]), metal)
			"hammer":
				draw_line(_pt(0.3, 0.95), _pt(0.6, 0.4), tint, 0.07 * _sz)
				_box(Rect2(_pt(0.45, 0.12), Vector2(0.45, 0.28) * _sz), metal)
			"broom":
				draw_line(_pt(0.7, 0.08), _pt(0.42, 0.6), tint, 0.05 * _sz)
				_shape(_poly([[0.3, 0.55], [0.56, 0.55], [0.72, 0.92], [0.14, 0.92]]), light)
				_box(Rect2(_pt(0.32, 0.52), Vector2(0.26, 0.08) * _sz), dark)
			"anvil":
				_box(Rect2(_pt(0.1, 0.3), Vector2(0.8, 0.16) * _sz), metal)
				_shape(_poly([[0.3, 0.46], [0.7, 0.46], [0.6, 0.7], [0.4, 0.7]]), metal)
				_box(Rect2(_pt(0.22, 0.7), Vector2(0.56, 0.16) * _sz), dark)
			"crop":
				draw_line(_pt(0.5, 0.95), _pt(0.5, 0.45), dark, 0.05 * _sz)
				_shape(_ellipse(0.32, 0.36, 0.2, 0.12), light)
				_shape(_ellipse(0.68, 0.34, 0.2, 0.12), light)
				_shape(_ellipse(0.5, 0.66, 0.24, 0.22), tint)
			"turnip":
				var leaf_col := Color("5f9a3a")
				_shape(_poly([[0.5, 0.46], [0.28, 0.14], [0.4, 0.08], [0.54, 0.4]]), leaf_col)
				_shape(_poly([[0.5, 0.46], [0.72, 0.14], [0.6, 0.08], [0.46, 0.4]]), leaf_col)
				_shape(_ellipse(0.5, 0.66, 0.3, 0.26), Color("efe8f2"))
				_shape(_ellipse(0.5, 0.52, 0.28, 0.1), Color("9a5aa8"))
			"pumpkin":
				_shape(_poly([[0.54, 0.2], [0.8, 0.08], [0.7, 0.28]]), Color("5f9a3a"))
				_box(Rect2(_pt(0.46, 0.14), Vector2(0.08, 0.16) * _sz), Color("4f6e2a"))
				_shape(_ellipse(0.5, 0.58, 0.4, 0.3), tint)
				draw_polyline(_ellipse(0.32, 0.58, 0.16, 0.3), dark, 0.02 * _sz)
				draw_polyline(_ellipse(0.68, 0.58, 0.16, 0.3), dark, 0.02 * _sz)
			"corn":
				_shape(_ellipse(0.5, 0.52, 0.16, 0.36), tint)
				_shape(_poly([[0.5, 0.92], [0.24, 0.3], [0.4, 0.5]]), Color("5f9a3a"))
				_shape(_poly([[0.5, 0.92], [0.76, 0.3], [0.6, 0.5]]), Color("5f9a3a"))
			"pumpkin_seed":
				_shape(_ellipse(0.4, 0.55, 0.2, 0.3), Color("efe2a6"))
				_shape(_ellipse(0.62, 0.48, 0.2, 0.3), Color("efe2a6"))
			"egg":
				_shape(_ellipse(0.5, 0.52, 0.3, 0.4), tint)
				draw_circle(_pt(0.42, 0.36), 0.05 * _sz, light)
			"milk":
				_shape(_poly([[0.3, 0.3], [0.5, 0.1], [0.7, 0.3]]), light)
				_box(Rect2(_pt(0.28, 0.3), Vector2(0.44, 0.62) * _sz), tint)
				_box(Rect2(_pt(0.28, 0.55), Vector2(0.44, 0.14) * _sz), dark)
			"grilled":
				_shape(_ellipse(0.42, 0.5, 0.34, 0.2), tint)
				_shape(_poly([[0.7, 0.5], [0.96, 0.3], [0.96, 0.7]]), dark)
				for x in [0.26, 0.4, 0.54]:
					draw_line(_pt(x, 0.4), _pt(x + 0.1, 0.6), dark, 0.03 * _sz)
			"smoked":
				_shape(_ellipse(0.42, 0.56, 0.34, 0.2), tint)
				_shape(_poly([[0.7, 0.56], [0.96, 0.36], [0.96, 0.76]]), dark)
				for x in [0.3, 0.5]:
					draw_arc(_pt(x, 0.2), 0.07 * _sz, PI * 0.8, PI * 2.2, 8, Color("bdbdbd"), 0.03 * _sz)
			"hash":
				_bowl_dish(tint)
				_box(Rect2(_pt(0.3, 0.22), Vector2(0.14, 0.14) * _sz), Color("efe8f2"))
				_box(Rect2(_pt(0.52, 0.2), Vector2(0.14, 0.14) * _sz), Color("9a5aa8"))
			"soup":
				_bowl_dish(tint)
				draw_circle(_pt(0.5, 0.2), 0.04 * _sz, Color("5f9a3a"))
				draw_circle(_pt(0.32, 0.24), 0.05 * _sz, light)
				draw_circle(_pt(0.66, 0.22), 0.05 * _sz, light)
			"fish_stew":
				_bowl_dish(tint)
				_shape(_ellipse(0.4, 0.24, 0.14, 0.07), Color("8fb8c9"))
				draw_circle(_pt(0.62, 0.22), 0.05 * _sz, Color("efe8f2"))
			"hearty":
				_bowl_dish(tint)
				for x in [0.38, 0.6]:
					draw_arc(_pt(x, 0.18), 0.06 * _sz, PI * 0.8, PI * 2.2, 8, Color("d8d0c0"), 0.03 * _sz)
				_box(Rect2(_pt(0.3, 0.26), Vector2(0.14, 0.14) * _sz), dark)
				_box(Rect2(_pt(0.56, 0.26), Vector2(0.14, 0.14) * _sz), dark)
			"dried":
				for y in [0.42, 0.6, 0.78]:
					_shape(_ellipse(0.5, y, 0.36, 0.1), tint)
			"canned":
				_box(Rect2(_pt(0.27, 0.14), Vector2(0.46, 0.8) * _sz), metal)
				_box(Rect2(_pt(0.27, 0.4), Vector2(0.46, 0.28) * _sz), tint)
				draw_line(_pt(0.27, 0.2), _pt(0.73, 0.2), dark, 0.03 * _sz)
			"fermented":
				_box(Rect2(_pt(0.3, 0.1), Vector2(0.4, 0.12) * _sz), metal)
				_box(Rect2(_pt(0.24, 0.22), Vector2(0.52, 0.7) * _sz), tint)
				draw_circle(_pt(0.4, 0.5), 0.04 * _sz, light)
				draw_circle(_pt(0.6, 0.62), 0.05 * _sz, light)
				draw_circle(_pt(0.5, 0.78), 0.035 * _sz, light)
			"firewood":
				for k in 3:
					var fy: float = 0.3 + 0.24 * float(k)
					_box(Rect2(_pt(0.14, fy), Vector2(0.72, 0.17) * _sz), tint)
					draw_circle(_pt(0.14, fy + 0.085), 0.09 * _sz, light)
			"fish":
				_shape(_ellipse(0.42, 0.5, 0.36, 0.22), tint)
				_shape(_poly([[0.72, 0.5], [0.98, 0.25], [0.98, 0.75]]), dark)
				draw_circle(_pt(0.24, 0.45), 0.04 * _sz, dark)
			"jar":
				_box(Rect2(_pt(0.3, 0.12), Vector2(0.4, 0.12) * _sz), metal)
				_box(Rect2(_pt(0.22, 0.22), Vector2(0.56, 0.7) * _sz), tint)
				_box(Rect2(_pt(0.3, 0.45), Vector2(0.4, 0.2) * _sz), light)
			"seed":
				_shape(_ellipse(0.5, 0.62, 0.3, 0.28), tint)
				_shape(_poly([[0.4, 0.4], [0.6, 0.4], [0.5, 0.2]]), dark)
				draw_circle(_pt(0.42, 0.62), 0.04 * _sz, light)
				draw_circle(_pt(0.58, 0.66), 0.04 * _sz, light)
			"log":
				_box(Rect2(_pt(0.2, 0.32), Vector2(0.6, 0.36) * _sz), tint)
				draw_circle(_pt(0.2, 0.5), 0.18 * _sz, light)
				draw_circle(_pt(0.2, 0.5), 0.08 * _sz, dark)
			"fiber":
				for x in [0.2, 0.4, 0.6, 0.8]:
					draw_line(_pt(x, 0.9), _pt(x + 0.1, 0.1), tint, 0.05 * _sz)
			"sticks":
				for k in 3:
					var sx: float = 0.22 + 0.26 * float(k)
					draw_line(_pt(sx, 0.92), _pt(sx + 0.14, 0.08), tint, 0.08 * _sz)
					draw_line(_pt(sx + 0.02, 0.9), _pt(sx + 0.15, 0.1), light, 0.02 * _sz)
			"resin":
				_shape(_ellipse(0.5, 0.56, 0.34, 0.28), tint)
				draw_circle(_pt(0.38, 0.44), 0.09 * _sz, light)
				draw_circle(_pt(0.34, 0.4), 0.035 * _sz, Color("fff4d0"))
				_shape(_poly([[0.6, 0.78], [0.66, 0.78], [0.66, 0.92], [0.6, 0.92]]), tint)
			"stone":
				_shape(_rock(), tint)
				draw_line(_pt(0.3, 0.45), _pt(0.5, 0.6), dark, 0.03 * _sz)
			"ore":
				_shape(_rock(), tint)
				for sparkle in [[0.4, 0.5], [0.6, 0.62], [0.5, 0.36]]:
					draw_circle(_pt(sparkle[0], sparkle[1]), 0.05 * _sz, light)
			"bar":
				_shape(_poly([[0.12, 0.62], [0.28, 0.34], [0.72, 0.34], [0.88, 0.62], [0.72, 0.74], [0.28, 0.74]]), tint)
				draw_line(_pt(0.3, 0.42), _pt(0.7, 0.42), light, 0.04 * _sz)
			# Code-only pictures for the seasonal crops, fish, forage and dishes, tinted per item.
			"fish_t":
				_shape(_ellipse(0.42, 0.5, 0.36, 0.2), tint)
				_shape(_poly([[0.72, 0.5], [0.96, 0.28], [0.96, 0.72]]), dark)
				draw_line(_pt(0.3, 0.42), _pt(0.6, 0.42), light, 0.03 * _sz)
				draw_circle(_pt(0.2, 0.46), 0.04 * _sz, OUTLINE)
			"seed_t":
				_shape(_ellipse(0.38, 0.58, 0.16, 0.22), tint)
				_shape(_ellipse(0.62, 0.5, 0.16, 0.22), tint.darkened(0.15))
				draw_circle(_pt(0.36, 0.52), 0.04 * _sz, light)
			"leafy":
				for a in [-0.5, 0.0, 0.5]:
					_shape(_ellipse(0.5 + a * 0.4, 0.42 + absf(a) * 0.12, 0.2, 0.32), tint if a != 0.0 else light.darkened(0.15))
				draw_line(_pt(0.5, 0.92), _pt(0.5, 0.3), dark, 0.03 * _sz)
			"pod":
				_shape(_poly([[0.14, 0.7], [0.4, 0.42], [0.86, 0.24], [0.66, 0.5], [0.3, 0.76]]), tint)
				for k in 3:
					draw_circle(_pt(0.36 + 0.14 * float(k), 0.58 - 0.08 * float(k)), 0.06 * _sz, light)
			"potato":
				_shape(_ellipse(0.5, 0.58, 0.36, 0.26), tint)
				for p in [[0.36, 0.52], [0.58, 0.64], [0.66, 0.48]]:
					draw_circle(_pt(p[0], p[1]), 0.025 * _sz, dark)
			"leek":
				_box(Rect2(_pt(0.42, 0.42), Vector2(0.16, 0.48) * _sz), Color("efeadc"))
				_shape(_poly([[0.42, 0.44], [0.2, 0.06], [0.48, 0.38]]), tint)
				_shape(_poly([[0.58, 0.44], [0.8, 0.06], [0.52, 0.38]]), tint.darkened(0.2))
				draw_line(_pt(0.44, 0.92), _pt(0.56, 0.92), Color("8a7a5a"), 0.05 * _sz)
			"root":
				_shape(_poly([[0.3, 0.2], [0.7, 0.2], [0.54, 0.94], [0.46, 0.94]]), tint)
				_shape(_poly([[0.44, 0.22], [0.3, 0.02], [0.5, 0.18]]), Color("5f9a3a"))
				_shape(_poly([[0.56, 0.22], [0.72, 0.04], [0.52, 0.18]]), Color("5f9a3a"))
				draw_line(_pt(0.4, 0.4), _pt(0.52, 0.42), dark, 0.02 * _sz)
			"berry":
				_shape(_poly([[0.5, 0.3], [0.3, 0.12], [0.5, 0.2], [0.7, 0.12]]), Color("5f9a3a"))
				for p in [[0.36, 0.5], [0.62, 0.48], [0.48, 0.72], [0.7, 0.72], [0.3, 0.74]]:
					_shape(_ellipse(p[0], p[1], 0.13, 0.13), tint)
					draw_circle(_pt(p[0] - 0.04, p[1] - 0.04), 0.03 * _sz, light)
			"bulb":
				_shape(_poly([[0.5, 0.06], [0.58, 0.3], [0.42, 0.3]]), Color("8aa86a"))
				_shape(_ellipse(0.5, 0.6, 0.32, 0.3), tint)
				draw_line(_pt(0.5, 0.32), _pt(0.5, 0.88), dark, 0.02 * _sz)
				draw_line(_pt(0.34, 0.42), _pt(0.36, 0.82), dark, 0.02 * _sz)
				draw_line(_pt(0.66, 0.42), _pt(0.64, 0.82), dark, 0.02 * _sz)
			"fern":
				draw_arc(_pt(0.5, 0.36), 0.2 * _sz, PI * 0.5, PI * 2.2, 14, tint, 0.09 * _sz)
				draw_line(_pt(0.5, 0.56), _pt(0.46, 0.94), tint, 0.08 * _sz)
				draw_circle(_pt(0.5, 0.36), 0.07 * _sz, light)
			"hip":
				for p in [[0.36, 0.56], [0.64, 0.48]]:
					_shape(_ellipse(p[0], p[1], 0.16, 0.22), tint)
					draw_line(_pt(p[0], p[1] - 0.22), _pt(p[0], p[1] - 0.32), OUTLINE, 0.04 * _sz)
				draw_line(_pt(0.36, 0.24), _pt(0.64, 0.16), Color("5a4a2a"), 0.04 * _sz)
			"mushroom":
				_box(Rect2(_pt(0.42, 0.46), Vector2(0.16, 0.44) * _sz), light)
				var cap := PackedVector2Array()
				for i in range(13):
					var a := PI + PI * float(i) / 12.0
					cap.append(_pt(0.5, 0.5) + Vector2(cos(a) * 0.38, sin(a) * 0.32) * _sz)
				_shape(cap, tint)
			"pipe":
				for x in [0.32, 0.52, 0.7]:
					draw_line(_pt(x, 0.92), _pt(x, 0.38), tint, 0.07 * _sz)
					_shape(_ellipse(x + 0.06, 0.34, 0.08, 0.1), tint)
				draw_circle(_pt(0.6, 0.34), 0.025 * _sz, Color("404050"))
			"dish":
				_bowl_dish(tint)
				draw_line(_pt(0.4, 0.3), _pt(0.36, 0.1), Color(1, 1, 1, 0.6), 0.03 * _sz)
				draw_line(_pt(0.6, 0.3), _pt(0.64, 0.1), Color(1, 1, 1, 0.6), 0.03 * _sz)
			"tea":
				_box(Rect2(_pt(0.24, 0.38), Vector2(0.44, 0.5) * _sz), Color("e8e0d0"))
				_box(Rect2(_pt(0.28, 0.42), Vector2(0.36, 0.14) * _sz), tint)
				draw_arc(_pt(0.72, 0.6), 0.1 * _sz, -PI * 0.5, PI * 0.5, 8, OUTLINE, 0.04 * _sz)
				draw_line(_pt(0.4, 0.3), _pt(0.36, 0.1), Color(1, 1, 1, 0.6), 0.03 * _sz)
			"pie":
				_shape(_poly([[0.08, 0.56], [0.92, 0.56], [0.8, 0.8], [0.2, 0.8]]), Color("c89a58"))
				_shape(_ellipse(0.5, 0.56, 0.42, 0.14), tint)
				for x in [0.32, 0.5, 0.68]:
					draw_line(_pt(x, 0.46), _pt(x + 0.04, 0.66), Color("e8c890"), 0.04 * _sz)
			_:
				draw_circle(_pt(0.5, 0.5), 0.3 * _sz, tint)

