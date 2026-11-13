extends "res://tools/balance_sim.gd"

# CCH-LOOP-001: the daily-activity audit's availability probe. It plays the balance sim's day (the same strategy,
# through the game's own functions; walking and real time are not modelled) and, at six points of each day, records
# what a player could worthwhile do then, read from the game's real state. It also records what the sim did in each
# block of the day (counts of planted, watered, gathered ...), which tools/loop_audit.py turns into estimated game
# minutes with unit times measured from the input-driven play logs. This is SIMULATION evidence, kept apart from
# the played evidence in the report.
#   godot --path . --headless -s tools/loop_audit.gd -- mode=engaged days=400 treks=3
# Prints one "LOOP {json}" line per day, besides the sim's own table.
#
# Activity statuses (CCH-LOOP-001 section 10):
#   worth    available and worthwhile now (gives resources, progress, discovery, survival or story)
#   repeat   available, but the same action as yesterday with little variation (fishing, felling, the cave grind)
#   leisure  a quiet pastime chosen for itself
#   wait     not now: comes back later today or tomorrow (nothing ripe, already done today, no walker today)
#   locked   needs a tool, level, building or season the player does not have yet
#   unclear  possible, but nothing in the game has pointed the player to it yet

var checkpoints: Array = []
var blocks: Dictionary = {}
var _stats_at := {}


func _play_day() -> String:
	checkpoints = []
	blocks = {}
	m.current_hour = m.START_HOUR
	m.clock = 0.0
	m.inside = true
	_snap("06:00 wake")
	_mark_block()
	_eat_drink()
	if m.sanity_sys._can_tidy():
		m.sanity_sys._tidy_house()
		chores["tidies"] += 1
	if m._can_mend() and (m.wear >= m.MEND_DUE_WEAR or int(m.materials["fiber"]) > FIBER_KEEP):
		m._mend_house()
		chores["mends"] += 1
	if m._can_mend() and int(m.materials["fiber"]) > FIBER_KEEP:
		m._mend_house()
		chores["mends"] += 1
	if m.sanity_sys._can_cleanse():
		m.sanity_sys._cleanse_house()
	if m.sanity_sys._can_bless():
		m.sanity_sys._take_blessing()
		nights["blessed"] += 1
	if m.tax_owed > 0 and m.money >= m.tax_owed:
		spent["tax"] += m.tax_owed
		m.desk._pay_tax()
		_mark("tax paid")
	_pass(1.0, true)
	_end_block("morning_house")
	_snap("07:00 out")
	_happening()
	_tend_field()
	_gather()
	_forage()
	_animals()
	_end_block("morning_out")
	_pass(6.0, false)
	_snap("13:00 midday")
	_eat_drink()
	_craft_and_build()
	_tend_field()
	_cook()
	_folk()
	_sell()
	_order()
	var walked := _walked_total()
	_trek()
	blocks["trek"] = _walked_total() - walked
	_end_block("afternoon")
	_pass(6.0, false)
	_snap("19:00 dusk")
	_eat_drink()
	_craft_and_build()
	_split_firewood()
	_end_block("evening")
	var night := ""
	if mode == "engaged":
		_pass(1.0, false)
		_desk_game()
		_davy()
		_pass(2.0 - (m.current_hour - 20.0), false)
		_snap("22:00 night")
		night = _face_night()
		_pass(1.0, true)
	elif mode == "ignore":
		_pass(1.0, true)
		_desk_game()
		_pass(22.0 - m.current_hour, true)
		_snap("22:00 night")
		night = _ignore_night()
		_pass(1.0, true)
	else:
		_pass(1.0, true)
		_desk_game()
		_pass(maxf(0.0, 21.0 - m.current_hour), true)
		_snap("21:00 bed")
		nights["skipped"] += 1
		night = "-"
	m.firewood._feed_fire()
	_end_block("night")
	print("LOOP " + JSON.stringify({"day": m.day, "season": m.projects._season(),
		"weather": m.weather_kind, "sanity": int(m.sanity), "coins": m.money, "house": m.house_stage,
		"lantern": m.lantern_tier, "chapter": str(m._current_chapter().get("id", "done")),
		"step": str(m.projects._next_step().get("id", "done")), "night": night,
		"blocks": blocks, "checkpoints": checkpoints}))
	return night


func _walked_total() -> int:
	var n := 0
	for id in m.trek.walked:
		n += int(m.trek.walked[id])
	return n + (1 if m.trek.edge_done else 0)


const COUNTED := ["planted", "harvested", "watered", "gathered", "felled", "mined", "foraged", "sold", "cooked",
	"fished", "caught", "tidied", "mended", "faced", "eaten", "drank", "jobs", "cleansed"]


func _mark_block() -> void:
	_stats_at = {}
	for k in COUNTED:
		_stats_at[k] = int(m.stats.get(k, 0))
	_stats_at["coins"] = m.money
	_stats_at["xp"] = _xp_total()
	_stats_at["crafted"] = _crafted()


func _end_block(name: String) -> void:
	var d := {}
	for k in COUNTED:
		var n := int(m.stats.get(k, 0)) - int(_stats_at.get(k, 0))
		if n != 0:
			d[k] = n
	d["coins"] = m.money - int(_stats_at["coins"])
	d["xp"] = _xp_total() - int(_stats_at["xp"])
	var c := _crafted() - int(_stats_at["crafted"])
	if c != 0:
		d["crafted"] = c
	blocks[name] = d
	_mark_block()


func _xp_total() -> int:
	var n := 0
	for s in m.skill_xp:
		n += int(m.skill_xp[s])
	return n


# Built and made things: tool tiers, lantern, house stage, buildings and decor, a rough count of what was made.
func _crafted() -> int:
	var n := m.lantern_tier + m.house_stage + m.projects.decor.size() + m.estate.built.size() + m.estate.furniture.size()
	for k in m.tool_tier:
		n += int(m.tool_tier[k])
	for b in ["coop_built", "barn_built", "cellar_built", "furnace_built", "smokehouse_built", "well_repaired", "hose_attached"]:
		n += 1 if bool(m.get(b)) else 0
	return n


# --- What could be done now -----------------------------------------------------------------------------------

var _sold_at_dawn := 0
var _mined_at_dawn := 0


func _snap(label: String) -> void:
	if label.begins_with("06"):
		_sold_at_dawn = int(m.stats.get("sold", 0))
		_mined_at_dawn = int(m.stats.get("mined", 0))
	checkpoints.append({"at": label, "acts": _avail()})


func _enabled(rows: Array) -> int:
	var n := 0
	for r in rows:
		if r is Dictionary and bool(r.get("enabled", false)):
			n += 1
	return n


func _avail() -> Dictionary:
	var a := {}
	var h := m.current_hour
	var raining: bool = m.weather_kind in m.WATER_RAIN_KINDS
	var thirsty := 0
	var ripe := 0
	for t in m.crops:
		var c: Dictionary = m.crops[t]
		if int(c["stage"]) >= m.MAX_STAGE:
			ripe += 1
		elif int(c.get("watered_day", 0)) != m.day and not raining:
			thirsty += 1
	a["water"] = "worth" if thirsty > 0 else "wait"
	a["harvest"] = "worth" if ripe > 0 else ("wait" if not m.crops.is_empty() else "wait")
	# Seeds that can go in now: the kind grows this season (the sim plants only what ripens before it ends).
	var seeds := 0
	var season: String = m.projects._season()
	for kind in m.CROPS:
		var ss: Array = m.CROPS[kind].get("seasons", [])
		if ss.is_empty() or ss.has(season):
			seeds += int(m.inventory.get(str(m.CROPS[kind]["seed"]), 0))
	var open_soil := 0
	for t in _soil_tiles():
		if not m.crops.has(t):
			open_soil += 1
	if open_soil > 0 and seeds > 0:
		a["plant"] = "worth"
	elif open_soil > 0:
		a["plant"] = "unclear" if m.day < 3 else "wait"   # needs the catalog
	else:
		a["plant"] = "wait"
	a["forage"] = "worth" if m.forage.spots.size() > 0 else "wait"
	a["brush"] = "worth" if m.brush.size() > 0 else "wait"
	# Felling, fishing and cooking can always be done again; they count as repeatable, not as something new.
	a["fell"] = "repeat" if int(m.tool_tier["hatchet"]) > 0 else "locked"
	a["rocks"] = ("worth" if m.rocks.size() > 0 else "wait") if int(m.tool_tier["pick"]) > 0 else "locked"
	var cave_tool: bool = int(m.tool_tier["pick"]) > 0 or m._has_weapon()
	var mined_today := int(m.stats.get("mined", 0)) > int(_mined_at_dawn)
	a["cave"] = ("repeat" if mined_today else "worth") if cave_tool else ("unclear" if m.day >= 4 else "locked")
	a["fish"] = "repeat"
	var goods := 0
	for k in m.inventory:
		if k in ["seeds", "firewood", "trail_ration", "bandage", "crow_charm"] or str(k).ends_with("_seeds"):
			continue
		goods += int(m.inventory[k])
	# Selling is worth a trip until today's sales are made (the sim sells everything worth selling at once).
	var sold_today := int(m.stats.get("sold", 0)) > int(_sold_at_dawn)
	a["sell"] = ("worth" if goods > 0 and not sold_today else ("repeat" if goods > 0 else "wait")) if h < 22.0 else "wait"
	# The catalog is a need when the fields wait for seed; otherwise spending is optional.
	var need_seed := seeds == 0 and open_soil > 0
	if m.day < 3:
		a["catalog"] = "unclear" if m.money >= 15 else "wait"
	else:
		a["catalog"] = ("worth" if need_seed else "repeat") if m.money >= 15 else "wait"
	# Only new things count: a tool tier or gear not worn yet.
	var craft := 0
	for r in m.crafting._recipes_tools():
		if r is Dictionary and bool(r.get("enabled", false)) and str(r.get("button", "")) != "Worn":
			craft += 1
	a["craft"] = "worth" if craft > 0 else "wait"
	a["cook"] = "repeat" if _enabled(m.stall._recipes_cooking()) > 0 else "wait"
	a["tidy"] = "worth" if m.sanity_sys._can_tidy() else ("locked" if m.house_stage < 2 else "wait")
	a["mend"] = ("worth" if m.wear >= m.MEND_DUE_WEAR else "repeat") if m._can_mend() else "wait"
	a["repair"] = "worth" if m._can_repair() else ("locked" if m.house_stage < 3 else "wait")
	a["cleanse"] = "worth" if m.sanity_sys._can_cleanse() else "wait"
	var hens_hungry: bool = m.hens > 0 and m.hens_fed_day != m.day and not (m.coop_hopper_built and m.coop_hopper > 0)
	var goats_hungry: bool = m.goats > 0 and m.goats_fed_day != m.day and not (m.barn_hopper_built and m.barn_hopper > 0)
	a["animals"] = ("worth" if hens_hungry or goats_hungry else "wait") if (m.coop_built or m.barn_built) else "locked"
	a["folk"] = ("worth" if m.folk.visitor != "" and h < 16.0 else "wait") if m.day >= 5 else "locked"
	var trek_open := m.trek._any_waiting()
	a["trek"] = ("worth" if trek_open and m.lantern_tier >= 1 else ("locked" if trek_open else "wait")) if m.day >= 4 else "locked"
	a["happening"] = "worth" if m.happenings._pending() else "wait"
	a["mail"] = "worth" if m.mail._flag_up() else "wait"
	a["pastime"] = "leisure" if (m.desk._can_pastime("cards") or m.desk._can_pastime("sudoku")) and h < 24.0 else "wait"
	# The sim does not run the night's schedule; a visitor comes after 22:00 on most nights (NightSystem).
	a["night"] = "worth" if h >= 21.9 else "wait"
	a["step"] = str(m.projects._next_step().get("id", "done"))
	return a
