extends SceneTree

# CCH-WICKER-COVE-002: Edith's leak and the first Living Memory loop. Run headless from the project folder:
#   godot --path . --headless -s tools/inn_repair_test.gd
# Plays in save slot 9 (deleted when done; slots 1-3 are never touched). Prints ok or FAIL for each case and a
# total; the exit code is the number of failures. Covers the quote at Edith's counter (exact requirements), every
# refusal (no materials, part of them, Carpentry, too late, away from the inn), leaving it without penalty, the work
# through the real panel action (materials, hours, XP and coins exactly once), the bucket tile and look text before
# and after, Edith's lines (same day, the next day with and without rain, then as things are), Thomas only on a later
# day and once, the diary page from the record, saving and loading, old saves and inconsistent saves remembering
# nothing, and the workbench and Wicker Cove's road, shops and notices still working afterwards.

const SLOT := 9

var m: MainGame
var t: TownSystem
var started := false
var failures := 0
var path := ""


func _initialize() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	path = TitleMenu.slot_path(SLOT)
	SaveSystem.delete_save(path)
	m._on_title_start("new", SLOT)
	m.set_process(false)
	t = m.town
	_run()
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _set_hour(h: float) -> void:
	m.clock = (h - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	m.current_hour = h


func _bucket() -> Vector2i:
	return TownLayout.INT_ORIGIN + TownData.LEAK_TILE


func _snapshot() -> Dictionary:
	return {"money": m.money, "planks": int(m.materials["planks"]), "iron": int(m.materials["iron_bar"]),
		"hour": m.current_hour, "xp": int(m.skill_xp["Carpentry"]), "repairs": m.woodwork.repairs.duplicate(true),
		"flags": t.flags.duplicate(), "diary_new": m.diary_new.duplicate()}


func _unchanged(a: Dictionary) -> bool:
	return _snapshot() == a


func _leak_row(name: String) -> Dictionary:
	for r in t._rows("The inn"):
		if typeof(r) == TYPE_DICTIONARY and str(r.get("name", "")) == name:
			return r
	return {}


func _notes() -> Array:
	m.diary_found = true
	for s in m.panels._diary_sections():
		if str(s["name"]) == "Notes":
			return s["pages"]
	return []


func _inn_note() -> Dictionary:
	for p in _notes():
		if str(p["title"]) == "The leak at the inn":
			return p
	return {}


func _memory(text: String) -> bool:
	return text in [TownData.LEAK_SAME_DAY, TownData.LEAK_HELD, TownData.LEAK_HELD_RAIN, TownData.LEAK_THOMAS,
		TownData.LEAK_AFTER, TownData.LEAK_AFTER_SPRING]


func _run() -> void:
	var r: Dictionary = TownData.INN_REPAIR
	# --- Down to the village and into the inn -------------------------------------------------------
	m.day = 3
	_set_hour(9.0)
	t.go(true)
	m.player.position = m._tile_center(TownLayout.INN_DOOR.x, TownLayout.INN_DOOR.y)
	m._check_doors()
	_check("setup: in the inn", t.active and t.indoors)
	var entry := TownLayout.INT_ORIGIN + TownLayout.INT_ENTRY
	m.player.facing = Vector2.UP
	m.player.position = m._tile_center(entry.x + 2, TownLayout.INT_ORIGIN.y + 5)
	m._interact()
	_check("setup: Edith's counter opens the inn", m.open_tab == "The inn" and t.flags.has("met_edith"))
	m._close_panel()

	# --- Before: the bucket, the quote ------------------------------------------------------------------
	_check("before: not mended on a new game", not t.inn_fixed() and not m.woodwork.repairs.has("inn_roof"))
	_check("before: the bucket's tile is solid", m._is_blocked_world(m._tile_center(_bucket().x, _bucket().y)))
	m.player.position = m._tile_center(_bucket().x, _bucket().y + 1)
	m.player.facing = Vector2.UP
	m._interact()
	_check("before: facing the bucket describes the leak", m.chatter_text == TownData.LOOK_LEAK)
	var rows := t._rows("The inn")
	var heads: Array = []
	for row in rows:
		if row.has("section"):
			heads.append(str(row["section"]))
	_check("quote: the counter has a section for the leak", heads.has("The leak"))
	var quote := _leak_row("Mend the leak")
	_check("quote: the job is offered", not quote.is_empty() and str(quote["action"]) == "town:repair|inn_roof")
	var texts: Array = []
	for n in quote.get("needs", []):
		texts.append(str(n["text"]))
	_check("quote: shows the exact requirements", texts == ["8 planks", "2 iron bars", "Carpentry 2", "2 hours, begun by 17:00"])
	_check("quote: shows the pay", str(quote.get("value", "")).contains("pays 60 coins"))
	_check("quote: Edith explains it", str(quote.get("about", "")).begins_with(TownData.LEAK_OFFER))
	_check("quote: can't be started with nothing", not bool(quote["enabled"]) and str(quote["status"]) == "Not yet")
	_check("quote: leaving it is offered", str(_leak_row("Leave it for now").get("action", "")) == "town:leave|inn_roof")
	_check("quote: looking records nothing", not t.inn_fixed() and not t.flags.has("inn_roof"))

	# --- Refusals: nothing changes -----------------------------------------------------------------------
	m.materials["planks"] = 0
	m.materials["iron_bar"] = 0
	m.skill_xp["Carpentry"] = 0
	var s := _snapshot()
	_check("refuse: no materials", not t.repair_inn() and _unchanged(s))
	m.materials["planks"] = 8
	s = _snapshot()
	_check("refuse: planks but no iron", not t.repair_inn() and _unchanged(s))
	m.materials["planks"] = 7
	m.materials["iron_bar"] = 2
	s = _snapshot()
	_check("refuse: one plank short", not t.repair_inn() and _unchanged(s))
	m.materials["planks"] = 8
	s = _snapshot()
	_check("refuse: Carpentry 1", m.progression._level("Carpentry") < 2 and not t.repair_inn() and _unchanged(s))
	m.skill_xp["Carpentry"] = m.progression._xp_for_level(2)
	_check("quote: ready with everything", bool(_leak_row("Mend the leak")["enabled"]))
	_set_hour(17.5)
	s = _snapshot()
	_check("refuse: too late to start", not t.repair_inn() and _unchanged(s) and m.chatter_text == TownData.LEAK_LATE)
	_check("quote: not ready late", not bool(_leak_row("Mend the leak")["enabled"]))
	_set_hour(9.0)
	t.indoors = false
	s = _snapshot()
	_check("refuse: away from the inn", not t.repair_inn() and _unchanged(s))
	t.indoors = true
	_check("refuse: an unknown id does nothing", _act("town:repair|something_else", _snapshot()))

	# --- Leaving it: no penalty --------------------------------------------------------------------------
	s = _snapshot()
	m._on_panel_action("town:leave|inn_roof")
	_check("leave: nothing taken or recorded", _unchanged(s) and not t.inn_fixed())
	_check("leave: Edith shrugs it off", m.chatter_text == TownData.LEAK_LEAVE)
	_check("leave: the offer still stands", bool(_leak_row("Mend the leak")["enabled"]))
	_check("leave: no diary page", _inn_note().is_empty())

	# --- The work, through the panel's own action ----------------------------------------------------------
	m.materials["planks"] = 11
	m.materials["iron_bar"] = 3
	s = _snapshot()
	m._toggle_tab("The inn")
	m._on_panel_action("town:repair|inn_roof")
	_check("work: done", t.inn_fixed())
	_check("work: 8 planks taken", int(m.materials["planks"]) == 3)
	_check("work: 2 iron bars taken", int(m.materials["iron_bar"]) == 1)
	_check("work: logged as a notice", str(m.message_log[-1]["text"]).begins_with("Two hours in the back room"))
	_check("work: two hours pass", absf(m.current_hour - 11.0) < 0.01)
	_check("work: 60 coins paid", m.money == int(s["money"]) + 60)
	_check("work: Carpentry XP given", int(m.skill_xp["Carpentry"]) == int(s["xp"]) + m.rewards._xp(int(r["xp"])))
	var rec: Dictionary = m.woodwork.repairs["inn_roof"]
	_check("work: recorded once, with the day, cost and pay", int(rec["day"]) == 3 and rec["cost"] == {"planks": 8, "iron_bar": 2} and int(rec["paid"]) == 60)
	_check("work: the day is a memory hook", int(t.flags.get("inn_roof", -1)) == 3)
	_check("work: a new diary page", m.diary_new.has("town_inn_roof"))
	_check("work: the counter shows it mended", str(_leak_row("The back room's roof").get("status", "")) == "Mended" and _leak_row("Mend the leak").is_empty())
	s = _snapshot()
	m._on_panel_action("town:repair|inn_roof")
	_check("work: never twice (panel)", _unchanged(s))
	_check("work: never twice (call)", not t.repair_inn() and _unchanged(s))
	_check("work: never twice (try_repair)", not m.woodwork.try_repair("inn_roof", r["cost"], "Carpentry", 2, 2.0, 30) and _unchanged(s))
	m._close_panel()

	# --- After: the room ----------------------------------------------------------------------------------
	_check("after: the bucket is gone (tile open)", not m._is_blocked_world(m._tile_center(_bucket().x, _bucket().y)))
	m.player.position = m._tile_center(_bucket().x, _bucket().y + 1)
	m.player.facing = Vector2.UP
	m._interact()
	_check("after: the wall is mended", m.chatter_text == TownData.LOOK_MENDED)

	# --- The diary -----------------------------------------------------------------------------------------
	var note := _inn_note()
	_check("diary: a Notes page for the repair", not note.is_empty() and bool(note["new"]))
	var text := str(note.get("text", ""))
	_check("diary: the day and date", text.begins_with("Day 3, October 3."))
	_check("diary: what it took", text.contains("8 planks, 2 iron bars") and text.contains("two hours"))
	_check("diary: what was paid", text.contains("She paid me 60 coins."))
	_check("diary: facts only (no feelings written for you)", not (text.contains("proud") or text.contains("felt") or text.contains("happy") or text.contains("glad")))
	_check("diary: only one page for it", _notes().filter(func(p): return str(p["title"]) == "The leak at the inn").size() == 1)

	# --- Edith and Thomas remember ------------------------------------------------------------------------
	_check("Edith: same day", t._line("edith") == TownData.LEAK_SAME_DAY)
	_check("Thomas: not the same day (he hasn't heard)", t._line("thomas") != TownData.LEAK_THOMAS)
	_check("Thomas: nothing marked heard yet", not t.flags.has("inn_roof_thomas"))
	m.day = 4
	_set_hour(10.0)
	_check("Edith: next day, it has held (no rain yet)", t._line("edith") == TownData.LEAK_HELD)
	_check("Edith: the same line again that day", t._line("edith") == TownData.LEAK_HELD)
	_check("Thomas: the next day he has heard", t._line("thomas") == TownData.LEAK_THOMAS)
	_check("Thomas: and again that day", t._line("thomas") == TownData.LEAK_THOMAS)
	_set_hour(20.0)
	_check("Thomas: even late in the day", t._line("thomas") == TownData.LEAK_THOMAS)
	_set_hour(10.0)
	m.day = 5
	_check("Thomas: once only", t._line("thomas") != TownData.LEAK_THOMAS)
	_check("Edith: the callback once only", not (t._line("edith") in [TownData.LEAK_HELD, TownData.LEAK_HELD_RAIN, TownData.LEAK_SAME_DAY]))
	# With rain between the work and her next word, she says it held through it.
	t.flags.erase("inn_roof_edith")
	m.stats["rain_days"] = int(rec["rain"]) + 1
	_check("Edith: after rain, it held through the rain", t._line("edith") == TownData.LEAK_HELD_RAIN)
	var bucket_after := true
	for d in range(6, 60):
		m.day = d
		var line := t._line("edith")
		if line == str(TownData.LINES["edith"][0]) or line == str(TownData.SEASON_LINES["edith"]["Spring"]):
			bucket_after = false
	_check("Edith: never speaks of the bucket or the roof money again", bucket_after)
	m.day = 8
	_check("Edith: the back room as it is now", t._line("edith") == TownData.LEAK_AFTER)
	m.day = 10
	_check("Edith: the inn's other troubles remain (her other lines)", t._line("edith") == str(TownData.LINES["edith"][2]))

	# --- Saving and loading ----------------------------------------------------------------------------------
	t.go(false)
	m.saver._save_game()
	var raw := _raw(path)
	_check("save: the record is written", raw.has("woodwork") and raw["woodwork"]["repairs"].has("inn_roof"))
	var money := m.money
	m.woodwork.repairs = {}
	t.flags = {}
	m.money = 1
	_check("load: loads", m.saver._load_game())
	_check("load: still mended, same record", t.inn_fixed() and int(m.woodwork.repairs["inn_roof"]["day"]) == 3 and int(m.woodwork.repairs["inn_roof"]["paid"]) == 60 and m.woodwork.repairs["inn_roof"].has("rain"))
	_check("load: memory hooks come back", int(t.flags.get("inn_roof", -1)) == 3 and t.flags.has("inn_roof_thomas"))
	_check("load: coins not paid again", m.money == money)
	_check("load: the bucket stays gone", (func() -> bool:
		t.indoors = true
		var open := t._kind(_bucket()) == MainGame.Tile.FLOOR
		t.indoors = false
		return open).call())
	_check("load: the diary page is still there", not _inn_note().is_empty())
	t.go(true)
	m.player.position = m._tile_center(TownLayout.INN_DOOR.x, TownLayout.INN_DOOR.y)
	m._check_doors()
	_check("load: can't be done again", not t.repair_inn() and m.money == money)
	t.go(false)

	# --- Older and odd saves remember nothing ---------------------------------------------------------------
	raw = _raw(path)
	raw["woodwork"]["repairs"].erase("inn_roof")
	raw["town"]["flags"].erase("inn_roof")
	raw["town"]["flags"].erase("inn_roof_edith")
	raw["town"]["flags"].erase("inn_roof_thomas")
	_write(path, JSON.stringify(raw))
	_check("old save (village, no repair): loads", m.saver._load_game())
	_check("old save: not mended, no memory", not t.inn_fixed() and not _memory(t._line("edith")) and not _memory(t._line("thomas")))
	_check("old save: no diary page", _inn_note().is_empty())
	_check("old save: the bucket is back", (func() -> bool:
		t.indoors = true
		var solid := t._kind(_bucket()) == MainGame.Tile.TABLE
		t.indoors = false
		return solid).call())
	raw["town"]["flags"]["inn_roof"] = 2
	raw["town"]["flags"]["inn_roof_thomas"] = 2
	_write(path, JSON.stringify(raw))
	_check("odd save (a flag but no record): loads", m.saver._load_game())
	_check("odd save: a flag alone is no memory", not t.inn_fixed() and not _memory(t._line("edith")) and not _memory(t._line("thomas")) and _inn_note().is_empty())
	raw.erase("town")
	raw.erase("woodwork")
	raw["save_version"] = 16
	_write(path, JSON.stringify(raw))
	_check("old save (before the village and woodwork): loads", m.saver._load_game())
	_check("old save: no false memory anywhere", not t.inn_fixed() and t.flags.is_empty() and not _memory(t._line("edith")) and not _memory(t._line("thomas")) and _inn_note().is_empty())
	raw["woodwork"] = {"hewn": 0, "repairs": {"inn_roof": "yes"}}
	raw["save_version"] = SaveSystem.SAVE_VERSION
	_write(path, JSON.stringify(raw))
	_check("bad repair data: loads and is ignored", m.saver._load_game() and not t.inn_fixed())

	# --- Everything round it still works ------------------------------------------------------------------
	m.day = 6
	_set_hour(9.0)
	var bench := m._world_tile(30, 30)
	m.projects.decor[bench] = "workbench"
	m.player.position = m._tile_center(bench.x - 1, bench.y)
	m.materials["wood"] = 2
	var planks := int(m.materials["planks"])
	_check("workbench: still hews logs into planks", m.woodwork.hew(1) == 1 and int(m.materials["planks"]) == planks + 2)
	m.projects.decor.erase(bench)
	_check("Nearwood: the system is there", m.get("nearwood") != null)
	_set_hour(9.0)
	t.go(true)
	_check("village: the road down still works", t.active and m._player_tile() == TownLayout.ARRIVE)
	m.money = 100
	_check("village: the store still sells", t.buy("store", "lamp_oil", 1) == 1)
	_check("village: the notice board still builds", t._rows("Notice board").size() > 2)
	_check("village: the inn still sells", t._rows("The inn").filter(func(row): return str(row.get("button", "")) == "Buy").size() == 3)
	t.go(false)
	_check("village: the road home still works", not t.active)


func _act(action: String, before: Dictionary) -> bool:
	m._on_panel_action(action)
	return _unchanged(before)


func _raw(p: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _write(p: String, text: String) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _check(label: String, ok: bool) -> void:
	print("%s  %s" % ["ok  " if ok else "FAIL", label])
	if not ok:
		failures += 1
