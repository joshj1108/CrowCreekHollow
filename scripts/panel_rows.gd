class_name PanelRows
extends RefCounted

# The row lists for the action bar's panels. Each one reads the game through `m`, the main
# scene, and returns plain dictionaries for the panel to draw. Nothing here changes game state.

var m: MainGame


func _init(main: Node) -> void:
	m = main


# The Game section of Settings: leaving the farm for the start screen.
func _game_rows() -> Array:
	var rows: Array = [
		{"section": "Game"},
		{
			"name": "Music",
			"value": "On" if m.music_on else "Off",
			"button": "Turn off" if m.music_on else "Turn on",
			"action": "toggle_music",
			"enabled": true,
		},
		{
			"name": "Sound effects",
			"value": "On" if m.sfx_on else "Off",
			"button": "Turn off" if m.sfx_on else "Turn on",
			"action": "toggle_sfx",
			"enabled": true,
		},
		{
			"name": "Unstick me",
			"value": "Cancels any placement and moves you to the path outside the farmhouse door",
			"button": "Unstick",
			"action": "unstick",
			"enabled": true,
		},
		{
			"name": "Quit to the main menu",
			"value": "Returns to the start screen without saving. Progress since your last sleep is lost.",
			"button": "Quit",
			"action": "quit_title",
			"enabled": true,
		},
	]
	# Debug builds only, so a released game never shows it.
	if OS.is_debug_build():
		rows.append({
			"name": "Dev: unlock everything",
			"value": "Every skill to level 10, coins, materials, every tool tier, the house and buildings (also F4)",
			"button": "Unlock",
			"action": "dev_unlock",
			"enabled": true,
		})
	return rows


# The seen tips, for the Settings menu.
func _tip_rows() -> Array:
	var rows: Array = [{"section": "Tips"}]
	var any := false
	for tip in m.TIPS:
		if m.tips_seen.has(tip["id"]):
			rows.append({"name": tip["title"], "value": tip["text"]})
			any = true
	if not any:
		rows.append({"note": "Tips appear as you reach each part of the farm. The first ones show as soon as you start."})
	return rows


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
	detail["progress"] = m.progression._level_progress(skill)
	return [
		{"split": {"recipes": marked, "columns": 4, "detail": detail}},
		{"note": "Skills grow by doing. Each action gives XP to the skill it trains. Levels unlock recipes, crops, and tools."},
	]


func _inventory_rows() -> Array:
	var rows: Array = [{"section": "Pack"}]
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
	rows.append({"name": "Planting with", "value": m.farm._seed_label(m.selected_seed)})
	var growing := m.crops.size()
	if growing > 0:
		rows.append({"name": "Watered today", "value": "%d of %d growing crops" % [m.farm._watered_today(), growing], "progress": float(m.farm._watered_today()) / float(growing)})
	var kinds := m.farm._unlocked_kinds()
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
	if m.craft_tab == "other":
		rows.append_array(_craft_camp_rows())
	return rows


func _craft_camp_rows() -> Array:
	if not m._in_village():
		return []
	return [
		{"section": "Campsite"},
		{
			"name": "Set up camp here",
			"value": "%d wood, %d fiber, Bushcrafting %d. Face open ground." % [int(m.CAMP_COST["wood"]), int(m.CAMP_COST["fiber"]), m.CAMP_LEVEL],
			"button": "Camp",
			"action": "camp",
			"enabled": m._can_camp(),
		},
		{"note": "A campsite is safe from foes. Rest there from 18:00 like a bed. It saves the game and ends the day. Setting up a new camp moves the old one."},
	]


func _quest_rows() -> Array:
	var rows: Array = []
	var current: Variant = null
	for q in m.STORY:
		if not m.quests_done.has(q["id"]):
			current = q
			break
	if current != null:
		rows.append({"section": "Current chapter"})
		rows.append(m._quest_row(current, true))
	else:
		rows.append({"note": "You have reached the end of the story for now. More chapters are coming."})
	rows.append({"section": "Chapters"})
	for q in m.STORY:
		rows.append(m._quest_row(q, false))
	if m.WORLD_ENABLED:
		rows.append({"section": "Guardian of Lowmere"})
		var guardian_current: Variant = null
		for q in m.GUARDIAN_QUESTS:
			if not m.guardian_done.has(q["id"]):
				guardian_current = q
				break
		if guardian_current != null:
			rows.append(m._quest_row(guardian_current, true))
		else:
			rows.append({"note": "Lowmere is safe for now."})
		for q in m.GUARDIAN_QUESTS:
			rows.append(m._quest_row(q, false))
	return rows


func _house_rows() -> Array:
	var rows: Array = [
		{"section": "Condition"},
		{"name": "Farmhouse", "value": m.STAGE_NAMES[m.house_stage]},
	]
	if m.house_stage < m.MAX_STAGE:
		var cost: Dictionary = m.REPAIR_COSTS[m.house_stage]
		rows.append({
			"name": "Repair to %s" % m.STAGE_NAMES[m.house_stage + 1],
			"value": "%d wood, %d fiber, Carpentry %d" % [cost["wood"], cost["fiber"], cost["level"]],
			"button": "Repair",
			"action": "repair",
			"enabled": m._can_repair(),
		})
	rows.append({"section": "Today's chores"})
	for chore in m._chore_list():
		var row := {"name": chore["name"]}
		if bool(chore["done"]):
			row["value"] = "Done"
		else:
			row["value"] = str(chore["detail"])
			if str(chore["action"]) != "":
				row["button"] = chore["button"]
				row["action"] = chore["action"]
				row["enabled"] = chore["enabled"]
		rows.append(row)
	rows.append({"note": "Each chore left undone adds 1 wear overnight. A night with every chore done brings back %d sanity." % m.WELL_KEPT_SANITY})
	rows.append_array(_job_rows())
	rows.append({"section": "Upkeep"})
	rows.append({"name": "Wear", "value": "%d of %d" % [m.wear, m.WEAR_MAX], "progress": float(m.wear) / float(m.WEAR_MAX)})
	rows.append({"note": "The house wears a little each night. Mending, tidying, and repairs bring it down. At %d wear, rain ruins a crop overnight. At %d, a fox can get into the coop. A third plot opens at Farming %d once the house is Patched." % [m.WEAR_RUNDOWN, m.WEAR_FOX, m.PLOT_THREE_LEVEL]})
	rows.append({"section": "Rest"})
	rows.append({"note": "The bed is in the bedroom. Walk there and press Space from 18:00 to save and end the day. If you aren't in bed by 03:00 you collapse, and your sanity limit drops permanently."})
	rows.append({"name": "Sanity limit", "value": "%d of %d" % [m.sanity_sys._sanity_max(), int(m.SANITY_MAX)]})
	rows.append({
		"name": "Cleanse the house",
		"value": "%d crops, Cleaning %d, once a day: +%d limit" % [m.CLEANSE_CROPS, m.CLEANSE_LEVEL, m.CLEANSE_RELIEF],
		"button": "Cleanse",
		"action": "cleanse",
		"enabled": m.sanity_sys._can_cleanse(),
	})
	rows.append({"section": "Storage"})
	if m.cellar_built:
		rows.append({"name": "Root cellar", "value": "built, holds %d crops. Stand beside it, facing it, and press Space." % m.CELLAR_CAP})
	else:
		rows.append({
			"name": "Build a root cellar (holds %d crops)" % m.CELLAR_CAP,
			"value": m.stall._price_text(m.CELLAR_COST),
			"button": "Build",
			"action": "build_cellar",
			"enabled": m._can_afford(m.CELLAR_COST),
		})
	if m.cooler_built:
		rows.append({"name": "Cooler", "value": "built, keeps %d fish fresh. Stand beside it, facing it, and press Space." % m.COOLER_CAP})
	else:
		rows.append({
			"name": "Build a cooler (keeps %d fish fresh)" % m.COOLER_CAP,
			"value": m.stall._price_text(m.COOLER_COST),
			"button": "Build",
			"action": "build_cooler",
			"enabled": m._can_afford(m.COOLER_COST),
		})
	rows.append({"note": "The workshop, the coop, and the barn are in the Buildings section on the section wheel (Shift)."})
	rows.append({"section": "Features"})
	for feature in m.HOUSE_FEATURES:
		var unlocked: bool = m.house_stage >= feature["stage"]
		rows.append({
			"name": feature["text"],
			"value": "unlocked" if unlocked else "at %s" % m.STAGE_NAMES[feature["stage"]],
		})
	return rows


# The coop panel: the hens are bought and fed here, not from the House panel.
func _coop_rows() -> Array:
	var rows: Array = [{"section": "Hens"}]
	rows.append({
		"name": "Hens",
		"value": "%d of %d, %d coins each" % [m.hens, m.COOP_HENS_MAX, m.HEN_PRICE],
		"button": "Buy hen",
		"action": "buy_hen",
		"enabled": m.animals._can_buy_hen(),
	})
	rows.append({
		"name": "Feed hens",
		"value": "%d crops, once a day" % (m.hens * m.HEN_FEED_CROPS),
		"button": "Feed",
		"action": "feed_hens",
		"enabled": m.animals._can_feed_hens(),
	})
	rows.append({"name": "Grown hens", "value": "%d of %d, %d coins each" % [m.animals._grown_count(m.hen_ages, m.HEN_MATURE_DAYS), m.hens, m.HEN_SELL], "button": "Sell a hen", "action": "sell_hen", "enabled": m.animals._grown_count(m.hen_ages, m.HEN_MATURE_DAYS) > 0})
	rows.append({"note": "A grown hen (%d nights) lays an egg each morning when fed, kept as a meal or sold at the farm stand. Young hens do not lay. Two unfed days in a row and a hen wanders off." % m.HEN_MATURE_DAYS})
	return rows


# The barn panel. Livestock aren't in the game yet, so for now it only says so.
func _barn_rows() -> Array:
	var rows: Array = [{"section": "Goats"}]
	rows.append({
		"name": "Goats",
		"value": "%d of %d, %d coins each" % [m.goats, m.BARN_GOATS_MAX, m.GOAT_PRICE],
		"button": "Buy goat",
		"action": "buy_goat",
		"enabled": m.animals._can_buy_goat(),
	})
	rows.append({
		"name": "Feed goats",
		"value": "%d crops, once a day" % (m.goats * m.GOAT_FEED_CROPS),
		"button": "Feed",
		"action": "feed_goats",
		"enabled": m.animals._can_feed_goats(),
	})
	rows.append({"name": "Grown goats", "value": "%d of %d, %d coins each" % [m.animals._grown_count(m.goat_ages, m.GOAT_MATURE_DAYS), m.goats, m.GOAT_SELL], "button": "Sell a goat", "action": "sell_goat", "enabled": m.animals._grown_count(m.goat_ages, m.GOAT_MATURE_DAYS) > 0})
	rows.append({"note": "A grown goat (%d nights) gives milk each morning when fed, kept to drink or sold at the farm stand. Young goats do not give milk. Two unfed days in a row and a goat wanders off." % m.GOAT_MATURE_DAYS})
	return rows


# The Buildings menu: the workshop, the coop, and the barn. Each one is placed on open grass.
func _buildings_rows() -> Array:
	var rows: Array = [{"section": "Workshop"}]
	if m.smokehouse_built:
		rows.append({"name": "Smokehouse", "value": "built. Stand beside it, facing it, and press Space to preserve food."})
	else:
		rows.append({
			"name": "Build a smokehouse (smokes and preserves food)",
			"value": m.stall._price_text(m.SMOKEHOUSE_COST),
			"button": "Build",
			"action": "build_smokehouse",
			"enabled": m._can_afford(m.SMOKEHOUSE_COST),
		})
	if m.furnace_built:
		rows.append({"name": "Furnace", "value": "built. Stand beside it, facing it, and press Space to smelt ore."})
	else:
		rows.append({
			"name": "Build a furnace (smelts ore into bars)",
			"value": m.stall._price_text(m.FURNACE_COST),
			"button": "Build",
			"action": "build_furnace",
			"enabled": m._can_afford(m.FURNACE_COST),
		})
	if m.woodshed_built:
		rows.append({"name": "Firewood store and chopping log", "value": "built in the workshop. Stand beside them to store firewood or split wood."})
	else:
		rows.append({
			"name": "Build a firewood store and chopping log",
			"value": m.stall._price_text(m.WOODSHED_COST) + ("" if m.smokehouse_built or m.furnace_built else ", needs the smokehouse or furnace first"),
			"button": "Build",
			"action": "build_woodshed",
			"enabled": m._can_afford(m.WOODSHED_COST) and (m.smokehouse_built or m.furnace_built),
		})
	rows.append({"note": "The workshop is a walled building against the east wall of the house. Its door is on the south side."})
	rows.append({"section": "Coop"})
	if not m.coop_built:
		rows.append({
			"name": "Build a coop (holds %d hens)" % m.COOP_HENS_MAX,
			"value": m.stall._price_text(m.COOP_COST),
			"button": "Build",
			"action": "build_coop",
			"enabled": m._can_build("coop"),
		})
	else:
		rows.append(m._placed_row("Coop", "coop", m.coop_tile, "move_coop"))
	rows.append({"section": "Barn"})
	if not m.barn_built:
		rows.append({
			"name": "Build a barn (for livestock)",
			"value": m.stall._price_text(m.BARN_COST),
			"button": "Build",
			"action": "build_barn",
			"enabled": m._can_build("barn"),
		})
		rows.append({"note": "The barn is for livestock. Livestock are still to come, so for now it simply stands."})
	else:
		rows.append(m._placed_row("Barn", "barn", m.barn_tile, "move_barn"))
	return rows


func _settings_rows() -> Array:
	return [
		{"section": "Controls"},
		{"name": "Move", "value": "WASD or arrow keys"},
		{"name": "Talk, sleep, open panels, gather, drink, plant with hands", "value": "Space"},
		{"name": "Cycle the seed you plant (with the trowel)", "value": "Z and X"},
		{"name": "Use the tool or weapon in hand: hoe, hose, trowel, axe, pick, rod, sword", "value": "Left click"},
		{"name": "Bag (Inventory is in the bag)", "value": "Tab"},
		{"name": "Section wheel: Skills, Gear, Craft, Quests, House, Buildings, Achievements", "value": "Shift, then the mouse"},
		{"name": "Settings", "value": "Esc"},
		{"name": "Close the open section, the wheel, or the bag", "value": "B or Esc"},
		{"section": "Gamepad"},
		{"name": "Move", "value": "Left stick or D-pad"},
		{"name": "Talk, sleep, open panels, gather, drink, plant with hands", "value": "A"},
		{"name": "Use the tool or weapon in hand: hoe, hose, trowel, axe, pick, rod, sword", "value": "RT"},
		{"name": "Close the open section, the wheel, or the bag", "value": "B"},
		{"name": "Bag (Inventory is in the bag)", "value": "Y"},
		{"name": "Section wheel", "value": "Left stick click, then left stick and A"},
		{"name": "Settings", "value": "Start"},
		{"note": "While a panel is open, the D-pad or left stick moves between its buttons, and A presses the highlighted one."},
		{"section": "Saving"},
		{"note": "Progress saves only when you sleep, or when you collapse at 03:00. The save includes your position and open panel."},
		{"note": "Sound effects and display options are coming later."},
	]


func _desk_rows() -> Array:
	var rows: Array = [{"section": "Desk"}]
	rows.append({"section": "Post on the desk"})
	if m.desk_mail.is_empty():
		rows.append({"note": "No post. The mail slot in the front door drops letters here."})
	for letter in m.desk_mail:
		rows.append({"note": "%s%s\n%s" % [str(letter["title"]), "  (new)" if bool(letter["unread"]) else "", str(letter["text"])]})
	rows.append({"name": "Property value", "value": "%d a quarter" % m.desk._property_value()})
	rows.append({"note": m.desk._property_text()})
	rows.append({"name": "Property tax", "value": m.desk._tax_text(), "button": "Pay", "action": "pay_tax", "enabled": m.tax_owed > 0 and m.money >= m.tax_owed})
	rows.append({"name": "Put letters away", "value": "read letters go in the drawer", "button": "Clear", "action": "mail_clear", "enabled": m.desk._has_read_mail()})
	rows.append({"section": "Games"})
	var entertained := m.entertained_day == m.day
	rows.append({"name": "Entertained today", "value": "yes" if entertained else "no, finish a game or your limit slips"})
	if m.boredom_loss > 0.0:
		rows.append({"name": "Sanity limit lost to boredom", "value": str(int(m.boredom_loss))})
	if m.desk_game.is_empty():
		rows.append({"name": "Sudoku", "value": "fill the 4 by 4 grid so each row, column and 2 by 2 box has 1 to 4", "button": "Play", "action": "game_new:sudoku"})
		rows.append({"name": "Solitaire", "value": "turn cards and build the four suit foundations", "button": "Play", "action": "game_new:solitaire"})
	elif m.desk_game["kind"] == "sudoku":
		rows.append_array(_sudoku_rows())
	else:
		rows.append_array(_solitaire_rows())
	return rows


func _sudoku_rows() -> Array:
	var puzzle: Array = m.desk_game["puzzle"]
	var guess: Array = m.desk_game["guess"]
	var lines: Array = []
	for r in 4:
		var cells: Array = []
		for c in 4:
			var i := r * 4 + c
			var v := int(puzzle[i]) if int(puzzle[i]) != 0 else int(guess[i])
			cells.append(str(v) if v != 0 else ".")
		lines.append(" ".join(PackedStringArray(cells)))
	var rows: Array = [{"section": "Sudoku"}, {"note": "\n".join(PackedStringArray(lines))}]
	for i in 16:
		if int(puzzle[i]) != 0:
			continue
		var g := int(guess[i])
		rows.append({"name": "Row %d, column %d" % [i / 4 + 1, i % 4 + 1], "value": str(g) if g != 0 else "empty", "button": "Next", "action": "sudoku_next:%d" % i})
	rows.append({"name": "Check your numbers", "value": "right ones are locked in, wrong ones clear", "button": "Check", "action": "sudoku_check"})
	rows.append({"name": "Put the game away", "value": "unfinished, so it does not count today", "button": "Put away", "action": "game_quit"})
	return rows


func _solitaire_rows() -> Array:
	var stock: Array = m.desk_game["stock"]
	var waste: Array = m.desk_game["waste"]
	var found: Array = m.desk_game["found"]
	var top := "empty" if waste.is_empty() else m.desk._card_name(int(waste.back()))
	var piles: Array = []
	for s in 4:
		piles.append("%s %d" % [m.DESK_SUITS[s], int(found[s])])
	return [
		{"section": "Solitaire"},
		{"name": "Waste top", "value": top},
		{"name": "Stock", "value": "%d left, %d of %d deck passes used" % [stock.size(), int(m.desk_game["passes"]), m.SOL_PASSES]},
		{"name": "Turn a card", "value": "from the stock", "button": "Turn", "action": "sol_draw", "enabled": m.desk._sol_can_turn()},
		{"name": "Play the waste card", "value": "up to its foundation, if it is next", "button": "Play", "action": "sol_play", "enabled": m.desk._sol_can_play()},
		{"note": "Foundations (cards played): " + ", ".join(PackedStringArray(piles))},
		{"name": "Put the game away", "value": "unfinished, so it does not count today", "button": "Put away", "action": "game_quit"},
	]


func _cooked_sell_rows() -> Array:
	var rows: Array = []
	for r in Foods.RECIPES:
		var f := Foods.find(str(r["food"]))
		var held := int(m.inventory[str(f["held"])])
		if held <= 0:
			continue
		rows.append({
			"name": "%s (%d each)" % [str(f["name"]), m.stall._food_price(str(f["id"]))],
			"value": "%d held" % held,
			"button": "Sell all",
			"action": "sell_food:" + str(f["id"]),
			"enabled": true,
		})
	return rows


func _smokehouse_rows() -> Array:
	var rows: Array = [
		{"section": "Smokehouse"},
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
	var rows: Array = [{"section": "Pump"}]
	if not m.well_repaired:
		rows.append({"name": "Pump", "value": "Seized. The pipe has rotted through, and the crank won't turn."})
		rows.append({
			"name": "Repair the pump",
			"value": "%d wood, %d fiber, Carpentry %d" % [m.WELL_REPAIR["wood"], m.WELL_REPAIR["fiber"], m.WELL_REPAIR["level"]],
			"button": "Repair",
			"action": "repair_well",
			"enabled": m._can_repair_well(),
		})
		rows.append({"note": "Repairing the pump also refills the tank and gives Carpentry XP."})
		return rows
	rows.append({"name": "Water in the tank", "value": "%d of %d" % [int(m.well_water), int(m.WELL_CAPACITY)], "progress": m.well_water / m.WELL_CAPACITY})
	rows.append({"note": "The tank refills each morning. Drinking from the pump costs nothing."})
	rows.append({
		"name": "Drink from the pump",
		"value": "+%d water" % int(m.DRINK_WELL),
		"button": "Drink",
		"action": "drink_well",
		"enabled": m.water < 100.0,
	})
	rows.append({"section": "Hose"})
	if m.hose_attached:
		rows.append({"name": "Hose", "value": "Attached. It reaches every plot on the farm. Face a crop and press Space to water it."})
	else:
		rows.append({
			"name": "Attach the hose",
			"value": "%d fiber, %d resin. It reaches every plot on the farm." % [m.HOSE_COST["fiber"], m.HOSE_COST["resin"]],
			"button": "Attach",
			"action": "attach_hose",
			"enabled": m._can_attach_hose(),
		})
	return rows


func _achievement_rows() -> Array:
	var total := m.ACHIEVEMENTS.size()
	var done_count := m.achievements_done.size()
	var rows: Array = [
		{"section": "Completion"},
		{
			"name": "Achievements",
			"value": "%d/%d  (%d%%)" % [done_count, total, int(100.0 * done_count / total)],
			"progress": float(done_count) / float(total),
		},
	]
	if done_count == total:
		rows.append({"note": "Every achievement earned. Hallowvale has nothing left to teach you."})
	for tier in m.ACHIEVEMENT_TIERS.size():
		var in_tier: Array = []
		for a in m.ACHIEVEMENTS:
			if a["tier"] == tier:
				in_tier.append(a)
		var tier_done := 0
		for a in in_tier:
			if m.achievements_done.has(a["id"]):
				tier_done += 1
		rows.append({"section": "%s   %d/%d" % [m.ACHIEVEMENT_TIERS[tier], tier_done, in_tier.size()]})
		for a in in_tier:
			rows.append(m._achievement_row(a))
	return rows


func _trade_rows() -> Array:
	var turnip_pack := m.SEED_TURNIP_PRICE * 5
	var corn_pack := m.SEED_CORN_PRICE * 4
	var pumpkin_pack := m.SEED_PUMPKIN_PRICE * 3
	return [
		{"section": "Purse"},
		{"name": "Coins", "value": str(m.money)},
		{"section": "Sell from your pack"},
		{
			"name": "Turnips (%d each)" % m.farm._crop_price("turnip"),
			"value": "%d held" % int(m.inventory["crops"]),
			"button": "Sell all",
			"action": "sell_crops",
			"enabled": int(m.inventory["crops"]) > 0,
		},
		{
			"name": "Corn (%d each)" % m.farm._crop_price("corn"),
			"value": "%d held" % int(m.inventory["corn"]),
			"button": "Sell all",
			"action": "sell_corn",
			"enabled": int(m.inventory["corn"]) > 0,
		},
		{
			"name": "Pumpkins (%d each)" % m.farm._crop_price("pumpkin"),
			"value": "%d held" % int(m.inventory["pumpkins"]),
			"button": "Sell all",
			"action": "sell_pumpkins",
			"enabled": int(m.inventory["pumpkins"]) > 0,
		},
		{
			"name": "Fish (%d each)" % m.SELL_FISH,
			"value": "%d held" % int(m.inventory["fish"]),
			"button": "Sell all",
			"action": "sell_fish",
			"enabled": int(m.inventory["fish"]) > 0,
		},
		{
			"name": "Eggs (%d each)" % m.SELL_EGG,
			"value": "%d held" % int(m.inventory["eggs"]),
			"button": "Sell all",
			"action": "sell_eggs",
			"enabled": int(m.inventory["eggs"]) > 0,
		},
		{
			"name": "Goat milk (%d each)" % m.SELL_MILK,
			"value": "%d held" % int(m.inventory["milk"]),
			"button": "Sell all",
			"action": "sell_milk",
			"enabled": int(m.inventory["milk"]) > 0,
		},
		] + _cooked_sell_rows() + [
		{"section": "Buy seeds"},
		{
			"name": "Turnip seeds (%d each)" % m.SEED_TURNIP_PRICE,
			"value": "5 for %d coins" % turnip_pack,
			"button": "Buy 5",
			"action": "buy_turnip",
			"enabled": m.money >= turnip_pack,
		},
		{
			"name": "Corn seeds (%d each)" % m.SEED_CORN_PRICE,
			"value": "4 for %d coins, Farming %d" % [corn_pack, m.CORN_LEVEL],
			"button": "Buy 4",
			"action": "buy_corn",
			"enabled": m.farm._crop_unlocked("corn") and m.money >= corn_pack,
		},
		{
			"name": "Pumpkin seeds (%d each)" % m.SEED_PUMPKIN_PRICE,
			"value": "3 for %d coins, Farming %d" % [pumpkin_pack, m.PUMPKIN_LEVEL],
			"button": "Buy 3",
			"action": "buy_pumpkin",
			"enabled": m.progression._level("Farming") >= m.PUMPKIN_LEVEL and m.money >= pumpkin_pack,
		},
		{"note": "The farm stand is open from 06:00 to 18:00. It only buys what you carry, so take crops or fish out of storage first."},
	]


func _cellar_rows() -> Array:
	return [
		{"section": "Root cellar"},
		{
			"name": "Crops stored",
			"value": "%d/%d" % [m.cellar_stock, m.CELLAR_CAP],
			"progress": float(m.cellar_stock) / float(m.CELLAR_CAP),
		},
		{
			"name": "Store crops from your pack",
			"value": "%d in pack" % int(m.inventory["crops"]),
			"button": "Store",
			"action": "store_crops",
			"enabled": int(m.inventory["crops"]) > 0 and m.cellar_stock < m.CELLAR_CAP,
		},
		{
			"name": "Take crops into your pack",
			"value": "%d free slots" % m.stall._pack_free(),
			"button": "Take",
			"action": "take_crops",
			"enabled": m.cellar_stock > 0 and m.stall._pack_free() > 0,
		},
		{"note": "Crops keep here. Nothing spoils in the cellar."},
	]


func _cooler_rows() -> Array:
	return [
		{"section": "Cooler"},
		{
			"name": "Fish stored",
			"value": "%d/%d" % [m.cooler_stock, m.COOLER_CAP],
			"progress": float(m.cooler_stock) / float(m.COOLER_CAP),
		},
		{
			"name": "Store fish from your pack",
			"value": "%d in pack" % int(m.inventory["fish"]),
			"button": "Store",
			"action": "store_fish",
			"enabled": int(m.inventory["fish"]) > 0 and m.cooler_stock < m.COOLER_CAP,
		},
		{
			"name": "Take fish into your pack",
			"value": "%d free slots" % m.stall._pack_free(),
			"button": "Take",
			"action": "take_fish",
			"enabled": m.cooler_stock > 0 and m.stall._pack_free() > 0,
		},
		{"note": "Fish in your pack spoil overnight. Fish kept here do not."},
	]


func _woodstore_rows() -> Array:
	return [
		{"section": "Firewood store"},
		{"name": "Firewood in the store", "value": "%d of %d" % [m.firewood_store, m.WOODSTORE_CAP], "progress": float(m.firewood_store) / float(m.WOODSTORE_CAP)},
		{"name": "Firewood in your pack", "value": str(int(m.inventory["firewood"]))},
		{"name": "Take 5 firewood", "value": "into your pack", "button": "Take", "action": "wood_take:5", "enabled": m.firewood_store > 0},
		{"name": "Store your firewood", "value": "all you carry, up to the store's room", "button": "Store", "action": "wood_store",
			"enabled": int(m.inventory["firewood"]) > 0 and m.firewood_store < m.WOODSTORE_CAP},
		{"note": "Split wood at the chopping log: stand beside it, facing it, hold the axe, and press RT or click. Feed the hearth in the house with firewood from your pack."},
	]


func _furnace_rows() -> Array:
	var rows: Array = [
		{"section": "Furnace"},
		{"note": "Smelting turns ore into bars, with wood as fuel. Bars make metal tools and gear. Stand beside the furnace, facing it, and press Space to open this panel."},
	]
	for kind in ["copper", "iron"]:
		rows.append({
			"name": "Smelt a %s bar (1 %s ore, 1 wood)" % [kind, kind],
			"value": "Smithing %d, +%d XP. Held: %d ore, %d bars" % [int(m.SMELT_LEVEL[kind]), m.XP_SMELT, int(m.materials[kind + "_ore"]), int(m.materials[kind + "_bar"])],
			"button": "Smelt",
			"action": "smelt:" + kind,
			"enabled": m.mining._can_smelt(kind),
		})
	return rows


func _general_shop_rows() -> Array:
	var rows: Array = [
		{"section": "Purse"},
		{"name": "Coins", "value": str(m.money)},
		{"section": "Buy materials (%d at a time)" % m.GENERAL_BUY_QTY},
	]
	for key in m.GENERAL_BUY.keys():
		var price := int(m.GENERAL_BUY[key])
		rows.append({
			"name": "%s (%d each)" % [str(key).capitalize(), price],
			"value": "%d held" % int(m.materials[key]),
			"button": "Buy %d" % m.GENERAL_BUY_QTY,
			"action": "buy:%s" % key,
			"enabled": m.money >= price * m.GENERAL_BUY_QTY,
		})
	rows.append({"section": "Sell materials (half price)"})
	for key in m.GENERAL_BUY.keys():
		var sell := maxi(1, int(m.GENERAL_BUY[key]) / 2)
		rows.append({
			"name": "%s (%d each)" % [str(key).capitalize(), sell],
			"value": "%d held" % int(m.materials[key]),
			"button": "Sell all",
			"action": "sellmat:%s" % key,
			"enabled": int(m.materials[key]) > 0,
		})
	return rows


func _bank_rows() -> Array:
	var rows: Array = [
		{"section": "Coins"},
		{"name": "Held", "value": str(m.money), "button": "Bank all", "action": "dep:coins", "enabled": m.money > 0},
		{"name": "Banked", "value": str(m.bank_coins), "button": "Take all", "action": "wd:coins", "enabled": m.bank_coins > 0},
		{"section": "Goods"},
	]
	for key in m.bank_materials.keys():
		var held := int(m.materials[key])
		var banked := int(m.bank_materials[key])
		if held == 0 and banked == 0:
			continue
		rows.append({"name": "%s: held" % str(key).capitalize(), "value": str(held), "button": "Bank all", "action": "dep:%s" % key, "enabled": held > 0})
		rows.append({"name": "%s: banked" % str(key).capitalize(), "value": str(banked), "button": "Take all", "action": "wd:%s" % key, "enabled": banked > 0})
	if rows.size() == 4:
		rows.append({"note": "Nothing to bank yet. Goods you deposit are kept safe here, even if you lose them in the wild."})
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
