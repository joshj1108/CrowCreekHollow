extends SceneTree

# Checks that saving is safe: every save is written whole or not at all, a damaged or missing save comes
# back from its backup, and older saves still load. Run headless, from the project folder:
#   godot --path . --headless -s tools/save_test.gd
# It plays in save slot 9 (not shown on the start screen) and deletes that save when done. Slots 1-3 are
# never touched. Prints PASS or FAIL for each case and a total; the exit code is the number of failures.

const SLOT := 9

var m: MainGame
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
	_remove(SaveSystem.broken_path(path))
	m._on_title_start("new", SLOT)
	m.set_process(false)
	_run()
	SaveSystem.delete_save(path)
	_remove(SaveSystem.broken_path(path))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _run() -> void:
	# Two saves in a row: the first becomes the backup, and no half-written file is left behind.
	_save_on_day(5)
	_check("first save has no backup", _day(path) == 5 and not _exists(SaveSystem.backup_path(path)))
	_save_on_day(6)
	_check("second save keeps the first as backup", _day(path) == 6 and _day(SaveSystem.backup_path(path)) == 5)
	_check("no temp file left after a save", not _exists(SaveSystem.temp_path(path)))
	_check("save records its version", int(_raw(path).get("save_version", 0)) == SaveSystem.SAVE_VERSION)
	_check("loads day 6", _load() == 6)
	var good := FileAccess.get_file_as_string(path)

	# A file cut off part way through, as after a power cut mid-write.
	_write_text(path, good.substr(0, good.length() / 2))
	_check("truncated: restored from backup", SaveSystem.recover(path) == "restored" and _load() == 5)
	_check("truncated: damaged file kept aside", _exists(SaveSystem.broken_path(path)))

	# Random bytes.
	_save_on_day(6)
	var junk := PackedByteArray()
	for i in 2000:
		junk.append(randi() % 256)
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer(junk)
	f.close()
	_check("garbage bytes: restored from backup", SaveSystem.recover(path) == "restored" and _load() == 5)
	_save_on_day(6)
	_write_text(path, "")
	_check("empty file: restored from backup", SaveSystem.recover(path) == "restored" and _load() == 5)

	# Valid JSON that isn't a save, or has a key of the wrong type.
	_save_on_day(6)
	_write_text(path, "[1, 2, 3]")
	_check("JSON array: restored from backup", SaveSystem.recover(path) == "restored")
	_save_on_day(6)
	var bad := _raw(path)
	bad["inventory"] = [1, 2]
	_write_text(path, JSON.stringify(bad))
	_check("inventory of the wrong type: restored from backup", SaveSystem.recover(path) == "restored")
	_save_on_day(6)
	bad = _raw(path)
	bad["day"] = 0
	_write_text(path, JSON.stringify(bad))
	_check("day 0: restored from backup", SaveSystem.recover(path) == "restored")

	# The loader recovers by itself too, if the start screen didn't.
	_save_on_day(6)
	_write_text(path, "{\"day\": 6, ")
	_check("load falls back to backup without the start screen", _load() == 5)

	# Missing save with a backup present, as after a crash between the two renames.
	_save_on_day(6)
	_remove(path)
	_check("missing save: restored from backup", SaveSystem.recover(path) == "restored" and _load() == 5)
	# The same crash with the new save fully written to .tmp: the newer save wins.
	_save_on_day(6)
	_save_on_day(7)
	DirAccess.rename_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(SaveSystem.temp_path(path)))
	_check("missing save with a whole temp file: temp is used", SaveSystem.recover(path) == "" and _load() == 7)
	_check("missing save with a whole temp file: backup untouched", _day(SaveSystem.backup_path(path)) == 6)
	# A stale temp file beside a good save is cleared.
	_write_text(SaveSystem.temp_path(path), "{\"day\": ")
	_check("good save: stale temp cleared", SaveSystem.recover(path) == "" and not _exists(SaveSystem.temp_path(path)))

	# A damaged save never pushes the good backup out: the day 7 backup outlives the damaged day 8 save.
	_save_on_day(8)
	_write_text(path, "garbage")
	_save_on_day(9)
	_check("saving over a damaged file keeps the good backup", _day(path) == 9 and _day(SaveSystem.backup_path(path)) == 7)

	# Damaged with no backup: the slot shows empty instead of loading as a new game by mistake.
	_remove(SaveSystem.backup_path(path))
	_write_text(path, "garbage")
	_check("damaged, no backup: lost", SaveSystem.recover(path) == "lost" and TitleMenu.slot_data(SLOT).is_empty())
	_check("damaged, no backup: won't load", not m.saver._load_game())

	# An old save from before the version number, the bell and treks.
	_save_on_day(10)
	var old := _raw(path)
	for key in ["save_version", "bell_day", "treks_done", "trek_grove_done", "trek_works"]:
		old.erase(key)
	for mat in ["lamp_oil", "storm_oak", "flax", "bell_metal", "bell_frame", "bell_rope"]:
		old["materials"].erase(mat)
	old["inventory"].erase("trail_ration")
	_write_text(path, JSON.stringify(old))
	m.projects.bell_day = 50
	m.trek.treks_done = 3
	m.trek.grove_done = true
	m.trek.works = {"waymarks": true}
	_check("old save: loads", _load() == 10)
	_check("old save: bell not begun, no treks", m.projects.bell_day == -1 and m.trek.treks_done == 0 and not m.trek.grove_done)
	_check("old save: no trail works", m.trek.works.is_empty())
	_check("old save: new materials and items present", m.materials.has("lamp_oil") and m.materials.has("bell_rope") and m.inventory.has("trail_ration"))
	_check("old save: migrated version", int(SaveSystem.read_save(path).get("save_version", 0)) == SaveSystem.SAVE_VERSION)
	# A save whose numbers are null instead of numbers.
	old["materials"]["wood"] = null
	_write_text(path, JSON.stringify(old))
	_check("old save: a null material loads", _load() == 10)

	# New fields round-trip.
	m.materials["lamp_oil"] = 3
	m.materials["storm_oak"] = 2
	m.inventory["trail_ration"] = 4
	m.projects.bell_day = 12
	m.trek.treks_done = 2
	m.trek.grove_done = true
	m.trek.works = {"footbridge": true, "chapel_steps": true}
	_save_on_day(11)
	m.materials["lamp_oil"] = 0
	m.inventory["trail_ration"] = 0
	m.projects.bell_day = -1
	m.trek.treks_done = 0
	m.trek.grove_done = false
	m.trek.works = {}
	_check("new fields round-trip", _load() == 11 and int(m.materials["lamp_oil"]) == 3 and int(m.materials["storm_oak"]) == 2
		and int(m.inventory["trail_ration"]) == 4 and m.projects.bell_day == 12 and m.trek.treks_done == 2 and m.trek.grove_done)
	_check("trail works round-trip", m.trek.works.size() == 2 and m.trek._has_work("footbridge") and m.trek._has_work("chapel_steps"))

	# Version 5: the clapper and Agnes's pages from the wood round-trip.
	m.materials["bell_clapper"] = 1
	m.mystery.found["t1"] = true
	m.mystery.found["t2"] = true
	_save_on_day(11)
	m.materials["bell_clapper"] = 0
	m.mystery.found.erase("t1")
	m.mystery.found.erase("t2")
	_check("clapper and trek pages round-trip", _load() == 11 and int(m.materials["bell_clapper"]) == 1
		and m.mystery.found.has("t1") and m.mystery.found.has("t2") and m.mystery._next_trek_page("mill") == ""
		and m.mystery._next_trek_page("orchard") == "t3")
	# Version 6: the day of the last trek and the walkers' standing round-trip, with flour, saplings, bread
	# and apples; an older save counts the wood from its own day, and its walkers from none.
	m.trek.last_day = 9
	m.trek.walked = {"mill": 3, "chapel": 1}
	m.materials["flour"] = 4
	m.materials["apple_sapling"] = 1
	m.inventory["bread"] = 2
	m.inventory["apples"] = 5
	_save_on_day(11)
	m.trek.last_day = 0
	m.trek.walked = {}
	m.materials["flour"] = 0
	m.inventory["bread"] = 0
	_check("last trek day and standing round-trip", _load() == 11 and m.trek.last_day == 9 and int(m.trek.walked.get("mill", 0)) == 3
		and int(m.trek.walked.get("chapel", 0)) == 1 and int(m.materials["flour"]) == 4 and int(m.materials["apple_sapling"]) == 1
		and int(m.inventory["bread"]) == 2 and int(m.inventory["apples"]) == 5)
	var v5 := _raw(path)
	v5["save_version"] = 5
	v5.erase("trek_last_day")
	v5.erase("trek_walked")
	_write_text(path, JSON.stringify(v5))
	_check("version 5 save: wood counts from the save's day, no standing", _load() == 11 and m.trek.last_day == 11 and m.trek.walked.is_empty())
	# A version 4 save with the three bell parts made, and one with them not made: only the first gets the clapper.
	var v4 := _raw(path)
	v4["save_version"] = 4
	v4["bell_day"] = -1
	v4["materials"].erase("bell_clapper")
	for part in ["bell_metal", "bell_frame", "bell_rope"]:
		v4["materials"][part] = 1
	_write_text(path, JSON.stringify(v4))
	_check("version 4 save with the bell's parts: gets the clapper", _load() == 11 and int(m.materials["bell_clapper"]) == 1)
	v4["materials"]["bell_rope"] = 0
	_write_text(path, JSON.stringify(v4))
	m.materials["bell_clapper"] = 0     # a key the save lacks keeps what's in memory, as on a fresh start
	_check("version 4 save without them: no clapper", _load() == 11 and int(m.materials["bell_clapper"]) == 0)

	# Version 7: the workshop's spot round-trips, with its pieces stamped there; an older save with a built
	# workshop keeps it where it stood, and one without stays unplaced.
	m.smokehouse_built = true
	m.woodshed_built = true
	m.workshop_tile = Vector2i(20 + m.BORDER_X, 14 + m.BORDER_Y)
	_save_on_day(11)
	m.workshop_tile = Vector2i(-1, -1)
	var shop := Vector2i(20 + m.BORDER_X, 14 + m.BORDER_Y)
	# The game stamps the farm's buildings after loading, as _on_title_start does.
	var loaded_day := _load()
	m._build_interior()
	_check("workshop spot round-trips", loaded_day == 11 and m.workshop_tile == shop
		and m.map[shop.y + m.SMOKEHOUSE_AT.y][shop.x + m.SMOKEHOUSE_AT.x] == MainGame.Tile.SMOKEHOUSE
		and m.map[shop.y + m.CHOPLOG_AT.y][shop.x + m.CHOPLOG_AT.x] == MainGame.Tile.CHOPLOG)
	var v6 := _raw(path)
	v6["save_version"] = 6
	v6.erase("workshop_x")
	v6.erase("workshop_y")
	_write_text(path, JSON.stringify(v6))
	var old_shop := m.WORKSHOP_OLD_IX + Vector2i(m.BORDER_X, m.BORDER_Y)
	loaded_day = _load()
	m._build_interior()
	_check("version 6 save: workshop stays where it stood", loaded_day == 11 and m.workshop_tile == old_shop
		and m.map[old_shop.y + m.SMOKEHOUSE_AT.y][old_shop.x + m.SMOKEHOUSE_AT.x] == MainGame.Tile.SMOKEHOUSE)
	v6["smokehouse_built"] = false
	v6["furnace_built"] = false
	_write_text(path, JSON.stringify(v6))
	_check("version 6 save without a workshop: none placed", _load() == 11 and m.workshop_tile.x < 0)
	m.smokehouse_built = false
	m.woodshed_built = false
	m._build_interior()

	# Saving in the cave puts you at the homestead on load.
	var home := m._tile_center(m.HOMESTEAD_ARRIVE.x, m.HOMESTEAD_ARRIVE.y)
	m.in_cave = true
	_save_on_day(12)
	m.in_cave = false
	var pos: Array = _raw(path)["player_pos"]
	_check("cave save records the homestead", is_equal_approx(float(pos[0]), home.x) and is_equal_approx(float(pos[1]), home.y))

	# A trek still going at day end is called off before the save.
	m.trek._start()
	var trek_save := _raw(path)
	m._end_day("Test.")
	_check("day end during a trek: trek over, out of the cave", not m.trek.active and not m.in_cave)
	_check("day end during a trek: saved and loads", _day(path) == m.day and _day(path) > int(trek_save["day"]) and _load() == m.day)

	# Eviction removes the save, its backup and any temp file, so nothing brings the farm back.
	_save_on_day(14)
	_save_on_day(15)
	_write_text(SaveSystem.temp_path(path), "x")
	SaveSystem.delete_save(path)
	_check("eviction: every file gone", not _exists(path) and not _exists(SaveSystem.backup_path(path)) and not _exists(SaveSystem.temp_path(path)))
	_check("eviction: nothing to recover", SaveSystem.recover(path) == "" and TitleMenu.slot_data(SLOT).is_empty())


func _save_on_day(d: int) -> void:
	m.day = d
	m.saver._save_game()


func _load() -> int:
	m.day = -99
	return m.day if m.saver._load_game() else -1


func _raw(p: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _day(p: String) -> int:
	return int(_raw(p).get("day", -1))


func _exists(p: String) -> bool:
	return FileAccess.file_exists(p)


func _write_text(p: String, text: String) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _remove(p: String) -> void:
	if FileAccess.file_exists(p):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


func _check(label: String, ok: bool) -> void:
	print("%s  %s" % ["ok  " if ok else "FAIL", label])
	if not ok:
		failures += 1
