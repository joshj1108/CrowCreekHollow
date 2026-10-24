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


# What a recipe input is held as. Turnips are the crops in the pack; the rest are pack or material counts.
func _recipe_held(key: String) -> int:
	if key == "turnips":
		return int(m.inventory["crops"])
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
	m._show_message("You make %s. +%d %s XP" % [str(f["name"]).to_lower(), int(r["xp"]), skill])


func _eat_food(food_id: String) -> void:
	var f := Foods.find(food_id)
	if f.is_empty():
		return
	var key := str(f["held"])
	if int(m.inventory[key]) <= 0:
		m._show_message("You have no %s left." % str(f["name"]).to_lower())
		return
	m.inventory[key] -= 1
	m.stats["eaten"] += 1
	m.sanity_sys._change_sanity(Foods.sanity_restore(f))
	m.hp = mini(m.max_hp(), m.hp + Foods.hp_restore(f))
	m.food = minf(100.0, m.food + Foods.food_restore(f))
	m.play_sfx("eat", 0.05)
	var verb := str(f.get("verb", "Eat")).to_lower()
	m._show_message("You %s the %s. Food %d/100, HP %d/%d" % [verb, str(f["name"]).to_lower(), m.food, m.hp, m.max_hp()])


# The first cooked food in the pack, for the miller's bread. Empty when there is none.
func _first_cooked() -> String:
	for r in Foods.RECIPES:
		var f := Foods.find(str(r["food"]))
		if int(m.inventory[str(f["held"])]) > 0:
			return str(f["id"])
	return ""


func _food_price(food_id: String) -> int:
	if food_id == "turnip":
		return m.farm._crop_price("turnip")
	if food_id == "pumpkin":
		return m.farm._crop_price("pumpkin")
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
	m._show_message("Sold %d for %d coins." % [count, count * price])


func _pack_used() -> int:
	var used := m._slots_for(int(m.inventory["fish"])) + m._slots_for(int(m.inventory["bandage"])) + m._slots_for(int(m.inventory["firewood"]))
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
	var price := m.farm._crop_price("pumpkin") if kind == "pumpkins" else m.farm._crop_price("turnip")
	if kind == "fish":
		price = m.SELL_FISH
	if kind == "eggs":
		price = m.SELL_EGG
	if kind == "milk":
		price = m.SELL_MILK
	m.inventory[kind] = 0
	m.money += count * price
	m.stats["sold"] += count
	m._show_message("Sold %d for %d coins." % [count, count * price])


func _buy_material(key: String) -> void:
	if not m.GENERAL_BUY.has(key):
		return
	var price := int(m.GENERAL_BUY[key]) * m.GENERAL_BUY_QTY
	if m.money < price:
		m._show_message("That costs %d coins. You have %d." % [price, m.money])
		return
	m.money -= price
	m.materials[key] += m.GENERAL_BUY_QTY
	m._show_message("You buy %d %s for %d coins." % [m.GENERAL_BUY_QTY, key, price])


func _sell_material(key: String) -> void:
	if not m.GENERAL_BUY.has(key):
		return
	var count := int(m.materials[key])
	if count <= 0:
		m._show_message("You have none of that to sell.")
		return
	var price := maxi(1, int(m.GENERAL_BUY[key]) / 2)
	m.materials[key] = 0
	m.money += count * price
	m._show_message("Sold %d %s for %d coins." % [count, key, count * price])


func _bank_move(action_id: String) -> void:
	var deposit := action_id.begins_with("dep:")
	var key := action_id.trim_prefix("dep:") if deposit else action_id.trim_prefix("wd:")
	if key == "coins":
		if deposit:
			m.bank_coins += m.money
			m._show_message("You bank %d coins." % m.money)
			m.money = 0
		else:
			m.money += m.bank_coins
			m._show_message("You take %d coins from the bank." % m.bank_coins)
			m.bank_coins = 0
		return
	if not m.bank_materials.has(key):
		return
	if deposit:
		m.bank_materials[key] += int(m.materials[key])
		m.materials[key] = 0
	else:
		m.materials[key] += int(m.bank_materials[key])
		m.bank_materials[key] = 0


func _pack_cells() -> Array:
	var cells: Array = []
	for f in Foods.LIST:
		for _i in int(m.inventory[str(f["held"])]):
			cells.append({"color": str(f["tint"]), "label": str(f["name"]), "tip": "%s. %s" % [str(f["name"]), m._food_stats_text(f)]})
	for _i in int(m.inventory["firewood"]):
		cells.append({"color": "9a6a3a", "label": "Firewood", "tip": "Split logs for the hearth."})
	for _i in int(m.inventory["fish"]):
		cells.append({"color": "6fb8d9", "label": "Fish", "tip": "Fish. Spoils overnight unless stored in the cooler."})
	while cells.size() < _pack_capacity():
		cells.append({"empty": true, "tip": "Empty slot"})
	return cells
