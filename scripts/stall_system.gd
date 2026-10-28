class_name StallSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _can_make_bandage() -> bool:
	return m.progression._level("Bushcrafting") >= int(m.BANDAGE["level"]) and m.materials["fiber"] >= int(m.BANDAGE["fiber"]) \
		and m.materials["resin"] >= int(m.BANDAGE["resin"])


func _price_text_items(cost: Dictionary) -> String:
	var parts: Array = []
	for mat in cost.keys():
		parts.append("%d %s" % [int(cost[mat]), mat])
	return ", ".join(parts) if parts.size() > 0 else "free"


# --- Cooking -----------------------------------------------------------------
# The Craft panel's cooking list: every recipe made at the fire.
func _recipes_cooking() -> Array:
	var out: Array = []
	for r in Foods.RECIPES:
		if r["station"] == "fire":
			out.append(_recipe_card(r))
	return out


func _recipe_card(r: Dictionary) -> Dictionary:
	var f := Foods.find(str(r["food"]))
	var costs: Array = []
	for key in r["needs"].keys():
		var need := int(r["needs"][key])
		costs.append({"label": "%d %s" % [need, m._need_label(str(key))], "have": _recipe_held(str(key)), "need": need})
	var skill := str(f["skill"])
	var level := int(f["level"])
	return {
		"key": "cook:" + str(f["id"]), "name": str(f["name"]), "icon": str(f["icon"]), "tint": str(f["tint"]),
		"desc": "%s %s +%d %s XP." % [str(f["desc"]), m._food_stats_text(f), int(r["xp"]), skill],
		"costs": costs, "level_text": m._level_text(skill, level) if level > 0 else "",
		"level_ok": m.progression._level(skill) >= level, "enabled": _can_make(str(f["id"])),
		"action": "cook:" + str(f["id"]), "button": "Cook",
	}


# What a recipe input is held as. Turnips are the crops in the pack, a group (any fish, berries) sums its
# members; the rest are pack or material counts.
func _recipe_held(key: String) -> int:
	return m._held(key)


func _recipe_needs_text(r: Dictionary) -> String:
	var parts: Array = []
	for key in r["needs"].keys():
		parts.append("%d %s" % [int(r["needs"][key]), m._need_label(str(key))])
	return ", ".join(parts)


func _can_make(food_id: String) -> bool:
	var r := Foods.recipe(food_id)
	if r.is_empty():
		return false
	if r["station"] == "smokehouse" and not m.smokehouse_built:
		return false
	var f := Foods.find(food_id)
	if m.progression._level(str(f["skill"])) < int(f["level"]):
		return false
	for key in r["needs"].keys():
		if _recipe_held(str(key)) < int(r["needs"][key]):
			return false
	return true


func _make_food(food_id: String) -> void:
	var r := Foods.recipe(food_id)
	var f := Foods.find(food_id)
	if r.is_empty() or f.is_empty():
		return
	if r["station"] == "smokehouse" and not m.smokehouse_built:
		m._show_message("Build a smokehouse from the House panel first.")
		return
	var skill := str(f["skill"])
	if m.progression._level(skill) < int(f["level"]):
		m._show_message("%s needs %s %d." % [str(f["name"]), skill, int(f["level"])])
		return
	if not _can_make(food_id):
		m._show_message("You need %s to make %s." % [_recipe_needs_text(r), str(f["name"]).to_lower()])
		return
	for key in r["needs"].keys():
		m._spend_recipe_input(str(key), int(r["needs"][key]))
	m.inventory[food_id] += 1
	m.stats["cooked"] += 1
	m.progression._grant_xp(skill, int(r["xp"]))
	m.play_sfx("cook")
	m._show_message("You make %s. +%d %s XP" % [str(f["name"]).to_lower(), int(r["xp"]), skill])


func _eat_food(food_id: String) -> void:
	var f := Foods.find(food_id)
	if f.is_empty():
		return
	var key := str(f["held"])
	if bool(f.get("inedible", false)):
		m._show_message("%s isn't eaten as it is. It goes into a remedy." % str(f["name"]))
		return
	if int(m.inventory[key]) <= 0:
		m._show_message("You have no %s left." % str(f["name"]).to_lower())
		return
	m.inventory[key] -= 1
	m.stats["eaten"] += 1
	m.sanity_sys._change_sanity(Foods.sanity_restore(f))
	m.hp = mini(m.max_hp(), m.hp + Foods.hp_restore(f))
	m.food = minf(100.0, m.food + Foods.food_restore(f))
	# Some foods warm you, slake thirst, or steady a walker on a trek as well.
	var fx: Dictionary = f.get("effect", {})
	var also := ""
	if fx.has("warm"):
		m.warmth = minf(100.0, m.warmth + float(fx["warm"]))
		also += " It warms you through."
	if fx.has("water"):
		m.water = minf(100.0, m.water + float(fx["water"]))
	if fx.has("nerve") and m.trek.active:
		m.trek.nerve = minf(100.0, m.trek.nerve + float(fx["nerve"]))
		also += " You share it with the walker, and they steady."
	if float(fx.get("calm", 0)) < 0.0:
		also += " Something about it stays with you."
	m.play_sfx("eat", 0.05)
	var verb := str(f.get("verb", "Eat")).to_lower()
	m._show_message("You %s the %s. Food %d/100, HP %d/%d%s" % [verb, str(f["name"]).to_lower(), m.food, m.hp, m.max_hp(), also])


# The first cooked food in the pack, for the miller's bread. Empty when there is none.
func _first_cooked() -> String:
	for r in Foods.RECIPES:
		var f := Foods.find(str(r["food"]))
		if int(m.inventory[str(f["held"])]) > 0:
			return str(f["id"])
	return ""


# What the farm stand pays for one. Crops, eggs, milk and perch use main.gd's price constants.
func _food_price(food_id: String) -> int:
	if m.CROP_VALUE.has(food_id):
		return m.farm._crop_price(food_id)
	match food_id:
		"egg":
			return m.SELL_EGG
		"milk":
			return m.SELL_MILK
		"perch":
			return m.SELL_FISH
	return int(Foods.find(food_id).get("price", 0))


func _sell_food(food_id: String) -> void:
	var f := Foods.find(food_id)
	if f.is_empty():
		return
	var key := str(f["held"])
	var count := int(m.inventory[key])
	if count <= 0:
		m._show_message("You have nothing to sell.")
		return
	var price := _food_price(food_id)
	m.inventory[key] = 0
	m.money += count * price
	m.stats["sold"] += count
	m.play_sfx("coin")
	m._show_message("Sold %d for %d coins." % [count, count * price])


func _pack_used() -> int:
	var used := m._slots_for(int(m.inventory["bandage"])) + m._slots_for(int(m.inventory["firewood"]))
	for f in Foods.LIST:
		used += m._slots_for(int(m.inventory[str(f["held"])]))
	return used


# True when adding amount more of a kind that already holds current still fits in the pack's free slots.
func _pack_room(current: int, amount: int) -> bool:
	return m._slots_for(current + amount) - m._slots_for(current) <= _pack_free()


func _pack_capacity() -> int:
	var cap := m.BAG_BASE
	for i in m.bag_tier:
		cap += int(m.BAG_TIERS[i]["slots"])
	return cap


func _pack_free() -> int:
	return _pack_capacity() - _pack_used()


func _price_text(cost: Dictionary) -> String:
	var parts: Array = []
	if int(cost.get("coins", 0)) > 0:
		parts.append("%d coins" % int(cost["coins"]))
	for key in cost.keys():
		if key == "coins" or key == "level" or int(cost[key]) <= 0:
			continue
		parts.append("%d %s" % [int(cost[key]), key])
	parts.append("Carpentry %d" % int(cost.get("level", 1)))
	return ", ".join(parts)


func _open_stall() -> void:
	if m.current_hour >= m.STALL_CLOSE_HOUR:
		m._show_message("The farm stand is shut for the night. It opens at 06:00.")
		return
	m._toggle_tab("Trade")


func _sell(kind: String) -> void:
	var count := int(m.inventory[kind])
	if count <= 0:
		m._show_message("You have nothing to sell.")
		return
	var price := _food_price(str(Foods.by_held(kind).get("id", "")))
	m.inventory[kind] = 0
	m.money += count * price
	m.stats["sold"] += count
	m.play_sfx("coin")
	m._show_message("Sold %d for %d coins." % [count, count * price])


func _pack_cells() -> Array:
	var cells: Array = []
	for f in Foods.LIST:
		for _i in int(m.inventory[str(f["held"])]):
			cells.append({"color": str(f["tint"]), "label": str(f["name"]), "tip": "%s. %s" % [str(f["name"]), m._food_stats_text(f)]})
	for _i in int(m.inventory["firewood"]):
		cells.append({"color": "9a6a3a", "label": "Firewood", "tip": "Split logs for the hearth."})
	while cells.size() < _pack_capacity():
		cells.append({"empty": true, "tip": "Empty slot"})
	return cells
