class_name SaveSystem
extends RefCounted

# Bumped when a save's keys change shape. Saves from before the number was written count as 1.
# _migrate lifts an older save one version at a time, so every old save still loads.
const SAVE_VERSION := 15
# Keys a save must hold with the right type, or it isn't read: the loader would trip over anything else.
const DICT_KEYS := ["inventory", "materials", "skill_xp", "stats", "equipment", "quests_done", "achievements_done",
	"tool_tier", "trek_walked", "night_seen"]
const ARRAY_KEYS := ["crops", "brush", "felled", "rocks", "cave_mined", "decor", "steps_done", "rook_pages",
	"desk_mail", "desk_orders", "tips_seen", "diary_new", "hen_ages", "goat_ages", "player_pos", "trek_works",
	"night_blight"]
# What version 8 cut along with the wider land. A save from before it keeps none of these keys.
const WORLD_KEYS := ["zone", "world_version", "campsite", "guardian_done", "quarry", "bank_materials", "bank_coins"]
# The ranged weapons cut in version 8, with the materials they cost, given back to an older save that made one.
const CUT_WEAPONS := {"hardwood_bow": {"hardwood": 3, "fiber": 2}, "crossbow": {"hardwood": 4, "copper_bar": 2}}

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


# Saves from before foods were named for what made them keep their food under the new names.
func _migrate_legacy_food(saved: Variant) -> void:
	if typeof(saved) != TYPE_DICTIONARY:
		return
	var moves := {"meals": "turnip_hash", "smoked": "smoked_fish", "dried": "dried_turnip", "canned": "canned_turnip",
		"fermented": "fermented_turnip", "stew": "fish_stew", "hearty": "hearty_stew"}
	for old in moves.keys():
		if saved.has(old):
			m.inventory[moves[old]] = int(m.inventory[moves[old]]) + int(saved[old])


# Where a save puts you: in the cave, the save records the homestead instead.
func _save_pos() -> Array:
	if m.in_cave:
		var home := m._tile_center(m.HOMESTEAD_ARRIVE.x, m.HOMESTEAD_ARRIVE.y)
		return [home.x, home.y]
	return [m.player.position.x, m.player.position.y]


func _save_game() -> void:
	var data := {
		"day": m.day,
		"weather_kind": m.weather_kind,
		"food": m.food,
		"water": m.water,
		"warmth": m.warmth,
		"starve_timer": m.starve_timer,
		"well_repaired": m.well_repaired,
		"hose_attached": m.hose_attached,
		"well_water": m.well_water,
		"cistern_built": m.cistern_built,
		"skill_xp": m.skill_xp,
		"inventory": m.inventory,
		"materials": m.materials,
		"stats": m.stats,
		"quests_done": m.quests_done,
		"tutorial_v2": true,
		"hp": m.hp,
		"equipment": m.equipment,
		"money": m.money,
		"bag_tier": m.bag_tier,
		"cellar_built": m.cellar_built,
		"cooler_built": m.cooler_built,
		"cellar": m.cellar,
		"cooler": m.cooler,
		"forage": m.forage._to_save(),
		"forage_day": m.forage.spots_day,
		"smokehouse_built": m.smokehouse_built,
		"furnace_built": m.furnace_built,
		"woodshed_built": m.woodshed_built,
		"firewood_store": m.firewood_store,
		"fire_hours": m.fire_hours,
		"achievements_done": m.achievements_done,
		"story_version": 2,
		"selected_seed": m.selected_seed,
		"lantern_tier": m.lantern_tier,
		"house_stage": m.house_stage,
		"tidied_day": m.tidied_day,
		"job_done_day": m.job_done_day,
		"mend_day": m.mend_day,
		"mends_today": m.mends_today,
		"smelt_day": m.smelt_day,
		"smelts_today": m.smelts_today,
		"cleanse_day": m.cleanse_day,
		"event_fired_day": m.event_fired_day,
		"shadow_steps": m.nights.shadow_steps,
		"happening_done_day": m.happenings.done_day,
		"decor": m.projects.decor.keys().map(func(t: Vector2i) -> Array: return [t.x, t.y, m.projects.decor[t]]),
		"steps_done": m.projects.steps_done.keys(),
		"bell_day": m.projects.bell_day,
		"treks_done": m.trek.treks_done,
		"trek_last_day": m.trek.last_day,
		"trek_walked": m.trek.walked,
		"trek_grove_done": m.trek.grove_done,
		"trek_edge_done": m.trek.edge_done,
		"sighting_seen": m.nights.sighting_seen,
		"trek_works": m.trek.works.keys(),
		"folk": m.folk._to_save(),
		"act": m.act._to_save(),
		"estate": m.estate._to_save(),
		"stand_glut": m.stall.glut,
		"rook_pages": m.mystery.found.keys(),
		"last_visitor": m.nights.last_visitor,
		"night_seen": m.nights.seen,
		"night_blight": m.nights.blight.keys().map(func(t: Vector2i) -> Array: return [t.x, t.y, m.nights.blight[t]]),
		"bless_offer_day": m.sanity_sys.bless_offer_day,
		"bless_day": m.sanity_sys.bless_day,
		"sanity": m.sanity,
		"sanity_penalty": m.sanity_penalty,
		"boredom_loss": m.boredom_loss,
		"entertained_day": m.entertained_day,
		"player_pos": _save_pos(),
		"inside": m.inside,
		"save_name": m.save_name,
		"open_tab": m.open_tab,
		"crops": m.farm._crops_to_array(),
		"brush": m._brush_to_array(),
		"brush_day": m.brush_day,
		"rock_day": m.rock_day,
		"felled": m._felled_to_array(),
		"rocks": m._tiles_to_array(m.rocks),
		"tool_tier": m.tool_tier,
		"cave_mined": m._tiles_to_array(m.cave_mined),
		"cave_mined_day": m.cave_mined_day,
		"wear": m.wear,
		"coop_built": m.coop_built,
		"layout": m.LAYOUT_VERSION,
		"coop_x": m.coop_tile.x,
		"coop_y": m.coop_tile.y,
		"barn_built": m.barn_built,
		"barn_x": m.barn_tile.x,
		"barn_y": m.barn_tile.y,
		"workshop_x": m.workshop_tile.x,
		"workshop_y": m.workshop_tile.y,
		"hens": m.hens,
		"hens_fed_day": m.hens_fed_day,
		"hen_unfed_days": m.hen_unfed_days,
		"goats": m.goats,
		"goats_fed_day": m.goats_fed_day,
		"goat_unfed_days": m.goat_unfed_days,
		"coop_hopper_built": m.coop_hopper_built,
		"coop_hopper": m.coop_hopper,
		"barn_hopper_built": m.barn_hopper_built,
		"barn_hopper": m.barn_hopper,
		"hen_ages": m.hen_ages,
		"goat_ages": m.goat_ages,
		"tax_owed": m.tax_owed,
		"tax_due_day": m.tax_due_day,
		"tax_stage": m.tax_stage,
		"clean_nights": m.clean_nights,
		"desk_mail": m.desk_mail,
		"card_games": m.card_games,
		"sudoku_puzzles": m.sudoku_puzzles,
		"desk_orders": m.desk_orders,
		"tips_seen": m.tips_seen.keys(),
		"diary_found": m.diary_found,
		"diary_new": m.diary_new,
		"guide_v": 1,
	}
	data["save_version"] = SAVE_VERSION
	if not write_save(m._save_path(), data):
		m._show_message("The game could not be saved. Your last save is still there.")


func _load_game() -> bool:
	var data := read_save(m._save_path())
	if data.is_empty() and recover(m._save_path()) != "":
		data = read_save(m._save_path())
	if data.is_empty():
		return false

	m.day = int(data.get("day", 1))
	m.weather_kind = str(data.get("weather_kind", ""))
	m.food = float(data.get("food", 100.0))
	m.water = float(data.get("water", 100.0))
	m.warmth = float(data.get("warmth", 100.0))
	m.starve_timer = float(data.get("starve_timer", 0.0))
	m.well_repaired = bool(data.get("well_repaired", false))
	m.hose_attached = bool(data.get("hose_attached", false))
	m.well_water = float(data.get("well_water", 0.0))
	m.cistern_built = bool(data.get("cistern_built", false))
	_merge_ints(m.skill_xp, data.get("skill_xp"))
	_merge_ints(m.inventory, data.get("inventory"))
	_migrate_legacy_food(data.get("inventory"))
	_merge_ints(m.materials, data.get("materials"))
	_merge_ints(m.stats, data.get("stats"))
	# Saves before version 2 used the old quest list, so their progress is reset.
	# Stat-based achievements re-check from saved stats on the next frame.
	var story_v := int(data.get("story_version", 1))
	m.quests_done = data.get("quests_done", {}) if story_v >= 2 else {}
	m.achievements_done = data.get("achievements_done", {}) if story_v >= 2 else {}
	m.selected_seed = str(data.get("selected_seed", "turnip"))
	m.lantern_tier = int(data.get("lantern_tier", 0))
	m.house_stage = int(data.get("house_stage", 0))
	m.tidied_day = int(data.get("tidied_day", 0))
	m.job_done_day = int(data.get("job_done_day", -1))
	m.mend_day = int(data.get("mend_day", 0))
	m.mends_today = int(data.get("mends_today", 0))
	m.smelt_day = int(data.get("smelt_day", 0))
	m.smelts_today = int(data.get("smelts_today", 0))
	m.cleanse_day = int(data.get("cleanse_day", 0))
	m.money = int(data.get("money", 0))
	m.bag_tier = int(data.get("bag_tier", 0))
	m.cellar_built = bool(data.get("cellar_built", false))
	m.cooler_built = bool(data.get("cooler_built", false))
	m.estate._from_save(data.get("estate"))   # before the cellar: the cellar room lets it keep every crop
	m.stall._glut_from_save(data.get("stand_glut"))
	m.cellar = _stock(data.get("cellar"), m.farm._cellar_keys())
	m.cooler = _stock(data.get("cooler"), Foods.group("any_fish"))
	if int(data.get("forage_day", -1)) == m.day:
		m.forage._from_save(data.get("forage"), m.day)
	m.smokehouse_built = bool(data.get("smokehouse_built", false))
	m.furnace_built = bool(data.get("furnace_built", false))
	m.woodshed_built = bool(data.get("woodshed_built", false))
	m.firewood_store = int(data.get("firewood_store", 0))
	m.fire_hours = float(data.get("fire_hours", 0.0))
	m.hp = int(data.get("hp", m.BASE_HP))
	var saved_eq: Variant = data.get("equipment", {})
	if typeof(saved_eq) == TYPE_DICTIONARY:
		for slot in m.equipment.keys():
			# A piece this build doesn't know would trip every lookup in GEAR_ITEMS, so its slot is left empty.
			if saved_eq.has(slot) and (str(saved_eq[slot]) == "" or m.GEAR_ITEMS.has(str(saved_eq[slot]))):
				m.equipment[slot] = str(saved_eq[slot])
	m.event_fired_day = int(data.get("event_fired_day", 0))
	m.nights.shadow_steps = int(data.get("shadow_steps", 0))
	m.happenings.done_day = int(data.get("happening_done_day", 0))
	m.projects.decor.clear()
	for d in data.get("decor", []):
		m.projects.decor[Vector2i(int(d[0]), int(d[1]))] = str(d[2])
	m.mystery.found.clear()
	for id in data.get("rook_pages", []):
		m.mystery.found[str(id)] = true
	m.projects.bell_day = int(data.get("bell_day", -1))
	m.trek.treks_done = int(data.get("treks_done", 0))
	m.trek.last_day = int(data.get("trek_last_day", 0))
	m.trek.walked.clear()
	var walked: Variant = data.get("trek_walked", {})
	if typeof(walked) == TYPE_DICTIONARY:
		for id in walked:
			if TrekSystem.ROUTES.has(str(id)) and typeof(walked[id]) in [TYPE_INT, TYPE_FLOAT]:
				m.trek.walked[str(id)] = int(walked[id])
	m.trek.grove_done = bool(data.get("trek_grove_done", false))
	m.trek.edge_done = bool(data.get("trek_edge_done", false))
	m.nights.sighting_seen = bool(data.get("sighting_seen", false))
	m.folk._from_save(data.get("folk", {}))
	m.act._from_save(data.get("act", {}))
	m.trek.works.clear()
	for id in data.get("trek_works", []):
		if TrekSystem.WORKS.has(str(id)):
			m.trek.works[str(id)] = true
	m.projects.steps_done.clear()
	for id in data.get("steps_done", []):
		m.projects.steps_done[str(id)] = true
	m.nights.last_visitor = str(data.get("last_visitor", ""))
	m.nights.seen.clear()
	var night_seen: Variant = data.get("night_seen", {})
	if typeof(night_seen) == TYPE_DICTIONARY:
		for id in night_seen:
			m.nights.seen[str(id)] = int(night_seen[id])
	m.nights.blight.clear()
	for b in data.get("night_blight", []):
		m.nights.blight[Vector2i(int(b[0]), int(b[1]))] = int(b[2])
	m.sanity_sys.bless_offer_day = int(data.get("bless_offer_day", -1))
	m.sanity_sys.bless_day = int(data.get("bless_day", -100))
	m.nights.first_beat = -1   # a first night playing out in the game left behind doesn't carry into this one
	m.sanity_penalty = int(data.get("sanity_penalty", 0))
	m.boredom_loss = float(data.get("boredom_loss", 0.0))
	m.entertained_day = int(data.get("entertained_day", 0))
	m.sanity = float(data.get("sanity", m.SANITY_MAX))
	m.saved_inside = bool(data.get("inside", false))
	m.save_name = str(data.get("save_name", ""))
	m.saved_panel = str(data.get("open_tab", ""))
	var pos: Variant = data.get("player_pos", null)
	if typeof(pos) == TYPE_ARRAY and pos.size() == 2:
		m.saved_pos = Vector2(float(pos[0]), float(pos[1]))
		# A position from another layout may now be a fence or water, so the player starts at the farm centre.
		m.has_saved_pos = str(data.get("layout", "")) == m.LAYOUT_VERSION

	# Rebuild the interior so the saved house stage shows the right rooms.
	# Crops and brush are restored here, after the map exists.
	# A save made on another layout has its plants, brush and trees on tiles that may now be water or a
	# fence, so the farm's planted and gathered state is reset. Money, skills, tools and animals are kept.
	var same_layout := str(data.get("layout", "")) == m.LAYOUT_VERSION
	m.crops.clear()
	for c in (data.get("crops", []) if same_layout else []):
		var kind := str(c.get("kind", "turnip"))
		# Saves from before watering existed have no record. Those crops count as watered today,
		# so they grow tonight like they used to.
		var watered := int(c["watered_day"]) if c.has("watered_day") else m.day
		var stage := int(c["stage"])
		# Saves from before crops counted days convert their stage to days.
		var days := int(c["days"]) if c.has("days") else stage * int(m.CROP_GROW_DAYS[kind]) / m.MAX_STAGE
		m.crops[Vector2i(int(c["x"]), int(c["y"]))] = {"stage": stage, "kind": kind, "days": days, "watered_day": watered}
	m.brush_day = int(data.get("brush_day", data.get("day", 0)))
	m.rock_day = int(data.get("rock_day", data.get("day", 0)))
	m.brush.clear()
	if same_layout:
		for b in data.get("brush", []):
			m.brush[Vector2i(int(b[0]), int(b[1]))] = true
		for g in data.get("felled", []):
			m.grove_felled[Vector2i(int(g[0]), int(g[1]))] = true
		m._apply_grove()
	else:
		m._fill_brush()
	_merge_ints(m.tool_tier, data.get("tool_tier"))
	if same_layout and data.has("rocks"):
		m.rocks.clear()
		for r in data["rocks"]:
			m.rocks[Vector2i(int(r[0]), int(r[1]))] = true
	else:
		m._fill_rocks()
	m.cave_mined_day = int(data.get("cave_mined_day", -1))
	m.wear = int(data.get("wear", 0))
	m.coop_built = bool(data.get("coop_built", false))
	m.coop_tile = Vector2i(int(data.get("coop_x", -1)), int(data.get("coop_y", -1)))
	m.barn_built = bool(data.get("barn_built", false))
	m.barn_tile = Vector2i(int(data.get("barn_x", -1)), int(data.get("barn_y", -1)))
	m.workshop_tile = Vector2i(int(data.get("workshop_x", -1)), int(data.get("workshop_y", -1)))
	if not same_layout:
		# The saved spots belong to the old farm, so each building is placed again.
		m._show_message("The farm was redrawn since this save. Plantings, brush and felled trees were reset.")
		if m.coop_built:
			m._relocate_building("coop")
		if m.barn_built:
			m._relocate_building("barn")
		if m._is_built("workshop"):
			m._relocate_building("workshop")
	elif m._is_built("workshop") and m.workshop_tile.x < 0:
		# A built workshop always has a spot; one without (a hand-edited save) goes by the farmhouse.
		m._relocate_building("workshop")
	m.hens = int(data.get("hens", 0))
	m.hens_fed_day = int(data.get("hens_fed_day", -1))
	m.hen_unfed_days = int(data.get("hen_unfed_days", 0))
	m.goats = int(data.get("goats", 0))
	m.goats_fed_day = int(data.get("goats_fed_day", -1))
	m.goat_unfed_days = int(data.get("goat_unfed_days", 0))
	m.coop_hopper_built = bool(data.get("coop_hopper_built", false))
	m.coop_hopper = int(data.get("coop_hopper", 0))
	m.barn_hopper_built = bool(data.get("barn_hopper_built", false))
	m.barn_hopper = int(data.get("barn_hopper", 0))
	# Saves from before ages existed count the animals they had as already grown.
	m.hen_ages = m.animals._int_list(data["hen_ages"]) if data.has("hen_ages") else m.animals._filled(m.hens, m.HEN_MATURE_DAYS)
	m.goat_ages = m.animals._int_list(data["goat_ages"]) if data.has("goat_ages") else m.animals._filled(m.goats, m.GOAT_MATURE_DAYS)
	m.tax_owed = int(data.get("tax_owed", 0))
	m.tax_due_day = int(data.get("tax_due_day", 0))
	m.tax_stage = int(data.get("tax_stage", 0))
	m.clean_nights = int(data.get("clean_nights", 0))
	m.desk_mail = data.get("desk_mail", [])
	m.card_games = int(data.get("card_games", m.START_CARD_GAMES))
	m.sudoku_puzzles = int(data.get("sudoku_puzzles", 0))
	m.desk_orders = data.get("desk_orders", [])
	m.animals._sync_ages()
	if data.has("tips_seen"):
		m.tips_seen = {}
		for id in data["tips_seen"]:
			m.tips_seen[str(id)] = true
	else:
		# Saves from before tips existed have seen the tutorial already, so it doesn't flood them.
		for tip in m.TIPS:
			m.tips_seen[str(tip["id"])] = true
	# Saves from before the diary had their tips on the card already, so the diary is theirs.
	m.diary_found = bool(data.get("diary_found", true))
	m.diary_new = []
	for id in data.get("diary_new", []):
		m.diary_new.append(str(id))
	# Saves from before the guided first day are past it already.
	if not data.has("guide_v"):
		for step in m.GUIDE:
			m.tips_seen[str(step["id"])] = true
	if data.has("cave_mined"):
		m.cave_mined.clear()
		for c in data["cave_mined"]:
			m.cave_mined[Vector2i(int(c[0]), int(c[1]))] = true
	return true


# A store's counts by pack key, keeping only the keys it can hold.
func _stock(saved: Variant, keys: Array) -> Dictionary:
	var out := {}
	if typeof(saved) != TYPE_DICTIONARY:
		return out
	for key in keys:
		if saved.has(key) and typeof(saved[key]) in [TYPE_INT, TYPE_FLOAT] and int(saved[key]) > 0:
			out[key] = int(saved[key])
	return out


func _merge_ints(target: Dictionary, saved: Variant) -> void:
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for key in target.keys():
		if saved.has(key) and typeof(saved[key]) in [TYPE_INT, TYPE_FLOAT, TYPE_BOOL]:
			target[key] = int(saved[key])


# --- Files ---------------------------------------------------------------------------------------
# A save is written to a .tmp file, read back, and only then moved into place. The save it replaces
# becomes the .bak, so a crash, a power cut or a bad file never costs more than one night.

static func backup_path(path: String) -> String:
	return path.get_basename() + ".bak.json"


static func temp_path(path: String) -> String:
	return path.get_basename() + ".tmp.json"


static func broken_path(path: String) -> String:
	return path.get_basename() + ".broken.json"


# The save at path, checked and brought up to SAVE_VERSION, or {} if it's missing or can't be used.
static func read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	# A JSON instance reports a damaged file quietly, where JSON.parse_string would print an error.
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	var parsed: Variant = json.data
	if typeof(parsed) != TYPE_DICTIONARY or not _valid(parsed):
		return {}
	return _migrate(parsed)


static func _valid(data: Dictionary) -> bool:
	if not data.has("inventory") or typeof(data.get("day")) not in [TYPE_INT, TYPE_FLOAT] or int(data["day"]) < 1:
		return false
	if data.has("save_version") and typeof(data["save_version"]) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	for key in DICT_KEYS:
		if data.has(key) and typeof(data[key]) != TYPE_DICTIONARY:
			return false
	for key in ARRAY_KEYS:
		if data.has(key) and typeof(data[key]) != TYPE_ARRAY:
			return false
	for c in data.get("crops", []):
		if typeof(c) != TYPE_DICTIONARY or not (c.has("x") and c.has("y") and c.has("stage")):
			return false
	return true


# Each step lifts a save one version. Keys a step doesn't name fall back to the loader's defaults,
# and _merge_ints keeps today's defaults for any material or item an old save never had.
static func _migrate(data: Dictionary) -> Dictionary:
	var v := int(data.get("save_version", 1))
	if v < 2:
		# Version 2 added the crow bell and treks. A save from before them has started neither.
		if not data.has("bell_day"):
			data["bell_day"] = -1
		if not data.has("treks_done"):
			data["treks_done"] = 0
	if v < 3:
		# Version 3 added the other trek routes. Nobody has walked the woman in the grey shawl to the grove yet.
		if not data.has("trek_grove_done"):
			data["trek_grove_done"] = false
	if v < 4:
		# Version 4 added the trail works. None are built yet.
		if not data.has("trek_works"):
			data["trek_works"] = []
	if v < 5:
		# Version 5 added the old bell's clapper, a fourth thing the bell needs, from the vicar on a chapel trek
		# (Agnes's pages from the wood go in rook_pages with the rest). A save that already made all three
		# parts but hasn't hung the bell gets it, so a farm that was ready for All Hallows still is.
		var mats: Variant = data.get("materials")
		if typeof(mats) == TYPE_DICTIONARY and int(data.get("bell_day", -1)) < 0 and not mats.has("bell_clapper"):
			var ready := true
			for part in ["bell_metal", "bell_frame", "bell_rope"]:
				if typeof(mats.get(part)) not in [TYPE_INT, TYPE_FLOAT] or int(mats[part]) < 1:
					ready = false
			if ready:
				mats["bell_clapper"] = 1
	if v < 6:
		# Version 6 brought the wood closer to a farm that goes too long without a trek. An older save starts its
		# count on the day it was saved, so loading it doesn't find the wood already at the fence. It also counts
		# walks by route for the walkers' standing; an older save didn't, so its walkers start from none.
		if not data.has("trek_last_day"):
			data["trek_last_day"] = int(data.get("day", 0))
		if not data.has("trek_walked"):
			data["trek_walked"] = {}
	if v < 7:
		# Version 7 lets the workshop be placed and moved. A built one from an older save stays where it stood.
		if not data.has("workshop_x") and (bool(data.get("smokehouse_built", false)) or bool(data.get("furnace_built", false))):
			data["workshop_x"] = MainGame.WORKSHOP_OLD_IX.x + MainGame.BORDER_X
			data["workshop_y"] = MainGame.WORKSHOP_OLD_IX.y + MainGame.BORDER_Y
	if v < 8:
		_migrate_world(data)
	if v < 9:
		# Version 9 added the hose heads (tool_tier "hose"), the copper cistern, the feed hoppers and sprinklers
		# (in decor). An older save has none of them, which the loader's defaults already give; the step is
		# here so the number marks when they came.
		pass
	if v < 10:
		# Version 10 added the seasonal crops, the pond's other fish and forage. The cellar and the cooler hold
		# each kind apart now: an older save's cellar was all turnips ("crops") and its cooler all perch ("fish").
		# Its crops are all turnips, corn and pumpkins, which keep growing; any out of season wither the next morning.
		if not data.has("cellar"):
			data["cellar"] = {"crops": int(data.get("cellar_stock", 0))}
		if not data.has("cooler"):
			data["cooler"] = {"fish": int(data.get("cooler_stock", 0))}
	if v < 11:
		# Version 11 added the house extensions, furniture, paint and wallpaper and the land deed ("estate"), and
		# the farm stand's demand ("stand_glut"). An older save has none of them, which the loader's defaults give.
		pass
	if v < 12:
		# Version 12 moved the first trek into week one: Old Maren asks to be walked to the wood's edge from day 4
		# (TrekSystem.EDGE_DAY), the mill only after that, and the first Hollow sighting comes that night. A save
		# already past day 4, or that has walked anyone, has them done, so it neither replays them nor waits on
		# them for the mill; its story counts the new chapter as done too.
		var past := int(data.get("day", 1)) > TrekSystem.EDGE_DAY or int(data.get("treks_done", 0)) > 0
		if not data.has("trek_edge_done"):
			data["trek_edge_done"] = past
		if not data.has("sighting_seen"):
			data["sighting_seen"] = past
		var quests: Variant = data.get("quests_done")
		if past and typeof(quests) == TYPE_DICTIONARY:
			quests["edge"] = true
	if v < 13:
		# Version 13 made the nights played (NightSystem): which visitors have been met (for the prompts), the
		# shadow's blight on the ground, and the vicar's blessing. An older save has met each visitor as often as it
		# has faced any, so a player past the first few nights isn't prompted again; the rest starts empty.
		if not data.has("night_seen"):
			var old_stats: Variant = data.get("stats", {})
			var met := mini(int(old_stats.get("faced", 0)), 3) if typeof(old_stats) == TYPE_DICTIONARY else 0
			var seen_ids := {}
			for id in ["field", "first", "knock", "crows", "pond", "watcher", "footsteps", "hollow", "raid"]:
				seen_ids[id] = met
			data["night_seen"] = seen_ids
	if v < 14:
		# Version 14 made the walkers neighbours (FolkSystem): friendship, gifts, requests, scenes and farm visits.
		# Friendship counts the walks already made (trek_walked), so every walker keeps the standing they had; an
		# older save has met each walker it has walked, and Maren once she was walked to the wood's edge.
		if not data.has("folk"):
			var met: Array = []
			var walked: Variant = data.get("trek_walked", {})
			for id in FolkSystem.IDS:
				if typeof(walked) == TYPE_DICTIONARY and int(walked.get(id, 0)) > 0:
					met.append(id)
			if bool(data.get("trek_edge_done", false)) and not "mill" in met:
				met.append("mill")
			data["folk"] = {"met": met}
	if v < 15:
		# Version 15 added the second year's story and the endings (StoryAct). A save that has hung the bell has
		# the act closed quietly (no pages for beats it never saw), and one past the grove has reached the bell's
		# ending, recorded without its sequence. Any other save plays the beats from where it is: each comes on
		# its own day or the first morning after, so a save past those days isn't stuck.
		if not data.has("act"):
			var act := {}
			if int(data.get("bell_day", -1)) >= 0 or bool(data.get("trek_grove_done", false)):
				act["beats"] = {"letter": -1, "shown": -1, "orchard": -1, "knock": -1, "meeting": -1}
				act["meeting"] = "lost"
			if bool(data.get("trek_grove_done", false)):
				act["endings"] = {"bell": int(data.get("day", 1))}
			data["act"] = act
	# A save from a newer build keeps its number; keys this build doesn't know are ignored.
	data["save_version"] = maxi(v, SAVE_VERSION)
	return data


# Version 8 cut the wider land: the towns, the bank, the campsite, the Lowmere quests and the ranged weapons.
# Banked goods and coins come back to the pack and purse, a bow or crossbow is taken apart for what it cost,
# and arrows and bolts are dropped. A save made out in the land wakes at the homestead.
static func _migrate_world(data: Dictionary) -> void:
	var mats: Variant = data.get("materials")
	if typeof(mats) != TYPE_DICTIONARY:
		mats = {}
		data["materials"] = mats
	var banked: Variant = data.get("bank_materials")
	if typeof(banked) == TYPE_DICTIONARY:
		for key in banked:
			if typeof(banked[key]) in [TYPE_INT, TYPE_FLOAT] and int(banked[key]) > 0:
				mats[key] = int(mats.get(key, 0)) + int(banked[key])
	if typeof(data.get("bank_coins")) in [TYPE_INT, TYPE_FLOAT]:
		data["money"] = int(data.get("money", 0)) + int(data["bank_coins"])
	mats.erase("arrows")
	mats.erase("bolts")
	var eq: Variant = data.get("equipment")
	if typeof(eq) == TYPE_DICTIONARY:
		for slot in eq:
			var id := str(eq[slot])
			if CUT_WEAPONS.has(id):
				for key in CUT_WEAPONS[id]:
					mats[key] = int(mats.get(key, 0)) + int(CUT_WEAPONS[id][key])
				eq[slot] = ""
	if int(data.get("zone", 0)) != 0 and int(data.get("world_version", 0)) >= 1:
		var home := Vector2(MainGame.HOMESTEAD_ARRIVE) * MainGame.PX + Vector2.ONE * MainGame.PX * 0.5
		data["player_pos"] = [home.x, home.y]
		data["inside"] = false
	if str(data.get("open_tab", "")) in ["Shop", "Bank"]:
		data["open_tab"] = ""
	var stats: Variant = data.get("stats")
	if typeof(stats) == TYPE_DICTIONARY:
		for key in ["talks", "delivered", "stalkers", "visited", "crops_given"]:
			stats.erase(key)
	for key in WORLD_KEYS:
		data.erase(key)


static func write_save(path: String, data: Dictionary) -> bool:
	var tmp := temp_path(path)
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	# A save that can't be read back is never put in place.
	if read_save(tmp).is_empty():
		_remove(tmp)
		return false
	# Only a good save becomes the backup, so a damaged one never pushes the last good one out.
	if not read_save(path).is_empty() and not _move(path, backup_path(path)):
		return false
	return _move(tmp, path)


# Puts a readable save back at path before it's listed or loaded. Returns "" when the save is fine,
# "restored" when it came back from the backup, or "lost" when it was damaged and had no backup.
# A damaged file is kept as .broken.json, so the slot shows empty instead of failing to load.
static func recover(path: String) -> String:
	var tmp := temp_path(path)
	if not read_save(path).is_empty():
		_remove(tmp)
		return ""
	var damaged := FileAccess.file_exists(path)
	if damaged:
		_move(path, broken_path(path))
	# A save written out and read back but not yet moved into place is the newest one there is.
	if not read_save(tmp).is_empty() and _move(tmp, path):
		return ""
	_remove(tmp)
	if not read_save(backup_path(path)).is_empty():
		DirAccess.copy_absolute(ProjectSettings.globalize_path(backup_path(path)), ProjectSettings.globalize_path(path))
		return "restored"
	return "lost" if damaged else ""


# Removes a slot's save with its backup and any half-written copy, as when the farm is taken.
static func delete_save(path: String) -> void:
	for p in [path, backup_path(path), temp_path(path)]:
		_remove(p)


static func _move(from: String, to: String) -> bool:
	var a := ProjectSettings.globalize_path(from)
	var b := ProjectSettings.globalize_path(to)
	if DirAccess.rename_absolute(a, b) == OK:
		return true
	# Some systems won't rename over a file, so the old one is cleared first.
	DirAccess.remove_absolute(b)
	return DirAccess.rename_absolute(a, b) == OK


static func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
