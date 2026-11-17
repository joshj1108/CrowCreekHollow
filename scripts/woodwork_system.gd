class_name WoodworkSystem
extends RefCounted

# CCH-WOODWORK-001: the workbench, the anvil, and timber. See DESIGN.md, "Workbench, anvil and timber".
#
# - Stations. The workbench and the anvil are placed like decor (FarmProjects.DECOR, saved in its `decor`), so they
#   block like any placed piece and are drawn there. Space at one opens its panel (PanelRows._workbench_rows /
#   _anvil_rows). The Craft panel stays a catalog you can browse from anywhere, but Make only works standing
#   beside the right station (`near`, any of the eight tiles round it). The rule is the bill of materials: a
#   recipe with copper or iron bars in it is forged at the anvil, everything else is made at the workbench
#   (`station_for`). Bandages, rope and charms are made in the hand, cooking stays at the fire, smelting at the
#   furnace, preserving at the smokehouse and splitting firewood at the chopping log.
# - Timber. The saved `wood` material is the raw log (shown as "logs"); the key is unchanged so every old save
#   and every existing cost keeps working. At the workbench a log is hewn into PLANKS_PER_LOG planks, which take
#   game time and train Carpentry. Planks are a material of their own (`planks`), spent by the later house
#   repairs (MainGame.REPAIR_COSTS) and by anything built with `try_repair`.
# - Repairs. `try_repair` is the one transaction for a repair or build paid in materials: it checks the skill and
#   the materials, takes them, passes the work's hours, gives the XP and records it once in `repairs`
#   ({id: {day, cost}}). The house repairs record themselves here too. Edith's inn repair (Wicker Cove) is meant
#   to come through it: planks, hardware, a Carpentry level, bounded hours, one recorded success.

var m: MainGame

const PLANKS_PER_LOG := 2
const HEW_MINUTES := 15.0          # game minutes to hew one log at Carpentry 1
const HEW_MINUTES_LEVEL := 1.5     # ... less for each Carpentry level past 1
const HEW_MINUTES_MIN := 6.0
const HEW_BATCH := 5               # the most logs one press hews
const HEW_LATE := 1.0              # hours before the day's end when the bench is put away
const XP_HEW := 5                  # Carpentry XP for each log hewn
const STATIONS := {"workbench": "Workbench", "anvil": "Anvil"}
const METALS := ["copper_bar", "iron_bar"]
const NOT_COSTS := ["level", "season", "skill", "hours"]

var hewn := 0                      # saved: logs hewn into planks, ever
var repairs := {}                  # saved: repair id -> {"day": day, "cost": {material: n}}


func _init(main: MainGame) -> void:
	m = main


# --- Stations ---------------------------------------------------------------------------------------------

# Where a recipe is made, by what it is made of: bars are forged at the anvil, the rest is made at the bench.
func station_for(cost: Dictionary) -> String:
	for metal in METALS:
		if int(cost.get(metal, 0)) > 0:
			return "anvil"
	return "workbench"


func has_station(kind: String) -> bool:
	return m.projects._count(kind) > 0


# Standing on one of the eight tiles round a placed station of this kind, out on the farm.
func near(kind: String) -> bool:
	if m.inside or m.in_cave or m.player == null:
		return false
	var here := m._player_tile()
	for t in m.projects.decor:
		if str(m.projects.decor[t]) == kind and absi(t.x - here.x) <= 1 and absi(t.y - here.y) <= 1:
			return true
	return false


# Why a recipe made at this station can't be made here, or "" when it can.
func why_not(kind: String) -> String:
	if near(kind):
		return ""
	if kind == "anvil":
		if not has_station("anvil"):
			return "This is forged at the anvil. Build one from Buildings, under Workshop, then stand beside it."
		return "This is forged at the anvil. Stand beside it and press Space (A)."
	if not has_station("workbench"):
		return "This is made at the workbench. Build one from Buildings, under Workshop: 4 sticks."
	return "This is made at the workbench. Stand beside it and press Space (A)."


# The Craft card's extra cost line: where it is made, green when you're there.
func station_line(kind: String) -> Dictionary:
	var label := "At the workbench" if kind == "workbench" else "At the anvil"
	return {"label": label, "have": 1 if near(kind) else 0, "need": 1}


# --- Hewing logs into planks --------------------------------------------------------------------------------

func hew_minutes() -> float:
	var lvl := m.progression._level("Carpentry")
	return maxf(HEW_MINUTES_MIN, HEW_MINUTES - HEW_MINUTES_LEVEL * float(lvl - 1))


func too_late() -> bool:
	return m.current_hour >= m.DAY_END_HOUR - HEW_LATE


func can_hew() -> bool:
	return near("workbench") and int(m.materials["wood"]) >= 1 and not too_late()


# Hews up to `n` logs (never more than you hold, HEW_BATCH, or what the hour allows). Returns how many.
func hew(n: int) -> int:
	if not near("workbench"):
		m._show_message(why_not("workbench"))
		return 0
	if too_late():
		m._show_message("It's too late to work wood. The bench can wait for morning.")
		return 0
	var logs := mini(mini(n, HEW_BATCH), int(m.materials["wood"]))
	if logs <= 0:
		m._show_message("You have no logs to hew. Fell trees in the Nearwood, or the grove trees round the farm.")
		return 0
	var per := hew_minutes() / 60.0
	# Stop short of the day's end rather than work into a collapse.
	var room := floori((m.DAY_END_HOUR - HEW_LATE - m.current_hour) / per)
	logs = clampi(logs, 1, maxi(1, room))
	m.materials["wood"] -= logs
	m.materials["planks"] = int(m.materials.get("planks", 0)) + logs * PLANKS_PER_LOG
	hewn += logs
	m.stats["hewn"] = int(m.stats.get("hewn", 0)) + logs
	pass_hours(per * logs)
	var xp := XP_HEW * logs
	m.progression._grant_xp("Carpentry", xp)
	m.play_sfx("chop", 0.05)
	m._show_message("You hew %d %s into %d planks (%d min). %d planks held. +%d Carpentry XP" % [
		logs, "log" if logs == 1 else "logs", logs * PLANKS_PER_LOG, roundi(per * logs * 60.0), int(m.materials["planks"]), xp])
	return logs


func pass_hours(hours: float) -> void:
	if hours <= 0.0:
		return
	m.clock += hours * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR)
	m.current_hour += hours
	m._update_needs(hours)


# --- Paying for repairs and builds ---------------------------------------------------------------------------

# The materials in a cost, without its level, season, skill or hours.
func mats(cost: Dictionary) -> Dictionary:
	var out := {}
	for key in cost:
		if not NOT_COSTS.has(str(key)) and int(cost[key]) > 0:
			out[str(key)] = int(cost[key])
	return out


func can_pay(cost: Dictionary) -> bool:
	for key in mats(cost):
		if m._held(key) < int(cost[key]):
			return false
	return true


func pay(cost: Dictionary) -> void:
	var c := mats(cost)
	for key in c:
		if key == "coins":
			m.money -= int(c[key])
		elif m.materials.has(key):
			m.materials[key] = maxi(0, int(m.materials[key]) - int(c[key]))
		else:
			m.inventory[key] = maxi(0, int(m.inventory.get(key, 0)) - int(c[key]))


func record(id: String, cost: Dictionary) -> void:
	if not repairs.has(id):
		repairs[id] = {"day": m.day, "cost": mats(cost)}


# One repair or build: the skill and materials checked, paid, the hours passed, the XP given, recorded once.
# Returns false (and says why) if it can't be done; nothing is taken then.
func try_repair(id: String, cost: Dictionary, skill: String, level: int, hours: float, xp: int) -> bool:
	if repairs.has(id):
		m._show_message("That's already been repaired.")
		return false
	if skill != "" and m.progression._level(skill) < level:
		m._show_message("That needs %s %d." % [skill, level])
		return false
	if not can_pay(cost):
		m._show_message("That needs %s." % cost_text(cost))
		return false
	if hours > 0.0 and m.current_hour + hours > m.DAY_END_HOUR - HEW_LATE:
		m._show_message("There isn't enough of the day left for that. Start it in the morning.")
		return false
	pay(cost)
	pass_hours(hours)
	if skill != "" and xp > 0:
		m.progression._grant_xp(skill, xp)
	record(id, cost)
	m.play_sfx("repair", 0.05)
	return true


func cost_text(cost: Dictionary) -> String:
	var parts: Array = []
	var c := mats(cost)
	for key in c:
		parts.append("%d %s" % [int(c[key]), label(key)])
	return ", ".join(parts)


# What a material is called on screen. The raw log keeps its old `wood` key.
static func label(key: String) -> String:
	match key:
		"wood":
			return "logs"
		"seeds":
			return "turnip seeds"
		"feathers":
			return "crow feathers"
	return key.replace("_", " ")


# --- Saving ---------------------------------------------------------------------------------------------------

func _to_save() -> Dictionary:
	return {"hewn": hewn, "repairs": repairs}


# An older save has hewn nothing and recorded no repairs; its house repairs are recorded from its stage.
func _from_save(d: Variant) -> void:
	hewn = 0
	repairs = {}
	if typeof(d) == TYPE_DICTIONARY:
		hewn = int(d.get("hewn", 0))
		var r: Variant = d.get("repairs", {})
		if typeof(r) == TYPE_DICTIONARY:
			for id in r:
				var e: Variant = r[id]
				if typeof(e) == TYPE_DICTIONARY:
					repairs[str(id)] = {"day": int(e.get("day", 0)), "cost": e.get("cost", {}) if typeof(e.get("cost", {})) == TYPE_DICTIONARY else {}}
	for stage in range(1, m.house_stage + 1):
		var id := "house_%d" % stage
		if not repairs.has(id):
			repairs[id] = {"day": 0, "cost": {}}
