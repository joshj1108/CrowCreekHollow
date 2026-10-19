class_name ActionBar
extends CanvasLayer

## Classic RuneScape-style action bar: a row of tab buttons along the bottom
## and a panel that opens above it. main.gd decides what each panel shows.

signal tab_pressed(tab_name: String)

const TAB_LABELS := {
	"Skills": "Skills [K]",
	"Inventory": "Inventory [I]",
	"Gear": "Gear [G]",
	"Settings": "Settings",
}

var panel: PanelContainer
var title_label: Label
var body_label: Label
var xp_bar: ProgressBar


func _ready() -> void:
	# Full-screen root ignores mouse so clicks outside the bar still reach the game.
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	_place_bottom_center(bar, -12)
	root.add_child(bar)
	for tab in TAB_LABELS:
		var button := Button.new()
		button.text = TAB_LABELS[tab]
		button.custom_minimum_size = Vector2(140, 44)
		button.focus_mode = Control.FOCUS_NONE  # keeps Space/Enter for farming
		button.pressed.connect(_on_tab_pressed.bind(tab))
		bar.add_child(button)

	panel = PanelContainer.new()
	panel.visible = false
	_place_bottom_center(panel, -72)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(480, 0)
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	box.add_child(title_label)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body_label)

	xp_bar = ProgressBar.new()
	xp_bar.show_percentage = false
	xp_bar.custom_minimum_size = Vector2(0, 16)
	box.add_child(xp_bar)


func show_panel(title: String, body: String, xp_progress: float = -1.0) -> void:
	panel.visible = true
	title_label.text = title
	body_label.text = body
	# A value below zero hides the XP bar (used by tabs that aren't Skills).
	xp_bar.visible = xp_progress >= 0.0
	xp_bar.value = clampf(xp_progress, 0.0, 1.0) * 100.0


func hide_panel() -> void:
	panel.visible = false


func _on_tab_pressed(tab: String) -> void:
	tab_pressed.emit(tab)


func _place_bottom_center(ctrl: Control, bottom_offset: float) -> void:
	ctrl.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	ctrl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ctrl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	ctrl.offset_bottom = bottom_offset
