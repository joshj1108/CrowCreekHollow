extends SceneTree

# Checks the section wheel (UI-OVERHAUL-001 Phase 6). Run headless, from the project folder:
#   godot --path . --headless -s tools/wheel_test.gd
# Opens and closes the wheel every way it opens and closes, chooses every section by keyboard, controller and
# mouse, walks the ring both ways with wrapping, points the stick and the mouse at every segment and just either
# side of every boundary, presses many times in one frame, checks that the wheel takes input while it fades in,
# that a cancel opens nothing, that the farm comes back with no press leaking through, that the prompts follow
# the device, that the art loads and is drawn on whole pixels, and that it works with the fade turned off.
# Prints PASS or FAIL per case; the exit code is the number of failures. Plays in save slot 9 and puts
# settings.cfg back.

const SLOT := 9
const SETTINGS := "user://settings.cfg"

var m: MainGame
var w: SectionWheel
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
	w = m.wheel
	await _frames(3)
	_art_cases()
	await _open_close_cases()
	await _keyboard_cases()
	await _controller_cases()
	await _mouse_cases()
	await _boundary_cases()
	await _repeat_cases()
	await _every_section_cases()
	await _prompt_cases()
	await _no_fade_cases()
	if settings_backup != "":
		var f := FileAccess.open(SETTINGS, FileAccess.WRITE)
		f.store_string(settings_backup)
		f.close()
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


# --- Cases ----------------------------------------------------------------------

func _art_cases() -> void:
	_check("art: the dial, the lit frames and the icons load", w.dial_tex != null and w.hot_tex != null and w.icon_tex != null)
	if w.dial_tex == null or w.hot_tex == null or w.icon_tex == null:
		return
	_check("art: one lit frame per section", w.hot_tex.get_width() == int(SectionWheel.DIAL_SIZE) * SectionWheel.SECTIONS.size())
	_check("art: one icon per section", w.icon_tex.get_width() == int(SectionWheel.ICON_SIZE) * SectionWheel.SECTIONS.size())
	_check("art: drawn at a whole scale", SectionWheel.ART_SCALE == roundf(SectionWheel.ART_SCALE))
	var dial := SectionWheel.DIAL_SIZE * SectionWheel.ART_SCALE
	var corner := (w.ring.get_rect().size * 0.5).round() - Vector2(dial, dial) * 0.5
	_check("art: the dial sits on whole pixels", corner == corner.round())
	var fits := dial <= w.ring.get_rect().size.y and dial <= w.ring.get_rect().size.x
	_check("art: the dial fits the screen", fits)
	# The art's face (radius 47.5 to 105.5 native) lies inside the hit ring.
	_check("art: the drawn face lies inside the hit ring", 47.5 * SectionWheel.ART_SCALE >= SectionWheel.INNER_R and 105.5 * SectionWheel.ART_SCALE <= SectionWheel.OUTER_R)


func _open_close_cases() -> void:
	await _key(KEY_SHIFT)
	_check("open: Shift opens it", w.open and w.visible)
	_check("open: the clock stops", await _clock_stopped())
	await _key(KEY_ESCAPE)
	_check("close: Esc closes it", not w.open)
	await _seconds(SectionWheel.fade_seconds + 0.1)
	_check("close: it is gone once the fade is done", not w.visible)
	await _handed_back("Esc")
	await _pad(JOY_BUTTON_LEFT_STICK)
	_check("open: L3 opens it", w.open)
	await _pad(JOY_BUTTON_B)
	_check("close: B closes it", not w.open and m.open_tab == "")
	await _handed_back("B")
	await _key(KEY_SHIFT)
	await _key(KEY_SHIFT)
	_check("close: Shift again closes it", not w.open)
	await _handed_back("Shift")
	# Input works from the first frame, before the fade is done.
	w.highlight = 0
	Input.parse_input_event(_key_event(KEY_SHIFT, true))
	await _frames(1)
	Input.parse_input_event(_key_event(KEY_SHIFT, false))
	Input.parse_input_event(_key_event(KEY_RIGHT, true))
	await _frames(1)
	Input.parse_input_event(_key_event(KEY_RIGHT, false))
	_check("fade: a press while it fades in still moves the highlight", w.highlight == 1 and w._fade < 1.0)
	await _seconds(SectionWheel.fade_seconds + 0.1)
	_check("fade: the fade finishes fully opaque", w.ring.modulate.a == 1.0)
	# Choosing a section hides the wheel at once; the panel takes the screen.
	await _key(KEY_ENTER)
	_check("choose: Enter opens the lit section", m.open_tab == "Gear")
	_check("choose: the wheel is hidden at once", not w.open and not w.visible)
	await _key(KEY_ESCAPE)
	_check("back: Esc from a section returns to the wheel", w.open and m.open_tab == "")
	await _key(KEY_ESCAPE)
	_check("back: a second Esc closes it", not w.open)
	await _handed_back("section and back")
	# Cancelling opens nothing and leaks no press to the farm.
	var presses: int = m.world_presses
	await _key(KEY_SHIFT)
	await _pad(JOY_BUTTON_B)
	_check("cancel: B opens no section", m.open_tab == "")
	_check("cancel: the press doesn't reach the farm", m.world_presses == presses)


func _keyboard_cases() -> void:
	await _key(KEY_SHIFT)
	w.highlight = 0
	await _key(KEY_LEFT)
	_check("keys: left from the first section wraps to the last", w.highlight == SectionWheel.SECTIONS.size() - 1)
	await _key(KEY_RIGHT)
	_check("keys: right wraps back to the first", w.highlight == 0)
	await _key(KEY_DOWN)
	_check("keys: down steps clockwise", w.highlight == 1)
	await _key(KEY_UP)
	_check("keys: up steps back", w.highlight == 0)
	var seen := {}
	for i in SectionWheel.SECTIONS.size():
		await _key(KEY_D)
		seen[w.highlight] = true
	_check("keys: D steps through every section", seen.size() == SectionWheel.SECTIONS.size())
	for i in SectionWheel.SECTIONS.size():
		await _key(KEY_A)
	_check("keys: A steps all the way back", w.highlight == 0)
	await _key(KEY_ESCAPE)


func _controller_cases() -> void:
	await _pad(JOY_BUTTON_LEFT_STICK)
	w.highlight = 0
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("pad: D-pad right steps clockwise", w.highlight == 1)
	await _pad(JOY_BUTTON_DPAD_LEFT)
	await _pad(JOY_BUTTON_DPAD_LEFT)
	_check("pad: D-pad left wraps", w.highlight == SectionWheel.SECTIONS.size() - 1)
	# The stick pointed toward each segment's middle lights that segment.
	var ok := true
	for i in SectionWheel.SECTIONS.size():
		var v := w._dir(float(i) * TAU / SectionWheel.SECTIONS.size()) * 0.9
		Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, v.x))
		Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, v.y))
		await _frames(2)
		ok = ok and w.highlight == i
	_check("pad: the stick lights every segment it points at", ok)
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.1))
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, 0.2))
	var still := w.highlight
	await _frames(2)
	_check("pad: the stick inside the deadzone moves nothing", w.highlight == still)
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.0))
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, 0.0))
	await _frames(2)
	w.highlight = 3
	await _pad(JOY_BUTTON_A)
	_check("pad: A opens the lit section", m.open_tab == str(SectionWheel.SECTIONS[3]["name"]) and not w.open)
	await _pad(JOY_BUTTON_B)
	await _pad(JOY_BUTTON_B)
	await _handed_back("pad")


func _mouse_cases() -> void:
	await _key(KEY_SHIFT)
	var c := w._centre()
	var ok := true
	var mid := (SectionWheel.INNER_R + SectionWheel.OUTER_R) * 0.5
	for i in SectionWheel.SECTIONS.size():
		await _move_to(c + w._dir(float(i) * TAU / SectionWheel.SECTIONS.size()) * mid)
		ok = ok and w.highlight == i
	_check("mouse: hovering lights every segment", ok)
	# The rim and the hub: inside the ring's edges a hover counts, past them it doesn't.
	await _move_to(c + w._dir(TAU * 2.0 / 8.0) * (SectionWheel.OUTER_R - 2.0))
	_check("mouse: just inside the outer edge counts", w.highlight == 2)
	await _move_to(c + w._dir(TAU * 5.0 / 8.0) * (SectionWheel.INNER_R + 2.0))
	_check("mouse: just outside the hub counts", w.highlight == 5)
	await _move_to(c + w._dir(TAU * 1.0 / 8.0) * (SectionWheel.INNER_R - 10.0))
	_check("mouse: a hover over the hub changes nothing", w.highlight == 5)
	await _click_at(c + w._dir(TAU * 6.0 / 8.0) * mid)
	_check("mouse: a click opens that section", m.open_tab == str(SectionWheel.SECTIONS[6]["name"]) and not w.open)
	await _key(KEY_ESCAPE)
	await _click_at(Vector2(16, 16))
	_check("mouse: a click off the ring closes it", not w.open and m.open_tab == "")
	await _handed_back("mouse")


# Just either side of each boundary between two segments, by the stick and by the mouse.
func _boundary_cases() -> void:
	await _key(KEY_SHIFT)
	var n := SectionWheel.SECTIONS.size()
	var seg := TAU / n
	var c := w._centre()
	var mid := (SectionWheel.INNER_R + SectionWheel.OUTER_R) * 0.5
	var mouse_ok := true
	var stick_ok := true
	for i in n:
		var edge := (float(i) + 0.5) * seg
		for side in [-1, 1]:
			var want := i if side < 0 else posmod(i + 1, n)
			var a: float = edge + side * 0.03
			await _move_to(c + w._dir(a) * mid)
			mouse_ok = mouse_ok and w.highlight == want
			var v: Vector2 = w._dir(a) * 0.9
			Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, v.x))
			Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, v.y))
			await _frames(2)
			stick_ok = stick_ok and w.highlight == want
			# Let go, or the held stick keeps the highlight while the mouse moves.
			Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.0))
			Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, 0.0))
			await _frames(1)
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_X, 0.0))
	Input.parse_input_event(_axis_event(JOY_AXIS_LEFT_Y, 0.0))
	await _frames(2)
	_check("boundary: the mouse either side of every boundary lights the right segment", mouse_ok)
	_check("boundary: the stick either side of every boundary lights the right segment", stick_ok)
	await _key(KEY_ESCAPE)


func _repeat_cases() -> void:
	await _key(KEY_SHIFT)
	w.highlight = 0
	# Eleven presses arrive in one frame: each moves the highlight once, none opens a section.
	for i in 11:
		Input.parse_input_event(_key_event(KEY_RIGHT, true))
		Input.parse_input_event(_key_event(KEY_RIGHT, false))
	await _frames(2)
	_check("repeat: eleven presses in a frame step eleven times", w.highlight == 11 % SectionWheel.SECTIONS.size())
	_check("repeat: and open nothing", w.open and m.open_tab == "")
	# Held right auto-repeats (echo events) and keeps stepping.
	var at := w.highlight
	var echo := _key_event(KEY_RIGHT, true)
	echo.echo = true
	Input.parse_input_event(_key_event(KEY_RIGHT, true))
	await _frames(1)
	Input.parse_input_event(echo)
	await _frames(1)
	Input.parse_input_event(_key_event(KEY_RIGHT, false))
	await _frames(2)
	_check("repeat: a held key repeats", w.highlight == posmod(at + 2, SectionWheel.SECTIONS.size()))
	# Shift pressed over and over: open, closed, open, closed.
	await _key(KEY_ESCAPE)
	for i in 4:
		await _key(KEY_SHIFT)
	_check("repeat: four Shifts leave it closed", not w.open)
	await _handed_back("repeat")


# Every section opens from the wheel, and back returns to the wheel each time.
func _every_section_cases() -> void:
	for i in SectionWheel.SECTIONS.size():
		var section := str(SectionWheel.SECTIONS[i]["name"])
		await _key(KEY_SHIFT)
		w.highlight = 0
		for k in i:
			await _key(KEY_RIGHT)
		await _key(KEY_ENTER)
		_check("%s: chosen from the wheel" % section, m.open_tab == section and not w.open)
		await _key(KEY_ESCAPE)
		_check("%s: back to the wheel" % section, w.open and m.open_tab == "")
		await _key(KEY_ESCAPE)
	await _handed_back("every section")


func _prompt_cases() -> void:
	await _key(KEY_SHIFT)
	await _key(KEY_RIGHT)
	_check("prompts: the keyboard's names after a key", not w.pad_prompts)
	await _pad(JOY_BUTTON_DPAD_RIGHT)
	_check("prompts: the controller's names after a button", w.pad_prompts)
	await _key(KEY_LEFT)
	_check("prompts: back to the keyboard's", not w.pad_prompts)
	await _key(KEY_ESCAPE)
	await _pad(JOY_BUTTON_LEFT_STICK)
	_check("prompts: opened by L3, the wheel shows the controller's names", w.pad_prompts)
	await _pad(JOY_BUTTON_B)
	await _seconds(SectionWheel.fade_seconds + 0.1)


# With the fade off (reduced motion), the wheel shows and hides at once and works the same.
func _no_fade_cases() -> void:
	var keep := SectionWheel.fade_seconds
	SectionWheel.fade_seconds = 0.0
	await _key(KEY_SHIFT)
	_check("no fade: it shows whole at once", w.open and w.visible and w.ring.modulate.a == 1.0)
	await _key(KEY_RIGHT)
	await _key(KEY_ESCAPE)
	_check("no fade: Esc hides it at once", not w.open and not w.visible)
	await _key(KEY_SHIFT)
	w.highlight = 1
	await _key(KEY_ENTER)
	_check("no fade: Enter opens the lit section", m.open_tab == "Gear")
	await _key(KEY_ESCAPE)
	await _key(KEY_ESCAPE)
	await _handed_back("no fade")
	SectionWheel.fade_seconds = keep


# --- Helpers (as tools/menu_test.gd) ---------------------------------------------

func _handed_back(label: String) -> void:
	await _frames(2)
	_check("%s: the farm is back" % label, not m.player.paused and m.open_tab == "" and not w.open)
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
	return moved


func _clock_stopped() -> bool:
	var before := m.clock
	await _frames(5)
	return m.clock == before and m.player.paused


func _seconds(s: float) -> void:
	await create_timer(s).timeout
	await _frames(1)


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


func _check(label: String, ok: bool) -> void:
	if not ok:
		failures += 1
	print("%s  %s" % ["PASS" if ok else "FAIL", label])
