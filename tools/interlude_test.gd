extends SceneTree

# CCH-ORIGIN-001: checks "The Road to Crow Creek Hollow", the opening interlude. Run headless:
#   godot --path . --headless -s tools/interlude_test.gd
# Plays in save slot 9 only (never 1-3) and deletes it at the end. Prints PASS or FAIL per case and a total; the
# exit code is the number of failures. Every road is driven by injected input (keys, Xbox buttons, mouse clicks)
# through the real title-menu entry point (MainGame._on_title_choice), then checked against a farm started the
# old way (MainGame._on_title_start), which the interlude must leave exactly as it was.

const SLOT := 9
var failures := 0
var m: MainGame
var baseline := {}

# One road per origin, each driven by a different device, so every device walks a whole interlude.
const ROADS := [
	{"via": "key", "c": {"origin": "security", "security_exit": "extension", "contact": "friend", "contact_intent": "promise",
		"keepsake": "photo", "road_pause": "look", "arrival_intention": "fit_to_live"}},
	{"via": "pad", "c": {"origin": "work", "work_exit": "boundary", "contact": "none", "contact_intent": "none",
		"keepsake": "none", "road_pause": "drive", "arrival_intention": "one_repair"}},
	{"via": "mouse", "c": {"origin": "household", "household_relation": "partner", "household_change": "moved",
		"contact": "former_household", "contact_intent": "invite", "keepsake": "tool", "road_pause": "look", "arrival_intention": "keep_some"}},
	{"via": "key", "c": {"origin": "curiosity", "curiosity_interest": "quiet", "contact": "private", "contact_intent": "boundaries",
		"keepsake": "notebook", "road_pause": "drive", "arrival_intention": "find_out"}},
	{"via": "pad", "c": {"origin": "chance", "chance_loose_end": "meeting", "contact": "family", "contact_intent": "uncertain",
		"keepsake": "postcard", "road_pause": "look", "arrival_intention": "worth_doing"}},
]
# A line only that origin's own scene shows (screenplay Act 1).
const OWN_LINE := {"security": "The new terms were printed on one sheet.", "work": "There was a list of things to do tomorrow.",
	"household": "The shelf was still marked where the other things had been.", "curiosity": "The photograph wasn't a good one.",
	"chance": "You had not made plans to move that year."}


func _initialize() -> void:
	create_timer(900.0).timeout.connect(func() -> void:
		print("FAIL: the test stopped part way (a script error above?) and timed out")
		quit(99))
	_run.call_deferred()


func _run() -> void:
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	_script_cases()
	await _baseline()
	for i in ROADS.size():
		await _road_case(ROADS[i], i == 0)
	await _back_cases()
	await _pause_cases()
	await _save_cases()
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


# --- The script itself (no game needed) ----------------------------------------------------------------------

func _script_cases() -> void:
	var opts := RoadScript.all_options()
	_check("script: every screenplay choice key exists", opts.keys().size() == 12 and opts.has("origin") and opts.has("arrival_intention"))
	_check("script: five origins", opts["origin"] == ["security", "work", "household", "curiosity", "chance"])
	_check("script: 'someone from the house' is only offered on the household road",
		not _ids(RoadScript.next_choice({"origin": "work", "work_exit": "finish"})).has("former_household")
		and _ids(RoadScript.next_choice({"origin": "household", "household_relation": "friend", "household_change": "ended"})).has("former_household"))
	# Every complete road ends at the door, and only there; it can't end with a choice unmade.
	var roads := 0
	var bad := 0
	var frontier := [{}]
	var words_by_origin := {}
	while not frontier.is_empty():
		var c: Dictionary = frontier.pop_back()
		var next := RoadScript.next_choice(c)
		if next.is_empty():
			roads += 1
			var steps := RoadScript.sequence(c)
			if steps[-1]["kind"] != "arrive" or c.size() != steps.filter(func(s: Dictionary) -> bool: return s["kind"] == "choice").size():
				bad += 1
			var words := 0
			for s in steps:
				for l in s["lines"]:
					words += str(l).split(" ").size()
			var o := str(c["origin"])
			words_by_origin[o] = maxi(int(words_by_origin.get(o, 0)), words)
			continue
		for id in RoadScript.option_ids(next):
			var more := c.duplicate()
			more[next["key"]] = id
			frontier.append(more)
	_check("script: all %d complete roads end at the door with every choice made" % roads, roads > 1000 and bad == 0)
	print("   longest road, words of narration per origin: ", words_by_origin)
	# A contradictory or damaged record is cut back to the last consistent choice, never kept whole.
	var r := OriginState.sanitize({"status": "complete", "choices": {"origin": "work", "security_exit": "stored", "contact": "friend"},
		"order": ["origin", "security_exit", "contact"]})
	_check("record: a choice from another road is dropped, and an unfinished road isn't 'complete'",
		r["choices"] == {"origin": "work"} and r["status"] == "in_progress")
	_check("record: garbage is 'none'", OriginState.sanitize("x")["status"] == "none" and OriginState.sanitize({"status": "complete", "choices": 5})["status"] == "in_progress")
	var legacy := OriginState.new({"status": "legacy"})
	_check("record: a legacy past answers nothing", not legacy.known() and legacy.origin() == "" and legacy.contact() == "" and legacy.thread() == "")


func _ids(step: Dictionary) -> Array:
	return RoadScript.option_ids(step)


# --- A farm started the old way, to compare against ----------------------------------------------------------

func _snapshot(g: MainGame) -> Dictionary:
	return {"day": g.day, "clock": g.clock, "hour": g.current_hour, "money": g.money, "inventory": g.inventory.duplicate(),
		"materials": g.materials.duplicate(), "equipment": g.equipment.duplicate(), "skill_xp": g.skill_xp.duplicate(),
		"food": g.food, "water": g.water, "warmth": g.warmth, "hp": g.hp, "sanity": g.sanity, "house_stage": g.house_stage,
		"pos": g.player.position, "inside": g.inside, "quests": g.quests_done.duplicate(), "guide": g._guide_step().get("id", g._guide_step()),
		"first_night": g.nights._first_night(), "act": g.act._to_save(), "town": g.town._to_save()}


func _baseline() -> void:
	await _new_main()
	m._on_title_start("new", SLOT)
	await _frames(5)
	baseline = _snapshot(m)
	_check("baseline: a farm started the old way has no origin ('none')", m.origin.status() == "none")
	await _free_main()


# --- One whole road per origin -------------------------------------------------------------------------------

func _road_case(road: Dictionary, deep: bool) -> void:
	var c: Dictionary = road["c"]
	var o := str(c["origin"])
	var via := str(road["via"])
	await _new_main()
	m.title_menu._show_name(SLOT)   # the title's name page, then Begin, as a player would
	await _frames(2)
	TitleMenu.pending_name = "Road %s" % o
	m._on_title_choice("new", SLOT)
	await _frames(3)
	var it := m.interlude
	_check("%s: New Game opens the interlude before the farm" % o, it != null and not m.world_started and not m.title_menu.visible)
	_check("%s: the road starts at the farm notice" % o, it.current()["id"] == "s00" and _body_text().contains("Old farmhouse. Fields and outbuildings."))
	_check("%s: the clock hasn't started (no farm)" % o, m.clock == 0.0 and not m.world_started)
	await _press(via)
	_check("%s: the origin choice shows all five reasons" % o, it.current()["id"] == "c00" and _options().size() == 5)
	var saw_own := false
	var saw_other := false
	var guard := 0
	while it != null and not it.done and guard < 60:
		guard += 1
		var step := it.current()
		var text := _body_text()
		for k in OWN_LINE:
			if text.contains(OWN_LINE[k]):
				if k == o:
					saw_own = true
				else:
					saw_other = true
		if not _focus_ok():
			_check("%s: focus is on a usable control at %s" % [o, step["id"]], false)
		match str(step["kind"]):
			"page", "arrive":
				await _press(via)
			"choice":
				await _choose(str(c[step["key"]]), via)
	_check("%s: the road reached the door by %s alone" % [o, via], it != null and it.done)
	_check("%s: its own scene showed, and no other origin's" % o, saw_own and not saw_other)
	# The fade to black, the farm built behind it, and the fade in.
	await create_timer(1.0).timeout   # the fade to black (0.8 s) and the farm built behind it
	await _frames(2)
	_check("%s: the farm is built after the door" % o, m.world_started)
	_check("%s: the clock is held while the farm fades in" % o, m.transitioning and m.clock == 0.0)
	await create_timer(1.2).timeout   # the fade in (1 s)
	await _frames(2)
	_check("%s: the interlude is gone and the clock runs" % o, m.interlude == null and not m.transitioning)
	_check("%s: the origin record is complete and is exactly the road taken" % o, m.origin.known() and m.origin.data["choices"] == c)
	var now := _snapshot(m)
	var differ := []
	for k in baseline:
		if k in ["clock", "hour"]:
			continue
		if k in ["food", "water", "warmth"]:
			# The meters start full; both farms have run a moment since, so allow the drift of a second or two.
			if absf(float(now[k]) - float(baseline[k])) > 1.0:
				differ.append(k)
		elif str(now[k]) != str(baseline[k]):
			differ.append(k)
	_check("%s: Day 1 begins exactly as before (pack, purse, meters, skills, tools, place, guide, story): %s" % [o, differ], differ.is_empty())
	_check("%s: no in-game minutes were lost (06:%02d after the fade-in)" % [o, int((m.current_hour - 6.0) * 60.0)], m.current_hour < 6.1 and m.day == 1)
	_check("%s: the slot holds the arrived record until the first save" % o,
		SaveSystem.is_interlude(_slot()) and str(_slot()["origin"]["status"]) == "complete")
	if deep:
		_check("%s: the first-night story is still ahead" % o, m.nights._first_night())
		_check("%s: Maren's day-4 trek is untouched (the act has seen no beats)" % o, str(m.act._to_save()) == str(baseline["act"]))
		# The farm takes input again: a step to the right moves the farmer.
		var at: Vector2 = m.player.position
		Input.parse_input_event(_key_event(KEY_D, true))
		await _frames(20)
		Input.parse_input_event(_key_event(KEY_D, false))
		await _frames(2)
		_check("%s: the farmer walks once the road is over" % o, m.player.position != at)
	await _free_main()


# --- Going back ----------------------------------------------------------------------------------------------

func _back_cases() -> void:
	await _new_main()
	m._on_title_choice("new", SLOT)
	await _frames(3)
	var it := m.interlude
	await _press("key")                       # s00 -> c00
	await _choose("security", "key")          # -> s1a
	await _press("key")                       # -> c1a
	await _choose("stored", "key")            # -> s1a_end
	_check("back: 'stored' leads to its own page", _body_text().contains("keep two boxes"))
	await _key(KEY_BACKSPACE)
	_check("back: Backspace returns to the choice with the answer marked", it.current()["id"] == "c1a" and (_focused_option() == "stored"))
	await _pad(JOY_BUTTON_B)
	await _pad(JOY_BUTTON_B)
	_check("back: B goes back again, to the origin choice", it.current()["id"] == "c00" and _focused_option() == "security")
	await _key(KEY_BACKSPACE)
	await _key(KEY_BACKSPACE)
	_check("back: Back stops at the first page", it.current()["id"] == "s00" and it.index == 0)
	await _press("key")
	await _choose("security", "key")
	_check("back: the same answer keeps the answers after it", it.choices.get("security_exit", "") == "stored")
	await _key(KEY_BACKSPACE)
	await _choose("work", "pad")
	_check("back: a different origin drops every later answer", it.choices == {"origin": "work"} and it.order == ["origin"])
	_check("back: the new road shows the work scene", _body_text().contains(OWN_LINE["work"]))
	var rec := OriginState.sanitize(it.record())
	_check("back: the saved record is consistent", rec["choices"] == {"origin": "work"})
	await _free_main()


# --- Pausing, quitting and resuming --------------------------------------------------------------------------

func _pause_cases() -> void:
	await _new_main()
	m._on_title_choice("new", SLOT)
	await _frames(3)
	var it := m.interlude
	await _press("key")
	await _choose("chance", "pad")
	await _press("pad")
	await _choose("storage", "key")
	var at := str(it.current()["id"])
	await _key(KEY_ESCAPE)
	_check("pause: Esc pauses, with Resume in focus", it.paused and _focus_ok() and (_focus() as Button).text == "Resume")
	_check("pause: the footer names the keys", it.footer_text().contains("Esc Resume"))
	await _key(KEY_SPACE)   # the space on Resume
	_check("pause: Resume returns to the same page", not it.paused and str(it.current()["id"]) == at)
	await _pad(JOY_BUTTON_START)
	_check("pause: Start pauses", it.paused and it.footer_text().contains("B Resume"))
	await _pad(JOY_BUTTON_B)
	_check("pause: B resumes", not it.paused and str(it.current()["id"]) == at)
	await _pad(JOY_BUTTON_START)
	var stub := _slot()
	_check("pause: the slot holds the road, at this page", SaveSystem.is_interlude(stub) and int(stub["origin"]["pos"]) == it.index
		and stub["origin"]["choices"] == {"origin": "chance", "chance_loose_end": "storage"})
	var title_line := TitleMenu.new()._slot_text(SLOT, stub)
	_check("pause: the slot reads 'on the road'", title_line.contains("on the road"))
	# Quit (the scene is thrown away, as Quit to title reloads it), then Continue from the title.
	await _free_main()
	await _new_main()
	m._on_title_choice("load", SLOT)
	await _frames(3)
	it = m.interlude
	_check("resume: Continue reopens the road on the same page", it != null and str(it.current()["id"]) == at and not m.world_started)
	_check("resume: with the same answers", it.choices == {"origin": "chance", "chance_loose_end": "storage"})
	await _free_main()


# --- Saving and older saves ----------------------------------------------------------------------------------

func _save_cases() -> void:
	# A finished road whose farm was never saved starts the farm fresh, with the record, and no interlude.
	SaveSystem.write_interlude(TitleMenu.slot_path(SLOT), "Arrived", OriginState.sanitize({"status": "complete",
		"choices": ROADS[3]["c"], "order": ["origin", "curiosity_interest", "contact", "contact_intent", "keepsake", "road_pause", "arrival_intention"]}))
	await _new_main()
	m._on_title_choice("load", SLOT)
	await _frames(5)
	_check("saves: an arrived slot starts Day 1 with its record and no interlude", m.world_started and m.interlude == null and m.origin.origin() == "curiosity" and m.day == 1)
	# The first real save carries the record, and loading it keeps it.
	m.saver._save_game()
	var saved := _slot()
	_check("saves: the farm's save holds the origin", not SaveSystem.is_interlude(saved) and str(saved["origin"]["status"]) == "complete"
		and saved["origin"]["choices"]["keepsake"] == "notebook")
	await _free_main()
	await _new_main()
	m._on_title_choice("load", SLOT)
	await _frames(5)
	_check("saves: loading keeps every origin choice", m.world_started and m.interlude == null and m.origin.data["choices"] == ROADS[3]["c"])
	_check("saves: the queries answer from it", m.origin.thread() == "the_place" and m.origin.has_contact() and m.origin.contact_intent() == "boundaries")
	# A farm saved before the interlude existed (version 17, no origin) loads straight in, with no past made up.
	var old := _slot()
	old.erase("origin")
	old["save_version"] = 17
	old["day"] = 40
	SaveSystem.write_save(TitleMenu.slot_path(SLOT), old)
	await _free_main()
	await _new_main()
	m._on_title_choice("load", SLOT)
	await _frames(5)
	_check("old save: loads with no interlude", m.world_started and m.interlude == null and m.day == 40)
	_check("old save: its past is 'legacy', with nothing chosen for it", m.origin.status() == "legacy" and m.origin.origin() == "" and m.origin.keepsake() == "")
	m.saver._save_game()
	_check("old save: saved again, it stays legacy", str(_slot()["origin"]["status"]) == "legacy")
	await _free_main()


# --- Helpers -------------------------------------------------------------------------------------------------

func _new_main() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await _frames(3)


func _free_main() -> void:
	m.queue_free()
	await _frames(3)


func _slot() -> Dictionary:
	return SaveSystem.read_save(TitleMenu.slot_path(SLOT))


func _body_text() -> String:
	var out := []
	_collect(m.interlude.body, out)
	return "\n".join(out)


func _collect(n: Node, out: Array) -> void:
	for c in n.get_children():
		if c.is_queued_for_deletion():
			continue
		if c is Label:
			out.append((c as Label).text)
		_collect(c, out)


func _options() -> Array:
	return m.interlude.body.get_children().filter(func(c: Node) -> bool: return c is Button and c.has_meta("option") and not c.is_queued_for_deletion())


func _focus() -> Control:
	return root.gui_get_focus_owner()


func _focus_ok() -> bool:
	var f := _focus()
	return f != null and f.is_visible_in_tree() and not (f is Button and (f as Button).disabled)


func _focused_option() -> String:
	var f := _focus()
	return str(f.get_meta("option")) if f != null and f.has_meta("option") else ""


# Continue (or Go in) by the device.
func _press(via: String) -> void:
	match via:
		"key":
			await _key(KEY_SPACE)
		"pad":
			await _pad(JOY_BUTTON_A)
		"mouse":
			await _click(_focus())
	await _frames(1)


# Picks an option as a player would: the D-pad or arrow keys to it and A or Space, or a click on it.
func _choose(id: String, via: String) -> void:
	await _frames(1)
	if via == "mouse":
		for b in _options():
			if str(b.get_meta("option")) == id:
				await _click(b)
				return
		_check("an option '%s' to click" % id, false)
		return
	for i in 8:
		if _focused_option() == id:
			break
		if via == "pad":
			await _pad(JOY_BUTTON_DPAD_DOWN)
		else:
			await _key(KEY_DOWN)
	if _focused_option() != id:
		_check("reach option '%s' by %s" % [id, via], false)
		return
	await _press(via)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


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
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	ev.pressed = true
	ev.pressure = 1.0
	Input.parse_input_event(ev)
	await _frames(1)
	var up := InputEventJoypadButton.new()
	up.button_index = button
	Input.parse_input_event(up)
	await _frames(2)


func _click(c: Control) -> void:
	if c == null:
		_check("a control to click", false)
		return
	var at: Vector2 = root.get_final_transform() * c.get_global_rect().get_center()
	var mv := InputEventMouseMotion.new()
	mv.position = at
	mv.global_position = at
	Input.parse_input_event(mv)
	await _frames(2)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = at
		ev.global_position = at
		Input.parse_input_event(ev)
		await _frames(1)
	await _frames(1)


func _check(label: String, ok: bool) -> void:
	if not ok:
		failures += 1
	print("%s  %s" % ["PASS" if ok else "FAIL", label])
