class_name MiningSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _gather(tile: Vector2i) -> void:
	m.play_sfx("gather", 0.05)
	m.brush.erase(tile)
	m.materials["sticks"] += 2
	m.materials["fiber"] += 1
	m.stats["gathered"] += 1
	var found := "sticks and fiber"
	if randf() < 0.34:
		m.materials["resin"] += 1
		found = "sticks, fiber, and resin"
	m.progression._grant_xp("Bushcrafting", m.XP_GATHER)
	m._show_message("Gathered %s from the brush. +%d Bushcrafting XP" % [found, m.XP_GATHER])
	m.queue_redraw()


func _mine(tile: Vector2i) -> void:
	# Breaking a rock keeps rolling each tick until it gives way. Moving away stops it.
	m.farm._start_harvest("mine", tile)
	m._show_message("You start working the rock.")


func _finish_mine(tile: Vector2i) -> void:
	m.play_sfx("rock_break", 0.06)
	m.rocks.erase(tile)
	var pick := int(m.tool_tier["pick"])
	var amount := 2 if pick >= 1 else 1
	m.materials["stone"] += amount
	var found := "%d stone" % amount
	if pick >= 1 and m.progression._level("Mining") >= m.ORE_MINING_LEVEL and randf() < m.ORE_CHANCE:
		m.materials["copper_ore"] += 1
		found += " and copper ore"
	m.stats["mined"] += 1
	m.progression._grant_xp("Mining", m.XP_MINE)
	m._show_message("You break the rock. +%s. +%d Mining XP" % [found, m.XP_MINE])
	m.queue_redraw()


# The furnace makes SMELT_DAILY_LIMIT bars a day, so stockpiled ore can't buy several Smithing levels at once.
func _smelts_left() -> int:
	var used: int = m.smelts_today if m.smelt_day == m.day else 0
	return m.SMELT_DAILY_LIMIT - used


func _can_smelt(kind: String) -> bool:
	if not m.furnace_built or _smelts_left() <= 0:
		return false
	if m.progression._level("Smithing") < int(m.SMELT_LEVEL[kind]):
		return false
	return int(m.materials[kind + "_ore"]) >= 1 and int(m.materials["wood"]) >= 1


func _smelt(kind: String) -> void:
	if not m.furnace_built:
		m._show_message("Build a furnace from the House panel first.")
		return
	if _smelts_left() <= 0:
		m._show_message("The furnace needs to cool. Come back tomorrow.")
		return
	if not _can_smelt(kind):
		m._show_message("You need %s ore, a piece of wood, and Smithing %d." % [kind, int(m.SMELT_LEVEL[kind])])
		return
	if m.smelt_day != m.day:
		m.smelt_day = m.day
		m.smelts_today = 0
	m.smelts_today += 1
	m.materials[kind + "_ore"] -= 1
	m.materials["wood"] -= 1
	m.materials[kind + "_bar"] += 1
	m.play_sfx("smelt", 0.04)
	m.progression._grant_xp("Smithing", m.XP_SMELT)
	m._show_message("You smelt a %s bar. +%d Smithing XP" % [kind, m.XP_SMELT])


func _fill_quarry() -> void:
	m.quarry.clear()
	for spot in m.ASHFORD_QUARRY:
		m.quarry[m.ASHFORD_ORIGIN + spot] = true


func _quarry(tile: Vector2i) -> void:
	var pick := int(m.tool_tier["pick"])
	if pick < 1:
		m._show_message("The quarry rock is too hard for your hands. Craft a stone pick from the Craft panel.")
		return
	m.farm._start_harvest("quarry", tile)
	m._show_message("You start working the quarry rock.")


func _finish_quarry(tile: Vector2i) -> void:
	var pick := int(m.tool_tier["pick"])
	m.play_sfx("rock_break", 0.06)
	m.quarry.erase(tile)
	var kind := "copper_ore" if m.progression._level("Mining") >= 3 else "stone"
	if m.progression._level("Mining") >= 5 and pick >= 2 and randf() < 0.5:
		kind = "iron_ore"
	m.materials[kind] += 1
	m.stats["mined"] += 1
	m.progression._grant_xp("Mining", m.XP_MINE)
	m._show_message("You work the quarry rock. +1 %s. +%d Mining XP" % [kind.replace("_", " "), m.XP_MINE])
	m.queue_redraw()


# Copper needs a stone pick and Mining 2. Iron needs a copper pick and Mining 5.
func _mine_cave(tile: Vector2i, kind: int) -> void:
	var iron := kind == m.Tile.ORE_IRON
	var need_pick := 2 if iron else 1
	var need_level := 5 if iron else 2
	var ore := "iron" if iron else "copper"
	if int(m.tool_tier["pick"]) < need_pick:
		m._show_message("The %s ore is too hard for your hands. Craft a %s pick from the Craft panel." % [ore, "copper" if iron else "stone"])
		return
	if m.progression._level("Mining") < need_level:
		m._show_message("You need Mining %d to work %s ore." % [need_level, ore])
		return
	m.farm._start_harvest("cave_ore", tile)
	m._show_message("You start working the %s ore." % ore)


func _finish_cave_ore(tile: Vector2i) -> void:
	var iron := m._kind_at(tile) == m.Tile.ORE_IRON
	var ore := "iron" if iron else "copper"
	m.play_sfx("rock_break", 0.06)
	m.cave[tile.y][tile.x] = m.Tile.FLOOR
	m.cave_mined[tile] = true
	m.materials[ore + "_ore"] += 1
	m.progression._grant_xp("Mining", m.XP_MINE)
	m._show_message("You break the %s ore. +1 %s ore. +%d Mining XP" % [ore, ore, m.XP_MINE])
	m.queue_redraw()
