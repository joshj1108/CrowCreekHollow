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

	# Version 9: the hose head, the cistern, the hoppers and a sprinkler round-trip; a version 8 save has none.
	var sprinkler := Vector2i(4 + m.BORDER_X, 20 + m.BORDER_Y)
	m.tool_tier["hose"] = 2
	m.cistern_built = true
	m.coop_hopper_built = true
	m.coop_hopper = 17
	m.barn_hopper_built = true
	m.barn_hopper = 9
	m.projects.decor[sprinkler] = "sprinkler"
	_save_on_day(11)
	m.tool_tier["hose"] = 0
	m.cistern_built = false
	m.coop_hopper = 0
	m.barn_hopper = 0
	m.projects.decor.erase(sprinkler)
	_check("hose head, cistern, hoppers and sprinkler round-trip", _load() == 11 and int(m.tool_tier["hose"]) == 2 and m.cistern_built
		and m.coop_hopper_built and m.coop_hopper == 17 and m.barn_hopper_built and m.barn_hopper == 9 and m.projects.decor.get(sprinkler, "") == "sprinkler")
	var v8 := _raw(path)
	v8["save_version"] = 8
	for key in ["cistern_built", "coop_hopper_built", "coop_hopper", "barn_hopper_built", "barn_hopper"]:
		v8.erase(key)
	v8["tool_tier"].erase("hose")
	v8["decor"] = []
	_write_text(path, JSON.stringify(v8))
	m.tool_tier["hose"] = 0     # a key the save lacks keeps what's in memory, as on a fresh start
	_check("version 8 save: no hose head, cistern, hoppers or sprinklers", _load() == 11 and int(m.tool_tier["hose"]) == 0 and not m.cistern_built
		and not m.coop_hopper_built and m.coop_hopper == 0 and not m.barn_hopper_built and m.projects._count("sprinkler") == 0
		and int(SaveSystem.read_save(path).get("save_version", 0)) == SaveSystem.SAVE_VERSION)

	# Version 10: seasonal crops, fish and forage in the pack, the cellar and cooler by kind, and today's forage.
	m.inventory["leeks"] = 3
	m.inventory["trout"] = 2
	m.inventory["chanterelles"] = 4
	m.inventory["garlic_seeds"] = 6
	m.cellar = {"crops": 5, "potatoes": 7}
	m.cooler = {"fish": 2, "sturgeon": 1}
	var kale_tile := Vector2i(6 + m.BORDER_X, 21 + m.BORDER_Y)
	m.crops[kale_tile] = {"stage": 2, "kind": "kale", "days": 4, "watered_day": 0}
	var find := Vector2i(3 + m.BORDER_X, 3 + m.BORDER_Y)
	m.forage.spots = {find: "rosehips"}
	m.forage.spots_day = 11   # the day _save_on_day saves on
	_save_on_day(11)
	m.inventory["leeks"] = 0
	m.inventory["trout"] = 0
	m.cellar = {}
	m.cooler = {}
	m.forage.spots = {}
	_check("seasonal items, stores by kind and forage round-trip", _load() == 11 and int(m.inventory["leeks"]) == 3 and int(m.inventory["trout"]) == 2
		and int(m.inventory["chanterelles"]) == 4 and int(m.inventory["garlic_seeds"]) == 6
		and int(m.cellar.get("potatoes", 0)) == 7 and int(m.cellar.get("crops", 0)) == 5 and int(m.cooler.get("sturgeon", 0)) == 1
		and str(m.crops.get(kale_tile, {}).get("kind", "")) == "kale" and m.forage.spots.get(find, "") == "rosehips")
	var v9 := _raw(path)
	v9["save_version"] = 9
	for key in ["cellar", "cooler", "forage", "forage_day"]:
		v9.erase(key)
	v9["cellar_stock"] = 12
	v9["cooler_stock"] = 4
	for key in ["leeks", "trout", "chanterelles", "garlic_seeds"]:
		v9["inventory"].erase(key)
	_write_text(path, JSON.stringify(v9))
	m.inventory["leeks"] = 0   # keys the save lacks keep what's in memory, as on a fresh start
	m.inventory["trout"] = 0
	_check("version 9 save: cellar turnips and cooler perch carried over", _load() == 11 and int(m.cellar.get("crops", 0)) == 12
		and int(m.cooler.get("fish", 0)) == 4 and m.farm._cellar_total() == 12 and m.fishing._cooler_total() == 4
		and int(m.inventory["leeks"]) == 0 and int(m.inventory["trout"]) == 0)

	# Version 11: the house extensions, furniture, paint, wallpaper, the land deed, and the stand's demand.
	# The cellar room keeps every crop, so a cellar of kale loads with it.
	m.cellar_built = true
	m.estate.built = {"cellar_room": true, "porch": true}
	m.estate.furniture = {"clock": true}
	m.estate.paint = "sage"
	m.estate.paper = "toile"
	m.estate.deed_paid = 1500
	m.estate.deed_offered = true
	m.stall.glut = {"egg": 4.0, "kale": 13.0}
	m.cellar = {"kale": 9}
	_save_on_day(11)
	m.estate._from_save({})
	m.stall.glut = {}
	m.cellar = {}
	_check("estate, deed and stand demand round-trip", _load() == 11 and m.estate._has("cellar_room") and m.estate._has("porch")
		and not m.estate._has("second_storey") and m.estate.furniture.has("clock") and m.estate.paint == "sage" and m.estate.paper == "toile"
		and m.estate.deed_paid == 1500 and m.estate.deed_offered and is_equal_approx(float(m.stall.glut.get("kale", 0.0)), 13.0)
		and int(m.cellar.get("kale", 0)) == 9)
	var v10 := _raw(path)
	v10["save_version"] = 10
	v10.erase("estate")
	v10.erase("stand_glut")
	v10["cellar"] = {"crops": 3, "kale": 9}
	_write_text(path, JSON.stringify(v10))
	_check("version 10 save: no extensions, deed or glut; only keepers in the cellar", _load() == 11 and m.estate.built.is_empty()
		and m.estate.furniture.is_empty() and m.estate.paint == "plain" and m.estate.deed_paid == 0 and m.stall.glut.is_empty()
		and int(m.cellar.get("crops", 0)) == 3 and not m.cellar.has("kale")
		and int(SaveSystem.read_save(path).get("save_version", 0)) == SaveSystem.SAVE_VERSION)
	m.cellar_built = false

	# Version 12: the walk to the wood's edge and the first Hollow sighting, in week one. A new game has neither;
	# an older save past day 4 has both done (and the new chapter), one before it plays them as a new game would.
	m.trek.edge_done = true
	m.nights.sighting_seen = true
	_save_on_day(11)
	m.trek.edge_done = false
	m.nights.sighting_seen = false
	_check("edge walk and sighting round-trip", _load() == 11 and m.trek.edge_done and m.nights.sighting_seen)
	var v11 := _raw(path)
	v11["save_version"] = 11
	v11.erase("trek_edge_done")
	v11.erase("sighting_seen")
	(v11["quests_done"] as Dictionary).erase("edge")
	_write_text(path, JSON.stringify(v11))
	_check("version 11 save past day 4: edge walk, sighting and chapter done", _load() == 11 and m.trek.edge_done
		and m.nights.sighting_seen and m.quests_done.has("edge") and m.trek._route_open("mill") == (m.day >= m.trek.FROM_DAY)
		and not m.trek._route_open("edge"))
	v11["day"] = 3
	v11["treks_done"] = 0   # a save that has walked anyone has the walk to the edge done whatever the day
	_write_text(path, JSON.stringify(v11))
	_check("version 11 save on day 3: edge walk and sighting still to come", _load() == 3 and not m.trek.edge_done
		and not m.nights.sighting_seen and not m.quests_done.has("edge"))
	m.trek.edge_done = false
	m.nights.sighting_seen = false

	# Version 13: the nights' prompts met, the shadow's blight on the ground and the vicar's blessing round-trip;
	# an older save has met each visitor as often as it faced any (up to 3), and no blight.
	m.nights.seen = {"field": 2, "raid": 1}
	m.nights.blight = {Vector2i(40, 20): 9, Vector2i(41, 20): 10}
	m.sanity_sys.bless_offer_day = 11
	m.sanity_sys.bless_day = 11
	_save_on_day(11)
	m.nights.seen = {}
	m.nights.blight = {}
	m.sanity_sys.bless_offer_day = -1
	m.sanity_sys.bless_day = -100
	_check("night prompts, blight and blessing round-trip", _load() == 11 and int(m.nights.seen.get("field", 0)) == 2
		and int(m.nights.seen.get("raid", 0)) == 1 and int(m.nights.blight.get(Vector2i(41, 20), 0)) == 10
		and m.sanity_sys.bless_offer_day == 11 and m.sanity_sys._blessed_tonight())
	var v12 := _raw(path)
	v12["save_version"] = 12
	for key in ["night_seen", "night_blight", "bless_offer_day", "bless_day"]:
		v12.erase(key)
	(v12["stats"] as Dictionary)["faced"] = 7
	_write_text(path, JSON.stringify(v12))
	_check("version 12 save: visitors met, no blight, no blessing", _load() == 11 and int(m.nights.seen.get("watcher", 0)) == 3
		and m.nights.blight.is_empty() and m.sanity_sys.bless_day == -100
		and int(SaveSystem.read_save(path).get("save_version", 0)) == SaveSystem.SAVE_VERSION)
	m.nights.seen = {}

	# Version 14: the walkers' friendship, scenes, gift tastes, requests and today's visitor round-trip, and an old
	# save keeps each walker's standing from the walks it made (friendship counts them) and has met them.
	m.trek.walked = {"mill": 3, "post": 1}
	m.folk.bonus = {"mill": 7, "orchard": 24}
	m.folk.met = {"mill": true, "orchard": true}
	m.folk.seen = {"maren_lamp": 10}
	m.folk.tastes = {"mill:bramble_jam": "loved"}
	m.folk.requests = {"maren_eggs": 10}
	m.folk.requests_done = {"davy_fish": 9}
	m.folk.talk_day = {"mill": 11}
	m.folk.gift_day = {"mill": 11}
	m.folk.gifts_given = 4
	m.folk.visit_day = 11
	m.folk.visitor = "orchard"
	_save_on_day(11)
	m.folk._from_save({})
	m.trek.walked = {}
	_check("friendship, scenes, tastes, requests and visit round-trip", _load() == 11 and m.folk._hearts("mill") == 3
		and m.folk._points("mill") == 67 and m.folk._hearts("orchard") == 1 and m.folk.seen.has("maren_lamp")
		and str(m.folk.tastes.get("mill:bramble_jam", "")) == "loved" and m.folk.requests.has("maren_eggs")
		and m.folk.requests_done.has("davy_fish") and m.folk.gifts_given == 4 and m.folk.visitor == "orchard"
		and m.folk.visit_day == 11 and not m.folk._can_give("mill"))
	var v13 := _raw(path)
	v13["save_version"] = 13
	v13.erase("folk")
	v13["trek_walked"] = {"mill": 4, "chapel": 2}
	v13["trek_edge_done"] = true
	_write_text(path, JSON.stringify(v13))
	_check("version 13 save: walks become friendship, standing kept", _load() == 11 and m.folk._hearts("mill") == 3
		and m.folk._points("mill") == 64 and m.folk._hearts("chapel") == 2 and m.folk.met.has("chapel") and m.folk.met.has("mill")
		and not m.folk.met.has("post") and m.folk.seen.is_empty() and m.folk.gifts_given == 0
		and m.folk._hearts("chapel") >= int(TrekSystem.STANDING["chapel"]["at"]))
	m.folk._from_save({})
	m.trek.walked = {}

	# Version 15: the second year's beats, the meeting, Davy's night, the Hollow's count and the endings reached
	# round-trip; an old save with the bell hung has the act closed, and one past the grove has the bell's ending.
	m.act.beats = {"letter": 240, "shown": 244, "orchard": 270, "knock": -1}
	m.act.meeting = "won"
	m.act.meeting_there = true
	m.act.davy = "stopped"
	m.act.davy_day = 371
	m.act.knock_from = 276
	m.act.hollow_left = 2
	m.act.endings = {"hollow": 330}
	m.act.pending = "hollow"
	_save_on_day(13)
	m.act._from_save({})
	_check("second year and endings round-trip", _load() == 13 and int(m.act.beats.get("orchard", 0)) == 270
		and m.act._has("knock") and not m.act._lived("knock") and m.act.meeting == "won" and m.act.meeting_there
		and m.act.davy == "stopped" and m.act.davy_day == 371 and m.act.knock_from == 276 and m.act.hollow_left == 2
		and int(m.act.endings.get("hollow", 0)) == 330 and m.act.pending == "hollow")
	var v14 := _raw(path)
	v14["save_version"] = 14
	v14.erase("act")
	v14["bell_day"] = 396
	v14["trek_grove_done"] = true
	_write_text(path, JSON.stringify(v14))
	_check("version 14 save past the grove: act closed, the bell's ending reached", _load() == 13
		and m.act._has("meeting") and not m.act._lived("letter") and m.act.meeting == "lost"
		and m.act.endings.has("bell") and m.act.pending == "" and m.act._year_pages(func(_id: String) -> bool: return false).is_empty())
	v14["bell_day"] = -1
	v14["trek_grove_done"] = false
	v14["day"] = 380
	_write_text(path, JSON.stringify(v14))
	_check("version 14 save at day 380 without the bell: the act plays from here", _load() == 380
		and m.act.beats.is_empty() and m.act.endings.is_empty())
	m.projects.bell_day = -1
	m.trek.grove_done = false
	m.act._from_save({})
	m.act.beats = {}
	m.act.endings = {}

	# Version 16: the achievements are keyed by their Steam API names. An old save keeps the ones whose old id
	# has a match and drops the rest; counters added as things happen (crop_, faced_) load back.
	m.achievements_done = {"ACH_EDGE": true}
	m.stats["crop_kale"] = 4
	m.stats["faced_watcher"] = 2
	_save_on_day(13)
	m.achievements_done = {}
	m.stats.erase("crop_kale")
	m.stats.erase("faced_watcher")
	_check("achievements and new counters round-trip", _load() == 13 and m.achievements_done.has("ACH_EDGE")
		and int(m.stats.get("crop_kale", 0)) == 4 and int(m.stats.get("faced_watcher", 0)) == 2)
	var v15 := _raw(path)
	v15["save_version"] = 15
	v15["achievements_done"] = {"first_fruit": true, "brush_clear": true, "hollow_light": true, "story_end": true}
	_write_text(path, JSON.stringify(v15))
	_check("version 15 save: old achievements mapped, the unmatched dropped", _load() == 13
		and m.achievements_done.has("ACH_FIRST_HARVEST") and m.achievements_done.has("ACH_HOLLOW_LANTERN")
		and m.achievements_done.has("ACH_ALL_CHAPTERS") and not m.achievements_done.has("brush_clear")
		and m.achievements_done.size() == 3)
	m.achievements_done = {}

	# Saving in the cave puts you at the homestead on load.
	var home := m._tile_center(m.HOMESTEAD_ARRIVE.x, m.HOMESTEAD_ARRIVE.y)
	m.in_cave = true
	_save_on_day(12)
	m.in_cave = false
	var pos: Array = _raw(path)["player_pos"]
	_check("cave save records the homestead", is_equal_approx(float(pos[0]), home.x) and is_equal_approx(float(pos[1]), home.y))

	# A version 7 save made out in the wider land, with goods in the bank, a crossbow in hand and bolts in the pack.
	var v7 := _raw(path)
	v7["save_version"] = 7
	v7["zone"] = 4
	v7["world_version"] = 1
	v7["player_pos"] = [9000.0, 12000.0]
	v7["campsite"] = [400, 450]
	v7["guardian_done"] = {"meet": true}
	v7["quarry"] = [[496, 456]]
	v7["bank_materials"] = {"wood": 7, "iron_bar": 2, "arrows": 5}
	v7["bank_coins"] = 55
	v7["money"] = 10
	v7["materials"]["wood"] = 1
	v7["materials"]["hardwood"] = 0
	v7["materials"]["bolts"] = 6
	v7["equipment"]["hand_r"] = "crossbow"
	v7["open_tab"] = "Bank"
	_write_text(path, JSON.stringify(v7))
	var migrated := SaveSystem.read_save(path)
	_check("version 7 world save: world keys dropped", not migrated.has("zone") and not migrated.has("campsite")
		and not migrated.has("bank_materials") and not migrated.has("guardian_done") and not migrated.has("quarry"))
	_check("version 7 world save: loads", _load() == 12)
	_check("version 7 world save: bank comes home", int(m.materials["wood"]) == 8 and int(m.materials["iron_bar"]) >= 2 and m.money == 65)
	_check("version 7 world save: crossbow refunded, ammo gone", m.equipment["hand_r"] == "" and int(m.materials["hardwood"]) == 4
		and not m.materials.has("bolts") and not m.materials.has("arrows"))
	_check("version 7 world save: wakes at the homestead", m.has_saved_pos and m.saved_pos.distance_to(home) < 1.0)
	_check("version 7 world save: no bank panel", m.saved_panel == "")
	_save_on_day(12)

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
