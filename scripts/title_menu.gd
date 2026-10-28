class_name TitleMenu
extends CanvasLayer

## The start screen. It opens when the game launches: Continue the newest save, start a New Game
## or Load Game from one of the save slots, look at Settings, or Quit. main.gd builds the world
## once the player picks a choice; this screen only reports the choice.

signal start_requested(mode: String, slot: int)
signal quit_requested

const SLOT_COUNT := 3
static var notice := ""      # shown once on the start screen, e.g. after the farm was lost
static var active_slot := 1   # the slot in play, kept across a return to the start screen
const LEGACY_SAVE := "user://hallowvale_save.json"
const COL_TEXT := Color("e8dcc0")
const COL_GOLD := Color("d8b050")
const COL_DIM := Color("9a8a6a")
const COL_BUTTON := Color("231a12")
const COL_BUTTON_HOVER := Color("3a2a18")
const COL_BUTTON_DISABLED := Color("16110c")

var settings_rows: Array = []   # the controls list, from main.gd
var page := "title"             # the page showing, so B or Esc can go back from it
var root_panel: Control
var content: VBoxContainer
var overwrite_armed := -1       # slot waiting for a second press in New Game
# The name typed for a new game, handed to the game when it starts.
static var pending_name := ""
const NAME_MAX := 24


static func slot_path(slot: int) -> String:
	return "user://hallowvale_save_%d.json" % slot


# The game was called Hallowvale, and Godot keeps each game's files in a folder named after it. On the first
# run under the new name, saves and settings are copied over from the old folder, so nothing is lost.
static func migrate_old_folder() -> void:
	var old := OS.get_data_dir().path_join("Godot/app_userdata/Hallowvale")
	var dir := DirAccess.open(old)
	if dir == null or OS.get_user_data_dir() == old:
		return
	for file in dir.get_files():
		if file.begins_with("hallowvale_") and file.ends_with(".json") and not FileAccess.file_exists("user://" + file):
			DirAccess.copy_absolute(old.path_join(file), "user://" + file)


# Saves from before there were slots become slot 1, so an old save still loads.
static func migrate_legacy_save() -> void:
	if FileAccess.file_exists(LEGACY_SAVE) and not FileAccess.file_exists(slot_path(1)):
		DirAccess.copy_absolute(LEGACY_SAVE, slot_path(1))


static func slot_data(slot: int) -> Dictionary:
	return SaveSystem.read_save(slot_path(slot))


# Puts each slot's save right before the slots are listed: a damaged or missing save comes back from its
# backup, and the start screen says so once.
static func recover_slots() -> void:
	for slot in range(1, SLOT_COUNT + 1):
		var result := SaveSystem.recover(slot_path(slot))
		var line := ""
		if result == "restored":
			line = "Slot %d's save was damaged, so it was restored from the night before (day %d)." % [slot, int(slot_data(slot).get("day", 1))]
		elif result == "lost":
			line = "Slot %d's save was damaged and had no backup, so the slot is empty." % slot
		if line != "":
			notice = line if notice == "" else notice + "
" + line


# The slot saved most recently, or -1 if there are no saves.
static func newest_slot() -> int:
	var best := -1
	var best_time := -1
	for slot in range(1, SLOT_COUNT + 1):
		var path := slot_path(slot)
		if FileAccess.file_exists(path):
			var t := FileAccess.get_modified_time(path)
			if t > best_time:
				best_time = t
				best = slot
	return best


func _ready() -> void:
	layer = 10
	root_panel = Control.new()
	root_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_panel)

	var bg := ColorRect.new()
	bg.color = Color("0d0a07")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_panel.add_child(bg)

	var column := CenterContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_panel.add_child(column)

	# The build version sits in the corner, so a tester's feedback can name the build it came from.
	var version := Label.new()
	version.text = "v%s" % ProjectSettings.get_setting("application/config/version", "dev")
	version.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)
	version.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	version.grow_vertical = Control.GROW_DIRECTION_BEGIN
	version.add_theme_font_size_override("font_size", 14)
	version.add_theme_color_override("font_color", COL_DIM)
	root_panel.add_child(version)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size = Vector2(420, 0)
	column.add_child(box)
	migrate_legacy_save()
	recover_slots()
	if notice != "":
		var notice_label := Label.new()
		notice_label.text = notice
		notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notice_label.custom_minimum_size = Vector2(420, 0)
		notice_label.add_theme_color_override("font_color", COL_GOLD)
		box.add_child(notice_label)
		notice = ""

	var title := Label.new()
	title.text = "CROW CREEK HOLLOW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", COL_GOLD)
	box.add_child(title)

	var tagline := Label.new()
	tagline.text = "A farm at the edge of the wood"
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.add_theme_color_override("font_color", COL_DIM)
	box.add_child(tagline)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	box.add_child(spacer)

	# The options sit in a scroll box, so a long list such as the controls stays on screen.
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(440, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)

	show_title()


func show_title() -> void:
	_clear()
	page = "title"
	overwrite_armed = -1
	var newest := newest_slot()
	_add_button("Continue", newest >= 0, func() -> void: start_requested.emit("continue", newest))
	_add_button("New Game", true, func() -> void: _show_slots("new"))
	_add_button("Load Game", newest >= 0, func() -> void: _show_slots("load"))
	_add_button("Settings", true, _show_settings)
	_add_button("Quit", true, func() -> void: quit_requested.emit())
	_add_hint("Up and down to choose, Enter or A to pick.")
	_focus_first()


func _show_slots(mode: String) -> void:
	_clear()
	page = "slots"
	var heading := "Choose a slot for the new game" if mode == "new" else "Load a game"
	_add_heading(heading)
	for slot in range(1, SLOT_COUNT + 1):
		var data := slot_data(slot)
		var text := _slot_text(slot, data)
		if mode == "new":
			var slot_number := slot
			if data.is_empty():
				_add_button(text, true, func() -> void: _show_name(slot_number))
			else:
				_add_button(text, true, func() -> void: _arm_overwrite(slot_number))
		else:
			_add_button(text, not data.is_empty(), func() -> void: start_requested.emit("load", slot))
	_add_button("Back", true, show_title)
	_focus_first()


# Starting over in a used slot takes two presses, so a save isn't lost by accident.
func _arm_overwrite(slot: int) -> void:
	if overwrite_armed != slot:
		overwrite_armed = slot
		_show_slots_refresh_armed(slot)
		return
	_show_name(slot)


func _show_slots_refresh_armed(slot: int) -> void:
	_show_slots("new")
	for child in content.get_children():
		var button := child as Button
		if button != null and button.text.begins_with("Slot %d:" % slot):
			button.text = "Slot %d: press again to overwrite" % slot
			# Keep focus on the armed slot, so a gamepad's second press overwrites it.
			# Queued after _show_slots' own focus call, so this one wins.
			button.grab_focus.call_deferred()


# A new game asks for a save name, so the slots are easy to tell apart. It starts filled in, so a
# gamepad player can just press Begin.
func _show_name(slot: int) -> void:
	_clear()
	page = "name"
	_add_heading("Name this save")
	var field := LineEdit.new()
	field.text = "Farm %d" % slot
	field.max_length = NAME_MAX
	field.select_all_on_focus = true
	field.custom_minimum_size = Vector2(420, 44)
	field.add_theme_font_size_override("font_size", 20)
	field.add_theme_color_override("font_color", COL_TEXT)
	field.add_theme_stylebox_override("normal", _box(COL_BUTTON))
	field.add_theme_stylebox_override("focus", _box(COL_BUTTON_HOVER))
	content.add_child(field)
	var begin := func() -> void:
		pending_name = field.text.strip_edges()
		if pending_name == "":
			pending_name = "Farm %d" % slot
		start_requested.emit("new", slot)
	field.text_submitted.connect(func(_t: String) -> void: begin.call())
	_add_button("Begin", true, begin)
	_add_button("Back", true, func() -> void: _show_slots("new"))
	_add_hint("Type a name, then press Enter or Begin.")
	field.grab_focus.call_deferred()


# B or Esc goes back a page: from Controls to Settings, and from any other page to the title.
func _unhandled_input(event: InputEvent) -> void:
	if not visible or page == "title" or not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if page == "controls":
		_show_settings()
	elif page == "name":
		_show_slots("new")
	else:
		show_title()


# The same settings as the Pause menu, from GameSettings. keep_action keeps focus on the button just pressed.
func _show_settings(keep_action: String = "") -> void:
	_clear()
	page = "settings"
	for row in GameSettings.rows():
		if row.has("section"):
			_add_heading(str(row["section"]))
			continue
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		var name_label := Label.new()
		name_label.text = str(row["name"])
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_color_override("font_color", COL_TEXT)
		line.add_child(name_label)
		var value_label := Label.new()
		value_label.text = str(row.get("value", ""))
		value_label.add_theme_color_override("font_color", COL_DIM)
		line.add_child(value_label)
		for key in ["2", ""]:
			if row.has("button" + key):
				var action := str(row["action" + key])
				var button := _make_button(str(row["button" + key]), true, _on_setting.bind(action), Vector2(44 if row.has("button2") else 96, 36), 16)
				button.set_meta("action", action)
				line.add_child(button)
				if action == keep_action:
					button.grab_focus.call_deferred()
		content.add_child(line)
	_add_button("Controls", true, _show_controls)
	_add_button("Back", true, show_title)
	if keep_action == "":
		_focus_first()


func _on_setting(action: String) -> void:
	GameSettings.change(action)
	_show_settings(action)


func _show_controls() -> void:
	_clear()
	page = "controls"
	for row in settings_rows:
		if row.has("section"):
			_add_heading(str(row["section"]))
		elif row.has("note"):
			_add_hint(str(row["note"]))
		elif row.has("name"):
			var line := HBoxContainer.new()
			var name_label := Label.new()
			name_label.text = str(row["name"])
			name_label.custom_minimum_size = Vector2(190, 0)
			name_label.add_theme_color_override("font_color", COL_TEXT)
			line.add_child(name_label)
			var value_label := Label.new()
			value_label.text = str(row.get("value", ""))
			value_label.add_theme_color_override("font_color", COL_DIM)
			value_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			value_label.custom_minimum_size = Vector2(220, 0)
			line.add_child(value_label)
			content.add_child(line)
	_add_button("Back", true, _show_settings)
	_focus_first()


func _slot_text(slot: int, data: Dictionary) -> String:
	if data.is_empty():
		return "Slot %d: empty" % slot
	var stages := ["Decrepit", "Boarded", "Patched", "Restored"]
	var stage := clampi(int(data.get("house_stage", 0)), 0, stages.size() - 1)
	var details := "day %d, %d coins, house %s" % [int(data.get("day", 1)), int(data.get("money", 0)), stages[stage]]
	var save_name := str(data.get("save_name", ""))
	if save_name == "":
		return "Slot %d: %s" % [slot, details]
	return "Slot %d: %s
%s" % [slot, save_name, details]


func _clear() -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()


func _add_button(text: String, enabled: bool, on_press: Callable) -> void:
	content.add_child(_make_button(text, enabled, on_press, Vector2(420, 44), 20))


func _make_button(text: String, enabled: bool, on_press: Callable, min_size: Vector2, font_size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = not enabled
	button.custom_minimum_size = min_size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", COL_TEXT)
	button.add_theme_color_override("font_disabled_color", COL_DIM)
	if not UiSkin.style_button(button):
		button.add_theme_stylebox_override("normal", _box(COL_BUTTON))
		button.add_theme_stylebox_override("hover", _box(COL_BUTTON_HOVER))
		button.add_theme_stylebox_override("focus", _box(COL_BUTTON_HOVER))
		button.add_theme_stylebox_override("pressed", _box(COL_BUTTON_HOVER))
		button.add_theme_stylebox_override("disabled", _box(COL_BUTTON_DISABLED))
	if enabled:
		button.pressed.connect(on_press)
	return button


func _add_heading(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", COL_GOLD)
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(label)


func _add_hint(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(420, 0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", COL_DIM)
	label.add_theme_font_size_override("font_size", 14)
	content.add_child(label)


func _box(color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = Color("6b4f2a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	return sb


func _focus_first() -> void:
	for child in content.get_children():
		var button := child as Button
		if button != null and not button.disabled:
			button.grab_focus.call_deferred()
			return
