extends SceneTree

# Plays a new game for many days with a simple strategy and prints how the numbers move, for balance tuning.
# Walking is skipped: each day calls the game's own functions (plant, water, harvest, sell, tidy, mend, build,
# smelt, order, pay tax, face or ignore the night) and passes time through _update_needs and sanity.
# Run headless, from the project folder:
#   godot --path . --headless -s tools/balance_sim.gd -- mode=engaged days=60
# Options, any order, after "--":
#   mode=NAME   engaged  - faces every visitor outdoors at 22:00 (the default)
#               ignore   - stays in, lets each visitor come and go, sleeps at 23:00
#               earlybed - stays in and sleeps at 21:00, before the visitor comes
#   days=N      days to play (default 60; the first tax bill comes on day 93, January 1st; the earliest
#               the crow bell can be hung is day 396, the second All Hallows)
#   seed=N      random seed (default 1)
#   every=N     print one table row every N days (default 1)
#   treks=N     go on N treks a week (default 0), on the longest open route the supplies allow. The routes,
#               events, forks and gifts come from TrekSystem; walking time and sanity are estimated (_route_trek).
# Approximations, since these need walking or real time:
#   - Each day takes every brush pile and up to TREES_PER_DAY trees, mines every farm rock, and breaks up to
#     CAVE_ORE_PER_DAY ore nodes from the day's real cave layout (copper, then iron).
#   - Bell parts are made as soon as they can be, and the bell is hung on the first All Hallows it can be.
#   - Fishing only when there is nothing to eat (grilled at once); no fights. Firewood is split straight into the pack once the woodshed stands.
#   - The day runs 06:00 inside, 07:00-19:00 outdoors, then evening per mode; a desk game is played at 20:00.
# It plays in save slot 8 (not shown on the start screen) and deletes that save when done.

const SLOT := 8
const TREES_PER_DAY := 6
const CAVE_ORE_PER_DAY := 8
const FIBER_KEEP := 6        # a second board is mended only above this much fiber
const PLANT_CAP := 40.0      # crops kept growing: what the tank waters on a dry day

var m: MainGame
# The trek routes (TrekSystem.ROUTES), longest first, with the trail rations the sim packs for each. The rest
# (day, level, clearings, events, pay) comes from TrekSystem in _route_trek.
const TREK_ROUTES := [
	{"id": "grove", "rations": 4},
	{"id": "chapel", "rations": 3},
	{"id": "orchard", "rations": 2},
	{"id": "mill", "rations": 1},
]
const CLEARING_SECONDS := 25.0  # a clearing's walk, for the oil (a flask burns TrekSystem.FLASK_SECONDS)
const CLEARING_SANITY := 2.0    # the wood's sanity drain and the tall one, a clearing (half again on the dark trail)
const EVENT_SANITY := 3.0       # crows, lights or dogs
const OIL_PRICE := 8
const ROPE_FIBER := 2
# Each work can be paid for from its day (when its route opens).
const TRAIL_WORKS := [
	{"id": "waymarks", "day": 62, "coins": 150, "wood": 10},
	{"id": "footbridge", "day": 62, "coins": 300, "wood": 12, "rope": 6},
	{"id": "gate lamp", "day": 62, "coins": 400, "iron_bar": 2},
	{"id": "boardwalk", "day": 152, "coins": 700, "wood": 20, "rope": 8},
	{"id": "waystation", "day": 244, "coins": 1200, "wood": 30, "hardwood": 10},
	{"id": "chapel steps", "day": 244, "coins": 1800, "stone": 30, "iron_bar": 4},
]

var mode := "engaged"
var treks_a_week := 0
var rope := 0
var works_done := 0
var trek_log := {"mill": 0, "orchard": 0, "chapel": 0, "grove": 0, "dark": 0, "floods": 0, "dogs": 0, "skipped": 0, "oil_coins": 0, "works_coins": 0}
var days := 60
var every := 1
var milestones := {}         # name -> first day
var nights := {"faced": 0, "ignored": 0, "skipped": 0, "hollow": 0}
var spent := {"seeds": 0, "animals": 0, "tax": 0, "pedlar": 0, "cards": 0}
var earned := {"crops": 0, "eggs_milk": 0}
var min_sanity := 100.0
var low_days := {}           # days sanity went under LOW_SANITY (the screen darkens)
var hp_lost := 0
var empty_hours := {"food": 0.0, "water": 0.0, "warmth": 0.0}
var fished_hours := 0
var caves := {"visits": 0, "copper": 0, "iron": 0}   # ore nodes seen in the day's cave


func _initialize() -> void:
	var s := 1
	for a in OS.get_cmdline_user_args():
		var kv := str(a).split("=")
		match kv[0]:
			"mode": mode = kv[1]
			"days": days = int(kv[1])
			"seed": s = int(kv[1])
			"every": every = maxi(1, int(kv[1]))
			"treks": treks_a_week = int(kv[1])
	seed(s)
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


var started := false


# The game is set up on the first frame, once its _ready has run, and played straight through.
func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	m._on_title_start("new", SLOT)
	m.set_process(false)
	_run()
	SaveSystem.delete_save(m._save_path())
	return true


func _run() -> void:
	print("mode=%s days=%d" % [mode, days])
	print("day date   coins san/max fea  Fa Ca Cl Bu Fo Mi Sm steps shd tax  grow wood fib wear kept night")
	for i in days:
		var night := _play_day()
		_note_milestones()
		if (m.day - 1) % every == 0 or i == days - 1:
			_row(night)
		if m.tax_owed > 0 and m.day - m.tax_due_day >= m.TAX_EVICT_DAYS - 1:
			print("LAND LOST on day %d: %d tax unpaid" % [m.day, m.tax_owed])
			break
		_sleep()
	_summary()


# --- One day ------------------------------------------------------------------------------

func _play_day() -> String:
	m.current_hour = m.START_HOUR
	m.clock = 0.0
	# Morning, inside: eat, chores, the desk.
	m.inside = true
	_eat_drink()
	if m.sanity_sys._can_tidy():
		m.sanity_sys._tidy_house()
	if m._can_mend():
		m._mend_house()
	if m._can_mend() and int(m.materials["fiber"]) > FIBER_KEEP:
		m._mend_house()
	if m.sanity_sys._can_cleanse():
		m.sanity_sys._cleanse_house()
	if m.tax_owed > 0 and m.money >= m.tax_owed:
		spent["tax"] += m.tax_owed
		m.desk._pay_tax()
		_mark("tax paid")
	_pass(1.0, true)
	# Outdoors: the happening, the field, gathering, the stand, building.
	_happening()
	_tend_field()
	_gather()
	_animals()
	_pass(6.0, false)
	_eat_drink()
	_craft_and_build()
	_tend_field()   # anything planted with new seeds today
	_sell()
	_order()
	_trek()
	_pass(6.0, false)
	_eat_drink()
	_craft_and_build()
	_split_firewood()
	# Evening.
	var night := ""
	if mode == "engaged":
		_pass(1.0, false)
		_desk_game()
		_pass(2.0 - (m.current_hour - 20.0), false)
		night = _face_night()
		_pass(1.0, true)
	elif mode == "ignore":
		_pass(1.0, true)
		_desk_game()
		_pass(22.0 - m.current_hour, true)
		night = _ignore_night()
		_pass(1.0, true)
	else:
		_pass(1.0, true)
		_desk_game()
		_pass(maxf(0.0, 21.0 - m.current_hour), true)
		nights["skipped"] += 1
		night = "-"
	m.firewood._feed_fire()
	return night


func _sleep() -> void:
	m.stats["slept"] += 1
	m.sanity_sys._change_sanity(m.SLEEP_SANITY)
	if m.firewood._fire_lit():
		m.warmth = 100.0
	m._end_day("", false)
	m.progression._check_achievements()
	m.progression._check_story()
	m.projects._check(false)
	m.mystery._check()
	_track_sanity()


# Hours pass as if standing there: needs drop, the fire burns, sanity drifts with the dark.
func _pass(h: float, indoors: bool) -> void:
	if h <= 0.0:
		return
	m.inside = indoors
	var steps := maxi(1, ceili(h / 0.25))
	var hp_before := m.hp
	for i in steps:
		var dh := h / steps
		m.current_hour += dh
		m.clock = (m.current_hour - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
		m._update_needs(dh)
		var dark := smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, m.current_hour)
		m.sanity_sys._update_sanity(dark, dh * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR))
		_track_sanity()
		for need in empty_hours:
			if float(m.get(need)) <= 0.0:
				empty_hours[need] += dh
		if not indoors and m.warmth < 20.0 and m.firewood._fire_lit():
			m.inside = true   # step in by the fire for a while
		elif indoors == false:
			m.inside = false
	hp_lost += maxi(0, hp_before - m.hp)


func _eat_drink() -> void:
	while m.food < 65.0:
		var ate := false
		for id in ["turnip", "corn", "egg", "milk", "pumpkin", "turnip_hash", "fish_meal"]:
			var f := Foods.find(id)
			if not f.is_empty() and int(m.inventory[str(f["held"])]) > 0:
				m.stall._eat_food(id)
				ate = true
				break
		if not ate:
			if not _fish_for_supper():
				break
	if m.water < 70.0:
		if m.well_repaired:
			m._drink_well()
		m._drink_pond()


# With nothing to eat, an hour at the pond: about two fish (half the rolls land, a roll every 3 seconds),
# grilled over a fire for 1 wood each.
func _fish_for_supper() -> bool:
	if int(m.materials["wood"]) < 2 or m.current_hour > 21.0:
		return false
	_pass(1.0, false)
	fished_hours += 1
	for i in 2:
		m.inventory["fish"] += 1
		m.progression._grant_xp("Fishing", m.XP_FISH)
		if m.stall._can_make("fish_meal"):
			m.stall._make_food("fish_meal")
	return int(m.inventory["fish_meal"]) > 0


func _happening() -> void:
	var h := m.happenings
	if not h._pending():
		return
	var id := str(h.today["id"])
	if id == "pedlar":
		var g := h._goods()
		var want := _spare() >= int(g["price"]) + 20
		_mark("pedlar seen")
		if not want:
			return
		spent["pedlar"] += int(g["price"])
	h._try_take(h.tile)


# --- The field ----------------------------------------------------------------------------

func _soil_tiles() -> Array:
	var out: Array = []
	var plots: Array = [m.PLOT_ONE]
	if m.plot_two_open:
		plots.append(m.PLOT_TWO)
	if m.plot_three_open:
		plots.append(m.PLOT_THREE)
	for r in plots:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var t := m._world_tile(x, y)
				if m.map[t.y][t.x] == MainGame.Tile.SOIL:
					out.append(t)
	return out


func _tend_field() -> void:
	for t in m.crops.keys():
		if int(m.crops[t]["stage"]) >= m.MAX_STAGE:
			m.farm._harvest(t)
	for t in m.crops.keys():
		if int(m.crops[t].get("watered_day", 0)) != m.day and m.well_repaired and m.hose_attached and m.well_water >= 1.0:
			m.farm._water_crop(t)
	m.farm._check_unlocks()
	# Plant the best seeds first, up to what the tank can water.
	var room := int(PLANT_CAP) - m.crops.size()
	for t in _soil_tiles():
		if room <= 0:
			break
		if m.crops.has(t):
			continue
		var kind := ""
		for k in ["pumpkin", "corn", "turnip"]:
			if m.farm._crop_unlocked(k) and int(m.inventory[m.CROPS[k]["seed"]]) > (2 if k == "turnip" and _want_flowers() else 0):
				kind = k
				break
		if kind == "":
			break
		m.selected_seed = kind
		m.farm._plant(t)
		room -= 1
		if m.hose_attached and m.well_water >= 1.0:
			m.farm._water_crop(t)


func _want_flowers() -> bool:
	return m.progression._level("Farming") >= 2 and m.projects._count("flowers") < 4


func _reserve() -> int:
	return 6 + m.hens * m.HEN_FEED_CROPS + m.goats * m.GOAT_FEED_CROPS + (m.CLEANSE_CROPS if m.sanity_penalty > 0 else 0)


func _sell() -> void:
	# Keep a few crops back for food, feed, the cleanse and trek rations, of any kind; sell the rest,
	# dearest first, so the cheap turnips are the ones kept.
	var keep := _reserve() + (4 if treks_a_week > 0 else 0)
	for k in ["pumpkins", "corn", "crops"]:
		var extra := mini(int(m.inventory[k]), m.farm._crop_total() - keep)
		if extra <= 0:
			continue
		var rest := int(m.inventory[k]) - extra
		m.inventory[k] = extra
		var before := m.money
		m.stall._sell(k)
		earned["crops"] += m.money - before
		m.inventory[k] = rest
	for k in ["eggs", "milk", "fish"]:
		var keep_n := 4 if treks_a_week > 0 and k != "fish" else 0
		var n := int(m.inventory[k]) - keep_n
		if n <= 0:
			continue
		var before := m.money
		m.inventory[k] = n
		m.stall._sell(k)
		m.inventory[k] = keep_n
		earned["eggs_milk"] += m.money - before


func _order() -> void:
	# Seeds: enough to keep the field full, best kind first.
	var growing := m.crops.size() + int(m.inventory["seeds"]) + int(m.inventory["corn_seeds"]) + int(m.inventory["pumpkin_seeds"])
	for id in ["seeds_pumpkin", "seeds_corn", "seeds_turnip"]:
		var item := m.desk._catalog_item(id)
		while bool(item["ok"]) and growing < int(PLANT_CAP) + 4 and m.money >= int(item["price"]) + 10 and m.desk_orders.size() < 12:
			m.desk._order(id)
			spent["seeds"] += int(item["price"])
			growing += {"seeds_pumpkin": 3, "seeds_corn": 4, "seeds_turnip": 5}[id]
		if bool(item["ok"]):
			break
	if m.card_games <= 0 and m.sudoku_puzzles <= 0 and not m.desk_orders.has("cards") and m.money >= m.CARDS_PRICE + 10:
		m.desk._order("cards")
		spent["cards"] += m.CARDS_PRICE
	var hen := m.desk._catalog_item("hen")
	if bool(hen["ok"]) and _spare() >= 60:
		m.desk._order("hen")
		spent["animals"] += m.HEN_PRICE
	var goat := m.desk._catalog_item("goat")
	if bool(goat["ok"]) and _spare() >= 200:
		m.desk._order("goat")
		spent["animals"] += m.GOAT_PRICE


func _animals() -> void:
	if m.animals._can_feed_hens():
		m.animals._feed_hens()
	if m.animals._can_feed_goats():
		m.animals._feed_goats()


func _desk_game() -> void:
	for kind in ["solitaire", "sudoku"]:
		if m.desk._can_pastime(kind):
			m.desk._play_pastime(kind)
			return


# --- Gathering, crafting, building --------------------------------------------------------

func _gather() -> void:
	for t in m.brush.keys():
		m.mining._gather(t)
	if int(m.tool_tier["hatchet"]) == 0 and m.crafting._can_craft_tool("hatchet"):
		m.crafting._craft_tool("hatchet")
	if int(m.tool_tier["hatchet"]) >= 1:
		var felled := 0
		for spot in m.GROVE_SPOTS:
			var t := m._world_tile(spot.x, spot.y)
			if felled >= TREES_PER_DAY or m.grove_felled.has(t):
				continue
			m.firewood._finish_chop(t)
			felled += 1
	for t in m.rocks.keys():
		m.mining._finish_mine(t)
	_cave()


func _cave() -> void:
	if int(m.tool_tier["pick"]) < 1 or m.progression._level("Mining") < 2:
		return
	m._generate_cave()
	var copper: Array = []
	var iron: Array = []
	for y in m.CAVE_H:
		for x in m.CAVE_W:
			if m.cave[y][x] == MainGame.Tile.ORE_IRON:
				iron.append(Vector2i(x, y))
			elif m.cave[y][x] == MainGame.Tile.ORE_COPPER:
				copper.append(Vector2i(x, y))
	caves["visits"] += 1
	caves["copper"] += copper.size()
	caves["iron"] += iron.size()
	var can_iron := int(m.tool_tier["pick"]) >= 2 and m.progression._level("Mining") >= 5
	var budget := CAVE_ORE_PER_DAY
	m.in_cave = true   # so the ore is read from the cave
	for t in (iron if can_iron else []) + copper:
		if budget <= 0:
			break
		m.mining._finish_cave_ore(t)
		budget -= 1
	m.in_cave = false


func _craft_and_build() -> void:
	# Iron bars for the tools, lamp and bell; copper is smelted with spare wood, for Smithing XP.
	while m.mining._can_smelt("iron") and int(m.materials["wood"]) > 4 and int(m.materials["iron_bar"]) < 9:
		m.mining._smelt("iron")
	while m.mining._can_smelt("copper") and int(m.materials["wood"]) > 30:
		m.mining._smelt("copper")
	for kind in ["hatchet", "pick"]:
		if m.crafting._can_craft_tool(kind):
			m.crafting._craft_tool(kind)
	if m._can_repair_well():
		m._repair_well()
	if m._can_attach_hose():
		m._attach_hose()
	if m._can_advance_lantern() and m.lantern_tier < 1:
		m._advance_lantern()
	for id in m.projects.BELL_PARTS:
		if m.projects._part_why(id) == "":
			m.projects._make_part(id)
	# The homestead in a sensible order. Something short only of coins, wood, fiber or stone is saved for;
	# something that needs a level, or rarer things, is passed over for now.
	for item in [
		["boarded", m.house_stage >= 1, m.REPAIR_COSTS[0]],
		["coop", m.coop_built, m.COOP_COST],
		["patched", m.house_stage >= 2, m.REPAIR_COSTS[1] if m.house_stage == 1 else {"level": 99}],
		["woodshed", m.woodshed_built, m.WOODSHED_COST if (m.smokehouse_built or m.furnace_built) else {"level": 99}],
		["smokehouse", m.smokehouse_built, m.SMOKEHOUSE_COST],
		["furnace", m.furnace_built, m.FURNACE_COST],
		["lamp", m.projects._count("lamp") >= 1, {}],
		["barn", m.barn_built, m.BARN_COST],
		["restored", m.house_stage >= 3, m.REPAIR_COSTS[2] if m.house_stage == 2 else {"level": 99}],
		["flowers", not _want_flowers(), {}],
		["lantern", m.lantern_tier >= 3, {}],
		["bell", m.projects._has_bell(), {}],
	]:
		if bool(item[1]):
			continue
		var r := _try_build(str(item[0]), item[2])
		if r == "wait":
			return


# Returns "done", "skip" (locked by a level or a rare material) or "wait" (save up for it).
func _try_build(id: String, cost: Dictionary) -> String:
	match id:
		"lamp", "flowers", "bell":
			var kind := "flowers" if id == "flowers" else id
			if not m.projects._level_ok(kind):
				return "skip"
			if not m.projects._can_afford(kind):
				if id == "bell":
					_note_bell()
				return "skip"
			if not m.projects._can_place(kind):
				return "skip"
			m.projects._confirm(kind, _open_grass())
			return "done"
		"lantern":
			if m._can_advance_lantern():
				m._advance_lantern()
				return "done"
			return "skip"
	var level := int(cost.get("level", 1))
	var skill_ok := m.progression._level("Carpentry") >= level
	if not skill_ok:
		return "skip"
	var ok := m.money >= int(cost.get("coins", 0))
	for k in cost:
		if k != "coins" and k != "level" and int(m.materials.get(k, 0)) < int(cost[k]):
			ok = false
	if not ok:
		return "wait"
	match id:
		"boarded", "patched", "restored":
			m._repair_house()
		"coop", "barn":
			# As _confirm_placement does, without choosing a spot.
			m.materials["wood"] -= int(cost["wood"])
			m.materials["fiber"] -= int(cost["fiber"])
			if id == "barn":
				m.barn_built = true
			else:
				m.coop_built = true
			m.progression._grant_xp("Carpentry", m.XP_REPAIR)
		"woodshed":
			m._build_woodshed()
		"smokehouse":
			m._build_smokehouse()
		"furnace":
			m._build_furnace()
	return "done"


# The first plain grass tile on the farm, row by row, for decor.
func _open_grass() -> Vector2i:
	for y in range(m.BORDER_Y, m.BORDER_Y + m.INNER_H):
		for x in range(m.BORDER_X, m.BORDER_X + m.INNER_W):
			if m._spot_ok(Vector2i(x, y), Vector2i.ONE):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _note_bell() -> void:
	var cost: Dictionary = m.projects.DECOR["bell"]["cost"]
	for k in cost:
		if m._held(str(k)) >= int(cost[k]):
			_mark("bell: %s" % k)


func _split_firewood() -> void:
	if not m.woodshed_built or int(m.tool_tier["hatchet"]) < 1:
		return
	while int(m.inventory["firewood"]) < 6 and int(m.materials["wood"]) > 10:
		m.materials["wood"] -= 1
		m.inventory["firewood"] += m.FIREWOOD_PER_WOOD
		m.progression._grant_xp("Forestry", m.XP_CHOP_LOG)


# --- Treks (planned) --------------------------------------------------------------------------

# On trek days, the longest open route the supplies allow. Oil is bought; a ration is an egg or milk, a crop
# and a wood; rope is fiber. Then a trail work, when the coins and materials are there.
func _trek() -> void:
	if treks_a_week <= 0:
		return
	_trail_works()
	if (m.day % 7) >= treks_a_week:
		return
	var t := m.trek
	for route in TREK_ROUTES:
		var id := str(route["id"])
		if not t._route_open(id) or m.progression._level("Bushcrafting") < int(t.ROUTES[id]["level"]):
			continue
		var r: Dictionary = _route_trek(route)
		var oil_cost := maxi(0, int(r["oil"]) - int(m.materials["lamp_oil"])) * OIL_PRICE
		var rations := int(r["rations"])
		var ration_food := int(m.inventory["eggs"]) + int(m.inventory["milk"])
		var need_rope := maxi(0, int(r["rope"]) - rope)
		var short := ""
		if _spare() < oil_cost:
			short = "coins"
		elif ration_food < rations:
			short = "eggs/milk"
		elif m.farm._crop_total() < rations + 2:
			short = "crops"
		elif int(m.materials["wood"]) < rations:
			short = "wood"
		elif int(m.materials["fiber"]) < need_rope * ROPE_FIBER:
			short = "rope"
		if short != "":
			trek_log["short " + short] = int(trek_log.get("short " + short, 0)) + 1
			continue
		# Oil is bought for what the walk burns, after any the chapel's vicar gave.
		m.money -= oil_cost
		m.materials["lamp_oil"] = maxi(0, int(m.materials["lamp_oil"]) - int(r["oil"]))
		m.money -= int(r.get("coins", 0))
		trek_log["oil_coins"] += oil_cost
		for i in rations:
			var k := "eggs" if int(m.inventory["eggs"]) > 0 else "milk"
			m.inventory[k] -= 1
			m.farm._spend_crops(1)
			m.materials["wood"] -= 1
		m.materials["fiber"] -= need_rope * ROPE_FIBER
		rope += need_rope - int(r["rope"])
		_pass(float(r["hours"]), false)
		m.sanity_sys._change_sanity(-float(r["sanity"]))
		_track_sanity()
		m.progression._grant_xp("Bushcrafting", int(r["xp"]))
		m.materials["feathers"] += int(r["feathers"])
		m.materials["fiber"] += int(r["fiber"])
		# The route's own gifts (seeds, applewood and flax, lamp oil and storm oak), from the game.
		t.night = false
		t._gifts(1)
		t.treks_done += 1
		if id == "grove":
			t.grove_done = true
		trek_log[id] += 1
		trek_log["dark"] += int(r["dark"])
		trek_log["floods"] += int(r["flood"])
		trek_log["dogs"] += int(r["dogs"])
		_mark("trek: " + id)
		return
	trek_log["skipped"] += 1


# A trek on a route, from the real day plan (TrekSystem._plan, _steps) and pay (ROUTES, dread, the dark trail).
# Unread, the fingerpost is a coin toss; read, the sim takes the dark trail every other trek. Oil is the walk's
# clearings at CLEARING_SECONDS each; sanity is CLEARING_SANITY a clearing (half again on the dark trail) and
# EVENT_SANITY for crows, lights or dogs. A flooded hollow takes a rope (unless the footbridge keeps the mill
# path dry); a cairn takes coins and gives sanity back; a hollow tree gives about 9 coins. By day only: night
# treks (double pay, double drain) are not modelled.
func _route_trek(route: Dictionary) -> Dictionary:
	var r := route.duplicate()
	var t := m.trek
	var id := str(route["id"])
	var spec: Dictionary = t.ROUTES[id]
	t.route_id = id
	var p: Dictionary = t._plan(m.day, id)
	var dark: bool = int(trek_log[id]) % 2 == 1 if t._can_read_sign() else bool(p["marked_right"])
	var evs: Array = p["dark"] if dark else p["marked"]
	var n: int = (t._steps(id)["dark" if dark else "marked"] as Array).size()
	var d: int = t._dread()
	r["dark"] = dark
	r["oil"] = ceili(n * CLEARING_SECONDS / t.FLASK_SECONDS)
	r["hours"] = 0.5 + 0.75 * n
	r["fiber"] = n
	r["xp"] = int(spec["xp"]) + t.DREAD_XP * d + (t.DARK_XP if dark else 0)
	r["feathers"] = int(spec["feathers"]) + 1 + d / 2 + (t.DARK_FEATHERS if dark else 0)
	var sanity := CLEARING_SANITY * n * (1.5 if dark else 1.0)
	for e in evs:
		if e in ["crows", "lights", "dogs"]:
			sanity += EVENT_SANITY
	var floods: int = evs.count("flood") if not t._hollows_dry() else 0
	r["flood"] = floods
	r["dogs"] = evs.count("dogs")
	# With no rope to be had (Bushcrafting under 3, or no fiber), the farmer wades: warmth, not modelled.
	var can_rope: bool = m.progression._level("Bushcrafting") >= int(t.ROPE["level"]) and (rope > 0 or int(m.materials["fiber"]) >= ROPE_FIBER)
	r["rope"] = floods if can_rope else 0
	var coins := 0
	for e in evs:
		if e == "cairn":
			coins += t.CAIRN_COINS
			sanity -= t.CAIRN_SANITY
		elif e == "hollow":
			coins -= 9
	r["coins"] = coins
	r["sanity"] = maxf(0.0, sanity)
	return r


# Coins free to spend: what is owed, or the next bill from a month before it comes, is kept back.
func _spare() -> int:
	var d := m._calendar_date(m.day + 30)
	var bill_soon := m.TAX_MONTHS.has(int(d["month"])) and m.tax_owed == 0
	return m.money - m.tax_owed - (m.desk._property_value() if bill_soon else 0)


func _trail_works() -> void:
	if works_done >= TRAIL_WORKS.size() or m.day < int(TRAIL_WORKS[works_done]["day"]):
		return
	var w: Dictionary = TRAIL_WORKS[works_done]
	if int(w.get("rope", 0)) > rope and int(m.materials["fiber"]) >= ROPE_FIBER:
		m.materials["fiber"] -= ROPE_FIBER   # twist a rope toward it
		rope += 1
	if _spare() < int(w["coins"]) + 100 or rope < int(w.get("rope", 0)):
		return
	for k in w:
		if not k in ["id", "day", "coins", "rope"] and int(m.materials[k]) < int(w[k]):
			return
	m.money -= int(w["coins"])
	trek_log["works_coins"] += int(w["coins"])
	rope -= int(w.get("rope", 0))
	for k in w:
		if not k in ["id", "day", "coins", "rope"]:
			m.materials[k] -= int(w[k])
	works_done += 1
	_mark("work: " + str(w["id"]))


# --- Nights -------------------------------------------------------------------------------

func _face_night() -> String:
	m.current_hour = maxf(m.current_hour, m.EVENT_HOUR)
	m.nights._begin()
	var v: Dictionary = m.nights.visitor
	if v.is_empty():
		return "quiet"
	var id := str(v["id"])
	if id == "hollow":
		nights["hollow"] += 1
	m.nights._resolve(true)
	nights["faced"] += 1
	return id + "+"


func _ignore_night() -> String:
	m.current_hour = maxf(m.current_hour, m.EVENT_HOUR)
	m.nights._begin()
	var v: Dictionary = m.nights.visitor
	if v.is_empty():
		return "quiet"
	var id := str(v["id"])
	if id == "hollow":
		nights["hollow"] += 1
	m.nights._resolve(false)
	nights["ignored"] += 1
	return id + "-"


# --- Output -------------------------------------------------------------------------------

func _track_sanity() -> void:
	min_sanity = minf(min_sanity, m.sanity)
	if m.sanity < m.LOW_SANITY:
		low_days[m.day] = true


func _mark(name: String) -> void:
	if not milestones.has(name):
		milestones[name] = m.day


func _note_milestones() -> void:
	for s in m.projects._steps():
		if bool(s["done"]):
			_mark("step: " + str(s["id"]))
	for skill in ["Farming", "Carpentry", "Cleaning", "Bushcrafting", "Forestry", "Mining", "Smithing"]:
		for lv in range(2, 11):
			if m.progression._level(skill) >= lv:
				_mark("%s %d" % [skill, lv])
	if m.well_repaired:
		_mark("well repaired")
	if m.hose_attached:
		_mark("hose attached")
	if m.tax_owed > 0:
		_mark("tax billed")
	if m.money >= 150:
		_mark("150 coins held")
	for k in ["storm_oak", "flax", "bell_metal", "bell_frame", "bell_rope"]:
		if int(m.materials[k]) > 0:
			_mark("got " + k)


func _lv(skill: String) -> int:
	return m.progression._level(skill)


func _row(night: String) -> void:
	var d := m._calendar_date(m.day)
	print("%3d %s %d %5d %3d/%3d %3d  %2d %2d %2d %2d %2d %2d %2d %5d %3d %4d %4d %4d %3d %4d %4d %s" % [
		m.day, str(m.MONTH_NAMES[int(d["month"])]).substr(0, 3), int(d["day"]), m.money, int(m.sanity), int(m.sanity_sys._sanity_max()),
		int(m.materials["feathers"]), _lv("Farming"), _lv("Carpentry"), _lv("Cleaning"), _lv("Bushcrafting"), _lv("Forestry"),
		_lv("Mining"), _lv("Smithing"), _steps_done(), m.nights.shadow_steps, m.tax_owed, m.crops.size(),
		int(m.materials["wood"]), int(m.materials["fiber"]), m.wear, m.clean_nights, night])


func _steps_done() -> int:
	var n := 0
	for s in m.projects._steps():
		if bool(s["done"]):
			n += 1
	return n


func _summary() -> void:
	print("--- milestones (first day)")
	var names := milestones.keys()
	names.sort_custom(func(a, b) -> bool: return milestones[a] < milestones[b] or (milestones[a] == milestones[b] and str(a) < str(b)))
	var line := ""
	for n in names:
		line += "%s=%d  " % [n, milestones[n]]
		if line.length() > 100:
			print(line)
			line = ""
	if line != "":
		print(line)
	print("--- totals: nights %s, min sanity %d, days under %d sanity %d, sanity limit %d, HP lost to needs %d, hours empty %s, hours fished %d" % [
		nights, int(min_sanity), int(m.LOW_SANITY), low_days.size(), int(m.sanity_sys._sanity_max()), hp_lost, empty_hours, fished_hours])
	print("--- coins earned %s, spent %s; hens %d goats %d; property value %d; tax owed %d" % [earned, spent, m.hens, m.goats, m.desk._property_value(), m.tax_owed])
	print("--- materials: %s" % JSON.stringify(m.materials))
	if treks_a_week > 0:
		print("--- treks: %s, trail works done %d" % [trek_log, works_done])
	if caves["visits"] > 0:
		print("--- cave: %.1f copper and %.1f iron nodes a day on average, over %d visits" % [
			float(caves["copper"]) / caves["visits"], float(caves["iron"]) / caves["visits"], caves["visits"]])
	var next := m.projects._next_step()
	print("--- next step: %s" % str(next.get("title", "all done")))
