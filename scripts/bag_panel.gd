class_name BagPanel
extends CanvasLayer

## The bag: a compact, centred grid of pack stacks in the bottom-right corner. Each slot takes its
## item's colour on its border. Tab or Y opens and closes the bag. The D-pad moves between the slots,
## A or a click uses the slot in focus, and B closes it. The Inventory button opens the full Inventory
## section. The Bag button at the corner works with a mouse.

signal slot_chosen(index: int)
signal toggle_requested
signal inventory_requested

const COLS := 4
const ROWS := 5
const CELL := Vector2(78, 46)
const GAP := 5
const RIGHT_MARGIN := 16.0
const PANEL_BOTTOM := 106.0    # the bag's bottom edge, clear of the corner buttons
const TOGGLE_BOTTOM := 56.0    # the Bag button's bottom edge, just above the Menu button
const DEFAULT_TINT := "8a6a3a"
const COL_PANEL := Color("16110c")
const COL_SLOT := Color("231a12")
const COL_SLOT_HOVER := Color("3a2a18")
const COL_SLOT_EMPTY := Color("120d09")
const COL_BORDER := Color("4a3820")
const COL_TEXT := Color("e8dcc0")
const COL_DIM := Color("8f7f60")
const COL_GOLD := Color("d8b050")

var open := false
var root: Control
var panel: PanelContainer
var slots: Array = []        # one Button per cell
var toggle_button: Button


func _ready() -> void:
	layer = 15
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# A zero-size anchor at the bottom right; the panel grows up and to the left to fit its contents.
	panel = PanelContainer.new()
	panel.visible = false
	var skinned := UiSkin.panel(14)
	panel.add_theme_stylebox_override("panel", skinned if skinned != null else _box(COL_PANEL, COL_GOLD.darkened(0.45), 2, 10, 10))
	panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	panel.offset_right = -RIGHT_MARGIN
	panel.offset_left = -RIGHT_MARGIN
	panel.offset_bottom = -PANEL_BOTTOM
	panel.offset_top = -PANEL_BOTTOM
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(column)

	var title := Label.new()
	title.text = "BAG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", COL_GOLD)
	column.add_child(title)

	var grid := GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", GAP)
	grid.add_theme_constant_override("v_separation", GAP)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(grid)
	for i in COLS * ROWS:
		var b := Button.new()
		b.custom_minimum_size = CELL
		b.clip_text = true
		b.alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", COL_TEXT)
		b.add_theme_color_override("font_disabled_color", COL_DIM)
		if UiSkin.slot(false) != null:
			b.add_theme_stylebox_override("normal", UiSkin.slot(false, 4))
			b.add_theme_stylebox_override("hover", UiSkin.slot(true, 4))
			b.add_theme_stylebox_override("focus", UiSkin.slot(true, 4))
			b.add_theme_stylebox_override("pressed", UiSkin.slot(true, 4))
			b.add_theme_stylebox_override("disabled", UiSkin.slot(false, 4))
		else:
			b.add_theme_stylebox_override("normal", _box(COL_SLOT, COL_BORDER, 2, 6, 4))
			b.add_theme_stylebox_override("hover", _box(COL_SLOT_HOVER, COL_GOLD.darkened(0.2), 2, 6, 4))
			b.add_theme_stylebox_override("focus", _box(COL_SLOT_HOVER, COL_GOLD, 2, 6, 4))
			b.add_theme_stylebox_override("pressed", _box(COL_SLOT_HOVER, COL_GOLD, 2, 6, 4))
			b.add_theme_stylebox_override("disabled", _box(COL_SLOT_EMPTY, Color("2a2016"), 1, 6, 4))
		b.pressed.connect(func() -> void: slot_chosen.emit(i))
		_add_slot_art(b)
		grid.add_child(b)
		slots.append(b)

	var inventory_row := CenterContainer.new()
	column.add_child(inventory_row)
	var inventory_button := Button.new()
	inventory_button.text = "Inventory"
	inventory_button.custom_minimum_size = Vector2(118, 28)
	inventory_button.add_theme_font_size_override("font_size", 13)
	inventory_button.add_theme_color_override("font_color", COL_TEXT)
	if not UiSkin.style_button(inventory_button):
		inventory_button.add_theme_stylebox_override("normal", _box(COL_SLOT, COL_BORDER, 2, 6, 4))
		inventory_button.add_theme_stylebox_override("hover", _box(COL_SLOT_HOVER, COL_GOLD.darkened(0.2), 2, 6, 4))
		inventory_button.add_theme_stylebox_override("focus", _box(COL_SLOT_HOVER, COL_GOLD, 2, 6, 4))
	inventory_button.pressed.connect(func() -> void: inventory_requested.emit())
	inventory_row.add_child(inventory_button)

	var hint := Label.new()
	hint.text = "A or click to use   ·   D-pad to move\nTab, Y or B to close"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint.custom_minimum_size = Vector2(COLS * CELL.x + (COLS - 1) * GAP, 0)
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", COL_DIM)
	column.add_child(hint)

	toggle_button = Button.new()
	toggle_button.text = "Bag (Tab)"
	toggle_button.custom_minimum_size = Vector2(150, 40)
	toggle_button.add_theme_font_size_override("font_size", 16)
	toggle_button.add_theme_color_override("font_color", COL_TEXT)
	if not UiSkin.style_button(toggle_button):
		toggle_button.add_theme_stylebox_override("normal", _box(COL_SLOT, COL_BORDER, 2, 6, 4))
		toggle_button.add_theme_stylebox_override("hover", _box(COL_SLOT_HOVER, COL_GOLD.darkened(0.2), 2, 6, 4))
		toggle_button.add_theme_stylebox_override("focus", _box(COL_SLOT_HOVER, COL_GOLD, 2, 6, 4))
	# Sits just above the Menu button, which lives in the same corner.
	toggle_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	toggle_button.offset_left = -166.0
	toggle_button.offset_right = -16.0
	toggle_button.offset_top = -TOGGLE_BOTTOM - 40.0
	toggle_button.offset_bottom = -TOGGLE_BOTTOM
	toggle_button.pressed.connect(func() -> void: toggle_requested.emit())
	root.add_child(toggle_button)


func show_bag() -> void:
	open = true
	panel.visible = true
	if not slots.is_empty():
		(slots[0] as Button).grab_focus.call_deferred()


func hide_bag() -> void:
	open = false
	panel.visible = false
	var vp := get_viewport()
	if vp.gui_get_focus_owner() != null:
		vp.gui_release_focus()


# Fills the cells from the stacks given. Each stack is {label, usable, desc, tint}, where label reads
# "Name xCount". Only the text and colour change, so the cell in focus keeps its focus while counts update.
func set_items(items: Array) -> void:
	for i in slots.size():
		var b := slots[i] as Button
		var icon := b.get_meta("icon") as ActionBar.RecipeIcon
		var count_label := b.get_meta("count") as Label
		var strip := b.get_meta("strip") as PanelContainer
		var name_label := b.get_meta("name") as Label
		if i < items.size():
			var it: Dictionary = items[i]
			var parts := str(it["label"]).rsplit(" x", true, 1)
			name_label.text = parts[0]
			count_label.text = "x" + parts[parts.size() - 1] if parts.size() == 2 else ""
			icon.visible = true
			icon.kind = str(it.get("icon", ""))
			icon.tint = Color(str(it.get("tint", DEFAULT_TINT)))
			icon.queue_redraw()
			b.tooltip_text = str(it.get("desc", ""))
			b.disabled = false
			b.modulate = Color(1, 1, 1) if bool(it.get("usable", false)) else Color(0.78, 0.76, 0.72)
			var tint := str(it.get("tint", DEFAULT_TINT))
			# Flat slots take the item's tint on their edge; the skinned slots keep their frame.
			if UiSkin.slot(false) == null and str(b.get_meta("tint", "")) != tint:
				b.set_meta("tint", tint)
				var edge := Color(tint).lightened(0.1)
				b.add_theme_stylebox_override("normal", _box(COL_SLOT, edge, 2, 6, 4))
				b.add_theme_stylebox_override("hover", _box(COL_SLOT_HOVER, edge.lightened(0.2), 2, 6, 4))
		else:
			icon.visible = false
			count_label.text = ""
			strip.visible = false
			name_label.text = ""
			b.tooltip_text = ""
			b.disabled = true
			b.modulate = Color(1, 1, 1)
			b.set_meta("tint", "")


# A slot's picture, its count, and a name strip that shows only while the slot is highlighted.
func _add_slot_art(b: Button) -> void:
	var icon := ActionBar.RecipeIcon.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 4.0
	icon.offset_top = 3.0
	icon.offset_right = -4.0
	icon.offset_bottom = -3.0
	b.add_child(icon)

	var count_label := Label.new()
	count_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	count_label.offset_left = -40.0
	count_label.offset_top = -17.0
	count_label.offset_right = -5.0
	count_label.offset_bottom = -2.0
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.add_theme_font_size_override("font_size", 11)
	count_label.add_theme_color_override("font_color", COL_GOLD)
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(count_label)

	var strip := PanelContainer.new()
	strip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	strip.offset_left = 2.0
	strip.offset_right = -2.0
	strip.offset_top = -19.0
	strip.offset_bottom = -2.0
	strip.add_theme_stylebox_override("panel", _box(Color(0.06, 0.04, 0.03, 0.9), Color(0, 0, 0, 0), 0, 4, 1))
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.visible = false
	var name_label := Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", COL_TEXT)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(name_label)
	b.add_child(strip)

	b.set_meta("icon", icon)
	b.set_meta("count", count_label)
	b.set_meta("strip", strip)
	b.set_meta("name", name_label)
	b.focus_entered.connect(func() -> void: strip.visible = true)
	b.focus_exited.connect(func() -> void: strip.visible = false)
	b.mouse_entered.connect(func() -> void: strip.visible = true)
	b.mouse_exited.connect(func() -> void: strip.visible = false)
func _box(color: Color, border: Color, border_width: int, radius: int, margin: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = border
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(margin)
	return sb
