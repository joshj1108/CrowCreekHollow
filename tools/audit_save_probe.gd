extends "res://tools/balance_sim.gd"

# CCH-PLAYABLE-001: save and load round trips on real progression states. Two uses:
#
# 1. Round trip through a long game (default). The balance sim plays through the real game functions; at each
#    checkpoint day the night's save (A) is loaded into a second, fresh game, which saves at once (B), and A and B
#    are compared key by key. Anything a save holds that the loader drops, resets or changes shows as a difference.
#      godot --path . --headless -s tools/audit_save_probe.gd -- mode=engaged days=400 treks=3 at=2,5,9,14,30,62,93,150,246,300,397,400
# 2. An existing save file (load=N): slot N of the profile it runs in is loaded, saved again and compared the same
#    way, to check older saves. Run it ONLY in a throwaway profile holding a COPY of a save: it writes the slot.
#      godot --path . --headless -s tools/audit_save_probe.gd -- load=1
#
# Differences that are expected (a value that is the moment of saving, not state) are listed in IGNORE.

const IGNORE := ["save_time", "saved_at", "play_seconds"]
var at_days: Array = []
var load_slot := -1
var diffs_total := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := str(a).split("=")
		if kv[0] == "at":
			for d in kv[1].split(","):
				at_days.append(int(d))
		elif kv[0] == "load":
			load_slot = int(kv[1])
	if at_days.is_empty():
		at_days = [2, 5, 9, 14, 30, 62, 93, 150, 246, 300, 397, 400]
	if load_slot < 0:
		super._initialize()


func _process(delta: float) -> bool:
	if load_slot < 0:
		return super._process(delta)
	if started:
		return true
	started = true
	_load_file()
	return true


func _path(slot: int) -> String:
	return TitleMenu.slot_path(slot)


func _load_file() -> void:
	var before := _raw(_path(load_slot))
	if before.is_empty():
		print("LOAD slot %d: no readable save file in this profile" % load_slot)
		quit(1)
		return
	var migrated := SaveSystem.read_save(_path(load_slot))
	print("LOAD slot %d: file version %s, day %s, name \"%s\", %d keys; after migration version %s, %d keys" % [load_slot,
		str(before.get("version", "?")), str(before.get("day", "?")), str(before.get("save_name", "")), before.size(),
		str(migrated.get("version", "?")), migrated.size()])
	var g: MainGame = load("res://scenes/main.tscn").instantiate()
	root.add_child(g)
	g._on_title_start("load", load_slot)
	print("LOAD slot %d: loaded=%s day %d coins %d house stage %d lantern %d inside=%s tile=%s open_tab=\"%s\"" % [load_slot, g.world_started,
		g.day, g.money, g.house_stage, g.lantern_tier, g.inside, g._player_tile(), g.open_tab])
	var t: Vector2i = g._player_tile()
	if g._is_blocked_world(g.player.position + Vector2(0, 8)):
		print("DIFF slot %d: the loaded farmer stands inside something solid at %s" % [load_slot, t])
		diffs_total += 1
	g.saver._save_game()
	var after := _raw(_path(load_slot))
	_compare("slot %d" % load_slot, migrated, after)
	print("save probe: %d difference(s)" % diffs_total)
	quit(diffs_total)


func _raw(p: String) -> Dictionary:
	if not FileAccess.file_exists(p):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(p))
	return parsed if parsed is Dictionary else {}


func _run() -> void:
	print("save round trips: mode=%s days=%d at=%s" % [mode, days, str(at_days)])
	for i in days:
		_play_day()
		_note_milestones()
		if m.tax_owed > 0 and m.day - m.tax_due_day >= m.TAX_EVICT_DAYS - 1:
			print("LAND LOST on day %d" % m.day)
			break
		_sleep()
		if at_days.has(m.day):
			_round_trip()
	print("save probe: %d difference(s) over %d checkpoints" % [diffs_total, at_days.size()])
	SaveSystem.delete_save(_path(SLOT))
	quit(diffs_total)


# The night's save, loaded by a second game and saved again at once.
func _round_trip() -> void:
	# The sim never runs the per-frame checks that file a page or a homestead step within half a second of play,
	# so they are run here and the save written again: A is then what a played game would have saved.
	m.projects._check(false)
	m.mystery._check(true)
	m.saver._save_game()
	var a := _raw(_path(SLOT))
	if a.is_empty():
		print("DIFF day %d: no save file was written by the night" % m.day)
		diffs_total += 1
		return
	var g: MainGame = load("res://scenes/main.tscn").instantiate()
	root.add_child(g)
	g._on_title_start("load", SLOT)
	g.set_process(false)
	g.saver._save_game()
	var b := _raw(_path(SLOT))
	var n0 := diffs_total
	_compare("day %d" % m.day, a, b)
	print("checkpoint day %d: %d keys, %d bytes, %d difference(s); coins %d, stage %d, quests %d, pages %d, furniture %d" % [m.day, a.size(),
		JSON.stringify(a).length(), diffs_total - n0, m.money, m.house_stage, m.quests_done.size(), m.mystery.found.size(), m.estate.furniture.size()])
	root.remove_child(g)
	g.free()
	# Put the sim's own save back, so the next night's backup is its own.
	var f := FileAccess.open(_path(SLOT), FileAccess.WRITE)
	f.store_string(JSON.stringify(a))
	f.close()


func _compare(label: String, a: Dictionary, b: Dictionary) -> void:
	var keys := {}
	for k in a:
		keys[k] = true
	for k in b:
		keys[k] = true
	var names := keys.keys()
	names.sort()
	for k in names:
		# The sim stands the farmer "inside" without moving them, so the loader rightly puts them by the bed.
		if IGNORE.has(k) or (k == "player_pos" and load_slot < 0):
			continue
		if not b.has(k):
			_diff(label, "key \"%s\" is in the save but gone after load and save" % k)
		elif not a.has(k):
			_diff(label, "key \"%s\" appears only after load and save (%s)" % [k, _short(b[k])])
		elif not _same(a[k], b[k]):
			_diff(label, "\"%s\" changed: %s -> %s" % [k, _short(a[k]), _short(b[k])])


func _same(x: Variant, y: Variant) -> bool:
	if (x is float or x is int) and (y is float or y is int):
		return absf(float(x) - float(y)) < 0.01
	if x is Dictionary and y is Dictionary:
		if x.size() != y.size():
			return false
		for k in x:
			if not y.has(k) or not _same(x[k], y[k]):
				return false
		return true
	if x is Array and y is Array:
		if x.size() != y.size():
			return false
		# Lists of tiles and entries are compared as sets: the order they are written in is not state.
		var ys: Array = []
		for e in y:
			ys.append(JSON.stringify(e))
		for e in x:
			var i := ys.find(JSON.stringify(e))
			if i < 0:
				return x == y
			ys.remove_at(i)
		return true
	return typeof(x) == typeof(y) and x == y


func _short(v: Variant) -> String:
	var s := JSON.stringify(v)
	return s if s.length() <= 160 else s.substr(0, 157) + "..."


func _diff(label: String, text: String) -> void:
	diffs_total += 1
	print("DIFF %s: %s" % [label, text])
