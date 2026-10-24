class_name FarmSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _seed_label(kind: String) -> String:
	return "Pumpkin" if kind == "pumpkin" else "Turnip"


# Steps through the seeds you have in the pouch: turnip always, pumpkin once Farming reaches its level.
func _cycle_seed(step: int) -> void:
	var options: Array = []
	for kind in ["turnip", "pumpkin"]:
		if kind == "pumpkin" and m._level("Farming") < m.PUMPKIN_LEVEL:
			continue
		if int(m.inventory[m.CROPS[kind]["seed"]]) > 0:
			options.append(kind)
	if options.is_empty():
		m._show_message("You have no seeds to plant.")
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
	m.selected_seed = "turnip" if m.selected_seed == "pumpkin" else "pumpkin"
	m._show_message("You'll plant %s seeds now." % _seed_label(m.selected_seed).to_lower())


# Opens the third plot once Farming reaches level 4 and the house is at least Patched.
func _check_plot_three() -> void:
	if m.plot_three_open or m._level("Farming") < m.PLOT_THREE_LEVEL or m.house_stage < 2:
		return
	m.plot_three_open = true
	for y in range(m.PLOT_THREE.position.y, m.PLOT_THREE.end.y):
		for x in range(m.PLOT_THREE.position.x, m.PLOT_THREE.end.x):
			m.map[y + m.BORDER_Y][x + m.BORDER_X] = m.Tile.SOIL
	m.queue_redraw()


# Opens the second plot once Farming reaches level 2. It stays open afterward.
func _check_unlocks() -> void:
	_check_plot_three()
	if m.plot_two_open or m._level("Farming") < 2:
		return
	m.plot_two_open = true
	for y in range(m.PLOT_TWO.position.y, m.PLOT_TWO.end.y):
		for x in range(m.PLOT_TWO.position.x, m.PLOT_TWO.end.x):
			m.map[y + m.BORDER_Y][x + m.BORDER_X] = m.Tile.SOIL
	m.queue_redraw()


func _plant(tile: Vector2i) -> void:
	m.play_sfx("plant", 0.06)
	var kind := m.selected_seed
	if kind == "pumpkin" and m._level("Farming") < m.PUMPKIN_LEVEL:
		kind = "turnip"
	var seed_key: String = m.CROPS[kind]["seed"]
	if m.inventory[seed_key] <= 0:
		m._show_message("You're out of %s seeds." % _seed_label(kind).to_lower())
		return
	m.inventory[seed_key] -= 1
	m.crops[tile] = {"stage": 0, "kind": kind, "days": 0}
	if m.weather_kind in m.WATER_RAIN_KINDS:
		m.crops[tile]["watered_day"] = m.day
	m.stats["planted"] += 1
	m._grant_xp("Farming", m.XP_PLANT)
	m._show_message("Planted %s. +%d Farming XP" % [_seed_label(kind).to_lower(), m.XP_PLANT])


func _harvest(tile: Vector2i) -> void:
	m.play_sfx("harvest", 0.06)
	var kind: String = m.crops[tile]["kind"]
	var yield_count: int = m.CROPS[kind]["yield"]
	# Harvests go to the pack only. Storing in the cellar is up to the player.
	var held := int(m.inventory["pumpkins" if kind == "pumpkin" else "crops"])
	if not m._pack_room(held, yield_count):
		m._show_message("Your pack is full. Store crops in the root cellar, or sell them.")
		return
	if kind == "pumpkin":
		m.inventory["pumpkins"] += yield_count
	else:
		m.inventory["crops"] += yield_count
	m.crops.erase(tile)
	m.stats["harvested"] += 1
	if kind == "pumpkin":
		m.stats["pumpkins"] += 1
		m.inventory["pumpkin_seeds"] += 1
	else:
		m.inventory["seeds"] += 1
	var xp: int = m.CROPS[kind]["xp"]
	m._grant_xp("Farming", xp)
	m._show_message("Harvested %s for %d %s. +%d Farming XP" % [_seed_label(kind).to_lower(), yield_count, "pumpkins" if kind == "pumpkin" else "crops", xp])


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
			_roll_harvest(m.CHOP_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["hatchet"]), "Chip, chip. The tree is still standing.", func() -> void: m._finish_chop(tile))
		"mine":
			if not m.rocks.has(tile):
				_stop_harvest("")
				return
			_roll_harvest(m.MINE_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["pick"]), "The rock won't give yet.", func() -> void: m._finish_mine(tile))
		"quarry":
			if not m.quarry.has(tile):
				_stop_harvest("")
				return
			_roll_harvest(m.MINE_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["pick"]), "The quarry rock won't give yet.", func() -> void: m._finish_quarry(tile))
		"cave_ore":
			if not (m._kind_at(tile) == m.Tile.ORE_COPPER or m._kind_at(tile) == m.Tile.ORE_IRON):
				_stop_harvest("")
				return
			_roll_harvest(m.MINE_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["pick"]), "The ore won't give yet.", func() -> void: m._finish_cave_ore(tile))
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
		m.play_sfx("strike", 0.05)
		m._show_message(miss)


# Watering uses one unit from the tank, and a crop only needs to be watered once a day.
func _water_crop(tile: Vector2i) -> void:
	if not m.well_repaired or not m.hose_attached:
		m._show_message("Nothing comes out of the hose. Repair the pump and attach the hose from the Well.")
		return
	if m.well_water < 1.0:
		m._show_message("The tank is dry. It refills each morning.")
		return
	m.well_water -= 1.0
	m.play_sfx("water", 0.08)
	m.crops[tile]["watered_day"] = m.day
	m.stats["watered"] += 1
	m._show_message("Watered. The tank has %d left." % int(m.well_water))
	m.queue_redraw()


func _watered_today() -> int:
	var n := 0
	for pos in m.crops:
		if int(m.crops[pos].get("watered_day", 0)) == m.day:
			n += 1
	return n


# Turnips and pumpkins both feed you and cook into meals. Food and cooking count them together.
func _crop_total() -> int:
	return int(m.inventory["crops"]) + int(m.inventory["pumpkins"])


# Uses crops for food or cooking, taking turnips first and then pumpkins.
func _spend_crops(amount: int) -> void:
	var from_crops := mini(amount, int(m.inventory["crops"]))
	m.inventory["crops"] -= from_crops
	m.inventory["pumpkins"] -= amount - from_crops


# How much one crop sells for: its seed's cost spread over its yield, plus its difficulty.
func _crop_price(kind: String) -> int:
	return int(m.CROP_VALUE[kind])


func _buy_seeds(kind: String) -> void:
	if kind == "pumpkin":
		if m._level("Farming") < m.PUMPKIN_LEVEL:
			m._show_message("Pumpkin seeds need Farming level %d." % m.PUMPKIN_LEVEL)
			return
		var pumpkin_total := m.SEED_PUMPKIN_PRICE * 3
		if m.money < pumpkin_total:
			m._show_message("Three pumpkin seeds cost %d coins." % pumpkin_total)
			return
		m.money -= pumpkin_total
		m.inventory["pumpkin_seeds"] += 3
		m._show_message("You buy 3 pumpkin seeds for %d coins." % pumpkin_total)
		return
	var turnip_total := m.SEED_TURNIP_PRICE * 5
	if m.money < turnip_total:
		m._show_message("Five turnip seeds cost %d coins." % turnip_total)
		return
	m.money -= turnip_total
	m.inventory["seeds"] += 5
	m._show_message("You buy 5 turnip seeds for %d coins." % turnip_total)


func _store_crops() -> void:
	var amount := mini(int(m.inventory["crops"]), m.CELLAR_CAP - m.cellar_stock)
	if amount <= 0:
		m._show_message("Nothing to store, or the cellar is full.")
		return
	m.inventory["crops"] -= amount
	m.cellar_stock += amount
	m._show_message("You store %d crops in the cellar." % amount)


func _take_crops() -> void:
	var amount := mini(m.cellar_stock, m._pack_free())
	if amount <= 0:
		m._show_message("Your pack is full, or the cellar is empty.")
		return
	m.cellar_stock -= amount
	m.inventory["crops"] += amount
	m._show_message("You take %d crops from the cellar." % amount)


func _seed_cells() -> Array:
	return [
		{"color": "a8d46f", "label": "Turnip", "count": str(m.inventory["seeds"]), "tip": "Turnip seeds. Kept in the seed pouch."},
		{"color": "d98a35", "label": "Pumpkin", "count": str(m.inventory["pumpkin_seeds"]), "tip": "Pumpkin seeds. Farming %d to plant." % m.PUMPKIN_LEVEL},
	]


func _crops_to_array() -> Array:
	var arr: Array = []
	for pos in m.crops:
		var crop: Dictionary = m.crops[pos]
		arr.append({"x": pos.x, "y": pos.y, "stage": crop["stage"], "days": int(crop.get("days", 0)), "kind": crop["kind"], "watered_day": int(crop.get("watered_day", 0))})
	return arr
