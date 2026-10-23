class_name BagPanel
extends CanvasLayer

## The bag: a grid of stacks in the bottom-right corner. Tab or Y opens and closes it. The D-pad moves
## between the slots, A or a click uses the slot in focus, and B closes it. The Bag button at the corner
## works with a mouse.

signal slot_chosen(index: int)
signal toggle_requested

const COLS := 4
const ROWS := 4
const CELL := Vector2(104, 60)
const COL_PANEL := Color("16110c")
const COL_SLOT := Color("231a12")
const COL_SLOT_HOVER := Color("3a2a18")
const COL_SLOT_EMPTY := Color("120d09")
const COL_BORDER := Color("6b4f2a")
const COL_TEXT := Color("e8dcc0")
const COL_DIM := Color("9a8a6a")
const COL_GOLD := Color("d8b050")
const TOGGLE_BOTTOM := 56.0   # gap from the bottom of the screen to the bottom of the Bag button, clear of the Menu button

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

	panel = PanelContainer.new()
	panel.visible = false
	panel.add_theme_stylebox_override("panel", _box(COL_PANEL, 2, 10))
	panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	panel.offset_right = -16.0
	panel.offset_bottom = -TOGGLE_BOTTOM - 50.0
	panel.offset_left = -16.0 - 480.0
	panel.offset_top = -TOGGLE_BOTTOM - 50.0 - 330.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	var title := Label.new()
	title.text = "Bag"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", COL_GOLD)
	col.add_child(title)

	var grid := GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	col.add_child(grid)
	for i in COLS * ROWS:
		var b := Button.new()
		b.custom_minimum_size = CELL
		b.clip_text = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 14)
		b.add_theme_color_override("font_color", COL_TEXT)
		b.add_theme_color_override("font_disabled_color", COL_DIM)
		b.add_theme_stylebox_override("normal", _box(COL_SLOT, 2, 6))
		b.add_theme_stylebox_override("hover", _box(COL_SLOT_HOVER, 2, 6))
		b.add_theme_stylebox_override("focus", _box(COL_SLOT_HOVER, 3, 6))
		b.add_theme_stylebox_override("pressed", _box(COL_SLOT_HOVER, 2, 6))
		b.add_theme_stylebox_override("disabled", _box(COL_SLOT_EMPTY, 2, 6))
		b.pressed.connect(func() -> void: slot_chosen.emit(i))
		grid.add_child(b)
		slots.append(b)

	var hint := Label.new()
	hint.text = "Click or A to use. D-pad or arrows to move. Tab, Y or B closes."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint.custom_minimum_size = Vector2(COLS * (CELL.x + 6.0), 0)
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", COL_DIM)
	col.add_child(hint)

	toggle_button = Button.new()
	toggle_button.text = "Bag (Tab)"
	toggle_button.custom_minimum_size = Vector2(150, 40)
	toggle_button.add_theme_font_size_override("font_size", 16)
	toggle_button.add_theme_color_override("font_color", COL_TEXT)
	toggle_button.add_theme_stylebox_override("normal", _box(COL_SLOT, 2, 6))
	toggle_button.add_theme_stylebox_override("hover", _box(COL_SLOT_HOVER, 2, 6))
	toggle_button.add_theme_stylebox_override("focus", _box(COL_SLOT_HOVER, 2, 6))
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


# Fills the cells from the stacks given. Each stack is {label, usable, desc}. Only the text changes, so
# the cell in focus keeps its focus while the counts update.
func set_items(items: Array) -> void:
	for i in slots.size():
		var b := slots[i] as Button
		if i < items.size():
			var it: Dictionary = items[i]
			b.text = str(it["label"])
			b.tooltip_text = str(it.get("desc", ""))
			b.disabled = false
			b.modulate = Color(1, 1, 1) if bool(it.get("usable", false)) else Color(0.8, 0.78, 0.74)
		else:
			b.text = ""
			b.tooltip_text = ""
			b.disabled = true
			b.modulate = Color(1, 1, 1)


func _box(color: Color, border: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = COL_BORDER
	sb.set_border_width_all(border)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(8)
	return sb
