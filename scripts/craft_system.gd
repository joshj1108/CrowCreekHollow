class_name CraftSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _gear_tiles() -> Array:
	var tiles: Array = []
	var bag_name := "Pack" if m.bag_tier == 0 else str(m.BAG_TIERS[m.bag_tier - 1]["name"])
	tiles.append({
		"key": "slot:back", "name": bag_name, "icon": "pack", "tint": "7a5a3a", "enabled": true,
		"desc": "Your bag. Upgrade it from the Inventory panel.", "level_text": "%d pack slots" % m.stall._pack_capacity(),
		"level_ok": true, "costs": [], "action": "",
	})
	tiles.append(_gear_slot_tile("head", "Head", "hat"))
	tiles.append(_gear_slot_tile("neck", "Neck", "pendant"))
	var lantern := {
		"key": "slot:belt", "name": "Belt", "icon": "lantern", "tint": "8a7a2a", "enabled": false, "level_ok": true,
		"desc": "No lantern yet. Build one in the Craft panel, under Other.", "level_text": "", "costs": [], "action": "",
	}
	if m.lantern_tier > 0:
		var current: Dictionary = m.LANTERN_TIERS[m.lantern_tier - 1]
		lantern["name"] = str(current["name"])
		lantern["enabled"] = true
		lantern["desc"] = "Lights a ring %.1f tiles across. It hangs from your belt." % float(current["radius"])
	tiles.append(lantern)
	tiles.append(_gear_slot_tile("offhand", "Off hand", "shield"))
	tiles.append(_gear_slot_tile("chest", "Chest", "shirt"))
	tiles.append(_gear_slot_tile("hand_r", "Main hand", "sword"))
	tiles.append(_gear_slot_tile("wrist", "Gloves", "glove"))
	tiles.append(_gear_slot_tile("legs", "Legs", "pants"))
	tiles.append(_gear_slot_tile("feet", "Feet", "boots"))
	var spots := {
		"slot:back": Vector2i(0, 1), "slot:head": Vector2i(1, 0), "slot:neck": Vector2i(1, 1),
		"slot:chest": Vector2i(1, 2), "slot:hand_r": Vector2i(0, 2), "slot:offhand": Vector2i(2, 2),
		"slot:wrist": Vector2i(0, 3), "slot:legs": Vector2i(1, 3), "slot:belt": Vector2i(2, 3), "slot:feet": Vector2i(1, 4),
	}
	for t in tiles:
		if spots.has(t["key"]):
			t["pos"] = spots[t["key"]]
	tiles.append({
		"key": "tool:hoe", "name": "Hoe", "icon": "hoe", "tint": "8a6a3a", "enabled": true,
		"desc": "Tills the soil so you can plant.", "level_text": "", "level_ok": true, "costs": [], "action": "",
	})
	tiles.append({
		"key": "tool:axe", "name": _tool_name("hatchet") if int(m.tool_tier["hatchet"]) > 0 else "Axe", "icon": "axe", "tint": m.TINT_TOOL, "enabled": int(m.tool_tier["hatchet"]) > 0,
		"desc": "Chops trees. Upgrade it in the Craft panel, under Tools.", "level_text": "", "level_ok": true, "costs": [], "action": "",
	})
	tiles.append({
		"key": "tool:rod", "name": _tool_name("rod") if int(m.tool_tier["rod"]) > 0 else "Fishing rod", "icon": "rod", "tint": m.TINT_TOOL,
		"enabled": int(m.tool_tier["rod"]) > 0, "level_ok": true, "costs": [], "action": "",
		"desc": "Adds to your catch chance when you fish. Make better rods in the Craft panel, under Tools.", "level_text": "",
	})
	tiles.append({
		"key": "tool:pick", "name": _tool_name("pick") if int(m.tool_tier["pick"]) > 0 else "Pickaxe", "icon": "pick", "tint": m.TINT_TOOL, "enabled": int(m.tool_tier["pick"]) > 0,
		"desc": "Breaks rocks and ore. Upgrade it in the Craft panel, under Tools.", "level_text": "", "level_ok": true, "costs": [], "action": "",
	})
	return tiles


# One worn slot: the piece in it, or a dim empty tile that points to the Craft panel.
func _gear_slot_tile(slot: String, label: String, icon: String) -> Dictionary:
	var id := str(m.equipment[slot])
	var tint := "4a4036"
	if id == "":
		return {
			"key": "slot:" + slot, "name": label, "icon": icon, "tint": tint, "enabled": false,
			"desc": "Nothing worn here. Craft a piece for this slot in the Craft panel.", "level_text": "Empty", "level_ok": true,
			"costs": [], "action": "open_craft", "button": "Craft",
		}
	var item: Dictionary = m.GEAR_ITEMS[id]
	tint = m.TINT_WEAPON if slot == "hand_r" or item.has("ammo") else (m.TINT_ACCESSORY if slot == "neck" or slot == "wrist" else m.TINT_ARMOR)
	var parts: Array = []
	if int(item["dmg"]) > 0:
		parts.append("Damage %d" % int(item["dmg"]))
	if int(item["def"]) > 0:
		parts.append("Armor %d" % int(item["def"]))
	var desc := ", ".join(parts) if not parts.is_empty() else "No damage or armor."
	return {
		"key": "slot:" + slot, "name": str(item["name"]), "icon": icon, "tint": tint, "enabled": true,
		"desc": desc + ".", "level_text": "Worn now", "level_ok": true, "costs": [], "action": "open_craft", "button": "Craft",
	}


func _gear_chosen(tiles: Array) -> Dictionary:
	for t in tiles:
		if str(t["key"]) == m.gear_selected:
			return t
	return tiles[0] if not tiles.is_empty() else {}


func _chosen_recipe(recipes: Array) -> Dictionary:
	for r in recipes:
		if str(r["key"]) == m.craft_selected:
			return r
	return recipes[0] if not recipes.is_empty() else {}


func _craft_recipes() -> Array:
	match m.craft_tab:
		"cooking":
			return m.stall._recipes_cooking()
		"tools":
			return _recipes_tools()
		"other":
			return _recipes_other()
	return _recipes_gear()


func _craft_footer() -> String:
	match m.craft_tab:
		"cooking":
			return "Eat meals from the Inventory panel. Smoking and preserving are done at the smokehouse, and smelting at the furnace."
		"tools":
			return "Tools are kept by tier rather than worn in a slot. Upgrade them one tier at a time."
		"other":
			return "The lantern hangs from the belt and lights a ring around you in the dark."
	return "Crafted gear equips at once and replaces what was worn in that slot. Armor cuts damage from foes. Weapons decide how hard you hit."


func _recipes_gear() -> Array:
	var out: Array = []
	for id in m.GEAR_ITEMS.keys():
		if id == "hoe":
			continue
		var item: Dictionary = m.GEAR_ITEMS[id]
		var worn: bool = str(m.equipment[item["slot"]]) == str(id)
		var skill := str(item.get("skill", "Bushcrafting"))
		var level := int(item["level"])
		var parts: Array = []
		if int(item.get("dmg", 0)) > 0:
			parts.append("Damage %d" % int(item["dmg"]))
		if int(item.get("def", 0)) > 0:
			parts.append("Armor %d" % int(item["def"]))
		var desc := ", ".join(parts) if not parts.is_empty() else "No damage or armor."
		desc += ". Worn %s." % str(item["slot"]).replace("_", " ")
		if worn:
			desc = "Already worn. " + desc
		var tint := m.TINT_WEAPON
		if item.has("ammo"):
			tint = m.TINT_WEAPON
		elif str(item["slot"]) in ["head", "chest", "legs", "feet", "offhand"]:
			tint = m.TINT_ARMOR
		elif str(item["slot"]) in ["neck", "wrist"]:
			tint = m.TINT_ACCESSORY
		out.append({
			"key": "gear:" + str(id), "name": str(item["name"]), "icon": m._slot_icon(item), "tint": tint,
			"desc": desc, "costs": m._cost_lines(item["cost"]), "level_text": m._level_text(skill, level),
			"level_ok": m.progression._level(skill) >= level, "enabled": _can_craft(str(id)), "action": "craft:" + str(id),
			"button": "Worn" if worn else "Make",
		})
	return out


func _recipes_tools() -> Array:
	var out: Array = []
	for kind in ["hatchet", "pick", "rod"]:
		var tiers: Array = m.TOOL_TIERS[kind]
		var have := int(m.tool_tier[kind])
		var icon := "axe" if kind == "hatchet" else ("pick" if kind == "pick" else "rod")
		if have >= tiers.size():
			out.append({
				"key": "tool:" + kind, "name": _tool_name(kind), "icon": icon, "tint": m.TINT_TOOL,
				"desc": "You have the best %s there is." % kind, "costs": [], "level_text": "", "level_ok": true,
				"enabled": false, "action": "", "button": "Best",
			})
			continue
		var tier: Dictionary = tiers[have]
		out.append({
			"key": "tool:" + kind, "name": str(tier["name"]), "icon": icon, "tint": m.TINT_TOOL,
			"desc": _tool_desc(kind, tier, have),
			"costs": m._cost_lines(tier["cost"]), "level_text": m._level_text(str(tier["skill"]), int(tier["level"])),
			"level_ok": m.progression._level(str(tier["skill"])) >= int(tier["level"]), "enabled": _can_craft_tool(kind),
			"action": "tool:" + kind, "button": "Make",
		})
	for kind in ["arrows", "bolts"]:
		var ammo: Dictionary = m.AMMO[kind]
		out.append({
			"key": "ammo:" + kind, "name": str(ammo["name"]), "icon": "arrow", "tint": m.TINT_TOOL,
			"desc": "Makes %d at a time. You hold %d." % [int(ammo["yield"]), int(m.materials[kind])],
			"costs": m._cost_lines(ammo["cost"]), "level_text": m._level_text(str(ammo["skill"]), int(ammo["level"])),
			"level_ok": m.progression._level(str(ammo["skill"])) >= int(ammo["level"]), "enabled": m._can_fletch(kind),
			"action": "ammo:" + kind, "button": "Make",
		})
	return out


func _recipes_other() -> Array:
	var out: Array = []
	if m.lantern_tier < m.LANTERN_TIERS.size():
		var t: Dictionary = m.LANTERN_TIERS[m.lantern_tier]
		var costs: Array = [
			{"label": "%d wood" % int(t["wood"]), "have": m._held("wood"), "need": int(t["wood"])},
			{"label": "%d fiber" % int(t["fiber"]), "have": m._held("fiber"), "need": int(t["fiber"])},
		]
		if int(t["resin"]) > 0:
			costs.append({"label": "%d resin" % int(t["resin"]), "have": m._held("resin"), "need": int(t["resin"])})
		var desc := "Lights a ring %.1f tiles across. It hangs from your belt." % float(t["radius"])
		if m.lantern_tier > 0:
			desc = "You have the %s. %s" % [m.LANTERN_TIERS[m.lantern_tier - 1]["name"], desc]
		out.append({
			"key": "lantern", "name": str(t["name"]), "icon": "lantern", "tint": m.TINT_LIGHT,
			"desc": desc, "costs": costs, "level_text": m._level_text("Bushcrafting", int(t["level"])),
			"level_ok": m.progression._level("Bushcrafting") >= int(t["level"]), "enabled": m._can_advance_lantern(),
			"action": "advance_lantern", "button": "Build" if m.lantern_tier == 0 else "Upgrade",
		})
	out.append(m._recipes_other_bandage())
	out.append(m.trek._rope_recipe())
	out.append(m.nights._charm_recipe())
	return out


func _make_bandage() -> void:
	if not m.stall._can_make_bandage():
		m._show_message("You need %d fiber, %d resin, and Bushcrafting %d." % [int(m.BANDAGE["fiber"]), int(m.BANDAGE["resin"]), int(m.BANDAGE["level"])])
		return
	m.materials["fiber"] -= int(m.BANDAGE["fiber"])
	m.materials["resin"] -= int(m.BANDAGE["resin"])
	m.inventory["bandage"] += 1
	m.progression._grant_xp("Bushcrafting", int(m.BANDAGE["xp"]))
	m.play_sfx("cloth")
	m._show_message("You roll a bandage. +%d Bushcrafting XP" % int(m.BANDAGE["xp"]))


func _tool_desc(kind: String, tier: Dictionary, have: int) -> String:
	if kind == "rod":
		var now := "You have no rod yet." if have == 0 else "You have the %s." % _tool_name("rod")
		return "%s Adds %d%% to your catch chance." % [now, int(float(tier["bonus"]) * 100.0)]
	return "Your %s is %s. This is the next tier." % [kind, _tool_name(kind)]


func _tool_name(kind: String) -> String:
	var have := int(m.tool_tier[kind])
	if have == 0:
		return "none"
	return str(m.TOOL_TIERS[kind][have - 1]["name"])


func _can_craft_tool(kind: String) -> bool:
	var have := int(m.tool_tier[kind])
	var tiers: Array = m.TOOL_TIERS[kind]
	if have >= tiers.size():
		return false
	var tier: Dictionary = tiers[have]
	if m.progression._level(str(tier["skill"])) < int(tier["level"]):
		return false
	return m._has_materials(tier["cost"])


func _craft_tool(kind: String) -> void:
	if not _can_craft_tool(kind):
		m._show_message("You need the materials and skill level for the next %s." % kind)
		return
	m.progression._bump("crafted")
	var tier: Dictionary = m.TOOL_TIERS[kind][int(m.tool_tier[kind])]
	for mat in tier["cost"].keys():
		m.materials[mat] -= int(tier["cost"][mat])
	m.tool_tier[kind] += 1
	m.progression._grant_xp(str(tier["skill"]), 10)
	m.play_sfx("craft")
	m._show_message("You make a %s. +10 %s XP" % [tier["name"], tier["skill"]])


func _craft_ammo(kind: String) -> void:
	if not m._can_fletch(kind):
		m._show_message("You need the materials and skill level to make %s." % kind)
		return
	var ammo: Dictionary = m.AMMO[kind]
	for mat in ammo["cost"].keys():
		m.materials[mat] -= int(ammo["cost"][mat])
	m.materials[kind] += int(ammo["yield"])
	m.progression._grant_xp(str(ammo["skill"]), 6)
	m.play_sfx("craft")
	m._show_message("You make %d %s. +6 %s XP" % [int(ammo["yield"]), kind, ammo["skill"]])


func _can_craft(id: String) -> bool:
	var item: Dictionary = m.GEAR_ITEMS[id]
	if str(m.equipment[item["slot"]]) == id:
		return false
	if m.progression._level(str(item.get("skill", "Bushcrafting"))) < int(item["level"]):
		return false
	var cost: Dictionary = item["cost"]
	for mat in cost.keys():
		if int(m.materials[mat]) < int(cost[mat]):
			return false
	return true


func _craft_gear(id: String) -> void:
	if not _can_craft(id):
		m._show_message("You don't have the materials, or Bushcrafting is too low for that.")
		return
	var item: Dictionary = m.GEAR_ITEMS[id]
	var cost: Dictionary = item["cost"]
	for mat in cost.keys():
		m.materials[mat] -= int(cost[mat])
	m.equipment[item["slot"]] = id
	m.progression._grant_xp(str(item.get("skill", "Bushcrafting")), 10)
	m.play_sfx("craft")
	m._show_message("You fashion a %s and equip it. +10 %s XP" % [item["name"], item.get("skill", "Bushcrafting")])
