extends SceneTree

# Checks that every menu works with the mouse, the keyboard and an Xbox controller. Run headless, from the
# project folder:
#   godot --path . --headless -s tools/menu_test.gd
# It opens each menu by its own key or button (the small panels by the call their building makes), then
# drives it with injected keys, joypad buttons and axes, and mouse moves, clicks and wheel steps. For each
# it checks that something has focus when it opens, that focus moves and every entry can be reached, that
# nothing hidden or disabled can take focus, that A, Space and Enter press, that B and Esc go back one level,
# that tabs switch, that the footer prompts follow the last device, that the clock stops while it is open,
# and that closing it hands the farm back with no press leaking through. Prints PASS or FAIL for each case
# and a total; the exit code is the number of failures.
# The game plays in save slot 9 and never sleeps, so nothing is saved; slots 1-3 are only listed, never
# pressed. settings.cfg is put back as it was when the test ends.

const SLOT := 9
const SETTINGS := "user://settings.cfg"

var m: MainGame
var failures := 0
var settings_backup := ""


func _initialize() -> void:
	if FileAccess.file_exists(SETTINGS):
		settings_backup = FileAccess.get_file_as_string(SETTINGS)
	# A script error stops the test's coroutine; fail instead of hanging.
	create_timer(600.0).timeout.connect(func() -> void:
		print("FAIL: the test stopped part way (a script error above?) and timed out")
		quit(99))
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)
	_run.call_deferred()


func _run() -> void:
	await _frames(3)
	await _title_cases()
	m._on_title_start("new", SLOT)
	await _frames(5)
	# Everything unlocked, so every panel has its buttons and every build can be pressed.
	m._dev_unlock_all()
	m.diary_found = true
	await _frames(3)
	await _farm_cases()
	await _pause_cases()
	await _wheel_cases()
	await _section_cases()
	await _craft_pad_cases()
	await _cooking_pad_cases()
	await _split_cases()
	await _amount_cases()
	await _diary_cases()
	await _bag_cases()
	await _small_panel_cases()
	await _mouse_cases()
	await _device_cases()
	await _placement_cases()
	await _scene_cases()
	await _ending_cases()
	await _overlap_cases()
	await _late_cases()
	if settings_backup != "":
		var f := FileAccess.open(SETTINGS, FileAccess.WRITE)
		f.store_string(settings_backup)
		f.close()
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


# --- The start screen ---------------------------------------------------------

func _title_cases() -> void:
	var t: TitleMenu = m.title_menu
	_check("title: a button has focus on open", _focus_ok())
	_check("title: focus starts on the first usable button", _focus() == _first_usable(t.content))
	await _walk_all("title (keys)", t.content, KEY_DOWN, -1)
	await _walk_all("title (D-pad)", t.content, -1, JOY_BUTTON_DPAD_DOWN)
	_check("title: no disabled button can take focus", _no_disabled_focus(t.content))
	# The left stick moves focus past its 0.3 deadzone, and not inside it.
	_first_usable(t.content).grab_focus()
	await _frames(1)
	var before := _focus()
	await _axis(JOY_AXIS_LEFT_Y, 0.2)
	_check("title: left stick inside the deadzone doesn't move focus", _focus() == before)
	await _axis(JOY_AXIS_LEFT_Y, 0.8)
	_check("title: left stick past the deadzone moves focus", _focus() != before and _focus_ok())

	# Settings with Enter, back with Esc; with A, back with B; with Space; and with a click.
	await _press_title_button("Settings", KEY_ENTER, -1)
	_check("title: Enter opens Settings", t.page == "settings" and _focus_ok())
	await _walk_reach("title settings", t.content)
	var top := _focus()
	for i in 30:
		await _key(KEY_DOWN)
	_check("title settings: down reaches Back at the bottom", _focus_ok() and (_focus() as Button).text == "Back")
	await _key(KEY_RIGHT)
	_check("title settings: focus never leaves the page", _focus_ok() and t.content.is_ancestor_of(_focus()) and top != null)
	_check("title settings: no disabled button can take focus", _no_disabled_focus(t.content))
	var scroll := t.content.get_parent() as ScrollContainer
	_check("title settings: the list follows focus", scroll.follow_focus and scroll.scroll_vertical > 0)
	await _key(KEY_ESCAPE)
	_check("title settings: Esc goes back to the title", t.page == "title" and _focus_ok())
	await _press_title_button("Settings", -1, JOY_BUTTON_A)
	_check("title: A opens Settings", t.page == "settings")
	await _press_title_button("Controls", -1, JOY_BUTTON_A)
	_check("title: Controls opens from Settings", t.page == "controls" and _focus_ok())
	var scrolled := scroll.scroll_vertical
	for i in 6:
		await _key(KEY_DOWN)
	_check("title controls: down scrolls the long list", scroll.scroll_vertical > scrolled)
	await _pad(JOY_BUTTON_B)
	_check("title controls: B goes back to Settings", t.page == "settings" and _focus_ok())
	await _pad(JOY_BUTTON_B)
	_check("title settings: B goes back to the title", t.page == "title" and _focus_ok())
	await _press_title_button("New Game", KEY_SPACE, -1)
	_check("title: Space opens New Game", t.page == "slots" and _focus_ok())
	_check("title slots: no disabled button can take focus", _no_disabled_focus(t.content))
	await _key(KEY_ESCAPE)
	_check("title slots: Esc goes back", t.page == "title")
	await _press_title_button("Load Game", -1, JOY_BUTTON_A)
	if t.page == "slots":
		_check("title load: focus is on a usable slot", _focus_ok())
		await _pad(JOY_BUTTON_B)
	_check("title load: B goes back", t.page == "title")

	# The name page: the field has focus, the D-pad reaches Begin, and B or Esc goes back to the slots.
	t._show_name(SLOT)
	await _frames(2)
	_check("title name: the name field has focus", _focus() is LineEdit)
	var field := _focus() as LineEdit
	field.caret_column = field.text.length()
	for letter in ["w", "a", "s", "d"]:
		var typed := _key_event(OS.find_keycode_from_string(letter.to_upper()), true)
		typed.unicode = letter.unicode_at(0)
		Input.parse_input_event(typed)
		await _frames(1)
		Input.parse_input_event(_key_event(typed.keycode, false))
		await _frames(1)
	_check("title name: W, A, S and D type into the name", field.text.ends_with("wasd") and _focus() == field)
	await _pad(JOY_BUTTON_DPAD_DOWN)
	_check("title name: the D-pad moves from the field to Begin", _focus() is Button and (_focus() as Button).text == "Begin")
	await _key(KEY_UP)
	_check("title name: up goes back to the field", _focus() is LineEdit)
	await _key(KEY_ESCAPE)
	_check("title name: Esc in the field goes back to the slots", t.page == "slots")
	t._show_name(SLOT)
	await _frames(2)
	await _pad(JOY_BUTTON_B)
	_check("title name: B goes back to the slots", t.page == "slots")
	await _key(KEY_ESCAPE)

	# The mouse: hover and click Settings, and the wheel scrolls the Controls page.
	var settings_button := _button_named(t.content, "Settings")
	await _click(settings_button)
	_check("title: a click opens Settings", t.page == "settings")
	var controls := _button_named(t.content, "Controls")
	scroll.ensure_control_visible(controls)
	await _frames(2)
	await _click(controls)
	_check("title settings: a click on Controls opens it", t.page == "controls")
	scroll.scroll_vertical = 0
	await _wheel(scroll, MOUSE_BUTTON_WHEEL_DOWN)
	_check("title controls: the mouse wheel scrolls", scroll.scroll_vertical > 0)
	var back := _button_named(t.content, "Back")
	scroll.ensure_control_visible(back)
	await _frames(2)
	await _click(back)
	_check("title controls: a click on Back goes to Settings", t.page == "settings")
	await _key(KEY_ESCAPE)


func _press_title_button(text: String, key: int, button: int) -> void:
	var target := _button_named(m.title_menu.content, text)
	if target == null or target.disabled:
		return
	target.grab_focus()
	await _frames(1)
	if key >= 0:
		await _key(key)
	else:
		await _pad(button)


# --- The farm with nothing open -------------------------------------------------

func _farm_cases() -> void:
	_check("farm: nothing has focus", _focus() == null)
	_check("farm: the player can move", await _player_moves())
	var clock_before := m.clock
	await _frames(5)
	_check("farm: the clock runs", m.clock > clock_before)


# --- The Pause menu, Settings and Controls -------------------------------------

func _pause_cases() -> void:
	await _key(KEY_ESCAPE)
	_check("pause: Esc opens it", m.open_tab == "Pause")
	await _ledger_checks("pause")
	await _press_entry("resume", KEY_ENTER, -1)
	_check("pause: Enter on Resume closes it", m.open_tab == "" and not m.action_bar.panel.visible)
	await _handed_back("pause: Resume")
	await _pad(JOY_BUTTON_START)
	_check("pause: Start opens it", m.open_tab == "Pause")
	await _pad(JOY_BUTTON_START)
	_check("pause: Start closes it", m.open_tab == "")
	await _handed_back("pause: Start")
	await _key(KEY_ESCAPE)
	await _press_entry("open_settings", -1, JOY_BUTTON_A)
	_check("pause: A on Settings opens Settings", m.open_tab == "Settings")
	await _ledger_checks("settings")
	# Left and right step a volume line, as on a slider.
	m.action_bar._open_ledger_tab(0)
	await _frames(2)
	var volume := GameSettings.sfx_volume
	await _focus_action("set_sfx_up")
	await _key(KEY_LEFT)
	_check("settings: left steps the volume down", GameSettings.sfx_volume < volume or volume == 0)
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("settings: the D-pad right steps it back up", GameSettings.sfx_volume == volume)
	_check("settings: focus stays on the volume line", _focus_ok() and str(_focus().get_meta("action", "")) == "set_sfx_up")
	await _pad(JOY_BUTTON_B)
	_check("settings: B goes back to the Pause menu", m.open_tab == "Pause" and _focus_ok())
	await _press_entry("open_controls", KEY_SPACE, -1)
	_check("pause: Space on Controls opens Controls", m.open_tab == "Controls")
	await _ledger_checks("controls")
	await _key(KEY_ESCAPE)
	_check("controls: Esc goes back to the Pause menu", m.open_tab == "Pause")
	# A quit waits for a second press, and B from there closes the menu without quitting.
	await _press_entry("quit_title", KEY_ENTER, -1)
	_check("pause: one press on Quit to the main menu only arms it", m.pause_armed == "quit_title" and m.open_tab == "Pause")
	_check("pause: focus stays on the armed quit", _focus_ok() and str(_focus().get_meta("action", "")) == "quit_title")
	await _pad(JOY_BUTTON_B)
	_check("pause: B closes it", m.open_tab == "")
	await _handed_back("pause: B")


# --- The section wheel ----------------------------------------------------------

func _wheel_cases() -> void:
	var w: SectionWheel = m.wheel
	await _key(KEY_SHIFT)
	_check("wheel: Shift opens it", w.open)
	_check("wheel: the clock stops", await _clock_stopped())
	var at := w.highlight
	await _key(KEY_RIGHT)
	_check("wheel: right moves the highlight", w.highlight == posmod(at + 1, SectionWheel.SECTIONS.size()))
	await _key(KEY_LEFT)
	_check("wheel: left moves it back", w.highlight == at)
	await _pad(JOY_BUTTON_DPAD_DOWN)
	_check("wheel: the D-pad moves the highlight", w.highlight != at)
	var seen := {}
	for i in SectionWheel.SECTIONS.size():
		seen[w.highlight] = true
		await _key(KEY_D)
	_check("wheel: D steps through every section", seen.size() == SectionWheel.SECTIONS.size())
	await _key(KEY_ESCAPE)
	_check("wheel: Esc closes it", not w.open)
	await _handed_back("wheel: Esc")
	await _pad(JOY_BUTTON_LEFT_STICK)
	_check("wheel: L3 opens it", w.open)
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.2))
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, 0.0))
	var still := w.highlight
	await _frames(2)
	_check("wheel: the stick inside the deadzone doesn't move it", w.highlight == still)
	# Straight down on the stick is the section at the bottom of the ring.
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.0))
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, 0.9))
	await _frames(2)
	var bottom := SectionWheel.SECTIONS.size() / 2
	_check("wheel: the left stick highlights a section", w.highlight == bottom)
	await _axis(JOY_AXIS_LEFT_Y, 0.0)
	await _pad(JOY_BUTTON_A)
	_check("wheel: A opens the highlighted section", m.open_tab == str(SectionWheel.SECTIONS[bottom]["name"]) and not w.open)
	await _pad(JOY_BUTTON_B)
	_check("wheel: B from a section goes back to the wheel", m.open_tab == "" and w.open)
	await _pad(JOY_BUTTON_B)
	_check("wheel: B closes the wheel", not w.open)
	await _handed_back("wheel: B")
	await _key(KEY_SHIFT)
	await _key(KEY_SHIFT)
	_check("wheel: Shift closes it again", not w.open)
	m.wheel.highlight = 0
	await _key(KEY_SHIFT)
	await _key(KEY_ENTER)
	_check("wheel: Enter opens the highlighted section", m.open_tab == "Skills")
	await _key(KEY_ESCAPE)
	await _key(KEY_SPACE)
	_check("wheel: Space opens the highlighted section", m.open_tab == "Skills")
	await _key(KEY_ESCAPE)
	await _key(KEY_ESCAPE)
	_check("wheel: Esc twice from a section is back on the farm", m.open_tab == "" and not w.open)


# --- Every wheel section --------------------------------------------------------

func _section_cases() -> void:
	for i in SectionWheel.SECTIONS.size():
		var section := str(SectionWheel.SECTIONS[i]["name"])
		if section == "Diary":
			continue
		await _open_from_wheel(i)
		_check("%s: opens from the wheel" % section, m.open_tab == section)
		_check("%s: the clock stops" % section, await _clock_stopped())
		if m.action_bar.ledger.visible:
			await _ledger_checks(section.to_lower())
		else:
			await _grid_checks(section.to_lower())
		await _key(KEY_ESCAPE)
		_check("%s: Esc goes back to the wheel" % section, m.open_tab == "" and m.wheel.open)
		await _key(KEY_ESCAPE)
		await _handed_back(section)
	# Craft's own sub-tabs, each in turn.
	await _open_from_wheel(2)
	var tabs: Array = m.CRAFT_TABS
	for k in tabs.size():
		await _grid_checks("craft %s" % str(tabs[k]["name"]).to_lower())
		await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	_check("craft: RB steps round the sub-tabs back to the first", m.craft_tab == str(tabs[0]["id"]))
	# Picking a recipe with A keeps focus on it.
	var tiles := _focusables(m.action_bar.grid_body).filter(func(c: Control) -> bool: return str(c.get_meta("action", "")).begins_with("craft_pick:"))
	if tiles.size() > 2:
		var tile: Control = tiles[2]
		var action := str(tile.get_meta("action"))
		tile.grab_focus()
		await _frames(1)
		await _pad(JOY_BUTTON_A)
		await _frames(2)
		_check("craft: picking a recipe moves focus to its button, or keeps it on the recipe", _focus_ok() and (str(_focus().get_meta("action", "")) == action or _focus() == _make_button()))
	else:
		_check("craft: recipe tiles carry their action", false)
	await _pad(JOY_BUTTON_B)
	await _pad(JOY_BUTTON_B)
	# Inventory, Gear and Skills share a tab strip.
	await _open_from_wheel(0)
	await _key(KEY_Q)
	_check("skills: Q steps to Gear", m.open_tab == "Gear")
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check("gear: LB steps to Inventory", m.open_tab == "Inventory")
	await _grid_checks("inventory")
	await _key(KEY_E)
	_check("inventory: E steps to Gear", m.open_tab == "Gear")
	await _key(KEY_ESCAPE)
	await _key(KEY_ESCAPE)
	# Quests has its Folk tab.
	await _open_from_wheel(3)
	m.action_bar._open_ledger_tab(1)
	await _frames(2)
	_check("quests: the Folk tab opens with focus", _focus_ok())
	await _key(KEY_ESCAPE)
	await _key(KEY_ESCAPE)


# --- Craft on a controller, start to finish ----------------------------------------

func _craft_pad_cases() -> void:
	var pressed: Array = []
	var record := func(action_id: String) -> void: pressed.append(action_id)
	m.action_bar.action_pressed.connect(record)
	await _close_all()
	# L3, the stick toward Craft (third round the ring, straight right), then A.
	await _pad(JOY_BUTTON_LEFT_STICK)
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.9))
	await _frames(2)
	await _axis(JOY_AXIS_LEFT_X, 0.0)
	_check("craft pad: the stick highlights Craft", m.wheel.highlight == 2)
	await _pad(JOY_BUTTON_A)
	await _frames(2)
	_check("craft pad: A opens Craft with a recipe in focus", m.open_tab == "Craft" and _focus_ok() and str(_focus().get_meta("action", "")).begins_with("craft_pick:"))
	var first := _focus()
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("craft pad: the D-pad moves to the next recipe", _focus_ok() and _focus() != first and str(_focus().get_meta("action", "")).begins_with("craft_pick:"))
	await _pad(JOY_BUTTON_DPAD_DOWN)
	_check("craft pad: the D-pad moves down a row", _focus_ok() and str(_focus().get_meta("action", "")).begins_with("craft_pick:"))
	await _pad(JOY_BUTTON_DPAD_UP)
	await _pad(JOY_BUTTON_DPAD_LEFT)
	_check("craft pad: and back to the first", _focus() == first or str(_focus().get_meta("action", "")) == str(first.get_meta("action", "")) if is_instance_valid(first) else _focus_ok())
	# Pick the first craftable recipe with A, then reach Make and press it.
	var made := false
	for tile in _focusables(m.action_bar.grid_body):
		var action := str(tile.get_meta("action", ""))
		if not action.begins_with("craft_pick:"):
			continue
		tile.grab_focus()
		await _frames(1)
		await _pad(JOY_BUTTON_A)
		await _frames(2)
		_check("craft pad: A picks the recipe", _focus_ok() and m.craft_selected == action.trim_prefix("craft_pick:"))
		var make := _make_button()
		if make == null:
			continue
		for i in 6:
			if _focus() == make:
				break
			await _pad(JOY_BUTTON_DPAD_RIGHT)
		_check("craft pad: A jumps the highlight to Make", _focus() == make)
		pressed.clear()
		await _pad(JOY_BUTTON_A)
		await _frames(2)
		_check("craft pad: A on Make crafts", pressed.any(func(a: String) -> bool: return a.begins_with("craft:")))
		_check("craft pad: focus stays in the panel after crafting", _focus_ok() and m.action_bar.panel.is_ancestor_of(_focus()))
		made = true
		break
	_check("craft pad: some recipe could be made", made)
	# RB to the next sub-tab, then the D-pad still works there.
	var tab := m.craft_tab
	await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	await _frames(2)
	_check("craft pad: RB switches the sub-tab with focus on a recipe", m.craft_tab != tab and _focus_ok())
	var here := _focus()
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("craft pad: the D-pad works on the new sub-tab", _focus_ok() and _focus() != here)
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	await _frames(2)
	_check("craft pad: LB switches back", m.craft_tab == tab and _focus_ok())
	await _pad(JOY_BUTTON_B)
	_check("craft pad: B goes back to the wheel", m.open_tab == "" and m.wheel.open)
	await _pad(JOY_BUTTON_B)
	m.action_bar.action_pressed.disconnect(record)
	await _handed_back("craft pad")


# Cooking a fish with only the D-pad and A: move to Grilled Fish, A picks it and jumps to Cook, A cooks.
func _cooking_pad_cases() -> void:
	for key in Foods.group("any_fish"):
		m.inventory[key] = 0
	m.inventory[Foods.group("any_fish")[0]] = 2
	var pressed: Array = []
	var record := func(action_id: String) -> void: pressed.append(action_id)
	m.action_bar.action_pressed.connect(record)
	await _open_from_wheel(2)
	for i in m.CRAFT_TABS.size():
		if m.craft_tab == "cooking":
			break
		await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	await _frames(2)
	_check("cooking pad: RB reaches the Cooking tab with a recipe in focus", m.craft_tab == "cooking" and _focus_ok())
	# Step right and down through the grid until Grilled Fish is in focus.
	var target := "craft_pick:cook:fish_meal"
	var found := false
	for i in 12:
		if str(_focus().get_meta("action", "")) == target:
			found = true
			break
		await _pad(JOY_BUTTON_DPAD_RIGHT if i % 4 != 3 else JOY_BUTTON_DPAD_DOWN)
	_check("cooking pad: the D-pad reaches Grilled Fish", found)
	await _pad(JOY_BUTTON_A)
	await _frames(3)
	_check("cooking pad: A picks Grilled Fish", m.crafting._chosen_recipe(m.crafting._craft_recipes()).get("key", "") == "cook:fish_meal")
	_check("cooking pad: A jumps the highlight to Cook", _focus_ok() and str(_focus().get_meta("action", "")) == "cook:fish_meal")
	pressed.clear()
	await _pad(JOY_BUTTON_A)
	await _frames(2)
	_check("cooking pad: A on Cook cooks it", pressed.has("cook:fish_meal"))
	_check("cooking pad: focus stays on Cook while it can be pressed again", _focus_ok() and str(_focus().get_meta("action", "")) == "cook:fish_meal")
	await _pad(JOY_BUTTON_A)
	await _frames(2)
	_check("cooking pad: with no fish left focus goes back to Grilled Fish", _focus_ok() and str(_focus().get_meta("action", "")) == target)
	await _pad(JOY_BUTTON_DPAD_LEFT)
	_check("cooking pad: the D-pad still moves after cooking", _focus_ok())
	# Keyboard: Space on a recipe jumps to its button too; a click only picks.
	m.inventory["crops"] = 4
	await _frames(3)
	var tile := _focusables(m.action_bar.grid_body).filter(func(c: Control) -> bool: return str(c.get_meta("action", "")) == "craft_pick:cook:turnip_hash")
	_check("cooking keys: Turnip Hash is in the grid", not tile.is_empty())
	if not tile.is_empty():
		tile[0].grab_focus()
		await _frames(1)
		await _key(KEY_SPACE)
		await _frames(3)
		_check("cooking keys: Space picks a recipe and jumps to Cook", _focus_ok() and str(_focus().get_meta("action", "")) == "cook:turnip_hash")
		var other := _focusables(m.action_bar.grid_body).filter(func(c: Control) -> bool: return str(c.get_meta("action", "")) == target)
		m.inventory[Foods.group("any_fish")[0]] = 2
		await _frames(3)
		other = _focusables(m.action_bar.grid_body).filter(func(c: Control) -> bool: return str(c.get_meta("action", "")) == target)
		m.action_bar.scroll.ensure_control_visible(other[0])
		await _frames(2)
		await _click(other[0])
		await _frames(3)
		var at := str(_focus().get_meta("action", "")) if _focus() != null else "nothing"
		_check("cooking mouse: a click picks a recipe without jumping (focus on %s)" % at, m.craft_selected == "cook:fish_meal" and not at.begins_with("cook:"))
	m.action_bar.action_pressed.disconnect(record)
	await _close_all()
	await _handed_back("cooking")


# --- Grid panels: the list scrolls, the picked recipe's card stays put -------------

func _split_cases() -> void:
	var ab: ActionBar = m.action_bar
	await _open_from_wheel(2)
	_check("split: Craft's card sits beside the list, outside its scroll", ab.side_column.visible and ab._detail_button != null and not ab.scroll.is_ancestor_of(ab._detail_button))
	ab.scroll.scroll_vertical = 0
	for i in 12:
		await _pad(JOY_BUTTON_DPAD_DOWN)
	_check("split: moving down the recipes scrolls the list", ab.scroll.scroll_vertical > 0)
	var column := ab.side_column.get_global_rect()
	var frame := ab.grid_body.get_global_rect()
	var button := ab._detail_button.get_global_rect()
	_check("split: the card's button stays in view while the list scrolls", column.encloses(button) and frame.encloses(button) and ab._detail_button.is_visible_in_tree())
	var shown := ab.scroll.scroll_vertical
	await _wheel(ab.scroll, MOUSE_BUTTON_WHEEL_UP)
	_check("split: the mouse wheel scrolls the list", ab.scroll.scroll_vertical < shown)
	# Every recipe, however long its text: its button is in view.
	var all_in_view := true
	var picks: Array = []
	for tile in _focusables(ab.grid_body):
		if str(tile.get_meta("action", "")).begins_with("craft_pick:"):
			picks.append(str(tile.get_meta("action")).trim_prefix("craft_pick:"))
	for pick in picks:
		m.craft_selected = pick
		await _frames(2)
		if ab._detail_button != null and not ab.grid_body.get_global_rect().encloses(ab._detail_button.get_global_rect()):
			all_in_view = false
			print("   out of view: ", m.craft_selected)
	_check("split: every recipe's button is in view", all_in_view and not picks.is_empty())
	await _open_from_wheel(0)
	_check("split: Skills has its card beside the list too", ab.side_column.visible and _focus_ok())
	await _close_all()
	await _handed_back("split")


# --- Amounts: sell, store and take some, not only all -------------------------------

func _amount_cases() -> void:
	var fish: String = Foods.group("any_fish")[0]
	var fish_id := str(Foods.by_held(fish)["id"])
	for key in Foods.group("any_fish"):
		m.inventory[key] = 0
	m.inventory[fish] = 6
	m._toggle_tab("Trade")
	await _frames(3)
	_check("stand: a ledger with an entry in focus", m.action_bar.ledger.visible and _focus_ok())
	await _focus_action("sell_food:" + fish_id)
	_check("stand: an entry starts at Sell 1", _chip() == "Sell 1")
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	await _key(KEY_RIGHT)
	_check("stand: right steps the amount up (pad and keys)", _chip() == "Sell 3" and _focus_ok())
	await _axis(JOY_AXIS_LEFT_X, 0.9)
	_check("stand: one push of the stick steps once", _chip() == "Sell 4")
	await _key(KEY_LEFT)
	_check("stand: left steps it down", _chip() == "Sell 3")
	var money := m.money
	var price := m.stall._sale_value(fish_id, 3)
	await _pad(JOY_BUTTON_A)
	await _frames(2)
	_check("stand: A sells that many", int(m.inventory[fish]) == 3 and m.money == money + price)
	_check("stand: focus stays on the entry", _focus_ok() and str(_focus().get_meta("action", "")) == "sell_food:" + fish_id)
	_check("stand: the amount fits what's left", _chip() == "Sell 3")
	await _key(KEY_RIGHT)
	_check("stand: right from all goes round to 1", _chip() == "Sell 1")
	await _key(KEY_LEFT)
	_check("stand: left from 1 goes round to all", _chip() == "Sell 3")
	# The mouse: - on the detail page, then the button.
	await _click(_button_named(m.action_bar.detail_box, "-"))
	_check("stand: the mouse's - steps it down", _chip() == "Sell 2")
	await _click(_button_named(m.action_bar.detail_box, "Sell 2"))
	_check("stand: a click on Sell 2 sells 2", int(m.inventory[fish]) == 1)
	await _key(KEY_SPACE)
	_check("stand: Space sells the last one", int(m.inventory[fish]) == 0)
	await _pad(JOY_BUTTON_B)
	await _handed_back("stand")

	# The cellar: store 2 turnips of 6, then take 1 back.
	m.cellar_built = true
	m.cellar.clear()
	m.inventory["crops"] = 6
	m._toggle_tab("Cellar")
	await _frames(3)
	await _focus_action("cellar_store:crops")
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	await _pad(JOY_BUTTON_A)
	await _frames(2)
	_check("cellar: storing 2 of 6 turnips", int(m.cellar.get("crops", 0)) == 2 and int(m.inventory["crops"]) == 4)
	await _focus_action("cellar_take:crops")
	await _key(KEY_ENTER)
	await _frames(2)
	_check("cellar: taking 1 back", int(m.cellar.get("crops", 0)) == 1 and int(m.inventory["crops"]) == 5)
	await _pad(JOY_BUTTON_B)
	await _handed_back("cellar amounts")

	# The cooler: store 3 of 4 fish.
	m.cooler.clear()
	m.inventory[fish] = 4
	m._toggle_tab("Cooler")
	await _frames(3)
	await _focus_action("cooler_store:" + fish)
	for i in 2:
		await _pad(JOY_BUTTON_DPAD_RIGHT)
	await _pad(JOY_BUTTON_A)
	await _frames(2)
	_check("cooler: storing 3 of 4 fish", int(m.cooler.get(fish, 0)) == 3 and int(m.inventory[fish]) == 1)
	await _pad(JOY_BUTTON_B)

	# The firewood store: take 3.
	m.firewood_store = 10
	var wood := int(m.inventory["firewood"])
	m._toggle_tab("Woodstore")
	await _frames(3)
	await _focus_action("wood_take")
	for i in 2:
		await _key(KEY_D)
	await _key(KEY_SPACE)
	await _frames(2)
	_check("firewood: taking 3", m.firewood_store == 7 and int(m.inventory["firewood"]) == wood + 3)
	await _pad(JOY_BUTTON_B)
	await _handed_back("firewood amounts")


# The focused ledger entry's status, such as "Sell 3".
func _chip() -> String:
	var f := _focus()
	if f == null or not f.has_meta("chip"):
		return ""
	return (f.get_meta("chip") as Label).text


# The detail card's Make (or Equip) button, when it can be pressed.
func _make_button() -> Button:
	var b: Button = m.action_bar._detail_button
	return b if is_instance_valid(b) and m.action_bar._focusable(b) else null


# --- The diary ------------------------------------------------------------------

func _diary_cases() -> void:
	await _key(KEY_J)
	_check("diary: J opens it", m.open_tab == "Diary" and m.action_bar.book.visible)
	_check("diary: the clock stops", await _clock_stopped())
	var ab: ActionBar = m.action_bar
	ab.open_book_at(0, 0)
	await _frames(1)
	var spread := ab.book_spread
	var section := ab.book_section
	await _key(KEY_RIGHT)
	_check("diary: right turns the page", ab.book_spread != spread or ab.book_section != section)
	await _key(KEY_A)
	_check("diary: A turns it back", ab.book_spread == spread and ab.book_section == section)
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("diary: the D-pad turns the page", ab.book_spread != spread or ab.book_section != section)
	await _axis(JOY_AXIS_LEFT_X, -0.9)
	_check("diary: the left stick turns it back", ab.book_spread == spread and ab.book_section == section)
	await _wheel(ab.book, MOUSE_BUTTON_WHEEL_DOWN)
	_check("diary: the mouse wheel turns the page", ab.book_spread != spread or ab.book_section != section)
	ab.open_book_at(0, 0)
	await _frames(1)
	await _key(KEY_E)
	_check("diary: E jumps to the next section", ab.book_section == 1)
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check("diary: LB jumps back", ab.book_section == 0)
	_check("diary: the footer shows the pad's names", _prompt_glyph() == "< >" and _prompt_has("B"))
	await _key(KEY_Q)
	_check("diary: the footer follows the keyboard", _prompt_has("Esc"))
	await _key(KEY_ESCAPE)
	_check("diary: Esc goes back to the wheel", m.open_tab == "" and m.wheel.open)
	await _key(KEY_ESCAPE)
	await _handed_back("diary")


# --- The bag --------------------------------------------------------------------

func _bag_cases() -> void:
	var b: BagPanel = m.bag
	await _key(KEY_TAB)
	_check("bag: Tab opens it", b.open)
	_check("bag: a usable slot has focus", _focus_ok())
	_check("bag: the clock stops", await _clock_stopped())
	_check("bag: no empty slot can take focus", _no_disabled_focus(b.panel))
	await _walk_reach("bag", b.panel)
	await _key(KEY_TAB)
	_check("bag: Tab closes it", not b.open)
	await _handed_back("bag: Tab")
	await _pad(JOY_BUTTON_Y)
	_check("bag: Y opens it", b.open and _focus_ok())
	var first := _focus()
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("bag: the D-pad moves between slots", _focus() != first and _focus_ok())
	await _pad(JOY_BUTTON_B)
	_check("bag: B closes it", not b.open)
	await _handed_back("bag: B")
	await _pad(JOY_BUTTON_Y)
	await _pad(JOY_BUTTON_Y)
	_check("bag: Y closes it", not b.open)
	await _key(KEY_TAB)
	await _key(KEY_ESCAPE)
	_check("bag: Esc closes it", not b.open and m.open_tab == "")
	await _handed_back("bag: Esc")
	# The Inventory button opens the Inventory section.
	await _key(KEY_TAB)
	var inv := _button_named(b.panel, "Inventory")
	inv.grab_focus()
	await _frames(1)
	await _key(KEY_ENTER)
	_check("bag: Enter on Inventory opens the Inventory", m.open_tab == "Inventory" and not b.open and _focus_ok())
	await _key(KEY_ESCAPE)
	await _key(KEY_ESCAPE)
	# Using the last of something keeps focus in the bag.
	await _key(KEY_TAB)
	await _frames(1)
	var items: Array = m._bag_items()
	_check("bag: focus is on a slot that holds something", items.size() == 0 or b.slots.find(_focus()) < items.size())
	await _key(KEY_TAB)


# --- The small panels -----------------------------------------------------------

func _small_panel_cases() -> void:
	for panel_name in ["Desk", "Furnace", "Smokehouse", "Coop", "Barn", "Cellar", "Cooler", "Woodstore", "Well", "Trade"]:
		m._toggle_tab(panel_name)
		await _frames(3)
		var label: String = panel_name.to_lower()
		_check("%s: opens with focus" % label, m.open_tab == panel_name and _focus_ok())
		_check("%s: the clock stops" % label, await _clock_stopped())
		if m.action_bar.ledger.visible:
			await _ledger_checks(label)
		else:
			await _grid_checks(label)
		await _pad(JOY_BUTTON_B)
		_check("%s: B closes it" % label, m.open_tab == "" and not m.action_bar.panel.visible)
		await _handed_back(label)


# --- The mouse in a ledger --------------------------------------------------------

func _mouse_cases() -> void:
	await _open_from_wheel(7)   # Achievements: long lists
	var ab: ActionBar = m.action_bar
	var entries := _entries()
	if entries.size() > 2:
		await _click(entries[2])
		_check("achievements: a click picks an entry", ab._ledger_pick == 2 and _focus() == entries[2])
	var tab_before := int(ab.ledger_tabs.get("Achievements", 0))
	var tab_buttons := ab.tab_strip.get_children().filter(func(c: Node) -> bool: return c is Button)
	if tab_buttons.size() > 1:
		await _click(tab_buttons[(tab_before + 1) % tab_buttons.size()])
		_check("achievements: a click on a tab opens it", int(ab.ledger_tabs.get("Achievements", 0)) != tab_before and _focus_ok())
	# Find a tab long enough to scroll, then wheel over it.
	var scrolled := false
	var slot := m.active_slot
	for k in tab_buttons.size():
		ab._open_ledger_tab(k)
		await _frames(2)
		if ab.list_scroll.get_v_scroll_bar().max_value > ab.list_scroll.size.y + 4:
			ab.list_scroll.scroll_vertical = 0
			await _wheel(ab.list_scroll, MOUSE_BUTTON_WHEEL_DOWN)
			scrolled = ab.list_scroll.scroll_vertical > 0
			break
	_check("achievements: the mouse wheel scrolls a long list", scrolled)
	_check("achievements: the wheel doesn't switch the tool", m.active_slot == slot)
	await _close_all()
	# The Menu button opens the wheel, and a click off the ring closes it.
	await _click(ab.menu_button)
	_check("menu button: a click opens the wheel", m.wheel.open)
	await _click_at(Vector2(20, 20))
	_check("wheel: a click off the ring closes it", not m.wheel.open)
	await _handed_back("wheel: click off")
	# A click on a segment opens that section.
	await _click(ab.menu_button)
	var centre := m.wheel._centre()
	var at := centre + Vector2(0, -(SectionWheel.INNER_R + SectionWheel.OUTER_R) * 0.5)
	await _move_to(at)
	_check("wheel: the mouse highlights a segment", m.wheel.highlight == 0)
	await _click_at(at)
	_check("wheel: a click opens that section", m.open_tab == "Skills")
	await _click(ab.close_button)
	_check("skills: a click on Close goes back", m.open_tab == "" or m.wheel.open)
	if m.wheel.open:
		await _key(KEY_ESCAPE)
	await _handed_back("close button")
	# A click on the Bag button opens the bag; the same click doesn't act on the farm.
	var presses := m.world_presses
	await _click(m.bag.toggle_button)
	_check("bag button: a click opens the bag", m.bag.open)
	_check("bag button: the click doesn't reach the farm", m.world_presses == presses)
	await _close_all()


# --- Keyboard and gamepad at once ------------------------------------------------

func _device_cases() -> void:
	await _close_all()
	await _key(KEY_ESCAPE)
	await _key(KEY_DOWN)
	_check("prompts: the keyboard shows Space", _prompt_glyph() == "Space")
	await _pad(JOY_BUTTON_DPAD_DOWN)
	_check("prompts: the gamepad shows A", _prompt_glyph() == "A")
	_check("prompts: switching device keeps focus", _focus_ok())
	# Holding a stick while pressing keys: focus keeps moving one step per press.
	var entries := _entries()
	entries[0].grab_focus()
	await _frames(1)
	Input.parse_input_event(_key_event(KEY_DOWN, true))
	Input.parse_input_event(_pad_event(JOY_BUTTON_DPAD_DOWN, true))
	await _frames(1)
	Input.parse_input_event(_key_event(KEY_DOWN, false))
	Input.parse_input_event(_pad_event(JOY_BUTTON_DPAD_DOWN, false))
	await _frames(2)
	_check("mixed: a key and the D-pad together still leave focus on an entry", _focus_ok() and entries.has(_focus()))
	var slot := m.active_slot
	await _pad(JOY_BUTTON_RIGHT_SHOULDER)
	await _wheel(m.action_bar.list_scroll, MOUSE_BUTTON_WHEEL_DOWN)
	_check("menus: RB and the mouse wheel don't change the tool in hand", m.active_slot == slot)
	await _key(KEY_ESCAPE)
	await _handed_back("mixed")


# --- Placement ------------------------------------------------------------------

func _placement_cases() -> void:
	# Buildings, Decor: pressing a decor's Place with A starts placement and doesn't place it at once.
	await _open_from_wheel(6)
	var ab: ActionBar = m.action_bar
	var decor_tab := -1
	for k in ab.tab_strip.get_child_count():
		var c := ab.tab_strip.get_child(k)
		if c is Button and (c as Button).text == "Decor":
			decor_tab = k - 1
	_check("buildings: has a Decor tab", decor_tab >= 0)
	if decor_tab >= 0:
		ab._open_ledger_tab(decor_tab)
		await _frames(2)
		await _focus_action("decor:lamp")
		var presses := m.world_presses
		await _pad(JOY_BUTTON_A)
		_check("placement: A on Place starts placing", m.placing == "decor:lamp" and m.open_tab == "")
		_check("placement: the same press doesn't place it", m.placing != "" and m.world_presses == presses)
		_check("placement: the day runs while placing", not m.player.paused)
		await _pad(JOY_BUTTON_B)
		_check("placement: B cancels", m.placing == "" and m.open_tab == "")
		await _open_from_wheel(6)
		await _focus_action("decor:lamp")
		await _key(KEY_SPACE)
		_check("placement: Space on Place starts placing", m.placing == "decor:lamp")
		await _key(KEY_ESCAPE)
		_check("placement: Esc cancels and opens the Pause menu", m.placing == "" and m.open_tab == "Pause")
		await _key(KEY_ESCAPE)
	else:
		await _key(KEY_ESCAPE)
		await _key(KEY_ESCAPE)
	await _handed_back("placement")
	# Buildings, Animals: Build on the coop starts placing it.
	await _open_from_wheel(6)
	await _open_tab_named("Animals")
	await _focus_action("build_coop")
	await _key(KEY_ENTER)
	_check("placement: Enter on Build starts placing the coop", m.placing == "coop" and m.open_tab == "")
	await _pad(JOY_BUTTON_B)
	_check("placement: B cancels the coop", m.placing == "")
	await _handed_back("coop placement")
	# A passing line and a message never catch a click meant for the farm.
	m._show_message("A message.")
	m.folk.dialogue.say("", "neutral", "A passing word.", 3.0)
	await _frames(2)
	var presses := m.world_presses
	await _click_at(m.folk.dialogue.get_global_rect().get_center())
	_check("messages: a click through a passing line reaches the farm", m.world_presses == presses + 1)


# --- A walker's scene -----------------------------------------------------------

func _scene_cases() -> void:
	var d: DialogueBox = m.folk.dialogue
	var pages: Array = []
	for i in 6:
		pages.append({"who": "", "text": "Page %d" % i})
	var ended := [false]
	d.play(pages, func() -> void: ended[0] = true, "Space: next")
	await _frames(2)
	_check("scene: the clock stops", await _clock_stopped())
	await _key(KEY_SPACE)
	_check("scene: Space turns the page", d.page == 1)
	await _pad(JOY_BUTTON_A)
	_check("scene: A turns the page", d.page == 2)
	await _key(KEY_ENTER)
	_check("scene: Enter turns the page", d.page == 3)
	await _click_at(Vector2(640, 360))
	_check("scene: a click turns the page", d.page == 4)
	await _key(KEY_TAB)
	await _key(KEY_SHIFT)
	_check("scene: the bag and wheel wait for it", not m.bag.open and not m.wheel.open)
	await _key(KEY_SPACE)
	var presses := m.world_presses
	await _key(KEY_SPACE)
	_check("scene: the last page ends it", ended[0] and not d.in_scene())
	_check("scene: the last press doesn't reach the farm", m.world_presses == presses)
	await _handed_back("scene")


# --- An ending ------------------------------------------------------------------

func _ending_cases() -> void:
	var s: EndingScreen = m.act.screen
	s.play("Test ending", ["one", "two"], ["Credits"], func() -> void: pass)
	await _frames(2)
	_check("ending: the clock stops", await _clock_stopped())
	await _key(KEY_SPACE)
	_check("ending: Space moves it on", s.stage == "lines")
	s.t = 99.0
	await _pad(JOY_BUTTON_A)
	_check("ending: A shows the next line", s.line == 0)
	s.t = 99.0
	await _key(KEY_ENTER)
	_check("ending: Enter shows the next line", s.line == 1)
	await _key(KEY_ESCAPE)
	_check("ending: Esc doesn't open the Pause menu over it", m.open_tab == "")
	s.active = false
	s.visible = false
	await _frames(2)
	await _handed_back("ending")


# --- Two things at once ---------------------------------------------------------

func _overlap_cases() -> void:
	# Esc and Shift in the same frame with a section open; B and Tab with the bag open; J with the wheel open.
	await _open_from_wheel(5)
	Input.parse_input_event(_key_event(KEY_ESCAPE, true))
	Input.parse_input_event(_key_event(KEY_SHIFT, true))
	await _frames(1)
	Input.parse_input_event(_key_event(KEY_ESCAPE, false))
	Input.parse_input_event(_key_event(KEY_SHIFT, false))
	await _frames(2)
	_check("overlap: Esc and Shift together leave one menu up", _consistent())
	await _close_all()
	await _key(KEY_TAB)
	Input.parse_input_event(_pad_event(JOY_BUTTON_B, true))
	Input.parse_input_event(_key_event(KEY_TAB, true))
	await _frames(1)
	Input.parse_input_event(_pad_event(JOY_BUTTON_B, false))
	Input.parse_input_event(_key_event(KEY_TAB, false))
	await _frames(2)
	_check("overlap: B and Tab together leave things tidy", _consistent())
	await _close_all()
	await _key(KEY_SHIFT)
	await _key(KEY_J)
	_check("overlap: J with the wheel up opens the diary alone", m.open_tab == "Diary" and not m.wheel.open and _consistent())
	await _close_all()
	# A panel opened on the frame another closes.
	m._toggle_tab("Furnace")
	await _frames(2)
	await _pad(JOY_BUTTON_B)
	m._toggle_tab("Cellar")
	await _frames(3)
	_check("overlap: a panel opened right after another closes has focus", m.open_tab == "Cellar" and _focus_ok())
	await _close_all()
	await _handed_back("overlap")


# --- Later in the game ----------------------------------------------------------

func _late_cases() -> void:
	# Trail works opens from day 14, when the mill path opens.
	m.day = TrekSystem.FROM_DAY
	await _open_from_wheel(6)
	await _open_tab_named("Trail works")
	_check("buildings: Trail works has an entry in focus", m.action_bar._ledger_entries.size() > 0 and _focus_ok())
	await _ledger_checks("buildings late")
	await _close_all()
	await _handed_back("trail works")


# --- Shared checks --------------------------------------------------------------

# A ledger panel: focus on open, every entry reached with the keys and the D-pad, wrapping at the ends,
# tabs on Q/E and LB/RB, prompts on the device last used, and nothing disabled in the focus path.
func _ledger_checks(label: String) -> void:
	var ab: ActionBar = m.action_bar
	_check("%s: an entry has focus on open" % label, _focus_ok() and _entries().has(_focus()))
	var tab_count: int = ab._ledger_tab_count
	var start_tab := int(ab.ledger_tabs.get(ab.active_tab, 0))
	for k in maxi(1, tab_count):
		var entries := _entries()
		if entries.is_empty():
			_check("%s tab %d: has an entry" % [label, k], false)
		else:
			await _walk_all("%s tab %d" % [label, k], ab.list_box, KEY_DOWN if k % 2 == 0 else -1, JOY_BUTTON_DPAD_DOWN if k % 2 == 1 else -1)
			_entries()[-1].grab_focus()
			await _frames(1)
			await _key(KEY_DOWN)
			_check("%s tab %d: down from the last entry wraps to the first" % [label, k], _focus() == _entries()[0])
			await _pad(JOY_BUTTON_DPAD_UP)
			_check("%s tab %d: up from the first wraps to the last" % [label, k], _focus() == _entries()[-1])
			if entries.size() > 1:
				await _axis(JOY_AXIS_LEFT_Y, -0.8)
				_check("%s tab %d: the left stick moves focus" % [label, k], _focus_ok() and _focus() != _entries()[-1])
		_check("%s tab %d: nothing disabled or hidden takes focus" % [label, k], _no_disabled_focus(ab.panel))
		if tab_count > 1:
			var tab_now := int(ab.ledger_tabs.get(ab.active_tab, 0))
			if k % 2 == 0:
				await _key(KEY_E)
			else:
				await _pad(JOY_BUTTON_RIGHT_SHOULDER)
			_check("%s: %s steps to the next tab" % [label, "E" if k % 2 == 0 else "RB"], int(ab.ledger_tabs.get(ab.active_tab, 0)) == (tab_now + 1) % tab_count and _focus_ok())
	if tab_count > 1:
		_check("%s: the tabs wrap back to the first" % label, int(ab.ledger_tabs.get(ab.active_tab, 0)) == start_tab)
		await _key(KEY_Q)
		await _pad(JOY_BUTTON_LEFT_SHOULDER)
		await _key(KEY_E)
		await _pad(JOY_BUTTON_RIGHT_SHOULDER)
		_check("%s: Q and LB step back" % label, int(ab.ledger_tabs.get(ab.active_tab, 0)) == start_tab)
	await _key(KEY_DOWN)
	_check("%s: the footer shows the keyboard's names" % label, _prompt_glyph() == "Space" and _prompt_has("Esc"))
	await _pad(JOY_BUTTON_DPAD_UP)
	_check("%s: the footer shows the pad's names" % label, _prompt_glyph() == "A" and _prompt_has("B"))


# A grid or card panel: focus on open, every focusable reachable, nothing disabled in the path, and the
# tab strip's prompts when it has one.
func _grid_checks(label: String) -> void:
	var ab: ActionBar = m.action_bar
	await _frames(1)
	_check("%s: something has focus" % label, _focus_ok())
	_check("%s: nothing disabled or hidden takes focus" % label, _no_disabled_focus(ab.panel))
	await _walk_reach(label, ab.panel)
	var before := _focus()
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	await _key(KEY_DOWN)
	_check("%s: focus moves and stays on a usable control" % label, _focus_ok())
	if ab.prompt_bar.visible:
		_check("%s: the footer shows the keyboard's names" % label, _prompt_glyph() == "Space")
	if before == null:
		return


# Walks down a list with one key or button and checks every usable button in it is reached.
func _walk_all(label: String, box: Control, key: int, button: int) -> void:
	var want := _focusables(box)
	if want.is_empty():
		return
	want[0].grab_focus()
	await _frames(1)
	var seen := {}
	var stuck := false
	for i in want.size() + 1:
		var f := _focus()
		if f == null or not _usable(f):
			stuck = true
			break
		seen[f] = true
		if key >= 0:
			await _key(key)
		else:
			await _pad(button)
	var missed := want.filter(func(c: Control) -> bool: return not seen.has(c))
	_check("%s: every entry is reached%s" % [label, "" if missed.is_empty() else " (missed %s)" % _names(missed)], missed.is_empty() and not stuck)


# From the focused control, every usable control in root can be reached by stepping up, down, left and right.
func _walk_reach(label: String, box: Control) -> void:
	var start := _focus()
	var want := _focusables(box)
	if start == null or want.is_empty():
		_check("%s: has a control to focus" % label, not want.is_empty())
		return
	var seen := {start: true}
	var queue: Array = [start]
	while not queue.is_empty():
		var c: Control = queue.pop_front()
		for side in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
			var n := c.find_valid_focus_neighbor(side)
			if n != null and not seen.has(n) and box.is_ancestor_of(n):
				seen[n] = true
				queue.append(n)
	var missed := want.filter(func(c: Control) -> bool: return not seen.has(c))
	_check("%s: every control can be reached%s" % [label, "" if missed.is_empty() else " (missed %s)" % _names(missed)], missed.is_empty())


# After a menu closes: nothing focused, the day running, the player moving, and no press reaching the farm.
func _handed_back(label: String) -> void:
	await _frames(2)
	_check("%s: closing leaves nothing focused" % label, _focus() == null)
	_check("%s: closing lets the day run" % label, not m.player.paused)
	_check("%s: the player moves again" % label, await _player_moves())


func _player_moves() -> bool:
	var start: Vector2 = m.player.position
	var moved := false
	for key in [KEY_D, KEY_A, KEY_S, KEY_W]:
		Input.parse_input_event(_key_event(key, true))
		await _frames(6)
		Input.parse_input_event(_key_event(key, false))
		await _frames(2)
		if m.player.position != start:
			moved = true
			break
	# And stops when the key is let go.
	var at: Vector2 = m.player.position
	await _frames(4)
	return moved and m.player.position == at


func _clock_stopped() -> bool:
	var before := m.clock
	await _frames(5)
	return m.clock == before and m.player.paused


func _consistent() -> bool:
	var menus := int(m.open_tab != "") + int(m.bag.open) + int(m.wheel.open)
	var f := _focus()
	return menus <= 1 and m.action_bar.panel.visible == (m.open_tab != "") and (f == null or _usable(f))


func _close_all() -> void:
	for i in 4:
		if m.open_tab == "" and not m.bag.open and not m.wheel.open:
			return
		await _key(KEY_ESCAPE)
	if m.open_tab == "Pause":
		await _key(KEY_ESCAPE)


func _open_from_wheel(index: int) -> void:
	await _close_all()
	await _key(KEY_SHIFT)
	m.wheel.highlight = index
	await _key(KEY_ENTER)
	await _frames(2)


func _open_tab_named(tab_name: String) -> void:
	var ab: ActionBar = m.action_bar
	var buttons := ab.tab_strip.get_children().filter(func(c: Node) -> bool: return c is Button)
	for k in buttons.size():
		if (buttons[k] as Button).text == tab_name:
			ab._open_ledger_tab(k)
			await _frames(2)
			return
	_check("a tab named %s" % tab_name, false)


func _press_entry(action: String, key: int, button: int) -> void:
	await _focus_action(action)
	if key >= 0:
		await _key(key)
	else:
		await _pad(button)
	await _frames(1)


# Moves focus to the entry with this action by stepping down, as a player would.
func _focus_action(action: String) -> void:
	for i in 60:
		if _focus() != null and str(_focus().get_meta("action", "")) == action:
			return
		await _key(KEY_DOWN if i < 30 else KEY_UP)
	_check("found the entry %s" % action, false)


# --- Focus helpers --------------------------------------------------------------

func _focus() -> Control:
	return root.gui_get_focus_owner()


func _usable(c: Control) -> bool:
	return c.is_visible_in_tree() and not (c is BaseButton and (c as BaseButton).disabled)


func _focus_ok() -> bool:
	var f := _focus()
	return f != null and _usable(f)


func _focusables(box: Node) -> Array:
	var out: Array = []
	for child in box.get_children():
		var c := child as Control
		if c != null and c.is_visible_in_tree() and c.focus_mode != Control.FOCUS_NONE and _usable(c):
			out.append(c)
		out.append_array(_focusables(child))
	return out


# True when no hidden or disabled control in box can take focus.
func _no_disabled_focus(box: Node) -> bool:
	for child in box.get_children():
		var c := child as Control
		if c != null and c.focus_mode != Control.FOCUS_NONE and c.is_visible_in_tree() and c is BaseButton and (c as BaseButton).disabled:
			print("   disabled but focusable: ", _names([c]))
			return false
		if not _no_disabled_focus(child):
			return false
	return true


func _first_usable(box: Node) -> Control:
	var all := _focusables(box)
	return all[0] if not all.is_empty() else null


func _entries() -> Array:
	return m.action_bar.list_box.get_children().filter(func(c: Node) -> bool: return c is Button)


func _button_named(box: Node, text: String) -> Button:
	for child in box.get_children():
		if child is Button and (child as Button).text == text:
			return child
		var found := _button_named(child, text)
		if found != null:
			return found
	return null


func _names(list: Array) -> String:
	var out: Array = []
	for c in list.slice(0, 4):
		var text := (c as Button).text if c is Button else ""
		out.append("%s '%s' %s" % [c.get_class(), text.replace("\n", " "), str(c.get_meta("action", ""))])
	return ", ".join(out) + (" and %d more" % (list.size() - 4) if list.size() > 4 else "")


func _prompt_glyph() -> String:
	var bar: HBoxContainer = m.action_bar.prompt_bar
	if bar.get_child_count() == 0:
		return ""
	return (bar.get_child(0).get_child(0) as Label).text


func _prompt_has(glyph: String) -> bool:
	for pair in m.action_bar.prompt_bar.get_children():
		if (pair.get_child(0) as Label).text == glyph:
			return true
	return false


# --- Injected input -------------------------------------------------------------

func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _key_event(code: int, pressed: bool) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = pressed
	return ev


func _pad_event(button: int, pressed: bool) -> InputEventJoypadButton:
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	ev.pressed = pressed
	ev.pressure = 1.0 if pressed else 0.0
	return ev


func _axis_event(axis: int, value: float) -> InputEventJoypadMotion:
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = value
	return ev


func _key(code: int) -> void:
	Input.parse_input_event(_key_event(code, true))
	await _frames(1)
	Input.parse_input_event(_key_event(code, false))
	await _frames(2)


func _pad(button: int) -> void:
	Input.parse_input_event(_pad_event(button, true))
	await _frames(1)
	Input.parse_input_event(_pad_event(button, false))
	await _frames(2)


func _axis(axis: int, value: float) -> void:
	Input.parse_input_event(_axis_event(axis, value))
	await _frames(2)
	Input.parse_input_event(_axis_event(axis, 0.0))
	await _frames(2)


func _screen(at: Vector2) -> Vector2:
	return root.get_final_transform() * at


func _move_to(at: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = _screen(at)
	ev.global_position = ev.position
	Input.parse_input_event(ev)
	await _frames(2)


func _click_at(at: Vector2) -> void:
	await _move_to(at)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = _screen(at)
		ev.global_position = ev.position
		Input.parse_input_event(ev)
		await _frames(1)
	await _frames(1)


func _click(c: Control) -> void:
	if c == null:
		_check("a control to click", false)
		return
	await _move_to(c.get_global_rect().get_center())
	if OS.has_environment("MENU_TEST_DEBUG"):
		print("   click ", c, " ", c.get_global_rect(), " hovered ", root.gui_get_hovered_control(), " vis ", c.is_visible_in_tree())
	await _click_at(c.get_global_rect().get_center())


func _wheel(over: Control, button: int) -> void:
	var at := over.get_global_rect().get_center()
	await _move_to(at)
	for i in 3:
		for pressed in [true, false]:
			var ev := InputEventMouseButton.new()
			ev.button_index = button
			ev.pressed = pressed
			ev.factor = 1.0
			ev.position = _screen(at)
			ev.global_position = ev.position
			Input.parse_input_event(ev)
		await _frames(1)
	await _frames(1)


func _check(label: String, ok: bool) -> void:
	if not ok:
		failures += 1
	print("%s  %s" % ["PASS" if ok else "FAIL", label])
