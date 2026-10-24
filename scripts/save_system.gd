class_name SaveSystem
extends RefCounted

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
		"skill_xp": m.skill_xp,
		"inventory": m.inventory,
		"materials": m.materials,
		"stats": m.stats,
		"quests_done": m.quests_done,
		"tutorial_v2": true,
		"zone": m.zone,
		"world_version": 1,
		"campsite": [m.campsite.x, m.campsite.y],
		"hp": m.hp,
		"guardian_done": m.guardian_done,
		"equipment": m.equipment,
		"money": m.money,
		"bag_tier": m.bag_tier,
		"cellar_built": m.cellar_built,
		"cooler_built": m.cooler_built,
		"cellar_stock": m.cellar_stock,
		"cooler_stock": m.cooler_stock,
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
		"cleanse_day": m.cleanse_day,
		"event_fired_day": m.event_fired_day,
		"sanity": m.sanity,
		"sanity_penalty": m.sanity_penalty,
		"boredom_loss": m.boredom_loss,
		"entertained_day": m.entertained_day,
		"player_pos": _save_pos(),
		"inside": m.inside,
		"appearance": m.appearance,
		"open_tab": m.open_tab,
		"crops": m.farm._crops_to_array(),
		"brush": m._brush_to_array(),
		"brush_day": m.brush_day,
		"rock_day": m.rock_day,
		"felled": m._felled_to_array(),
		"rocks": m._tiles_to_array(m.rocks),
		"quarry": m._tiles_to_array(m.quarry),
		"tool_tier": m.tool_tier,
		"bank_materials": m.bank_materials,
		"bank_coins": m.bank_coins,
		"cave_mined": m._tiles_to_array(m.cave_mined),
		"cave_mined_day": m.cave_mined_day,
		"wear": m.wear,
		"coop_built": m.coop_built,
		"coop_x": m.coop_tile.x,
		"coop_y": m.coop_tile.y,
		"barn_built": m.barn_built,
		"barn_x": m.barn_tile.x,
		"barn_y": m.barn_tile.y,
		"hens": m.hens,
		"hens_fed_day": m.hens_fed_day,
		"hen_unfed_days": m.hen_unfed_days,
		"goats": m.goats,
		"goats_fed_day": m.goats_fed_day,
		"goat_unfed_days": m.goat_unfed_days,
		"hen_ages": m.hen_ages,
		"goat_ages": m.goat_ages,
		"tax_owed": m.tax_owed,
		"tax_due_day": m.tax_due_day,
		"tax_stage": m.tax_stage,
		"clean_nights": m.clean_nights,
		"desk_mail": m.desk_mail,
		"tips_seen": m.tips_seen.keys(),
	}
	var file := FileAccess.open(m._save_path(), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _load_game() -> bool:
	if not FileAccess.file_exists(m._save_path()):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(m._save_path()))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed

	m.day = int(data.get("day", 1))
	m.weather_kind = str(data.get("weather_kind", ""))
	m.food = float(data.get("food", 100.0))
	m.water = float(data.get("water", 100.0))
	m.warmth = float(data.get("warmth", 100.0))
	m.starve_timer = float(data.get("starve_timer", 0.0))
	m.well_repaired = bool(data.get("well_repaired", false))
	m.hose_attached = bool(data.get("hose_attached", false))
	m.well_water = float(data.get("well_water", 0.0))
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
	m.cleanse_day = int(data.get("cleanse_day", 0))
	m.money = int(data.get("money", 0))
	_merge_ints(m.bank_materials, data.get("bank_materials"))
	m.bank_coins = int(data.get("bank_coins", 0))
	m.bag_tier = int(data.get("bag_tier", 0))
	m.cellar_built = bool(data.get("cellar_built", false))
	m.cooler_built = bool(data.get("cooler_built", false))
	m.cellar_stock = int(data.get("cellar_stock", 0))
	m.cooler_stock = int(data.get("cooler_stock", 0))
	m.smokehouse_built = bool(data.get("smokehouse_built", false))
	m.furnace_built = bool(data.get("furnace_built", false))
	m.woodshed_built = bool(data.get("woodshed_built", false))
	m.firewood_store = int(data.get("firewood_store", 0))
	m.fire_hours = float(data.get("fire_hours", 0.0))
	m.saved_zone = int(data.get("zone", 0)) if int(data.get("world_version", 0)) >= 1 else 0
	var saved_camp: Variant = data.get("campsite", null)
	if typeof(saved_camp) == TYPE_ARRAY and saved_camp.size() == 2:
		m.campsite = Vector2i(int(saved_camp[0]), int(saved_camp[1]))
		m._apply_campsite()
	m.hp = int(data.get("hp", m.BASE_HP))
	m.guardian_done = data.get("guardian_done", {})
	var saved_eq: Variant = data.get("equipment", {})
	if typeof(saved_eq) == TYPE_DICTIONARY:
		for slot in m.equipment.keys():
			if saved_eq.has(slot):
				m.equipment[slot] = str(saved_eq[slot])
	m.event_fired_day = int(data.get("event_fired_day", 0))
	m.sanity_penalty = int(data.get("sanity_penalty", 0))
	m.boredom_loss = float(data.get("boredom_loss", 0.0))
	m.entertained_day = int(data.get("entertained_day", 0))
	m.sanity = float(data.get("sanity", m.SANITY_MAX))
	m.saved_inside = bool(data.get("inside", false))
	m.appearance = Appearance.clean(data.get("appearance", {}))
	m.saved_panel = str(data.get("open_tab", ""))
	var pos: Variant = data.get("player_pos", null)
	if typeof(pos) == TYPE_ARRAY and pos.size() == 2:
		m.saved_pos = Vector2(float(pos[0]), float(pos[1]))
		m.has_saved_pos = true

	# Rebuild the interior so the saved house stage shows the right rooms.
	# Crops and brush are restored here, after the map exists.
	m.crops.clear()
	for c in data.get("crops", []):
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
	for b in data.get("brush", []):
		m.brush[Vector2i(int(b[0]), int(b[1]))] = true
	for g in data.get("felled", []):
		m.grove_felled[Vector2i(int(g[0]), int(g[1]))] = true
	m._apply_grove()
	_merge_ints(m.tool_tier, data.get("tool_tier"))
	if data.has("rocks"):
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
	m.hens = int(data.get("hens", 0))
	m.hens_fed_day = int(data.get("hens_fed_day", -1))
	m.hen_unfed_days = int(data.get("hen_unfed_days", 0))
	m.goats = int(data.get("goats", 0))
	m.goats_fed_day = int(data.get("goats_fed_day", -1))
	m.goat_unfed_days = int(data.get("goat_unfed_days", 0))
	# Saves from before ages existed count the animals they had as already grown.
	m.hen_ages = m.animals._int_list(data["hen_ages"]) if data.has("hen_ages") else m.animals._filled(m.hens, m.HEN_MATURE_DAYS)
	m.goat_ages = m.animals._int_list(data["goat_ages"]) if data.has("goat_ages") else m.animals._filled(m.goats, m.GOAT_MATURE_DAYS)
	m.tax_owed = int(data.get("tax_owed", 0))
	m.tax_due_day = int(data.get("tax_due_day", 0))
	m.tax_stage = int(data.get("tax_stage", 0))
	m.clean_nights = int(data.get("clean_nights", 0))
	m.desk_mail = data.get("desk_mail", [])
	m.animals._sync_ages()
	if data.has("tips_seen"):
		m.tips_seen = {}
		for id in data["tips_seen"]:
			m.tips_seen[str(id)] = true
	else:
		# Saves from before tips existed have seen the tutorial already, so it doesn't flood them.
		for tip in m.TIPS:
			m.tips_seen[str(tip["id"])] = true
	if data.has("cave_mined"):
		m.cave_mined.clear()
		for c in data["cave_mined"]:
			m.cave_mined[Vector2i(int(c[0]), int(c[1]))] = true
	if data.has("quarry"):
		m.quarry.clear()
		for q in data["quarry"]:
			m.quarry[Vector2i(int(q[0]), int(q[1]))] = true
	else:
		m.mining._fill_quarry()
	return true


func _merge_ints(target: Dictionary, saved: Variant) -> void:
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for key in target.keys():
		if saved.has(key):
			target[key] = int(saved[key])
