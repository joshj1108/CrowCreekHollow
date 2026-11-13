extends "res://tools/balance_sim.gd"

# CCH-PLAYABLE-001: the progression probe. It is tools/balance_sim.gd (same options, same strategy, same game
# functions, slot 8) with read-only bookkeeping added: each day it notes which progression state first became
# true (chapters, house stages, lantern and tool tiers, Agnes's pages, letters, night visitors, treks, buildings,
# furniture, extensions, materials and foods ever held, recipes that were ever makeable, seasons, weather), and
# at the end it lists what was NEVER reached in the run. Nothing in the game is changed.
#   godot --path . --headless -s tools/audit_probe.gd -- mode=engaged days=400 every=40 treks=3
# "Reached" here means the sim's strategy got there through the game's own functions; it is not a played game.
# "Never" means this strategy never did, which is a lead to check by hand, not proof it is impossible: the sim
# does not fight, fishes only when hungry and never visits the cave's creatures.

var ever := {}          # category -> {name -> first day}
var last_season := ""


func _first(cat: String, name: String) -> void:
	if not ever.has(cat):
		ever[cat] = {}
	if not ever[cat].has(name):
		ever[cat][name] = m.day


func _note_milestones() -> void:
	super._note_milestones()
	for id in m.quests_done:
		_first("chapter", str(id))
	for s in range(1, m.house_stage + 1):
		_first("house stage", str(s))
	for t in range(1, m.lantern_tier + 1):
		_first("lantern tier", str(t))
	for kind in m.tool_tier:
		for t in range(1, int(m.tool_tier[kind]) + 1):
			_first("tool", "%s %d" % [kind, t])
	for t in range(1, int(m.bag_tier) + 1):
		_first("bag tier", str(t))
	for id in m.mystery.found:
		_first("page", str(id))
	for letter in m.desk_mail:
		if letter is Dictionary:
			_first("letter", str(letter.get("title", "?")))
	for id in m.nights.seen:
		_first("night", str(id))
	for id in m.trek.walked:
		_first("trek", str(id))
	if m.trek.edge_done:
		_first("trek", "edge")
	if m.trek.grove_done:
		_first("trek", "grove (walked)")
	for id in m.trek.works:
		_first("trail work", str(id))
	for flag in ["cellar_built", "cooler_built", "smokehouse_built", "furnace_built", "woodshed_built", "coop_built",
			"barn_built", "well_repaired", "hose_attached", "cistern_built"]:
		if bool(m.get(flag)):
			_first("building", flag)
	if m.hens > 0:
		_first("building", "hens kept")
	if m.goats > 0:
		_first("building", "goats kept")
	for id in m.estate.built:
		_first("extension", str(id))
	for id in m.estate.furniture:
		_first("furniture", str(id))
	_first("paint", str(m.estate.paint))
	_first("paper", str(m.estate.paper))
	if m.estate.deed_offered:
		_first("deed", "offered")
	if m.estate._deed_owned():
		_first("deed", "owned")
	for k in m.materials:
		if int(m.materials[k]) > 0:
			_first("material", str(k))
	for k in m.inventory:
		if (m.inventory[k] is int or m.inventory[k] is float) and int(m.inventory[k]) > 0:
			_first("pack item", str(k))
	for slot in m.equipment:
		if str(m.equipment[slot]) != "":
			_first("gear worn", str(m.equipment[slot]))
	var tab0: String = m.craft_tab
	for tab in ["gear", "cooking", "tools", "other"]:
		m.craft_tab = tab
		for r in m.crafting._craft_recipes():
			_first("recipe seen", "%s/%s" % [tab, str(r.get("key", r.get("name", "?")))])
			if bool(r.get("enabled", false)):
				_first("recipe makeable", "%s/%s" % [tab, str(r.get("key", r.get("name", "?")))])
	m.craft_tab = tab0
	var season := str(m._season_today())
	if season != last_season:
		last_season = season
		_first("season", "%s (year %d)" % [season, 1 + (m.day - 1) / 365])
	_first("weather", str(m.weather_kind))
	for id in m.folk.requests_done:
		_first("request", str(id))
	for id in FolkSystem.IDS:
		for h in range(1, m.folk._hearts(id) + 1):
			_first("hearts", "%s %d" % [id, h])


func _summary() -> void:
	super._summary()
	print("=== PROBE: first day each thing was reached (mode=%s, %d days, treks=%d) ===" % [mode, m.day, treks_a_week])
	var cats := ever.keys()
	cats.sort()
	for cat in cats:
		var names: Array = ever[cat].keys()
		names.sort_custom(func(a, b) -> bool: return int(ever[cat][a]) < int(ever[cat][b]))
		var parts: Array = []
		for n in names:
			parts.append("%s=%d" % [n, int(ever[cat][n])])
		print("PROBE %s: %s" % [cat, ", ".join(parts)])
	print("=== PROBE: never reached in this run ===")
	_never("chapter", m.STORY.map(func(q): return str(q["id"])))
	_never("page", Mystery.PAGES.map(func(p): return str(p["id"])) + Mystery.TREK_PAGES.map(func(p): return str(p["id"])))
	_never("extension", EstateSystem.EXTENSIONS.keys())
	_never("furniture", EstateSystem.FURNITURE.keys())
	_never("paint", EstateSystem.PAINTS.keys())
	_never("paper", EstateSystem.PAPERS.keys())
	_never("trek", TrekSystem.ROUTES.keys())
	_never("trail work", TrekSystem.WORKS.keys())
	_never("material", m.materials.keys())
	_never("house stage", ["1", "2", "3"])
	_never("lantern tier", range(1, m.LANTERN_TIERS.size() + 1).map(func(i): return str(i)))
	var tools: Array = []
	for kind in m.TOOL_TIERS:
		for t in range(1, m.TOOL_TIERS[kind].size() + 1):
			tools.append("%s %d" % [kind, t])
	_never("tool", tools)
	_never("bag tier", range(1, m.BAG_TIERS.size()).map(func(i): return str(i)))
	_never("night", NightSystem.VISITORS.map(func(v): return str(v["id"])) + ["hollow", "raid"])
	_never("request", FolkSystem.REQUESTS.map(func(r): return str(r["id"])))
	var hearts: Array = []
	for id in FolkSystem.IDS:
		hearts.append("%s %d" % [id, 8])
	_never("hearts", hearts)
	var seen: Dictionary = ever.get("recipe seen", {})
	var made: Dictionary = ever.get("recipe makeable", {})
	var not_made: Array = []
	for k in seen:
		if not made.has(k):
			not_made.append(str(k))
	not_made.sort()
	print("NEVER recipe makeable (%d of %d listed): %s" % [not_made.size(), seen.size(), ", ".join(not_made)])
	var undone: Array = []
	for s in m.projects._steps():
		if not bool(s["done"]):
			undone.append(str(s["id"]))
	print("NEVER homestead step (%d): %s" % [undone.size(), ", ".join(undone)])


func _never(cat: String, all: Array) -> void:
	var got: Dictionary = ever.get(cat, {})
	var missing: Array = []
	for n in all:
		if not got.has(str(n)):
			missing.append(str(n))
	print("NEVER %s (%d of %d): %s" % [cat, missing.size(), all.size(), ", ".join(missing)])
