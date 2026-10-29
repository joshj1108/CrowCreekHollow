class_name FarmSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _seed_label(kind: String) -> String:
	return str(m.CROPS.get(kind, m.CROPS["turnip"])["label"])


# True once Farming is high enough to plant this kind.
func _crop_unlocked(kind: String) -> bool:
	return m.progression._level("Farming") >= int(m.CROPS[kind]["level"])


# True when the kind grows in the season (today's when none is given). Turnips grow in every season.
func _in_season(kind: String, season: String = "") -> bool:
	var seasons: Array = m.CROPS[kind]["seasons"]
	return seasons.is_empty() or seasons.has(season if season != "" else m._season_today())


# "every season", "spring", "autumn and winter".
func _seasons_text(kind: String) -> String:
	var seasons: Array = m.CROPS[kind]["seasons"]
	if seasons.is_empty():
		return "every season"
	return " and ".join(PackedStringArray(seasons)).to_lower()


# The crop kinds Farming has unlocked, in unlock order.
func _unlocked_kinds() -> Array:
	var kinds: Array = []
	for kind in m.CROPS:
		if _crop_unlocked(kind):
			kinds.append(kind)
	return kinds


# Steps through the seeds in the pouch that can go in the ground today: unlocked, held, and in season.
func _cycle_seed(step: int) -> void:
	var options: Array = []
	var held_out := false
	for kind in _unlocked_kinds():
		if int(m.inventory[m.CROPS[kind]["seed"]]) > 0:
			if _in_season(kind):
				options.append(kind)
			else:
				held_out = true
	if options.is_empty():
		m._show_message(("None of your seeds will take in %s." % m._season_today().to_lower()) if held_out else "You have no seeds to plant.")
		return
	var at := options.find(m.selected_seed)
	var idx: int
	if at == -1:
		idx = 0 if step > 0 else options.size() - 1
	else:
		idx = posmod(at + step, options.size())
	m.selected_seed = str(options[idx])
	m._show_message("Planting %s seeds now. %d left." % [_seed_label(m.selected_seed).to_lower(), int(m.inventory[m.CROPS[m.selected_seed]["seed"]])])


func _switch_seed() -> void:
	var kinds: Array = _unlocked_kinds().filter(func(k) -> bool: return _in_season(k))
	if kinds.is_empty():
		kinds = _unlocked_kinds()
	m.selected_seed = str(kinds[posmod(kinds.find(m.selected_seed) + 1, kinds.size())])
	m._show_message("You'll plant %s seeds now." % _seed_label(m.selected_seed).to_lower())


# Opens the third plot once Farming reaches level 4 and the house is at least Patched.
func _check_plot_three() -> void:
	if m.plot_three_open or m.progression._level("Farming") < m.PLOT_THREE_LEVEL or m.house_stage < 2:
		return
	m.plot_three_open = true
	for y in range(m.PLOT_THREE.position.y, m.PLOT_THREE.end.y):
		for x in range(m.PLOT_THREE.position.x, m.PLOT_THREE.end.x):
			m.map[y + m.BORDER_Y][x + m.BORDER_X] = m.Tile.SOIL
	m.queue_redraw()


# Opens the second plot once Farming reaches level 2. It stays open afterward.
func _check_unlocks() -> void:
	_check_plot_three()
	if m.plot_two_open or m.progression._level("Farming") < 2:
		return
	m.plot_two_open = true
	for y in range(m.PLOT_TWO.position.y, m.PLOT_TWO.end.y):
		for x in range(m.PLOT_TWO.position.x, m.PLOT_TWO.end.x):
			m.map[y + m.BORDER_Y][x + m.BORDER_X] = m.Tile.SOIL
	m.queue_redraw()


func _plant(tile: Vector2i) -> void:
	var kind := m.selected_seed
	if not m.CROPS.has(kind) or not _crop_unlocked(kind):
		kind = "turnip"
	if not _in_season(kind):
		m._show_message("%s won't take in %s. It grows in %s." % [_seed_label(kind), m._season_today().to_lower(), _seasons_text(kind)])
		return
	var seed_key: String = m.CROPS[kind]["seed"]
	if m.inventory[seed_key] <= 0:
		m._show_message("You're out of %s seeds." % _seed_label(kind).to_lower())
		return
	m.play_sfx("plant", 0.06)
	m.inventory[seed_key] -= 1
	m.crops[tile] = {"stage": 0, "kind": kind, "days": 0}
	if m.weather_kind in m.WATER_RAIN_KINDS:
		m.crops[tile]["watered_day"] = m.day
	m.stats["planted"] += 1
	m.progression._grant_xp("Farming", m.XP_PLANT)
	m._show_message("Planted %s. +%d Farming XP" % [_seed_label(kind).to_lower(), m.XP_PLANT])


func _harvest(tile: Vector2i) -> void:
	var kind: String = m.crops[tile]["kind"]
	var crop: Dictionary = m.CROPS[kind]
	var yield_count: int = crop["yield"]
	# Harvests go to the pack only. Storing in the cellar is up to the player.
	var held_key: String = crop["held"]
	if not m.stall._pack_room(int(m.inventory[held_key]), yield_count):
		m._show_message("Your pack is full. Store crops in the root cellar, or sell them.")
		return
	m.play_sfx("harvest", 0.06)
	m.inventory[held_key] += yield_count
	# A crop that regrows stays in the ground and goes back a few watered days; the rest come up.
	var again := ""
	if crop.has("regrow"):
		var days := maxi(0, int(m.CROP_GROW_DAYS[kind]) - int(crop["regrow"]))
		m.crops[tile]["days"] = days
		m.crops[tile]["stage"] = m._stage_for(kind, days)
		again = " It will bear again in %d watered days." % int(crop["regrow"])
	else:
		m.crops.erase(tile)
	m.stats["harvested"] += 1
	m.progression._bump("crop_" + kind)   # Every Row (AchievementSystem)
	if kind == "pumpkin":
		m.stats["pumpkins"] += 1
	var seed_note := ""
	if randf() < float(crop["seed_back"]):
		m.inventory[crop["seed"]] += 1
		seed_note = " and a seed"
	var xp: int = crop["xp"]
	m.progression._grant_xp("Farming", xp)
	var food := Foods.by_held(held_key)
	m._show_message("Harvested %d %s%s. +%d Farming XP%s" % [yield_count, str(food.get("name", _seed_label(kind))).to_lower(), seed_note, xp, again])


# Crops whose seasons have ended wither in the morning. Called once the new day's date is set.
func _wither() -> String:
	var gone := 0
	for pos in m.crops.keys():
		if not _in_season(str(m.crops[pos]["kind"])):
			m.crops.erase(pos)
			gone += 1
	if gone == 0:
		return ""
	m.stats["withered"] += gone
	return " The season has turned: %d crop%s withered in the ground." % [gone, "" if gone == 1 else "s"]


# A warning three days before the season turns, and again on its last day, while crops would wither.
func _season_warning() -> String:
	var today := m._season_today()
	var tomorrow := m._season_of(m._calendar_date(m.day + 1)["month"])
	var in_two := m._season_of(m._calendar_date(m.day + 2)["month"])
	var in_three := m._season_of(m._calendar_date(m.day + 3)["month"])
	var next := ""
	if tomorrow != today:
		next = tomorrow
	elif in_three != today and in_two == today:
		next = in_three
	if next == "":
		return ""
	var doomed := 0
	for pos in m.crops:
		if not _in_season(str(m.crops[pos]["kind"]), next):
			doomed += 1
	if doomed == 0:
		return ""
	return " %s comes %s: %d crop%s won't survive it. Harvest what you can." % [next, "tomorrow" if tomorrow != today else "in three days", doomed, "" if doomed == 1 else "s"]


func _start_harvest(kind: String, tile: Vector2i) -> void:
	m.harvest_kind = kind
	m.harvest_tile = tile
	m.harvest_timer = 0.0
	m.harvest_place = m._place_key()


func _is_harvesting() -> bool:
	return m.harvest_kind != ""


func _stop_harvest(reason: String) -> void:
	m.harvest_kind = ""
	m.harvest_tile = m.NO_SPOT
	if reason != "":
		m._show_message(reason)


func _update_harvest(delta: float) -> void:
	if not _is_harvesting():
		return
	var moved := Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO
	if moved or m.open_tab != "" or m._place_key() != m.harvest_place or m._tile_in_front() != m.harvest_tile:
		_stop_harvest("You stop working.")
		return
	m.harvest_timer -= delta
	if m.harvest_timer > 0.0:
		return
	m.harvest_timer = m.HARVEST_TICK_SECONDS
	var tile := m.harvest_tile
	match m.harvest_kind:
		"chop":
			if m._kind_at(tile) != m.Tile.TREE or not m.GROVE_SPOTS.has(tile - Vector2i(m.BORDER_X, m.BORDER_Y)):
				_stop_harvest("")
				return
			_roll_harvest(m.CHOP_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["hatchet"]), "Chip, chip. The tree is still standing.", func() -> void: m.firewood._finish_chop(tile))
		"mine":
			if not m.rocks.has(tile):
				_stop_harvest("")
				return
			_roll_harvest(m.MINE_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["pick"]), "The rock won't give yet.", func() -> void: m.mining._finish_mine(tile))
		"cave_ore":
			if not (m._kind_at(tile) == m.Tile.ORE_COPPER or m._kind_at(tile) == m.Tile.ORE_IRON):
				_stop_harvest("")
				return
			_roll_harvest(m.MINE_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["pick"]), "The ore won't give yet.", func() -> void: m.mining._finish_cave_ore(tile))
		_:
			_stop_harvest("")
	m.queue_redraw()


# One roll at the given odds. A success ends the roll and runs the finish; a miss says so.
func _roll_harvest(base: float, miss: String, finish: Callable) -> void:
	var chance := clampf(base, 0.0, 0.95)
	if randf() < chance:
		_stop_harvest("")
		finish.call()
	else:
		m._show_message(miss)


# Watering uses one unit from the tank for each crop, and a crop only needs to be watered once a day.
# The hose's head (tool_tier "hose") sets how many crops one press reaches: see _spray_tiles.
func _water_crop(tile: Vector2i) -> void:
	if not m.well_repaired or not m.hose_attached:
		m._show_message("Nothing comes out of the hose. Repair the pump and attach the hose from the Well.")
		return
	if m.well_water < 1.0:
		m._show_message("The tank is dry. It refills each morning.")
		return
	var n := 0
	for t in _spray_tiles(tile):
		if m.well_water < 1.0:
			break
		if m.crops.has(t) and int(m.crops[t]["stage"]) < m.MAX_STAGE and int(m.crops[t].get("watered_day", 0)) != m.day:
			m.well_water -= 1.0
			m.crops[t]["watered_day"] = m.day
			m.stats["watered"] += 1
			n += 1
	if n == 0:
		m._show_message("Everything the hose reaches here is watered today.")
		return
	m.play_sfx("water", 0.08)
	m._show_message(("Watered. " if n == 1 else "Watered %d crops. " % n) + "The tank has %d left." % int(m.well_water))
	m.queue_redraw()


# The tiles one press of the hose waters: the crop you face; with the copper nozzle, the line of three
# running away from you; with the spray head, the 3 by 3 whose near middle is the crop you face.
func _spray_tiles(tile: Vector2i) -> Array:
	var tier := int(m.tool_tier["hose"])
	if tier <= 0:
		return [tile]
	var f: Vector2 = m.player.facing if m.player != null else Vector2.DOWN   # always cardinal
	var ahead := Vector2i(roundi(f.x), roundi(f.y))
	var out: Array = []
	if tier == 1:
		for k in 3:
			out.append(tile + ahead * k)
		return out
	var side := Vector2i(ahead.y, ahead.x)
	for k in 3:
		for s in [-1, 0, 1]:
			out.append(tile + ahead * k + side * s)
	return out


func _watered_today() -> int:
	var n := 0
	for pos in m.crops:
		if int(m.crops[pos].get("watered_day", 0)) == m.day:
			n += 1
	return n


# Every crop feeds you and the animals. Food and offerings count them together (apples aren't crops).
func _crop_total() -> int:
	var total := 0
	for kind in m.CROPS:
		total += int(m.inventory[m.CROPS[kind]["held"]])
	return total


# The crop kinds cheapest first: what the animals and the offerings take first.
func _feed_order() -> Array:
	var kinds: Array = m.CROPS.keys()
	kinds.sort_custom(func(a, b) -> bool: return int(m.CROP_VALUE[a]) < int(m.CROP_VALUE[b]))
	return kinds


# Uses crops for food or offerings, cheapest first (peas, kale and potatoes before turnips; garlic last).
func _spend_crops(amount: int) -> void:
	for kind in _feed_order():
		var key: String = m.CROPS[kind]["held"]
		var take := mini(amount, int(m.inventory[key]))
		m.inventory[key] -= take
		amount -= take


func _crop_price(kind: String) -> int:
	return int(m.CROP_VALUE[kind])


# --- The root cellar: the crops that keep (turnips, potatoes, leeks, parsnips, garlic), CELLAR_CAP in all ---

func _cellar_total() -> int:
	var total := 0
	for key in m.cellar:
		total += int(m.cellar[key])
	return total


func _cellar_keys() -> Array:
	var out: Array = []
	for kind in m.CROPS:
		if bool(m.CROPS[kind]["keeps"]) or m.estate._has("cellar_room"):   # the cellar room keeps every crop
			out.append(str(m.CROPS[kind]["held"]))
	return out


func _keepable_in_pack() -> int:
	var n := 0
	for key in _cellar_keys():
		n += int(m.inventory[key])
	return n


func _store_crops() -> void:
	var stored := 0
	for key in _cellar_keys():
		var amount := mini(int(m.inventory[key]), m.estate._cellar_cap() - _cellar_total())
		if amount <= 0:
			continue
		m.inventory[key] -= amount
		m.cellar[key] = int(m.cellar.get(key, 0)) + amount
		stored += amount
	if stored <= 0:
		m._show_message("Nothing that keeps to store, or the cellar is full.")
		return
	m._show_message("You store %d crops in the cellar." % stored)


func _take_crops() -> void:
	var taken := 0
	for key in _cellar_keys():
		while int(m.cellar.get(key, 0)) > 0 and m.stall._pack_room(int(m.inventory[key]), 1):
			m.inventory[key] += 1
			m.cellar[key] = int(m.cellar[key]) - 1
			taken += 1
	if taken <= 0:
		m._show_message("Your pack is full, or the cellar is empty.")
		return
	m._show_message("You take %d crops from the cellar." % taken)


# Stores (or takes) amount of one crop, or all of it when amount is -1, up to the cellar's room or the pack's.
func _move_crop(key: String, amount: int, storing: bool) -> void:
	if not key in _cellar_keys():
		return
	var name := str(Foods.by_held(key).get("name", key)).to_lower()
	var want := int(m.inventory[key]) if storing else int(m.cellar.get(key, 0))
	if amount >= 0:
		want = mini(want, amount)
	var moved := 0
	for i in want:
		if storing and _cellar_total() >= m.estate._cellar_cap():
			break
		if not storing and not m.stall._pack_room(int(m.inventory[key]), 1):
			break
		m.inventory[key] += -1 if storing else 1
		m.cellar[key] = int(m.cellar.get(key, 0)) + (1 if storing else -1)
		moved += 1
	if moved <= 0:
		m._show_message("The cellar is full." if storing else "Your pack is full.")
		return
	m._show_message("You %s %d %s." % ["store" if storing else "take", moved, name])


# What the cellar holds, as "12 turnip, 3 leek".
func _cellar_text() -> String:
	var parts: Array = []
	for key in _cellar_keys():
		var n := int(m.cellar.get(key, 0))
		if n > 0:
			parts.append("%d %s" % [n, str(Foods.by_held(key).get("name", key)).to_lower()])
	return ", ".join(PackedStringArray(parts)) if not parts.is_empty() else "nothing yet"


func _seed_cells() -> Array:
	var cells: Array = []
	for kind in m.CROPS:
		var c: Dictionary = m.CROPS[kind]
		var lvl := int(c["level"])
		cells.append({"color": str(c["colors"][3]), "label": str(c["label"]), "count": str(m.inventory[c["seed"]]),
			"tip": "%s seeds. Grows in %s.%s" % [str(c["label"]), _seasons_text(kind), (" Farming %d to plant." % lvl) if lvl > 0 else ""]})
	return cells


func _crops_to_array() -> Array:
	var arr: Array = []
	for pos in m.crops:
		var crop: Dictionary = m.crops[pos]
		arr.append({"x": pos.x, "y": pos.y, "stage": crop["stage"], "days": int(crop.get("days", 0)), "kind": crop["kind"], "watered_day": int(crop.get("watered_day", 0))})
	return arr
