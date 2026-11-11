extends SceneTree

# Checks the diary's book and its page turns (UI-OVERHAUL-001 Phase 5). Run headless, from the project folder:
#   godot --path . --headless -s tools/diary_test.gd
# Turns pages forward and back with the keyboard, D-pad, stick, mouse wheel and the corner arrows, jumps between
# sections by Q/E, LB/RB and a click on a ribbon, and checks that the diary's place moves at once and exactly
# once per press, that a turn plays and ends with its snapshots cleared, that repeated presses never stack
# turns, that closing mid-turn is clean, that reopening keeps the place, that it opens at a new page, that
# torn-out pages show their stub, that the place survives a save and load in slot 9, and that the Quick and Off
# page-turn settings work. Prints PASS or FAIL per case; the exit code is the number of failures.
# Plays in save slot 9 and puts settings.cfg back.

const SLOT := 9
const SETTINGS := "user://settings.cfg"

var m: MainGame
var ab: ActionBar
var failures := 0
var settings_backup := ""


func _initialize() -> void:
	if FileAccess.file_exists(SETTINGS):
		settings_backup = FileAccess.get_file_as_string(SETTINGS)
	create_timer(300.0).timeout.connect(func() -> void:
		print("FAIL: the test stopped part way (a script error above?) and timed out")
		quit(99))
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)
	_run.call_deferred()


func _run() -> void:
	await _frames(3)
	m._on_title_start("new", SLOT)
	await _frames(5)
	m._dev_unlock_all()
	m.diary_found = true
	for tip in m.TIPS:
		m.tips_seen[tip["id"]] = true
	# Agnes's first two pages found and the rest torn out; a page from the wood too.
	for i in 2:
		m.mystery.found[m.mystery.PAGES[i]["id"]] = true
	m.mystery.found[m.mystery.TREK_PAGES[0]["id"]] = true
	GameSettings.page_turns = 0
	ab = m.action_bar
	await _frames(3)
	await _key(KEY_J)
	_check("open: J opens the diary as a book", m.open_tab == "Diary" and ab.book.visible)
	_check("open: no turn is playing", not ab.page_turn.active)
	_check("open: the book has its cover, spread and turn layer", ab.book_cover is DiaryBook.Cover and ab.page_turn.get_parent() == ab.book_cover)
	_check("art: every diary texture loads", _art_loads())
	await _turn_cases()
	await _end_cases()
	await _section_cases()
	await _repeat_cases()
	await _device_cases()
	await _close_cases()
	await _new_page_cases()
	await _torn_cases()
	await _save_cases()
	await _motion_cases()
	_check("all content: every page of every section can be reached by turning", await _walk_all())
	if settings_backup != "":
		var f := FileAccess.open(SETTINGS, FileAccess.WRITE)
		f.store_string(settings_backup)
		f.close()
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


# --- Cases ----------------------------------------------------------------------

func _turn_cases() -> void:
	ab.open_book_at(1, 0)
	await _frames(2)
	var before := _place()
	await _key(KEY_RIGHT)
	_check("forward: the place moves on at once", _place() == before + 1)
	_check("forward: a turn plays", ab.page_turn.active and ab.page_turn.forward and ab.page_turn.leaves == 1)
	_check("forward: the turn is 550-650 ms", ab.page_turn.duration >= 0.55 and ab.page_turn.duration <= 0.65)
	_check("forward: the snapshots hold both spreads", ab.page_turn.old_root.get_child_count() == 3 and ab.page_turn.new_root.get_child_count() == 3)
	await _wait(0.75)
	_check("forward: the turn ends on its own", not ab.page_turn.active and not ab.page_turn.visible)
	await _frames(2)
	_check("forward: the snapshots are cleared after", ab.page_turn.old_root.get_child_count() == 0 and ab.page_turn.new_root.get_child_count() == 0)
	_check("forward: the live spread is rebuilt (two pages and the spine)", ab.book_spread_box.get_child_count() == 3)
	await _key(KEY_LEFT)
	_check("reverse: the place moves back at once", _place() == before)
	_check("reverse: a reverse turn plays", ab.page_turn.active and not ab.page_turn.forward)
	await _wait(0.75)
	_check("reverse: the turn ends cleanly", not ab.page_turn.active)


func _end_cases() -> void:
	ab.open_book_at(0, 0)
	await _frames(2)
	await _key(KEY_LEFT)
	_check("first page: left does nothing", _place() == 0 and not ab.page_turn.active)
	var last := ab.book_sections.size() - 1
	ab.open_book_at(last, ab.book_sections[last]["pages"].size() - 1)
	await _frames(2)
	var at := _place()
	await _key(KEY_RIGHT)
	_check("last page: right does nothing", _place() == at and not ab.page_turn.active)
	# A section's last spread runs on into the next section.
	ab.open_book_at(0, ab.book_sections[0]["pages"].size() - 1)
	await _frames(2)
	await _key(KEY_RIGHT)
	_check("section run-on: past a section's end opens the next", ab.book_section == 1 and ab.book_spread == 0)
	await _wait(0.7)


func _section_cases() -> void:
	ab.open_book_at(0, 0)
	await _frames(2)
	await _key(KEY_E)
	_check("sections: E jumps to the next section", ab.book_section == 1 and ab.book_spread == 0)
	_check("sections: the jump riffles leaves, briefly", ab.page_turn.active and ab.page_turn.leaves > 1 and ab.page_turn.duration <= 0.6)
	await _pad(JOY_BUTTON_LEFT_SHOULDER)
	_check("sections: LB jumps back", ab.book_section == 0)
	_check("sections: the jump back riffles the other way", ab.page_turn.active and not ab.page_turn.forward)
	await _wait(0.7)
	var ribbon := ab.book_tabs.get_child(3) as Button
	await _click(ribbon)
	_check("bookmark: a click on a ribbon opens its section", ab.book_section == 2 and ab.book_spread == 0)
	await _wait(0.7)
	_check("bookmark: the open ribbon has its eyelet", (ab.book_tabs.get_child(3) as Button).get_child_count() >= 1)


func _repeat_cases() -> void:
	ab.open_book_at(1, 0)
	await _frames(2)
	var before := _place()
	for i in 4:
		Input.parse_input_event(_key_event(KEY_RIGHT, true))
		await _frames(1)
		Input.parse_input_event(_key_event(KEY_RIGHT, false))
		await _frames(1)
		_check("repeat: press %d leaves one turn and two snapshots at most" % (i + 1),
			ab.page_turn.old_root.get_child_count() <= 3 and ab.page_turn.new_root.get_child_count() <= 3)
	_check("repeat: four quick presses turn exactly four spreads", _place() == before + 4)
	await _wait(0.75)
	_check("repeat: everything settles", not ab.page_turn.active and ab.book_spread_box.get_child_count() == 3)
	# Wheel steps arrive in one frame: one spread each.
	before = _place()
	await _wheel(ab.book, MOUSE_BUTTON_WHEEL_DOWN)
	_check("repeat: three wheel steps turn three spreads", _place() == before + 3)
	await _wait(0.75)


func _device_cases() -> void:
	ab.open_book_at(1, 0)
	await _frames(2)
	var before := _place()
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("controller: the D-pad turns forward", _place() == before + 1)
	await _axis(JOY_AXIS_LEFT_X, -0.9)
	_check("controller: the stick turns back", _place() == before)
	await _key(KEY_D)
	_check("keyboard: D turns forward", _place() == before + 1)
	await _key(KEY_A)
	_check("keyboard: A turns back", _place() == before)
	await _wait(0.7)
	var arrow := _arrow(1)
	await _click(arrow)
	_check("mouse: the > arrow turns forward", _place() == before + 1)
	await _wait(0.7)
	await _click(_arrow(0))
	_check("mouse: the < arrow turns back", _place() == before)
	await _wait(0.7)


func _close_cases() -> void:
	ab.open_book_at(1, 0)
	await _frames(2)
	var before := _place()
	await _key(KEY_RIGHT)
	await _frames(4)
	_check("close: a turn is playing", ab.page_turn.active)
	await _key(KEY_ESCAPE)
	await _frames(2)
	_check("close: Esc mid-turn closes the diary", m.open_tab != "Diary")
	_check("close: the turn ends with it", not ab.page_turn.active and not ab.page_turn.visible)
	_check("close: its snapshots are cleared", ab.page_turn.old_root.get_child_count() == 0 and ab.page_turn.new_root.get_child_count() == 0)
	await _close_all()
	await _key(KEY_J)
	_check("reopen: the diary opens again", m.open_tab == "Diary" and ab.book.visible and not ab.page_turn.active)
	_check("reopen: it opens where it was left", _place() == before + 1)
	await _key(KEY_RIGHT)
	_check("reopen: pages still turn", _place() == before + 2)
	await _wait(0.7)


func _new_page_cases() -> void:
	await _close_all()
	var tip: String = m.TIPS[5]["id"]
	m.diary_new.append(tip)
	await _key(KEY_J)
	await _frames(2)
	var page: Dictionary = {}
	var spread: int = ab.book_spread
	var pages: Array = ab.book_sections[ab.book_section]["pages"]
	for i in [spread * 2, spread * 2 + 1]:
		if i < pages.size() and bool(pages[i].get("new", false)):
			page = pages[i]
	_check("new page: the diary opens at the page not read yet", not page.is_empty())
	_check("new page: its ribbon carries the red dot", _ribbon_has_dot(ab.book_section))
	await _close_all()
	await _frames(2)
	_check("new page: closing marks it read", not m.diary_new.has(tip))


func _torn_cases() -> void:
	await _key(KEY_J)
	var agnes := -1
	for i in ab.book_sections.size():
		if str(ab.book_sections[i]["name"]) == "Agnes Rook":
			agnes = i
	_check("torn: Agnes Rook has a section", agnes >= 0)
	ab.open_book_at(agnes, 2)
	await _frames(3)
	var torn := false
	for page in ab.book_spread_box.get_children():
		for child in page.get_children():
			torn = torn or child is ActionBar.TornPage
	_check("torn: the missing page shows its stub", torn)
	await _key(KEY_RIGHT)
	_check("torn: a turn over torn pages plays", ab.page_turn.active)
	await _wait(0.7)


func _save_cases() -> void:
	var before := _place()
	var pages := {}
	for id in m.mystery.found:
		pages[id] = m.mystery.found[id]
	await _close_all()
	m.saver._save_game()
	await _frames(2)
	_check("save: slot 9 is written", FileAccess.file_exists(TitleMenu.slot_path(SLOT)))
	m.diary_found = false
	_check("load: slot 9 loads", m.saver._load_game())
	await _frames(3)
	_check("load: the diary is found", m.diary_found)
	var same := true
	for id in pages:
		same = same and m.mystery.found.get(id, false) == pages[id]
	_check("load: the diary's pages are kept", same)
	await _key(KEY_J)
	_check("load: the diary opens and keeps its place", m.open_tab == "Diary" and _place() == before)
	await _key(KEY_RIGHT)
	_check("load: pages turn after loading", ab.page_turn.active or GameSettings.page_turns == 2)
	await _wait(0.7)
	await _close_all()


func _motion_cases() -> void:
	await _key(KEY_J)
	ab.open_book_at(1, 0)
	await _frames(2)
	GameSettings.page_turns = 1
	await _key(KEY_RIGHT)
	_check("quick: a turn is half length", ab.page_turn.active and ab.page_turn.duration <= 0.31)
	await _key(KEY_E)
	_check("quick: a section jump is one quick leaf", ab.page_turn.leaves == 1 and ab.page_turn.duration <= 0.31)
	await _wait(0.4)
	GameSettings.page_turns = 2
	var before := _place()
	await _key(KEY_RIGHT)
	_check("off: the page turns with no animation", _place() == before + 1 and not ab.page_turn.active)
	_check("off: the new spread shows at once", ab.book_spread_box.get_child_count() == 3)
	await _key(KEY_LEFT)
	_check("off: turning back works", _place() == before)
	GameSettings.page_turns = 0
	var found := false
	for row in GameSettings.rows():
		found = found or (row is Dictionary and str(row.get("action", "")) == "set_page_turns")
	_check("settings: Diary page turns is in the settings", found)


func _walk_all() -> bool:
	if m.open_tab != "Diary":
		await _key(KEY_J)
	ab.open_book_at(0, 0)
	await _frames(2)
	var total := 0
	for s in ab.book_sections.size():
		total += ab._spreads(s)
	var seen := 1
	while ab._can_turn(1) and seen < 400:
		ab._turn_page(1)
		seen += 1
		await _frames(1)
	await _wait(0.7)
	await _close_all()
	return seen == total


# --- Helpers ---------------------------------------------------------------------

# The open place as a count of spreads from the book's start.
func _place() -> int:
	var n := 0
	for s in ab.book_section:
		n += ab._spreads(s)
	return n + ab.book_spread


func _art_loads() -> bool:
	for name in ["cover", "page_l", "page_r", "spine", "ribbon", "grommet", "endpaper", "feather", "fleuron"]:
		if DiaryBook.tex(name) == null:
			print("   missing art/ui/diary/%s.png" % name)
			return false
	return true


func _arrow(side: int) -> Button:
	var page := ab.book_spread_box.get_child(0 if side == 0 else 2)
	for b in page.find_children("*", "Button", true, false):
		if (b as Button).text == ("<" if side == 0 else ">"):
			return b
	return null


func _ribbon_has_dot(section: int) -> bool:
	var marker := ab.book_tabs.get_child(section + 1)
	for child in marker.get_children():
		if child is Panel:
			return true
	return false


func _close_all() -> void:
	for i in 4:
		if m.open_tab == "" and not m.bag.open and not m.wheel.open:
			return
		await _key(KEY_ESCAPE)


func _check(label: String, ok: bool) -> void:
	if not ok:
		failures += 1
	print("%s  %s" % ["PASS" if ok else "FAIL", label])


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout
	await _frames(1)


func _key_event(code: int, pressed: bool) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = pressed
	return ev


func _key(code: int) -> void:
	Input.parse_input_event(_key_event(code, true))
	await _frames(1)
	Input.parse_input_event(_key_event(code, false))
	await _frames(2)


func _pad(button: int) -> void:
	for pressed in [true, false]:
		var ev := InputEventJoypadButton.new()
		ev.button_index = button
		ev.pressed = pressed
		ev.pressure = 1.0 if pressed else 0.0
		Input.parse_input_event(ev)
		await _frames(1 if pressed else 2)


func _axis(axis: int, value: float) -> void:
	for v in [value, 0.0]:
		var ev := InputEventJoypadMotion.new()
		ev.axis = axis
		ev.axis_value = v
		Input.parse_input_event(ev)
		await _frames(2)


func _screen(at: Vector2) -> Vector2:
	return root.get_final_transform() * at


func _move_to(at: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = _screen(at)
	ev.global_position = ev.position
	Input.parse_input_event(ev)
	await _frames(1)


func _click(c: Control) -> void:
	if c == null:
		_check("a control to click", false)
		return
	var at := c.get_global_rect().get_center()
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
	await _frames(2)
