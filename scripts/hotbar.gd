class_name Hotbar
extends VBoxContainer

## The tool hotbar along the bottom centre: ten numbered slots with the active one lit.
## Slots that hold no tool stay empty. A locked tool shows greyed until it is unlocked.

const SLOT := 54.0
const SLOT_COUNT := 10

var _name_label: Label
var _cells: Array = []     # per slot: {"panel", "icon", "num"}
var _last_key := ""


func _init() -> void:
	add_theme_constant_override("separation", 4)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 15)
	_name_label.add_theme_color_override("font_color", Color("f2d27a"))
	_name_label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.92))
	_name_label.add_theme_constant_override("outline_size", 5)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	for i in SLOT_COUNT:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(SLOT, SLOT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# The icon fills the slot and sits in its centre. The slot number is a small mark in the top-left
		# corner, laid over the icon so it doesn't push the icon down.
		var holder := Control.new()
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(holder)
		var icon := ActionBar.RecipeIcon.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(icon)
		var num := Label.new()
		num.text = str(i + 1) if i < 9 else "0"
		num.add_theme_font_size_override("font_size", 11)
		num.add_theme_color_override("font_color", Color("9a8a6a"))
		num.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.92))
		num.add_theme_constant_override("outline_size", 4)
		num.add_theme_constant_override("line_spacing", 0)
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		num.position = Vector2(1, -2)
		holder.add_child(num)
		row.add_child(panel)
		_cells.append({"panel": panel, "icon": icon, "num": num})
	# The active tool's name, under the slots.
	add_child(_name_label)


# entries holds one dictionary per slot with id, name, icon, tint and enabled.
func set_state(entries: Array, active: int) -> void:
	var key := JSON.stringify([entries, active])
	if key == _last_key:
		return
	_last_key = key
	var active_name := ""
	for i in SLOT_COUNT:
		var entry: Dictionary = entries[i] if i < entries.size() else {}
		var cell: Dictionary = _cells[i]
		var icon: ActionBar.RecipeIcon = cell["icon"]
		var has_tool := str(entry.get("id", "")) != ""
		var enabled := bool(entry.get("enabled", false))
		icon.visible = has_tool
		icon.kind = str(entry.get("icon", ""))
		icon.tint = Color(str(entry.get("tint", "6b4a3a")))
		icon.modulate = Color.WHITE if enabled else Color(0.35, 0.35, 0.35, 0.85)
		icon.queue_redraw()
		(cell["panel"] as PanelContainer).add_theme_stylebox_override("panel", _slot_box(i == active))
		if i == active:
			active_name = str(entry.get("name", ""))
			if has_tool and not enabled:
				active_name += " (locked)"
	_name_label.text = active_name


func _slot_box(lit: bool) -> StyleBox:
	var skinned := UiSkin.slot(lit, 4)
	if skinned != null:
		return skinned
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.09, 0.065, 0.05, 0.9)
	box.border_color = Color("f2d27a") if lit else Color("8a6a3a")
	box.set_border_width_all(3 if lit else 2)
	box.set_corner_radius_all(6)
	box.shadow_color = Color(0, 0, 0, 0.4)
	box.shadow_size = 4 if lit else 2
	box.shadow_offset = Vector2(0, 2)
	box.content_margin_left = 4
	box.content_margin_right = 4
	box.content_margin_top = 2
	box.content_margin_bottom = 2
	return box
