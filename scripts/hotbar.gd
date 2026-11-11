class_name Hotbar
extends VBoxContainer

## The tool hotbar along the bottom centre: ten numbered slots with the active one lit.
## Slots that hold no tool stay empty. A locked tool shows greyed until it is unlocked.
## UI-OVERHAUL-001 Phase 3: the slots sit on the HUD's thin plate and use the Inventory's slot frames (the
## active tool has the gold inset), each icon is its 16 px art at exactly 3x, and the slot keys are small marks
## in the corners. With a gamepad, LB and RB key caps at the bar's ends show how to step through the tools.

const SLOT := 58.0
const ICON := 48.0
const SLOT_COUNT := 10

var pad := false           # set by main before set_state: show LB/RB caps (a gamepad was used last)
var _name_label: Label
var _cells: Array = []     # per slot: {"panel", "icon", "num"}
var _caps: Array = []      # the LB and RB key caps
var _last_key := ""


func _init() -> void:
	theme = UiTheme.get_theme()
	add_theme_constant_override("separation", 2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var plate := PanelContainer.new()
	plate.theme_type_variation = "HudPlate"
	plate.add_theme_stylebox_override("panel", UiTheme.hud_plate(10, 9))
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(plate)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(row)
	_caps.append(_cap(row, "LB"))
	for i in SLOT_COUNT:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(SLOT, SLOT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# The icon sits in the slot's centre at 3x. The key is a small mark in the top-left corner, laid over
		# the frame so it doesn't push the icon down.
		var holder := Control.new()
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(holder)
		var icon := ActionBar.RecipeIcon.new()
		icon.set_anchors_preset(Control.PRESET_CENTER)
		icon.offset_left = -ICON / 2
		icon.offset_top = -ICON / 2
		icon.offset_right = ICON / 2
		icon.offset_bottom = ICON / 2
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(icon)
		var num := Label.new()
		num.theme_type_variation = "HudKey"
		num.text = str(i + 1) if i < 9 else "0"
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		num.position = Vector2(-3, -7)
		holder.add_child(num)
		row.add_child(panel)
		_cells.append({"panel": panel, "icon": icon, "num": num})
	_caps.append(_cap(row, "RB"))
	# The active tool's name, under the slots.
	_name_label = Label.new()
	_name_label.theme_type_variation = "HudToolName"
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_label)


func _cap(row: Node, text: String) -> Label:
	var cap := Label.new()
	cap.theme_type_variation = "KeyGlyph"
	cap.text = text
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.visible = false
	row.add_child(cap)
	return cap


# entries holds one dictionary per slot with id, name, icon, tint and enabled.
func set_state(entries: Array, active: int) -> void:
	var key := JSON.stringify([entries, active, pad])
	if key == _last_key:
		return
	_last_key = key
	for cap in _caps:
		cap.visible = pad
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
		icon.modulate = Color.WHITE if enabled else Color(0.5, 0.48, 0.45, 0.8)
		icon.queue_redraw()
		var state := "picked" if i == active else ("occupied" if has_tool else "empty")
		# Phase 3 final: a free slot keeps a lit iron rim (hotbar_empty), so all ten read apart at night.
		var box: StyleBox = UiTheme.hotbar_empty() if state == "empty" else UiTheme.slot(state)
		(cell["panel"] as PanelContainer).add_theme_stylebox_override("panel", box)
		var num: Label = cell["num"]
		if i == active:
			num.add_theme_color_override("font_color", UiTheme.GOLD)
		else:
			num.remove_theme_color_override("font_color")
		if i == active:
			active_name = str(entry.get("name", ""))
			if has_tool and not enabled:
				active_name += " (locked)"
	_name_label.text = active_name
