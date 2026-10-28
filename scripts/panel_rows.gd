class_name PanelRows
extends RefCounted

# The row lists for the action bar's panels. Each one reads the game through `m`, the main
# scene, and returns plain dictionaries for the panel to draw. Nothing here changes game state.

var m: MainGame


func _init(main: Node) -> void:
	m = main


# The Pause menu: back to the farm, the settings, the controls, and the ways out.
# Each quit asks for a second press, since progress since the last sleep is lost.
func _pause_rows() -> Array:
	var title_armed: bool = m.pause_armed == "quit_title"
	var game_armed: bool = m.pause_armed == "quit_game"
	# One ledger tab with no status on the lines, so it reads as a plain menu. A quit that is waiting
	# for its second press says so in rust.
	var rows: Array = [
		{"tab": "Pause"},
		{"name": "Resume", "status": "", "value": "Back to the farm", "button": "Resume", "action": "resume", "enabled": true},
		{"name": "Settings", "status": "", "value": "Volume, screen, shake, messages", "button": "Open", "action": "open_settings", "enabled": true},
		{"name": "Controls", "status": "", "value": "Keyboard, mouse and gamepad", "button": "Open", "action": "open_controls", "enabled": true},
		{
			"name": "Unstick me",
			"status": "",
			"value": "Cancels any placement and moves you to the path outside the farmhouse door",
			"button": "Unstick",
			"action": "unstick",
			"enabled": true,
		},
		{
			"name": "Quit to the main menu",
			"status": "Press again" if title_armed else "",
			"status_kind": "short",
			"value": "Press again to quit. Progress since your last sleep is lost." if title_armed else "Returns to the start screen without saving. Progress since your last sleep is lost.",
			"button": "Yes, quit" if title_armed else "Quit",
			"action": "quit_title",
			"enabled": true,
		},
		{
			"name": "Quit the game",
			"status": "Press again" if game_armed else "",
			"status_kind": "short",
			"value": "Press again to close the game. Progress since your last sleep is lost." if game_armed else "Closes the game without saving. Progress since your last sleep is lost.",
			"button": "Yes, quit" if game_armed else "Quit",
			"action": "quit_game",
			"enabled": true,
		},
	]
	# Debug builds only, so a released game never shows it.
	if OS.is_debug_build():
		rows.append({
			"name": "Dev: unlock everything",
			"status": "",
			"value": "Every skill to level 10, coins, materials, every tool tier, the house and buildings (also F4)",
			"button": "Unlock",
			"action": "dev_unlock",
			"enabled": true,
		})
	return rows


# The diary: the first day's steps done and the next one, or the current chapter once the day is over,
# then a page for each tip, the newest first. Pages not read yet are marked new.
func _diary_rows() -> Array:
	if not m.diary_found:
		return [{"note": "Your diary is in the desk drawer, in the farmhouse bedroom."}]
	return [{"book": _diary_sections()}]


# The diary as a book: each section a tab marker down its side, each page {title, text, new, done, gap, hand}.
func _diary_sections() -> Array:
	var is_new := func(id: String) -> bool: return m.diary_new.has(id)
	var sections: Array = []
	var next := m._guide_step()
	if not next.is_empty():
		# The first day: a page for each step done, then the next one. Later steps stay hidden.
		var steps: Array = []
		for i in m.GUIDE.size():
			var step: Dictionary = m.GUIDE[i]
			var current := str(step["id"]) == str(next["id"])
			steps.append({"title": "%d of %d. %s" % [i + 1, m.GUIDE.size(), str(step["title"])],
				"text": m._fill_controls(str(step["text"])), "new": is_new.call(str(step["id"])), "done": not current})
			if current:
				break
		sections.append({"name": "First day", "heading": "The first day", "pages": steps})
	else:
		var chapter := m._current_chapter()
		var page := {"title": "Every chapter is done", "text": "The farm is yours."}
		if not chapter.is_empty():
			page = {"title": str(chapter["title"]), "text": "%s\n\n%s" % [str(chapter.get("story", "")), m._prompt_text(chapter)],
				"new": is_new.call("story")}
		sections.append({"name": "The farm asks", "heading": "What the farm asks", "pages": [page]})
	# Notes, in the order they were written.
	var notes: Array = []
	for id in m.tips_seen.keys():
		var tip := m._tip_data(str(id))
		if tip.has("id") and not str(id).begins_with("g_"):
			notes.append({"title": str(tip["title"]), "text": m._fill_controls(str(tip["text"])), "new": is_new.call(str(id))})
	if not notes.is_empty():
		sections.append({"name": "Notes", "heading": "Notes", "pages": notes})
	return sections + m.mystery._sections(is_new)


# The tab strip over Inventory, Gear and Skills, so LB/RB or Q/E step between them.
func _character_tabs(active: String) -> Dictionary:
	var tabs: Array = []
	for name in ["Inventory", "Gear", "Skills"]:
		tabs.append({"id": name, "name": name, "action": "section:" + name})
	return {"tabs": tabs, "active": active}


func _skill_rows() -> Array:
	var tiles: Array = []
	for skill in m.SKILLS:
		var info: Dictionary = m.SKILL_INFO[skill]
		tiles.append({
			"key": "skill:" + skill, "name": "%s\nLevel %d" % [skill, m.progression._level(skill)],
			"icon": str(info["icon"]), "tint": str(info["tint"]), "enabled": true, "costs": [], "level_ok": true,
			"desc": str(info["desc"]), "action": "",
		})
	var chosen := m._skill_chosen(tiles)
	var marked: Array = []
	for t in tiles:
		var tile: Dictionary = t.duplicate()
		tile["selected"] = str(t["key"]) == str(chosen["key"])
		tile["action"] = "skill_pick:" + str(t["key"])
		marked.append(tile)
	# The detail card shows the XP bar and what is left to the next level.
	var detail: Dictionary = chosen.duplicate()
	var skill := str(chosen["key"]).trim_prefix("skill:")
	var level := m.progression._level(skill)
	detail["name"] = skill
	detail["level_text"] = "Level %d. %d XP, %d more to level %d." % [level, int(m.skill_xp[skill]), m.progression._xp_for_level(level + 1) - int(m.skill_xp[skill]), level + 1]
	if level >= m.progression.LEVEL_CAP:
		detail["level_text"] = "Level %d, the highest. %d XP." % [level, int(m.skill_xp[skill])]
	detail["progress"] = m.progression._level_progress(skill)
	return [
		_character_tabs("Skills"),
		{"split": {"recipes": marked, "columns": 4, "detail": detail}},
		{"note": "Skills grow by doing. Each action gives XP to the skill it trains. Levels unlock recipes, crops, and tools."},
	]


func _inventory_rows() -> Array:
	var rows: Array = [_character_tabs("Inventory"), {"section": "Pack"}]
	var tiles := m._inventory_tiles()
	if tiles.is_empty():
		rows.append({"note": "Nothing in the pack yet. Harvest, catch, or gather to fill it."})
	else:
		var marked: Array = []
		var chosen := m._inventory_chosen(tiles)
		for t in tiles:
			var tile: Dictionary = t.duplicate()
			tile["selected"] = str(t["key"]) == str(chosen["key"])
			tile["action"] = "inv_pick:" + str(t["key"])
			tile["names_on_focus"] = true
			marked.append(tile)
		rows.append({"split": {"recipes": marked, "columns": 4, "detail": chosen}})
	rows.append({"name": "Coins", "value": str(m.money)})
	rows.append({
		"name": "Pack space",
		"value": "%d/%d" % [m.stall._pack_used(), m.stall._pack_capacity()],
		"progress": float(m.stall._pack_used()) / float(m.stall._pack_capacity()),
	})
	if m.bag_tier < m.BAG_TIERS.size():
		var tier: Dictionary = m.BAG_TIERS[m.bag_tier]
		rows.append({
			"name": "Next bag: %s (+%d slots)" % [tier["name"], tier["slots"]],
			"value": m.stall._price_text(tier),
			"button": "Upgrade",
			"action": "upgrade_bag",
			"enabled": m._can_upgrade_bag(),
		})
	rows.append({"note": "Crops, fish, meals, and preserved goods fill the pack. Seeds have their own pouch, and materials are uncapped for now."})
	rows.append({"section": "Body"})
	# Meters are rounded so the panel only rebuilds when a shown number changes.
	rows.append({"name": "Food", "progress": roundi(m.food) / 100.0})
	rows.append({"name": "Water", "progress": roundi(m.water) / 100.0})
	rows.append({"name": "Warmth", "progress": roundi(m.warmth) / 100.0})
	rows.append({"name": "Fire", "value": ("lit, about %d hours left" % ceili(m.fire_hours)) if m.firewood._fire_lit() else "out. Feed the hearth from the house with firewood."})
	rows.append({"name": "Outside", "value": "%d°F, %s" % [roundi(m._temperature()), str(m.WEATHER_NAMES.get(m.weather_kind, "Overcast")).to_lower()]})
	rows.append({"note": "Food and water drain through the day. Drink from the pond or the pump to refill water. Warmth drains outdoors on cold days, refills in the house, and is full again after a night's sleep. An empty need costs HP."})
	rows.append({"section": "Planting"})
	rows.append({"name": "Planting with", "value": "%s (grows in %s)" % [m.farm._seed_label(m.selected_seed), m.farm._seasons_text(m.selected_seed)]})
	var growing := m.crops.size()
	if growing > 0:
		rows.append({"name": "Watered today", "value": "%d of %d growing crops" % [m.farm._watered_today(), growing], "progress": float(m.farm._watered_today()) / float(growing)})
	var kinds: Array = m.farm._unlocked_kinds().filter(func(k) -> bool: return m.farm._in_season(k))
	if kinds.size() > 1:
		var labels: Array = []
		for kind in kinds:
			labels.append(m.farm._seed_label(kind))
		rows.append({
			"name": "Switch seed",
			"value": ", ".join(labels.slice(0, -1)) + " or " + str(labels[-1]),
			"button": "Switch",
			"action": "switch_seed",
			"enabled": true,
		})
	return rows


func _gear_rows() -> Array:
	var tiles := m.crafting._gear_tiles()
	var chosen := m.crafting._gear_chosen(tiles)
	var marked: Array = []
	for t in tiles:
		var tile: Dictionary = t.duplicate()
		tile["selected"] = str(t["key"]) == str(chosen["key"])
		tile["action"] = "gear_pick:" + str(t["key"])
		marked.append(tile)
	return [
		_character_tabs("Gear"),
		{"split": {"recipes": marked, "figure": true, "detail": chosen}},
		{"name": "Defense", "value": str(m._defense())},
		{"name": "Hit damage", "value": str(m.combat_sys._weapon_damage())},
		{"note": "Worn gear sets your defense, and your main hand sets how hard you hit. Crafting a piece equips it at once and swaps out what was in that slot. Press C for the Craft panel."},
	]


func _craft_rows() -> Array:
	var tabs: Array = []
	for tab in m.CRAFT_TABS:
		tabs.append({"id": tab["id"], "name": tab["name"], "action": "craft_tab:" + str(tab["id"])})
	var rows: Array = [{"tabs": tabs, "active": m.craft_tab}]
	var recipes := m.crafting._craft_recipes()
	var chosen := m.crafting._chosen_recipe(recipes)
	if recipes.is_empty():
		rows.append({"note": "Nothing to make here yet."})
	else:
		var tiles: Array = []
		for r in recipes:
			var tile: Dictionary = r.duplicate()
			tile["selected"] = not chosen.is_empty() and r["key"] == chosen["key"]
			tile["action"] = "craft_pick:" + str(r["key"])
			tiles.append(tile)
		rows.append({"split": {"recipes": tiles, "columns": 4, "detail": chosen}})
	rows.append({"note": m.crafting._craft_footer()})
	return rows


# The Quests panel: the story's chapters, then the Folk tab (FolkSystem._rows): the walkers' friendship,
# gifts and requests. The current chapter comes first, and the detail page tells its story.
func _quest_rows() -> Array:
	var rows: Array = [{"tab": "Story"}]
	rows.append_array(_quest_list(m.STORY, m.quests_done, "You have reached the end of the story for now. More chapters are coming."))
	rows.append_array(m.folk._rows())
	return rows


func _quest_list(quests: Array, done: Variant, all_done: String) -> Array:
	var rows: Array = []
	var current: Variant = null
	for q in quests:
		if not done.has(q["id"]):
			current = q
			break
	if current != null:
		rows.append({"section": "Current chapter"})
		rows.append(_quest_entry(current, done, true))
	else:
		rows.append({"note": all_done})
	rows.append({"section": "Chapters"})
	for q in quests:
		rows.append(_quest_entry(q, done, false))
	return rows


func _quest_entry(q: Dictionary, done_ids: Variant, current: bool) -> Dictionary:
	var done: bool = done_ids.has(q["id"])
	var shown := mini(m.progression._stat_value(q["stat"]), int(q["goal"]))
	return {
		"name": str(q["title"]),
		"status": "Done" if done else "%d / %d" % [shown, int(q["goal"])],
		"status_kind": "done" if done else ("ok" if current else "info"),
		"about": str(q.get("story", "")) if current else "",
		"value": str(q["text"]),
		"note": "Reward: %s" % m.progression._reward_text(q["reward"]),
		"progress": float(shown) / float(q["goal"]),
	}


# What a cost asks for, one line each, marked have or short, for the ledger's detail pane.
# skill is the skill the cost's "level" is for; level overrides it when the cost has none.
func _needs(cost: Dictionary, skill: String, level: int = 0) -> Array:
	var out: Array = []
	var keys: Array = cost.keys()
	keys.sort_custom(func(a, b): return a == "coins" and b != "coins")
	for key in keys:
		if key in ["level", "season"] or int(cost[key]) <= 0:
			continue
		var held: int = m._held(str(key))
		out.append({"text": "%d %s" % [int(cost[key]), _need_label(str(key))], "have": held, "ok": held >= int(cost[key])})
	var lvl := int(cost.get("level", level))
	if skill != "" and lvl > 0:
		var now: int = m.progression._level(skill)
		out.append({"text": "%s %d" % [skill, lvl], "have": now, "ok": now >= lvl})
	if cost.has("season"):
		var season: String = m._season_of(m._calendar_date(m.day)["month"])
		out.append({"text": "Only in %s" % str(cost["season"]).to_lower(), "ok": season == str(cost["season"])})
	return out


func _need_label(key: String) -> String:
	if key == "seeds":
		return "turnip seeds"
	if key == "feathers":
		return "crow feathers"
	return key.replace("_", " ")


# The House panel, in four tabs: the house itself, the day's chores, storage, and what each repair unlocks.
func _house_rows() -> Array:
	var rows: Array = [{"tab": "Home", "icon": "house"}]
	var next_feature := ""
	for feature in m.HOUSE_FEATURES:
		if int(feature["stage"]) == m.house_stage + 1:
			next_feature = str(feature["text"])
	rows.append({"name": "Farmhouse", "status": m.STAGE_NAMES[m.house_stage], "value": "Repair stage %d of %d." % [m.house_stage, m.MAX_STAGE],
		"note": "The next repair brings: %s." % next_feature if next_feature != "" else "Fully restored."})
	if m.house_stage < m.MAX_STAGE:
		var cost: Dictionary = m.REPAIR_COSTS[m.house_stage]
		rows.append({
			"name": "Repair to %s" % m.STAGE_NAMES[m.house_stage + 1],
			"value": "%d wood, %d fiber, Carpentry %d%s" % [cost["wood"], cost["fiber"], cost["level"], (", in %s" % str(cost["season"]).to_lower()) if cost.has("season") else ""],
			"about": "Unlocks: %s." % next_feature if next_feature != "" else "",
			"needs": _needs(cost, "Carpentry"),
			"note": "The paint needs a dry season, so this repair can only be done in summer." if cost.has("season") else "",
			"button": "Repair",
			"action": "repair",
			"enabled": m._can_repair(),
		})
	rows.append({"name": "Wear", "status": "%d / %d" % [m.wear, m.WEAR_MAX], "status_kind": "short" if m.wear >= m.WEAR_RUNDOWN else "info",
		"progress": float(m.wear) / float(m.WEAR_MAX),
		"note": "The house wears a little each night. Mending, tidying, and repairs bring it down. At %d wear, rain ruins a crop overnight. At %d, foxes and worse come to the coop and barn more often at night. A third plot opens at Farming %d once the house is Patched." % [m.WEAR_RUNDOWN, m.WEAR_FOX, m.PLOT_THREE_LEVEL]})
	rows.append({"name": "Sanity limit", "status": "%d / %d" % [m.sanity_sys._sanity_max(), int(m.SANITY_MAX)],
		"progress": float(m.sanity_sys._sanity_max()) / float(m.SANITY_MAX),
		"note": "The bed is in the bedroom. Walk there and press Space from 18:00 to save and end the day. If you aren't in bed by 03:00 you collapse, and your sanity limit drops permanently."})
	var cleanse_needs := _needs({"crops": m.CLEANSE_CROPS, "level": m.CLEANSE_LEVEL}, "Cleaning")
	cleanse_needs.append({"text": "Once a day", "ok": m.cleanse_day != m.day})
	cleanse_needs.append({"text": "Some of the limit lost", "ok": m.sanity_penalty > 0})
	rows.append({
		"name": "Cleanse the house",
		"value": "%d crops, Cleaning %d, once a day: +%d limit" % [m.CLEANSE_CROPS, m.CLEANSE_LEVEL, m.CLEANSE_RELIEF],
		"about": "Burn an offering of crops to win back %d of the sanity limit." % m.CLEANSE_RELIEF,
		"needs": cleanse_needs,
		"button": "Cleanse",
		"action": "cleanse",
		"enabled": m.sanity_sys._can_cleanse(),
	})
	# The vicar's blessing, only on a day he waits at the gate (sanity under SanitySystem.BLESS_BELOW at waking).
	if m.sanity_sys.bless_offer_day == m.day:
		var ss := m.sanity_sys
		rows.append({
			"name": "The vicar's blessing",
			"value": "%d crops for the poor box: +%d sanity, +%d limit, tonight halved" % [ss.BLESS_CROPS, int(ss.BLESS_SANITY), ss.BLESS_LIMIT],
			"about": "The vicar waits at the gate today. He will walk the rooms and bless the house.",
			"needs": _needs({"crops": ss.BLESS_CROPS}, "Cleaning") + [{"text": "Once", "ok": ss.bless_day != m.day}],
			"button": "Bless",
			"action": "bless",
			"enabled": ss._can_bless(),
		})

	rows.append({"tab": "Chores", "icon": "chores"})
	for chore in m._chore_list():
		var row := {"name": chore["name"], "value": str(chore["detail"])}
		if bool(chore["done"]):
			row["status"] = "Done"
			row["status_kind"] = "done"
		elif str(chore["action"]) != "":
			row["button"] = chore["button"]
			row["action"] = chore["action"]
			row["enabled"] = chore["enabled"]
		else:
			row["status"] = "Not yet"
			row["status_kind"] = "short"
		rows.append(row)
	if not m._chore_list().any(func(c: Dictionary) -> bool: return c["action"] == "mend"):
		rows.append({"name": "Mend a board", "value": "Not due until wear %d. It still trains Carpentry. %d left today" % [m.MEND_DUE_WEAR, m._mends_left()],
			"button": "Mend", "action": "mend", "enabled": m._can_mend()})
	rows.append({"note": "Each chore left undone adds 1 wear overnight. A night with every chore done brings back %d sanity; a night with none due keeps the streak as it is." % m.WELL_KEPT_SANITY})
	for job_row in _job_rows():
		if job_row.has("name") and m.job_done_day == m.day:
			job_row["status"] = "Done"
			job_row["status_kind"] = "done"
		rows.append(job_row)

	rows.append({"tab": "Storage", "icon": "storage"})
	if m.cellar_built:
		rows.append({"name": "Root cellar", "status": "Built", "status_kind": "done", "value": "built, holds %d crops. Stand beside it, facing it, and press Space." % m.estate._cellar_cap()})
	else:
		rows.append({
			"name": "Build a root cellar",
			"value": m.stall._price_text(m.CELLAR_COST),
			"about": "Holds %d crops, against the house's west wall." % m.estate._cellar_cap(),
			"needs": _needs(m.CELLAR_COST, "Carpentry"),
			"button": "Build",
			"action": "build_cellar",
			"enabled": m._can_afford(m.CELLAR_COST),
		})
	if m.cooler_built:
		rows.append({"name": "Cooler", "status": "Built", "status_kind": "done", "value": "built, keeps %d fish fresh. Stand beside it, facing it, and press Space." % m.COOLER_CAP})
	else:
		rows.append({
			"name": "Build a cooler",
			"value": m.stall._price_text(m.COOLER_COST),
			"about": "Keeps %d fish fresh, inside the house." % m.COOLER_CAP,
			"needs": _needs(m.COOLER_COST, "Carpentry"),
			"button": "Build",
			"action": "build_cooler",
			"enabled": m._can_afford(m.COOLER_COST),
		})
	rows.append({"note": "The workshop, the coop, and the barn are in the Buildings section on the section wheel (Shift)."})

	rows.append({"tab": "Features", "icon": "features"})
	for feature in m.HOUSE_FEATURES:
		var unlocked: bool = m.house_stage >= feature["stage"]
		rows.append({
			"name": m.STAGE_NAMES[feature["stage"]],
			"value": str(feature["text"]),
			"status": "Unlocked" if unlocked else "At %s" % m.STAGE_NAMES[feature["stage"]],
			"status_kind": "done" if unlocked else "info",
		})
	return rows


# The coop panel: the hens are fed here. They are ordered from the catalog at the desk.
func _coop_rows() -> Array:
	var rows: Array = [{"tab": "Hens"}]
	rows.append({
		"name": "Hens",
		"value": "%d of %d, order more from the catalog at the desk" % [m.hens, m.COOP_HENS_MAX],
	})
	rows.append({
		"name": "Feed hens",
		"value": "%d crops, once a day" % (m.hens * m.HEN_FEED_CROPS),
		"button": "Feed",
		"action": "feed_hens",
		"enabled": m.animals._can_feed_hens(),
	})
	rows.append(_hopper_row("coop"))
	rows.append({"name": "Grown hens", "value": "%d of %d, %d coins each" % [m.animals._grown_count(m.hen_ages, m.HEN_MATURE_DAYS), m.hens, m.HEN_SELL], "button": "Sell a hen", "action": "sell_hen", "enabled": m.animals._grown_count(m.hen_ages, m.HEN_MATURE_DAYS) > 0})
	rows.append({"note": "A grown hen (%d nights) lays an egg each morning when fed, kept as a meal or sold at the farm stand. Young hens do not lay. Two unfed days in a row and a hen wanders off. A filled hopper feeds them on the days you don't." % m.HEN_MATURE_DAYS})
	return rows


# The feed hopper in the coop or the barn: built once, then filled with crops from the pack.
func _hopper_row(which: String) -> Dictionary:
	var a: AnimalSystem = m.animals
	var animal := "hens" if which == "coop" else "goats"
	if not a._hopper_built(which):
		var cost := a._hopper_cost(which)
		return {"name": "Feed hopper", "value": m.stall._price_text(cost),
			"about": "Holds %d crops and feeds the %s each night you don't feed them by hand." % [m.HOPPER_CAP, animal],
			"needs": _needs(cost, "Carpentry"), "button": "Build", "action": "build_hopper:" + which, "enabled": a._can_build_hopper(which)}
	var need := a._hopper_need(which)
	var days := ", about %d days" % (a._hopper_stock(which) / need) if need > 0 else ""
	return {"name": "Feed hopper", "value": "%d of %d crops%s" % [a._hopper_stock(which), m.HOPPER_CAP, days],
		"progress": float(a._hopper_stock(which)) / float(m.HOPPER_CAP),
		"button": "Fill", "action": "fill_hopper:" + which, "enabled": a._can_fill_hopper(which)}


# The barn panel: the goats are fed here. They are ordered from the catalog at the desk.
func _barn_rows() -> Array:
	var rows: Array = [{"tab": "Goats"}]
	rows.append({
		"name": "Goats",
		"value": "%d of %d, order more from the catalog at the desk" % [m.goats, m.BARN_GOATS_MAX],
	})
	rows.append({
		"name": "Feed goats",
		"value": "%d crops, once a day" % (m.goats * m.GOAT_FEED_CROPS),
		"button": "Feed",
		"action": "feed_goats",
		"enabled": m.animals._can_feed_goats(),
	})
	rows.append(_hopper_row("barn"))
	rows.append({"name": "Grown goats", "value": "%d of %d, %d coins each" % [m.animals._grown_count(m.goat_ages, m.GOAT_MATURE_DAYS), m.goats, m.GOAT_SELL], "button": "Sell a goat", "action": "sell_goat", "enabled": m.animals._grown_count(m.goat_ages, m.GOAT_MATURE_DAYS) > 0})
	rows.append({"note": "A grown goat (%d nights) gives milk each morning when fed, kept to drink or sold at the farm stand. Young goats do not give milk. Two unfed days in a row and a goat wanders off. A filled hopper feeds them on the days you don't." % m.GOAT_MATURE_DAYS})
	return rows


# The Buildings section, in tabs: the homestead ladder, the workshop, the animals' buildings, decor,
# the crow bell's parts until the bell is hung, and the trail works once walkers come.
func _buildings_rows() -> Array:
	var p: FarmProjects = m.projects
	var rows: Array = [{"tab": "Homestead", "icon": "homestead"}]
	var nxt := p._next_step()
	var total := p._steps().size()
	rows.append({"name": "Progress", "status": "%d / %d" % [p.steps_done.size(), total],
		"value": "%d of %d steps done" % [p.steps_done.size(), total],
		"progress": float(p.steps_done.size()) / float(maxi(1, total)),
		"note": "Each step done pays %d coins and names the next." % p.STEP_COINS})
	if nxt.is_empty():
		rows.append({"note": "Every step is done. The farm is yours."})
	else:
		rows.append({"name": "Next: %s" % nxt["title"], "status": "Next", "value": str(nxt["how"])})

	rows += _estate_rows()

	rows.append({"tab": "Workshop", "icon": "workshop"})
	if m._is_built("workshop"):
		var shop: Dictionary = m._placed_row("Workshop", "workshop", m.workshop_tile, "move_workshop")
		shop["status"] = "Placed"
		rows.append(shop)
	rows.append(_build_row("smokehouse", "Smokehouse", m.smokehouse_built, m.SMOKEHOUSE_COST,
		"Smokes and preserves food.", "built. Stand beside it, facing it, and press Space to preserve food.", true))
	rows.append(_build_row("furnace", "Furnace", m.furnace_built, m.FURNACE_COST,
		"Smelts ore into bars.", "built. Stand beside it, facing it, and press Space to smelt ore.", true))
	var wood_row := _build_row("woodshed", "Firewood store and chopping log", m.woodshed_built, m.WOODSHED_COST,
		"Stores firewood, and a log to split wood on.", "built in the workshop. Stand beside them to store firewood or split wood.", m.smokehouse_built or m.furnace_built)
	if not m.woodshed_built:
		wood_row["needs"].append({"text": "The smokehouse or furnace first", "ok": m.smokehouse_built or m.furnace_built})
	rows.append(wood_row)
	if m._is_built("workshop"):
		rows.append({"note": "The workshop is a walled building, %d by %d, with its door on the south side. Move it any time from here; everything in it goes along." % [m.WORKSHOP_SIZE.x, m.WORKSHOP_SIZE.y]})
	else:
		rows.append({"note": "The first of the smokehouse or furnace comes with the workshop: you choose where it stands, on %d by %d open grass." % [m.WORKSHOP_SIZE.x, m.WORKSHOP_SIZE.y]})

	rows.append({"tab": "Animals", "icon": "animals"})
	if m.coop_built:
		var coop: Dictionary = m._placed_row("Coop", "coop", m.coop_tile, "move_coop")
		coop["status"] = "Placed" if m.coop_tile.x >= 0 else "Not placed"
		rows.append(coop)
	else:
		rows.append({"name": "Coop", "value": m.stall._price_text(m.COOP_COST), "about": "Holds %d hens. Order hens from the catalog at the desk." % m.COOP_HENS_MAX,
			"needs": _needs(m.COOP_COST, "Carpentry"), "button": "Build", "action": "build_coop", "enabled": m._can_build("coop")})
	if m.barn_built:
		var barn: Dictionary = m._placed_row("Barn", "barn", m.barn_tile, "move_barn")
		barn["status"] = "Placed" if m.barn_tile.x >= 0 else "Not placed"
		rows.append(barn)
	else:
		rows.append({"name": "Barn", "value": m.stall._price_text(m.BARN_COST), "about": "For livestock. Order goats from the catalog at the desk.",
			"needs": _needs(m.BARN_COST, "Carpentry"), "button": "Build", "action": "build_barn", "enabled": m._can_build("barn")})
	rows.append({"note": "Each one is placed on open grass. Move it any time from here."})

	rows.append({"tab": "Decor", "icon": "decor"})
	for kind in ["lamp", "flowers", "path", "fence", "sprinkler", "sprinkler_big", "apple_tree", "bench", "birdbath", "weathervane", "bell"]:
		var d: Dictionary = p.DECOR[kind]
		var have := p._count(kind)
		var row := {"name": str(d["name"]), "about": str(d["desc"]), "value": p._cost_text(kind)}
		if have >= int(d["max"]):
			row["status"] = "%d placed" % have if kind != "bell" else "Hung"
			row["status_kind"] = "done"
			row["value"] = "as many as there's room for"
			rows.append(row)
			continue
		var needs := _needs(d["cost"], str(d["skill"]), int(d["level"]))
		if kind == "flowers":
			needs.append({"text": "In spring or summer", "ok": p._season() in ["Spring", "Summer"]})
		if kind == "bell":
			needs.append({"text": "On All Hallows (October 31)", "ok": p._bell_night()})
		row["needs"] = needs
		if have > 0:
			row["status"] = "%d placed" % have
		row["button"] = "Place"
		row["action"] = "decor:" + kind
		row["enabled"] = p._can_place(kind)
		rows.append(row)
	rows.append({"note": "Face something you placed and press Space twice to take it down and get its materials back."})

	if not p._has_bell():
		rows.append({"tab": "Crow bell", "icon": "bell"})
		for id in p.BELL_PARTS:
			var part: Dictionary = p.BELL_PARTS[id]
			var why := p._part_why(id)
			var row := {"name": str(part["name"]), "about": str(part["desc"]),
				"value": "%s, %s %d" % [p._cost_list(part["cost"]), part["skill"], int(part["level"])]}
			if why == "made":
				row["status"] = "Made"
				row["status_kind"] = "done"
			else:
				var needs := _needs(part["cost"], str(part["skill"]), int(part["level"]))
				if str(part["season"]) != "":
					needs.append({"text": "Only in %s" % str(part["season"]).to_lower(), "ok": p._season() == str(part["season"])})
				if id == "bell_metal":
					needs.append({"text": "The furnace", "ok": m.furnace_built})
				row["needs"] = needs
				row["button"] = "Make"
				row["action"] = "bellpart:" + id
				row["enabled"] = why == ""
			rows.append(row)
		var clapper := {"name": "Old clapper", "about": "The vicar kept the old bell's clapper when he cut it down. Walk him to the chapel on the hill and he gives it to you.",
			"value": "a chapel trek, from summer, Bushcrafting %d" % int(TrekSystem.ROUTES["chapel"]["level"])}
		if int(m.materials["bell_clapper"]) > 0:
			clapper["status"] = "Given"
			clapper["status_kind"] = "done"
		else:
			clapper["status"] = "With the vicar"
		rows.append(clapper)
		rows.append({"note": "With the three parts and the clapper, place the bell from Decor on All Hallows (October 31). The Hollow comes to it that night."})

	if m.day >= TrekSystem.FROM_DAY:
		rows.append({"tab": "Trail works", "icon": "lantern"})
		for id in TrekSystem.WORKS:
			var w: Dictionary = TrekSystem.WORKS[id]
			var why: String = m.trek._work_why(id)
			var row := {"name": str(w["name"]), "about": str(w["about"]), "value": p._cost_list(w["cost"])}
			if why == "built":
				row["status"] = "Built"
				row["status_kind"] = "done"
				row["value"] = str(w["built"])
			else:
				var needs := _needs(w["cost"], "")
				var r: Dictionary = TrekSystem.ROUTES[w["route"]]
				needs.append({"text": "The way to %s open" % r["to"], "ok": m.day >= int(r["from"])})
				row["needs"] = needs
				row["button"] = "Build"
				row["action"] = "work:" + id
				row["enabled"] = why == ""
			rows.append(row)
		rows.append({"note": "Each work is built once, from when its route opens, and eases every trek after."})
		# The walkers, and what each gives once they know you.
		rows.append({"section": "Walkers"})
		for id in TrekSystem.STANDING:
			var s: Dictionary = TrekSystem.STANDING[id]
			var n := int(m.trek.walked.get(id, 0))
			var h: int = m.folk._hearts(id)
			var row := {"name": m.trek._cap(str(TrekSystem.ROUTES[id]["walker"])), "about": str(s["about"]),
				"value": "walked %d time%s, %d heart%s of friendship (Quests, Folk)" % [n, "" if n == 1 else "s", h, "" if h == 1 else "s"]}
			if h >= int(s["at"]):
				row["status"] = "Knows you"
				row["status_kind"] = "done"
			else:
				row["status"] = "%d more heart%s" % [int(s["at"]) - h, "" if int(s["at"]) - h == 1 else "s"]
			rows.append(row)
	return rows


# The house extensions, then the furniture, the paint and the wallpaper (EstateSystem).
func _estate_rows() -> Array:
	var e: EstateSystem = m.estate
	var rows: Array = [{"tab": "Extensions", "icon": "homestead"}]
	for id in e.EXTENSIONS:
		var x: Dictionary = e.EXTENSIONS[id]
		var why := e._why(id)
		var row := {"name": str(x["name"]), "about": e._about(id), "value": m.stall._price_text(x["cost"])}
		if why == "built":
			row["status"] = "Built"
			row["status_kind"] = "done"
			row["value"] = e._built_text(id)
		else:
			var needs := _needs(x["cost"], "Carpentry")
			needs.append({"text": "The house %s" % str(m.STAGE_NAMES[int(x["stage"])]), "ok": m.house_stage >= int(x["stage"])})
			if id == "cellar_room":
				needs.append({"text": "The root cellar", "ok": m.cellar_built})
			if x.has("after"):
				needs.append({"text": "The %s" % str(e.EXTENSIONS[x["after"]]["name"]).to_lower(), "ok": e._has(str(x["after"]))})
			row["needs"] = needs
			row["button"] = "Build"
			row["action"] = "ext:" + id
			row["enabled"] = why == ""
		rows.append(row)
	rows.append({"note": "Each extension adds %d%% to the property value, until the land deed is bought." % int(e.EXTENSION_VALUE * 100)})

	rows.append({"tab": "Furnishing", "icon": "decor"})
	rows.append({"section": "Furniture"})
	for id in e.FURNITURE:
		var f: Dictionary = e.FURNITURE[id]
		var why := e._furniture_why(id)
		var row := {"name": str(f["name"]), "about": "%s +%d sanity each morning." % [f["about"], int(e.COMFORT_SANITY)], "value": m.projects._cost_list(f["cost"])}
		if why == "bought":
			row["status"] = "In the house"
			row["status_kind"] = "done"
		else:
			var needs := _needs(f["cost"], "")
			if int(f["stage"]) > 0:
				needs.append({"text": "The house %s" % str(m.STAGE_NAMES[int(f["stage"])]), "ok": m.house_stage >= int(f["stage"])})
			row["needs"] = needs
			row["button"] = "Buy"
			row["action"] = "furn:" + id
			row["enabled"] = why == ""
		rows.append(row)
	rows.append({"section": "Outside paint (%s)" % m.projects._cost_list(e.PAINT_COST)})
	for id in e.PAINTS:
		var why := e._paint_why(id)
		var row := {"name": str(e.PAINTS[id]["name"]), "value": "the house's colour now" if why == "current" else "from the Restored stage"}
		if why == "current":
			row["status"] = "Painted"
			row["status_kind"] = "done"
		else:
			row["needs"] = _needs(e.PAINT_COST, "") + [{"text": "The house Restored", "ok": m.house_stage >= 3}]
			row["button"] = "Paint"
			row["action"] = "paint:" + id
			row["enabled"] = why == ""
		rows.append(row)
	rows.append({"section": "Wallpaper (%s)" % m.projects._cost_list(e.PAPER_COST)})
	for id in e.PAPERS:
		var why := e._paper_why(id)
		var row := {"name": str(e.PAPERS[id]["name"]), "value": "on the walls now" if why == "current" else "from the Patched stage"}
		if why == "current":
			row["status"] = "Hung"
			row["status_kind"] = "done"
		else:
			row["needs"] = _needs(e.PAPER_COST, "") + [{"text": "The house Patched", "ok": m.house_stage >= 2}]
			row["button"] = "Hang"
			row["action"] = "paper:" + id
			row["enabled"] = why == ""
		rows.append(row)
	return rows


# A workshop building: built, or what it costs. needs_ok is false while another building must come first.
func _build_row(id: String, label: String, built: bool, cost: Dictionary, about: String, built_text: String, needs_ok: bool) -> Dictionary:
	if built:
		return {"name": label, "status": "Built", "status_kind": "done", "value": built_text}
	return {"name": label, "about": about, "value": m.stall._price_text(cost), "needs": _needs(cost, "Carpentry"),
		"button": "Build", "action": "build_" + id, "enabled": m._can_afford(cost) and needs_ok}


# The controls list, shown from the Pause menu and the start screen.
func _controls_rows() -> Array:
	return [
		{"section": "Keyboard"},
		{"name": "Move", "value": "WASD or arrow keys"},
		{"name": "Talk, sleep, open panels, gather, drink, plant with hands", "value": "Space"},
		{"name": "Cycle the seed you plant (with the trowel)", "value": "Z and X"},
		{"name": "Use the tool or weapon in hand: hoe, hose, trowel, axe, pick, rod, sword", "value": "Left click"},
		{"name": "Bag (Inventory is in the bag)", "value": "Tab"},
		{"name": "Section wheel: Skills, Gear, Craft, Quests, House, Buildings, Achievements", "value": "Shift, then the mouse"},
		{"name": "Pause menu: resume, settings, controls, quit", "value": "Esc"},
		{"name": "Close the open section, the wheel, or the bag", "value": "B or Esc"},
		{"name": "Next or previous tab in a section", "value": "E and Q"},
		{"section": "Gamepad"},
		{"name": "Move", "value": "Left stick or D-pad"},
		{"name": "Talk, sleep, open panels, gather, drink, plant with hands", "value": "A"},
		{"name": "Use the tool or weapon in hand: hoe, hose, trowel, axe, pick, rod, sword", "value": "RT"},
		{"name": "Close the open section, the wheel, or the bag", "value": "B"},
		{"name": "Next or previous tab in a section", "value": "RB and LB"},
		{"name": "Bag (Inventory is in the bag)", "value": "Y"},
		{"name": "Section wheel", "value": "Left stick click, then left stick and A"},
		{"name": "Pause menu", "value": "Start"},
		{"note": "While a panel is open, the D-pad or left stick moves between its entries, A presses the highlighted one, and LB and RB switch tabs."},
		{"section": "Saving"},
		{"name": "When the game saves", "value": "Progress saves only when you sleep, or when you collapse at 03:00. The save includes your position and open panel."},
	]


# Settings and Controls share their rows with the start screen, which shows headings. In the game
# each heading becomes a ledger tab, and each line shows its value on the right.
func _as_tabs(rows: Array) -> Array:
	var out: Array = []
	for row in rows:
		var copy: Dictionary = row.duplicate()
		if copy.has("section"):
			out.append({"tab": str(copy["section"])})
			continue
		if copy.has("name") and not copy.has("status") and str(copy.get("value", "")).length() <= 40:
			copy["status"] = str(copy.get("value", ""))
			copy["status_kind"] = "info"
		out.append(copy)
	return out


# The desk, in tabs: the post and the diary, the property tax, pastimes, and the catalog.
func _desk_rows() -> Array:
	var rows: Array = [{"tab": "Post", "icon": "post"}]
	var diary_new := not m.diary_new.is_empty()
	rows.append({"name": "Your diary", "status": "New page" if diary_new else "", "status_kind": "ok",
		"value": "a new page to read" if diary_new else "what you have learned, and what to do next",
		"button": "Read", "action": "diary", "enabled": true})
	for letter in m.desk_mail:
		rows.append({"name": str(letter["title"]), "status": "New" if bool(letter["unread"]) else "Read",
			"status_kind": "ok" if bool(letter["unread"]) else "done", "value": str(letter["text"])})
	if m.desk_mail.is_empty():
		rows.append({"note": "No post. The mail slot in the front door drops letters here."})
	else:
		rows.append({"name": "Put letters away", "value": "read letters go in the drawer", "button": "Clear", "action": "mail_clear", "enabled": m.desk._has_read_mail()})

	rows.append({"tab": "Tax", "icon": "coins"})
	rows.append({"name": "Property value", "status": "%d a quarter" % m.desk._property_value(), "value": m.desk._property_text()})
	rows.append({"name": "Property tax", "status": "Owed" if m.tax_owed > 0 else "Paid up", "status_kind": "short" if m.tax_owed > 0 else "done",
		"value": m.desk._tax_text(), "needs": [{"text": "%d coins" % m.tax_owed, "have": m.money, "ok": m.money >= m.tax_owed}] if m.tax_owed > 0 else [],
		"button": "Pay", "action": "pay_tax", "enabled": m.tax_owed > 0 and m.money >= m.tax_owed})
	var deed_why := m.estate._deed_why()
	var deed := {"name": "Land deed", "about": "Buy the farm outright from the town, %d coins at a time. Once it is paid, no tax is owed again." % m.estate.DEED_STEP,
		"value": m.estate._deed_text(), "progress": float(m.estate.deed_paid) / float(m.estate.DEED_PRICE)}
	if deed_why == "owned":
		deed["status"] = "Yours"
		deed["status_kind"] = "done"
	else:
		deed["status"] = "%d / %d" % [m.estate.deed_paid, m.estate.DEED_PRICE]
		deed["needs"] = [{"text": "The house Patched", "ok": m.estate._deed_open()}, {"text": "%d coins" % m.estate._deed_step(), "have": m.money, "ok": m.money >= m.estate._deed_step()}]
		if m.tax_owed > 0:
			deed["needs"].append({"text": "No tax owed", "ok": false})
		deed["button"] = "Pay %d" % m.estate._deed_step()
		deed["action"] = "pay_deed"
		deed["enabled"] = deed_why == ""
	rows.append(deed)

	rows.append({"tab": "Pastimes", "icon": "cards"})
	var played := m.entertained_day == m.day
	rows.append({"name": "Played today", "status": "Yes" if played else "Not yet", "status_kind": "done" if played else "short",
		"value": "yes" if played else "no: today's first game gives +%d sanity and %d limit back" % [int(m.rewards.PASTIME_SANITY), int(m.rewards.PASTIME_RELIEF)]})
	if m.boredom_loss > 0.0:
		rows.append({"name": "Sanity limit lost to boredom", "status": "%d" % int(m.boredom_loss), "status_kind": "short", "value": "%d, won back by playing" % int(m.boredom_loss)})
	rows.append({"name": "Solitaire (%s)" % m.desk._hours_text(m.SOLITAIRE_HOURS), "value": "pack of cards: %d games left" % m.card_games,
		"needs": [{"text": "A pack of cards (order one from the catalog)", "ok": m.card_games > 0}],
		"button": "Play", "action": "pastime:solitaire", "enabled": m.desk._can_pastime("solitaire")})
	rows.append({"name": "Sudoku (%s)" % m.desk._hours_text(m.SUDOKU_HOURS), "value": "sudoku book: %d puzzles left" % m.sudoku_puzzles,
		"needs": [{"text": "A sudoku book (order one from the catalog)", "ok": m.sudoku_puzzles > 0}],
		"button": "Play", "action": "pastime:sudoku", "enabled": m.desk._can_pastime("sudoku")})

	rows.append({"tab": "Catalog", "icon": "catalog"})
	if not m.desk_orders.is_empty():
		rows.append({"name": "On order", "status": "%d coming" % m.desk_orders.size(), "value": m.desk._orders_text(), "note": "Orders come with the next morning's post."})
	# Grouped by section, in the order each section first appears.
	var order: Array = []
	for item in m.desk._catalog():
		if not order.has(str(item["section"])):
			order.append(str(item["section"]))
	var items: Array = m.desk._catalog()
	items.sort_custom(func(a, b): return order.find(str(a["section"])) < order.find(str(b["section"])))
	var heading := ""
	for item in items:
		if str(item["section"]) != heading:
			heading = str(item["section"])
			rows.append({"section": heading})
		var price := int(item["price"])
		var needs: Array = [{"text": "%d coins" % price, "have": m.money, "ok": m.money >= price}]
		if not bool(item["ok"]):
			needs.append({"text": str(item["why"]).left(1).to_upper() + str(item["why"]).substr(1), "ok": false})
		rows.append({"name": str(item["name"]), "status": "%d coins" % price, "status_kind": "ok" if bool(item["ok"]) and m.money >= price else "short",
			"value": str(item["detail"]) if bool(item["ok"]) else str(item["why"]), "about": str(item["detail"]), "needs": needs,
			"button": "Order", "action": "order:" + str(item["id"]), "enabled": bool(item["ok"]) and m.money >= price})
	rows.append({"note": "Orders are paid now and come with the next morning's post. Coins: %d." % m.money})
	return rows


func _cooked_sell_rows() -> Array:
	var rows: Array = []
	for r in Foods.RECIPES:
		var f := Foods.find(str(r["food"]))
		var held := int(m.inventory[str(f["held"])])
		if held <= 0:
			continue
		rows.append(_sell_row(f, held))
	return rows


# A Sell all row: the price the next one fetches, and how many more the lane takes today at full price.
func _sell_row(f: Dictionary, held: int) -> Dictionary:
	var id := str(f["id"])
	var price := m.stall._food_price(id)
	var now := m.stall._price_now(id)
	var left := m.stall._full_left(id)
	return {
		"name": "%s (%d each)" % [str(f["name"]), now] if now >= price else "%s (%d each, %d when wanted)" % [str(f["name"]), now, price],
		"value": "%d held, %d all for %d" % [held, held, m.stall._sale_value(id, held)],
		"about": "The lane takes %d more today at full price." % left if left > 0 else "The lane has had its fill: it pays less until it wants more.",
		"button": "Sell all",
		"action": "sell_food:" + id,
		"enabled": true,
	}


func _smokehouse_rows() -> Array:
	var rows: Array = [
		{"tab": "Smokehouse"},
		{"note": "Preserved goods keep in your pack, so nothing spoils. Stand beside the smokehouse, facing it, and press Space to open this panel."},
	]
	var held: Array = []
	for r in Foods.RECIPES:
		if r["station"] != "smokehouse":
			continue
		var f := Foods.find(str(r["food"]))
		rows.append({
			"name": "%s (%s)" % [str(f["name"]), m.stall._recipe_needs_text(r)],
			"value": "%s %d, +%d XP, sells %d" % [str(f["skill"]), int(f["level"]), int(r["xp"]), m.stall._food_price(str(f["id"]))],
			"button": "Make",
			"action": "cook:" + str(f["id"]),
			"enabled": m.stall._can_make(str(f["id"])),
		})
		var n := int(m.inventory[str(f["held"])])
		if n > 0:
			held.append("%s %d" % [str(f["name"]).to_lower(), n])
	rows.append({"name": "Held", "value": ", ".join(held) if not held.is_empty() else "nothing yet"})
	return rows


func _well_rows() -> Array:
	var rows: Array = [{"tab": "Pump"}]
	if not m.well_repaired:
		rows.append({"name": "Pump", "value": "Seized. The pipe has rotted through, and the crank won't turn."})
		rows.append({
			"name": "Repair the pump",
			"value": "%d wood, %d fiber, Carpentry %d" % [m.WELL_REPAIR["wood"], m.WELL_REPAIR["fiber"], m.WELL_REPAIR["level"]],
			"needs": _needs(m.WELL_REPAIR, "Carpentry"),
			"button": "Repair",
			"action": "repair_well",
			"enabled": m._can_repair_well(),
		})
		rows.append({"note": "Repairing the pump also refills the tank and gives Carpentry XP."})
		return rows
	rows.append({"name": "Water in the tank", "value": "%d of %d" % [int(m.well_water), int(m._well_capacity())], "progress": m.well_water / m._well_capacity()})
	if m.cistern_built:
		rows.append({"name": "Copper cistern", "value": "The tank holds %d" % int(m.CISTERN_CAPACITY), "status": "Built", "status_kind": "done"})
	else:
		rows.append({
			"name": "Copper cistern",
			"about": "A riveted copper tank on the well, so it holds %d water instead of %d. It refills each morning like the old one." % [int(m.CISTERN_CAPACITY), int(m.WELL_CAPACITY)],
			"value": "%d copper bars, %d iron bars, Smithing %d" % [int(m.CISTERN_COST["copper_bar"]), int(m.CISTERN_COST["iron_bar"]), int(m.CISTERN_COST["level"])],
			"needs": _needs(m.CISTERN_COST, "Smithing"),
			"button": "Build",
			"action": "build_cistern",
			"enabled": m._can_build_cistern(),
		})
	rows.append({"note": "The tank refills each morning. Drinking from the pump costs nothing."})
	rows.append({
		"name": "Drink from the pump",
		"value": "+%d water" % int(m.DRINK_WELL),
		"button": "Drink",
		"action": "drink_well",
		"enabled": m.water < 100.0,
	})
	rows.append({"tab": "Hose"})
	if m.hose_attached:
		rows.append({"name": "Hose", "status": "Attached", "status_kind": "done", "value": "Attached. It reaches every plot on the farm. Face a crop and press Space to water it."})
	else:
		rows.append({
			"name": "Attach the hose",
			"value": "%d fiber, %d resin. It reaches every plot on the farm." % [m.HOSE_COST["fiber"], m.HOSE_COST["resin"]],
			"about": "It reaches every plot on the farm.",
			"needs": _needs(m.HOSE_COST, ""),
			"button": "Attach",
			"action": "attach_hose",
			"enabled": m._can_attach_hose(),
		})
	return rows


func _achievement_rows() -> Array:
	var total := m.ACHIEVEMENTS.size()
	var done_count := m.achievements_done.size()
	# A tab per tier, named without its numeral. Each tab's note gives the tier's count and the total.
	var rows: Array = []
	for tier in m.ACHIEVEMENT_TIERS.size():
		var in_tier: Array = []
		for a in m.ACHIEVEMENTS:
			if a["tier"] == tier:
				in_tier.append(a)
		var tier_done := 0
		for a in in_tier:
			if m.achievements_done.has(a["id"]):
				tier_done += 1
		rows.append({"tab": str(m.ACHIEVEMENT_TIERS[tier]).get_slice(": ", 1)})
		for a in in_tier:
			var row: Dictionary = m._achievement_row(a)
			var earned: bool = m.achievements_done.has(a["id"])
			row["name"] = str(a["title"])
			row["status"] = "Done" if earned else str(row["value"])
			row["status_kind"] = "done" if earned else "info"
			row["value"] = str(a["text"])
			row["note"] = "Reward: %s" % m.progression._reward_text(a["reward"])
			rows.append(row)
		rows.append({"note": "%s: %d of %d earned. %d of %d (%d%%) overall." % [m.ACHIEVEMENT_TIERS[tier], tier_done, in_tier.size(), done_count, total, int(100.0 * done_count / total)]})
		if done_count == total:
			rows.append({"note": "Every achievement earned. Crow Creek Hollow has nothing left to teach you."})
	return rows


func _trade_rows() -> Array:
	var rows: Array = [
		{"section": "Purse"},
		{"name": "Coins", "value": str(m.money)},
		{"section": "Sell from your pack"},
	]
	# Everything the stand buys that you carry: crops, the animals' goods, fish and forage, then cooked food.
	var any := false
	for f in Foods.LIST:
		if f["kind"] == "cooked":
			continue
		var held := int(m.inventory[str(f["held"])])
		var price := m.stall._food_price(str(f["id"]))
		if held <= 0 or price <= 0:
			continue
		any = true
		rows.append(_sell_row(f, held))
	var cooked := _cooked_sell_rows()
	if not any and cooked.is_empty():
		rows.append({"name": "Nothing to sell", "value": "Crops, fish, forage, eggs, milk and cooked food sell here."})
	return rows + cooked + [
		{"note": "The farm stand is open from 06:00 to 18:00. It only buys what you carry, so take crops or fish out of storage first. The lane takes only so many of each thing a day at full price; sell a spread, or keep some back for another day."},
	]


func _cellar_rows() -> Array:
	var total := m.farm._cellar_total()
	var in_pack := m.farm._keepable_in_pack()
	return [
		{"tab": "Root cellar"},
		{
			"name": "Crops stored",
			"value": "%d/%d" % [total, m.estate._cellar_cap()],
			"progress": float(total) / float(m.estate._cellar_cap()),
		},
		{"name": "In the cellar", "value": m.farm._cellar_text()},
		{
			"name": "Store crops that keep",
			"value": "%d in pack" % in_pack,
			"button": "Store",
			"action": "store_crops",
			"enabled": in_pack > 0 and total < m.estate._cellar_cap(),
		},
		{
			"name": "Take crops into your pack",
			"value": "%d free slots" % m.stall._pack_free(),
			"button": "Take",
			"action": "take_crops",
			"enabled": total > 0 and m.stall._pack_free() > 0,
		},
		{"note": "Turnips, potatoes, leeks, parsnips and garlic keep here. Nothing spoils in the cellar. Corn, pumpkins, greens and berries don't keep, so eat, cook or sell them."},
	]


func _cooler_rows() -> Array:
	var total := m.fishing._cooler_total()
	var in_pack := m._held("any_fish")
	return [
		{"tab": "Cooler"},
		{
			"name": "Fish stored",
			"value": "%d/%d" % [total, m.COOLER_CAP],
			"progress": float(total) / float(m.COOLER_CAP),
		},
		{"name": "In the cooler", "value": m.fishing._cooler_text()},
		{
			"name": "Store fish from your pack",
			"value": "%d in pack" % in_pack,
			"button": "Store",
			"action": "store_fish",
			"enabled": in_pack > 0 and total < m.COOLER_CAP,
		},
		{
			"name": "Take fish into your pack",
			"value": "%d free slots" % m.stall._pack_free(),
			"button": "Take",
			"action": "take_fish",
			"enabled": total > 0 and m.stall._pack_free() > 0,
		},
		{"note": "Fish in your pack spoil overnight. Fish kept here do not. The best fish go in first."},
	]


func _woodstore_rows() -> Array:
	return [
		{"tab": "Firewood store"},
		{"name": "Firewood in the store", "value": "%d of %d" % [m.firewood_store, m.WOODSTORE_CAP], "progress": float(m.firewood_store) / float(m.WOODSTORE_CAP)},
		{"name": "Firewood in your pack", "value": str(int(m.inventory["firewood"]))},
		{"name": "Take 5 firewood", "value": "into your pack", "button": "Take", "action": "wood_take:5", "enabled": m.firewood_store > 0},
		{"name": "Store your firewood", "value": "all you carry, up to the store's room", "button": "Store", "action": "wood_store",
			"enabled": int(m.inventory["firewood"]) > 0 and m.firewood_store < m.WOODSTORE_CAP},
		{"note": "Split wood at the chopping log: stand beside it, facing it, hold the axe, and press RT or click. Feed the hearth in the house with firewood from your pack."},
	]


func _furnace_rows() -> Array:
	var rows: Array = [
		{"tab": "Furnace"},
		{"name": "Bars left today", "status": "%d of %d" % [m.mining._smelts_left(), m.SMELT_DAILY_LIMIT], "status_kind": "info" if m.mining._smelts_left() > 0 else "short",
			"progress": float(m.mining._smelts_left()) / float(m.SMELT_DAILY_LIMIT),
			"value": "The furnace makes %d bars a day before it must cool; %d left today." % [m.SMELT_DAILY_LIMIT, m.mining._smelts_left()]},
		{"note": "Smelting turns ore into bars, with wood as fuel. Bars make metal tools and gear. The furnace makes %d bars a day before it must cool; %d left today. Stand beside the furnace, facing it, and press Space to open this panel." % [m.SMELT_DAILY_LIMIT, m.mining._smelts_left()]},
	]
	for kind in ["copper", "iron"]:
		rows.append({
			"name": "Smelt %s %s bar (%d %s ore, 1 wood)" % ["an" if kind == "iron" else "a", kind, int(m.SMELT_ORE[kind]), kind],
			"value": "Smithing %d, +%d XP. Held: %d ore, %d bars" % [int(m.SMELT_LEVEL[kind]), m.XP_SMELT, int(m.materials[kind + "_ore"]), int(m.materials[kind + "_bar"])],
			"about": "+%d Smithing XP. You hold %d %s bars." % [m.XP_SMELT, int(m.materials[kind + "_bar"]), kind],
			"needs": _needs({kind + "_ore": int(m.SMELT_ORE[kind]), "wood": 1}, "Smithing", int(m.SMELT_LEVEL[kind])) + [{"text": "Bars left today", "ok": m.mining._smelts_left() > 0}],
			"button": "Smelt",
			"action": "smelt:" + kind,
			"enabled": m.mining._can_smelt(kind),
		})
	return rows


func _job_rows() -> Array:
	var job := m._job_today()
	var done := m.job_done_day == m.day
	var detail := "Done for today." if done else "Needs %s. Pays %d coins and %d %s XP." % [m._job_need_text(job), int(job["coins"]), int(job["xp"]), job["skill"]]
	var row := {"name": str(job["name"]), "value": detail, "enabled": m._can_do_job()}
	if not done:
		row["button"] = "Deliver"
		row["action"] = "job"
	return [{"section": "Daily job"}, row, {"note": "One job a day, separate from the chores. It doesn't add wear to the house."}]
