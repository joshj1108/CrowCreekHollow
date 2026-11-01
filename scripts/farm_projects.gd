class_name FarmProjects
extends RefCounted

# The farm's long-term goals and the things you place to make it yours.
# - Progress: a ladder of homestead steps (repairs, buildings, plots, decor, the crow bell). The Buildings
#   section shows how far along you are and the next step; each step done pays a little and names the next.
# - Decor, placed like the coop from the Buildings section: lamp posts that hold back the dark, flower beds
#   that lift your spirits each morning, gravel paths, sprinklers on the plots, and the crow bell, the last
#   big project, which keeps the Hollow away for good.

var m: MainGame

const DECOR := {
	"lamp": {"name": "Lamp post", "cost": {"wood": 3, "iron_bar": 1}, "skill": "Smithing", "level": 7, "max": 8, "blocks": true,
		"desc": "Lights the ground around it at night. In its light the dark doesn't wear on your sanity."},
	"flowers": {"name": "Flower bed", "cost": {"wood": 1, "seeds": 2}, "skill": "Farming", "level": 2, "max": 6, "blocks": true,
		"desc": "Planted in spring or summer. Each bed gives +1 sanity every morning, except in winter."},
	"path": {"name": "Gravel path", "cost": {"stone": 1}, "skill": "", "level": 0, "max": 400, "blocks": false,
		"desc": "Turns a tile of grass into path. Keeps placing until you run out of stone or press B."},
	"apple_tree": {"name": "Apple tree", "cost": {"apple_sapling": 1}, "skill": "Farming", "level": 4, "max": 6, "blocks": true,
		"desc": "A sapling from the drowned orchard, which the Tull family give once they know you (walk Davy to the orchard). Each bears an apple every autumn morning."},
	"sprinkler": {"name": "Sprinkler", "cost": {"copper_bar": 5, "iron_bar": 1}, "skill": "Smithing", "level": 4, "max": 12, "blocks": true,
		"desc": "Set on an empty plot tile and piped from the well. Each dry morning it waters the eight crops around it, a water each from the tank."},
	"sprinkler_big": {"name": "Spray sprinkler", "cost": {"copper_bar": 15, "iron_bar": 3}, "skill": "Smithing", "level": 8, "max": 6, "blocks": true,
		"desc": "A brass head on a tall copper riser, set on an empty plot tile. Each dry morning it waters the 24 crops in the five by five around it, a water each from the tank."},
	"fence": {"name": "Wattle fence", "cost": {"sticks": 2, "wood": 1}, "skill": "", "level": 0, "max": 300, "blocks": true,
		"desc": "Woven sticks between posts. Fences join up with the fences beside them. Keeps placing until you run short or press B."},
	"bench": {"name": "Garden bench", "cost": {"hardwood": 6, "iron_bar": 1}, "skill": "Carpentry", "level": 4, "max": 4, "blocks": true,
		"desc": "A hardwood bench with iron ends."},
	"birdbath": {"name": "Birdbath", "cost": {"stone": 12, "copper_bar": 3}, "skill": "", "level": 0, "max": 3, "blocks": true,
		"desc": "A stone bowl on a pillar with a copper rim. The crows don't drink from it."},
	"weathervane": {"name": "Weathervane", "cost": {"copper_bar": 8, "iron_bar": 2, "coins": 60}, "skill": "Smithing", "level": 5, "max": 1, "blocks": true,
		"desc": "A copper cockerel on an iron post. It turns to face the field at night, whatever the wind."},
	"torch": {"name": "Torch", "cost": {"sticks": 1, "fiber": 1, "resin": 1}, "skill": "Bushcrafting", "level": 2, "max": 12, "blocks": true, "xp": 5,
		"desc": "Pitch-soaked fiber bound to a stick. It burns one night in a small ring of light: in it the dark doesn't wear on you, and a coop or barn it lights is raided less and the thing scared off. Burnt out by morning."},
	"snare": {"name": "Snare", "cost": {"sticks": 2, "fiber": 2}, "skill": "Bushcrafting", "level": 2, "max": 4, "blocks": false, "xp": 5,
		"desc": "A noose of twisted fiber on a bent stick. Check it each morning: a hare, a few feathers, or nothing. Space takes what it holds."},
	"scarecrow": {"name": "Scarecrow", "cost": {"wood": 3, "sticks": 2, "fiber": 3}, "skill": "Carpentry", "level": 2, "max": 4, "blocks": true, "xp": 20,
		"desc": "Old clothes on a cross of boards. At night the crows won't settle on crops within 4 tiles of it."},
	"shutters": {"name": "Window shutters", "cost": {"wood": 6, "sticks": 2, "fiber": 2}, "skill": "Carpentry", "level": 3, "max": 1, "blocks": true, "xp": 30,
		"desc": "Hung on a farmhouse wall. From 18:00, Space bars them for the night, and the knocking takes half as much from you."},
	"bell": {"name": "Crow bell", "cost": {"bell_metal": 1, "bell_frame": 1, "bell_rope": 1, "bell_clapper": 1, "feathers": 20, "coins": 150}, "skill": "Carpentry", "level": 6, "max": 1, "blocks": true,
		"desc": "Hung only on All Hallows, and the Hollow comes to it that night. While it stands, the field shadow can't reach the house, so the Hollow stops coming, and the night takes a quarter less from your sanity."},
}
# The crow bell is made over a year: its metal in winter, its frame from a spring storm's oak, its rope from
# summer's wild flax, its clapper from the vicar (the old bell's, given on a chapel trek), and it is hung on
# All Hallows. A game starts on October 1st, so the earliest is the second All Hallows, day 396.
const BELL_PARTS := {
	"bell_metal": {"name": "Bell metal", "season": "Winter", "cost": {"iron_bar": 4, "copper_bar": 2, "feathers": 10}, "skill": "Smithing", "level": 6,
		"desc": "Cast at the furnace and cooled in the frost, so only in winter."},
	"bell_frame": {"name": "Bell frame", "season": "", "cost": {"storm_oak": 1, "hardwood": 6}, "skill": "Carpentry", "level": 6,
		"desc": "A yoke of storm oak. Spring storms split an oak at the wood's edge now and then."},
	"bell_rope": {"name": "Bell rope", "season": "", "cost": {"flax": 9, "resin": 2}, "skill": "Bushcrafting", "level": 5,
		"desc": "Twisted from wild flax, which flowers at the wood's edge in summer."},
}
const SPRINKLERS := {"sprinkler": 1, "sprinkler_big": 2}   # kind -> tiles of reach each way
const BELL_MONTH := 9           # All Hallows, October 31st: the only day the bell can be hung
const BELL_DOM := 31
const PART_XP := 40
const LAMP_RADIUS := 3.0        # tiles of light around a lamp post
const TORCH_RADIUS := 2.0       # a torch's smaller ring, for one night
const LIGHT_RADIUS := {"lamp": LAMP_RADIUS, "torch": TORCH_RADIUS}
const SCARECROW_REACH := 4.0    # crows won't settle on crops this close to a scarecrow
const SHUTTER_KNOCK := 0.5      # what the knocking takes while the shutters are barred
const XP_SNARE := 15            # Bushcrafting XP for taking a catch from a snare
const XP_BAR := 10              # Carpentry XP for barring the shutters, once a night
const XP_FENCE := 20            # Carpentry XP for mending a broken fence rail
const FENCE_MEND := {"wood": 1, "sticks": 1}
const RAID_FENCE := 0.03        # raid chance added for each broken fence rail
# A snare's catch each morning, tried in order: hare, feathers, or something wrong; otherwise nothing.
const SNARE_CATCHES := [
	{"chance": 0.40, "id": "hare"},
	{"chance": 0.15, "id": "feathers"},
	{"chance": 0.07, "id": "wrong"},
]
const BELL_NIGHT_MULT := 0.75
const STEP_COINS := 20          # paid for each homestead step done
const REMOVE_SECONDS := 4.0     # time to press Space again to take something down

var decor := {}                 # saved: world tile -> kind
var steps_done := {}            # saved: step id -> true
var bell_day := -1              # the day the bell was hung, so the Hollow comes to it that night
var snared := {}                # saved: snare tile -> what it caught overnight
var broken := {}                # saved: fence tiles (the farm's or yours) torn loose, until mended
var barred_day := -1            # the evening the shutters were barred
var layer: Node2D
var lights := {}                # lamp tile -> PointLight2D
var _remove_tile := Vector2i(-1, -1)
var _remove_until := 0.0


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	layer = Node2D.new()
	layer.draw.connect(_draw)
	m.add_child(layer)


# The homestead ladder, in order. Each is done when its test passes.
func _steps() -> Array:
	return [
		{"id": "boarded", "title": "Board up the house", "how": "House section: repair to Boarded, Carpentry 1.", "done": m.house_stage >= 1},
		{"id": "plot_two", "title": "Open the second plot", "how": "Opens at Farming 2.", "done": m.plot_two_open},
		{"id": "coop", "title": "Build the coop", "how": "Buildings section: 6 wood, 4 fiber, Carpentry 2.", "done": m.coop_built},
		{"id": "patched", "title": "Patch the house", "how": "House section: repair to Patched, Carpentry 3.", "done": m.house_stage >= 2},
		{"id": "smokehouse", "title": "Build the smokehouse", "how": "Buildings section, in the workshop: Carpentry 4.", "done": m.smokehouse_built},
		{"id": "woodshed", "title": "Build the firewood store", "how": "Buildings section, after the smokehouse or furnace.", "done": m.woodshed_built},
		{"id": "furnace", "title": "Build the furnace", "how": "Buildings section, in the workshop: Carpentry 5.", "done": m.furnace_built},
		{"id": "lamp", "title": "Light the yard", "how": "Place a lamp post (Buildings, Decor): 3 wood, 1 iron bar, Smithing 7.", "done": _count("lamp") >= 1},
		{"id": "plot_three", "title": "Open the third plot", "how": "Opens at Farming 9 once the house is Patched.", "done": m.plot_three_open},
		{"id": "barn", "title": "Build the barn", "how": "Buildings section: 10 wood, 6 fiber, Carpentry 7.", "done": m.barn_built},
		{"id": "hollow_lantern", "title": "Make the Hollow Lantern", "how": "Craft section, Other tab: the lantern's third tier.", "done": m.lantern_tier >= 3},
		{"id": "flowers", "title": "Plant four flower beds", "how": "Buildings, Decor, in spring or summer: 1 wood and 2 turnip seeds each, Farming 2.", "done": _count("flowers") >= 4},
		{"id": "restored", "title": "Restore the house", "how": "House section: repair to Restored, Carpentry 8, in summer when the paint can dry.", "done": m.house_stage >= 3},
		{"id": "bell", "title": "Hang the crow bell", "how": "Buildings, The crow bell: its metal in winter, its frame from storm oak, its rope from summer flax, its clapper from the vicar on a chapel trek, then hang it on All Hallows.", "done": _has_bell()},
	]


func _next_step() -> Dictionary:
	for s in _steps():
		if not s["done"]:
			return s
	return {}


# Records steps that are now done. announce pays for each and names the next; off when a game starts, so a
# loaded save's earlier steps are only recorded.
func _check(announce: bool) -> void:
	var newly: Array = []
	for s in _steps():
		if s["done"] and not steps_done.has(s["id"]):
			steps_done[s["id"]] = true
			newly.append(s)
	if not announce or newly.is_empty():
		return
	m.money += STEP_COINS * newly.size()
	var nxt := _next_step()
	var text := "Homestead step done: %s. +%d coins. %d of %d done." % [newly[-1]["title"], STEP_COINS * newly.size(), steps_done.size(), _steps().size()]
	text += (" Next: %s." % nxt["title"]) if not nxt.is_empty() else " Every step is done. The farm is yours."
	m.play_sfx("chime", 0.0)
	m._show_message(text)


func _count(kind: String) -> int:
	var n := 0
	for t in decor:
		if decor[t] == kind:
			n += 1
	return n


func _has_bell() -> bool:
	return _count("bell") > 0


func _level_ok(kind: String) -> bool:
	var d: Dictionary = DECOR[kind]
	return str(d["skill"]) == "" or m.progression._level(str(d["skill"])) >= int(d["level"])


func _can_afford(kind: String) -> bool:
	var cost: Dictionary = DECOR[kind]["cost"]
	for key in cost:
		if m._held(str(key)) < int(cost[key]):
			return false
	return true


func _can_place(kind: String) -> bool:
	return _level_ok(kind) and _can_afford(kind) and _count(kind) < int(DECOR[kind]["max"]) and (kind != "bell" or _bell_night()) \
		and (kind != "flowers" or _season() in ["Spring", "Summer"])


func _bell_night() -> bool:
	var d := m._calendar_date(m.day)
	return int(d["month"]) == BELL_MONTH and int(d["day"]) == BELL_DOM


func _season() -> String:
	return m._season_of(m._calendar_date(m.day)["month"])


# Why a bell part can't be made now: "made", a reason, or "" when it can.
func _part_why(id: String) -> String:
	var p: Dictionary = BELL_PARTS[id]
	if int(m.materials[id]) > 0 or _has_bell():
		return "made"
	if m.progression._level(str(p["skill"])) < int(p["level"]):
		return "needs %s %d" % [p["skill"], int(p["level"])]
	if str(p["season"]) != "" and _season() != str(p["season"]):
		return "only in %s" % str(p["season"]).to_lower()
	if id == "bell_metal" and not m.furnace_built:
		return "needs the furnace"
	for key in p["cost"]:
		if m._held(str(key)) < int(p["cost"][key]):
			return "needs %s" % _cost_list(p["cost"])
	return ""


func _make_part(id: String) -> void:
	var why := _part_why(id)
	var p: Dictionary = BELL_PARTS[id]
	if why != "":
		m._show_message("%s: %s." % [p["name"], why])
		return
	for key in p["cost"]:
		m.materials[key] -= int(p["cost"][key])
	m.materials[id] += 1
	m.progression._grant_xp(str(p["skill"]), PART_XP)
	m.play_sfx("repair", 0.05)
	m._show_message("You make the %s. +%d %s XP. The bell is hung on All Hallows." % [str(p["name"]).to_lower(), PART_XP, p["skill"]])


func _cost_list(cost: Dictionary) -> String:
	var parts: Array = []
	for key in cost:
		var label := "turnip seeds" if key == "seeds" else ("crow feathers" if key == "feathers" else str(key).replace("_", " "))
		parts.append("%d %s" % [int(cost[key]), label])
	return ", ".join(parts)


func _cost_text(kind: String) -> String:
	var parts: Array = [_cost_list(DECOR[kind]["cost"])]
	var d: Dictionary = DECOR[kind]
	if str(d["skill"]) != "":
		parts.append("%s %d" % [d["skill"], int(d["level"])])
	return ", ".join(parts)


func _pay(kind: String, sign: int) -> void:
	var cost: Dictionary = DECOR[kind]["cost"]
	for key in cost:
		var n := int(cost[key]) * sign
		if key == "coins":
			m.money -= n
		elif m.materials.has(key):
			m.materials[key] -= n
		else:
			m.inventory[key] -= n


func _start_place(kind: String) -> void:
	if m.inside or m.in_cave:
		m._show_message("You can only place things on the farm.")
		return
	if kind == "flowers" and not _season() in ["Spring", "Summer"]:
		m._show_message("Flower beds go in in spring or summer.")
		return
	if kind == "bell" and _level_ok(kind) and _can_afford(kind) and not _bell_night():
		m._show_message("The crow bell can only be hung on All Hallows, October 31.")
		return
	if not _can_place(kind):
		m._show_message("A %s needs %s." % [str(DECOR[kind]["name"]).to_lower(), _cost_text(kind)])
		return
	m.placing = "decor:" + kind
	m._close_panel()
	var where := "an empty plot tile" if kind in SPRINKLERS else "open grass"
	m._show_message("Face %s where the %s should go and press Space. B cancels." % [where, str(DECOR[kind]["name"]).to_lower()])


# A sprinkler goes on a plot tile with no crop; everything else on open grass.
func _fits(kind: String, t: Vector2i) -> bool:
	if kind in SPRINKLERS:
		return m._in_bounds(t) and m.map[t.y][t.x] == MainGame.Tile.SOIL and not m.crops.has(t) and not decor.has(t) and t != m._player_tile()
	if kind == "shutters":
		return m._in_bounds(t) and m.map[t.y][t.x] == MainGame.Tile.HOUSE and not decor.has(t)
	return m._spot_ok(t, Vector2i.ONE)


func _confirm(kind: String, t: Vector2i) -> void:
	if not _fits(kind, t):
		m._show_message("That spot isn't an empty plot tile." if kind in SPRINKLERS else ("Face the farmhouse wall." if kind == "shutters" else "That spot isn't open grass."))
		return
	_pay(kind, 1)
	decor[t] = kind
	if DECOR[kind].has("xp"):
		m.progression._grant_xp(str(DECOR[kind]["skill"]), int(DECOR[kind]["xp"]))
	if kind == "bell":
		bell_day = m.day
	_stamp()
	m.play_sfx("repair" if kind != "path" else "hoe", 0.05)
	if kind == "path" and _can_place("path"):
		# Paths keep going, one tile at a time, until the stone runs out or B is pressed.
		m._show_message("Path laid. Face the next tile and press Space, or B to stop. %d stone left." % int(m.materials["stone"]))
		return
	if kind == "fence" and _can_place("fence"):
		m._show_message("Fence put up. Face the next tile and press Space, or B to stop. %d sticks left." % int(m.materials["sticks"]))
		return
	m.placing = ""
	m._show_message("The %s stands here now." % str(DECOR[kind]["name"]).to_lower() if kind != "path" else "That was the last of your stone.")
	if kind == "fence":
		m._show_message("That was the last of your sticks or wood for fencing.")
	_check(true)


# Space on a placed thing: the first press asks, the second within a few seconds takes it down.
func _try_use(t: Vector2i) -> bool:
	if not decor.has(t):
		return false
	var kind: String = decor[t]
	if kind == "snare" and snared.has(t):
		_take_catch(t)
		return true
	if kind == "shutters" and m.current_hour >= 18.0 and barred_day != m.day:
		barred_day = m.day
		m.progression._grant_xp("Carpentry", XP_BAR)
		m.play_sfx("door", 0.05)
		m._show_message("You swing the shutters to and drop the bar. The knocking will take half as much tonight. +%d Carpentry XP" % XP_BAR)
		return true
	var now := Time.get_ticks_msec() / 1000.0
	if _remove_tile != t or now > _remove_until:
		_remove_tile = t
		_remove_until = now + REMOVE_SECONDS
		m._show_message("%s. %s Press Space again to take it down." % [DECOR[kind]["name"], DECOR[kind]["desc"]])
		return true
	_remove_tile = Vector2i(-1, -1)
	decor.erase(t)
	snared.erase(t)
	_pay(kind, -1)
	if kind == "path":
		m.map[t.y][t.x] = MainGame.Tile.GRASS
	m.queue_redraw()
	_stamp()
	m._show_message("You take down the %s and keep its materials." % str(DECOR[kind]["name"]).to_lower())
	return true


# Puts the placed things on the map and gives each lamp its light. Paths become path tiles.
func _stamp() -> void:
	for t in decor:
		if decor[t] == "path":
			m.map[t.y][t.x] = MainGame.Tile.PATH
	for t in lights.keys():
		if not LIGHT_RADIUS.has(decor.get(t, "")):
			(lights[t] as Node).queue_free()
			lights.erase(t)
	for t in decor:
		if LIGHT_RADIUS.has(decor[t]) and not lights.has(t):
			var torch: bool = decor[t] == "torch"
			var light := PointLight2D.new()
			light.texture = m._glow_texture()
			light.color = Color("ff9a4a") if torch else Color("ffd27a")
			light.texture_scale = float(LIGHT_RADIUS[decor[t]]) * m.PX / 128.0
			light.position = m._tile_center(t.x, t.y) + Vector2(0, -m.PX * (0.7 if torch else 1.1))
			light.enabled = false
			m.add_child(light)
			lights[t] = light
	m.queue_redraw()
	if layer != null:
		layer.queue_redraw()


func _blocks(t: Vector2i) -> bool:
	return decor.has(t) and bool(DECOR[decor[t]]["blocks"])


# True when a tile is in a lamp post's or a torch's light.
func _lit(t: Vector2i) -> bool:
	for l in lights:
		if Vector2(t - (l as Vector2i)).length() <= float(LIGHT_RADIUS.get(decor.get(l, "lamp"), LAMP_RADIUS)):
			return true
	return false


# True when a scarecrow stands near enough to keep the crows off this crop.
func _guarded(t: Vector2i) -> bool:
	for d in decor:
		if decor[d] == "scarecrow" and Vector2(t - (d as Vector2i)).length() <= SCARECROW_REACH:
			return true
	return false


# The shutters barred this evening (the night runs past midnight, so last evening's bar holds until dawn).
func _shutters_barred() -> bool:
	if _count("shutters") == 0:
		return false
	return barred_day == m.day or (barred_day == m.day - 1 and m.current_hour < 6.0)


# Each frame: lamps glow after dusk, and only out on the farm.
func _update(darkness: float) -> void:
	var on := not m.inside and not m.in_cave and darkness > 0.1
	for l in lights.values():
		(l as PointLight2D).enabled = on
		(l as PointLight2D).energy = m.WINDOW_ENERGY * (0.7 + 0.5 * darkness)
	if layer != null:
		layer.visible = not m.inside and not m.in_cave


# Each dry morning, every sprinkler waters the growing crops on the eight tiles around it from the well's
# tank, while the tank lasts. Rain has already watered them. Returns a note for the morning message.
func _sprinkle() -> String:
	if _count("sprinkler") + _count("sprinkler_big") == 0 or not m.well_repaired or not m.hose_attached or m.weather_kind in m.WATER_RAIN_KINDS:
		return ""
	var n := 0
	var dry := false
	for s in decor:
		if not decor[s] in SPRINKLERS:
			continue
		var reach: int = SPRINKLERS[decor[s]]
		for dy in range(-reach, reach + 1):
			for dx in range(-reach, reach + 1):
				var t: Vector2i = s + Vector2i(dx, dy)
				if not m.crops.has(t) or int(m.crops[t]["stage"]) >= m.MAX_STAGE or int(m.crops[t].get("watered_day", 0)) == m.day:
					continue
				if m.well_water < 1.0:
					dry = true
					continue
				m.well_water -= 1.0
				m.crops[t]["watered_day"] = m.day
				n += 1
	if n == 0 and not dry:
		return ""
	return " The sprinklers watered %d crop%s%s." % [n, "" if n == 1 else "s", ", and ran the tank dry" if dry else ""]


# The morning's lift from the flower beds.
func _morning() -> String:
	return _apples() + _flowers() + _burn_torches() + _check_snares() + _break_fences()


# Torches burn one night and are gone by morning.
func _burn_torches() -> String:
	var n := 0
	for t in decor.keys():
		if decor[t] == "torch":
			decor.erase(t)
			n += 1
	if n == 0:
		return ""
	_stamp()
	return " Your torch%s burned out in the night." % ("" if n == 1 else "es")


# Each empty snare may hold something by morning, fixed by the day and the spot.
func _check_snares() -> String:
	var caught := 0
	for t in decor:
		if decor[t] != "snare" or snared.has(t):
			continue
		var rng := RandomNumberGenerator.new()
		rng.seed = hash([m.day, t, "snare"])
		var roll := rng.randf()
		for c in SNARE_CATCHES:
			roll -= float(c["chance"])
			if roll < 0.0:
				snared[t] = str(c["id"])
				caught += 1
				break
	return (" Something is in %d of your snares." % caught) if caught > 0 else ""


func _take_catch(t: Vector2i) -> void:
	var text := ""
	match str(snared[t]):
		"hare":
			if not m.stall._pack_room(int(m.inventory["hare"]), 1):
				m._show_message("A hare is in the snare, but your pack is full.")
				return
			m.inventory["hare"] += 1
			text = "A hare, cold and stiff in the noose."
		"feathers":
			m.materials["feathers"] += 2
			text = "No hare, but a crow fought the noose and left two feathers."
		_:
			m.materials["feathers"] += 1
			m.sanity_sys._change_sanity(-3.0)
			text = "The noose is drawn tight around a crow's skull, picked clean. -3 sanity."
	snared.erase(t)
	m.progression._grant_xp("Bushcrafting", XP_SNARE)
	m.play_sfx("gather", 0.05)
	m._show_message(text + " You reset the snare. +%d Bushcrafting XP" % XP_SNARE)
	if layer != null:
		layer.queue_redraw()


# Storms, the wind and the creeping shadow tear fence rails loose, the farm's own and the ones you put up.
func _break_fences() -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, "fences"])
	var n := 0
	match str(m.weather_kind):
		"downpour":
			n = 2
		"rain":
			n = 1 if rng.randf() < 0.6 else 0
		_:
			n = 1 if rng.randf() < 0.15 else 0
	if m.nights.shadow_steps >= 4:
		n += 1
	var whole: Array = []
	for y in m.map.size():
		for x in (m.map[y] as Array).size():
			if m.map[y][x] == MainGame.Tile.FENCE and not broken.has(Vector2i(x, y)):
				whole.append(Vector2i(x, y))
	for t in decor:
		if decor[t] == "fence" and not broken.has(t):
			whole.append(t)
	var done := 0
	while done < n and not whole.is_empty():
		broken[whole.pop_at(rng.randi() % whole.size())] = true
		done += 1
	if layer != null:
		layer.queue_redraw()
	if done == 0:
		return ""
	return " %d fence rail%s tore loose in the night. Mend them before something finds the gap." % [done, "" if done == 1 else "s"]


# Space on a torn rail mends it.
func _repair_fence(t: Vector2i) -> bool:
	if not broken.has(t):
		return false
	for mat in FENCE_MEND:
		if int(m.materials[mat]) < int(FENCE_MEND[mat]):
			m._show_message("This rail is torn loose. Mending it takes %s." % _cost_list(FENCE_MEND))
			return true
	for mat in FENCE_MEND:
		m.materials[mat] -= int(FENCE_MEND[mat])
	broken.erase(t)
	m.progression._grant_xp("Carpentry", XP_FENCE)
	m.play_sfx("repair", 0.05)
	var left := ("%d more torn loose." % broken.size()) if broken.size() > 0 else "The fences are whole."
	m._show_message("You lash the rail back in place. %s +%d Carpentry XP" % [left, XP_FENCE])
	if layer != null:
		layer.queue_redraw()
	return true


# Each apple tree drops an apple every autumn morning.
func _apples() -> String:
	var trees := _count("apple_tree")
	if trees == 0 or _season() != "Autumn":
		return ""
	m.inventory["apples"] += trees
	return " The apple tree%s dropped %d apple%s in the night." % ["" if trees == 1 else "s", trees, "" if trees == 1 else "s"]


func _flowers() -> String:
	var beds := _count("flowers")
	if beds == 0:
		return ""
	if m._season_of(m._calendar_date(m.day)["month"]) == "Winter":
		return " The flower beds are bare under the frost."
	m.sanity_sys._change_sanity(float(beds))
	return " Your flower beds lift your spirits. +%d sanity." % beds


func _night_mult() -> float:
	return BELL_NIGHT_MULT if _has_bell() else 1.0


func _draw() -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	var winter := m._season_of(m._calendar_date(m.day)["month"]) == "Winter"
	for t in decor:
		var c := m._tile_center(t.x, t.y)
		match str(decor[t]):
			"lamp":
				var base := c + Vector2(0, px * 0.35)
				layer.draw_rect(Rect2(base + Vector2(-px * 0.2, -px * 0.12), Vector2(px * 0.4, px * 0.12)), ink)
				layer.draw_line(base, base + Vector2(0, -px * 1.2), ink, 6.0)
				layer.draw_line(base, base + Vector2(0, -px * 1.2), Color("3a3a40"), 4.0)
				var head := Rect2(base + Vector2(-px * 0.16, -px * 1.5), Vector2(px * 0.32, px * 0.32))
				layer.draw_rect(head.grow(2.0), ink)
				layer.draw_rect(head, Color(1.8, 1.5, 0.9))
				layer.draw_rect(Rect2(head.position + Vector2(-3, -5), Vector2(head.size.x + 6, 5)), Color("3a3a40"))
			"flowers":
				var bed := Rect2(c - Vector2(px * 0.42, px * 0.3), Vector2(px * 0.84, px * 0.6))
				layer.draw_rect(bed.grow(2.0), ink)
				layer.draw_rect(bed, Color("6b4a3a"))
				layer.draw_rect(bed.grow(-3.0), Color("4a3428"))
				var colours := [Color("d86a8a"), Color("e8c050"), Color("e8e0f0"), Color("9a7ad8")]
				for k in 6:
					var p := bed.position + Vector2(px * (0.14 + 0.28 * (k % 3)), px * (0.17 + 0.26 * (k / 3)))
					if winter:
						layer.draw_line(p, p + Vector2(0, -6), Color("7a6a50"), 2.0)
						continue
					layer.draw_line(p, p + Vector2(0, 6), Color("4a7a3a"), 2.0)
					layer.draw_circle(p, 4.5, ink)
					layer.draw_circle(p, 3.5, colours[(k + t.x) % colours.size()])
			"apple_tree":
				# A short trunk under a round crown, bare in winter, with apples in autumn.
				var foot := c + Vector2(0, px * 0.4)
				layer.draw_line(foot, foot + Vector2(0, -px * 0.6), ink, 8.0)
				layer.draw_line(foot, foot + Vector2(0, -px * 0.6), Color("5a3a26"), 5.0)
				var crown := foot + Vector2(0, -px * 0.85)
				if winter:
					for k in 3:
						var tip := crown + Vector2(px * (k - 1) * 0.3, -px * 0.25)
						layer.draw_line(foot + Vector2(0, -px * 0.55), tip, Color("5a3a26"), 3.0)
				else:
					layer.draw_circle(crown, px * 0.42 + 2.0, ink)
					layer.draw_circle(crown, px * 0.42, Color("4a6a32"))
					layer.draw_circle(crown + Vector2(-px * 0.1, -px * 0.1), px * 0.24, Color("5a7a3a"))
					if _season() == "Autumn":
						for k in 4:
							layer.draw_circle(crown + Vector2(px * (-0.22 + 0.15 * k), px * (0.12 if k % 2 == 0 else -0.08)), 3.5, Color("b8442e"))
			"sprinkler":
				# A copper riser on a stone foot, with a spinning head and two arms.
				var foot := c + Vector2(0, px * 0.3)
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.18, -px * 0.08), Vector2(px * 0.36, px * 0.14)).grow(2.0), ink)
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.18, -px * 0.08), Vector2(px * 0.36, px * 0.14)), Color("6a6a6a"))
				layer.draw_line(foot, foot + Vector2(0, -px * 0.55), ink, 6.0)
				layer.draw_line(foot, foot + Vector2(0, -px * 0.55), Color("b8733a"), 3.0)
				var head := foot + Vector2(0, -px * 0.6)
				layer.draw_line(head + Vector2(-px * 0.28, 0), head + Vector2(px * 0.28, 0), ink, 5.0)
				layer.draw_line(head + Vector2(-px * 0.28, 0), head + Vector2(px * 0.28, 0), Color("c8844a"), 2.0)
				layer.draw_circle(head, 4.5, ink)
				layer.draw_circle(head, 3.0, Color("d8a060"))
			"sprinkler_big":
				# A taller copper riser with a brass head and four arms.
				var foot := c + Vector2(0, px * 0.3)
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.22, -px * 0.1), Vector2(px * 0.44, px * 0.16)).grow(2.0), ink)
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.22, -px * 0.1), Vector2(px * 0.44, px * 0.16)), Color("6a6a6a"))
				layer.draw_line(foot, foot + Vector2(0, -px * 0.85), ink, 7.0)
				layer.draw_line(foot, foot + Vector2(0, -px * 0.85), Color("b8733a"), 4.0)
				var head := foot + Vector2(0, -px * 0.9)
				for arm in [Vector2(px * 0.36, 0), Vector2(px * 0.2, -px * 0.14)]:
					layer.draw_line(head - arm, head + arm, ink, 5.0)
					layer.draw_line(head - arm, head + arm, Color("d8b048"), 2.0)
				layer.draw_circle(head, 5.5, ink)
				layer.draw_circle(head, 4.0, Color("e8c060"))
			"fence":
				# A post, with woven rails reaching toward any fence beside it.
				var post := Rect2(c + Vector2(-px * 0.08, -px * 0.45), Vector2(px * 0.16, px * 0.8))
				for side in [Vector2i(1, 0), Vector2i(-1, 0)]:
					if decor.get(t + side, "") == "fence":
						for k in 2:
							var y := c.y - px * (0.25 - 0.25 * k)
							layer.draw_line(Vector2(c.x, y), Vector2(c.x + px * 0.5 * side.x, y), ink, 6.0)
							layer.draw_line(Vector2(c.x, y), Vector2(c.x + px * 0.5 * side.x, y), Color("8a6a40"), 3.0)
				if decor.get(t + Vector2i(0, -1), "") == "fence":
					layer.draw_line(c, c + Vector2(0, -px), ink, 6.0)
					layer.draw_line(c, c + Vector2(0, -px), Color("8a6a40"), 3.0)
				layer.draw_rect(post.grow(2.0), ink)
				layer.draw_rect(post, Color("6b4a30"))
			"bench":
				var seat := Rect2(c + Vector2(-px * 0.45, -px * 0.1), Vector2(px * 0.9, px * 0.16))
				var back := Rect2(c + Vector2(-px * 0.45, -px * 0.45), Vector2(px * 0.9, px * 0.14))
				for x in [seat.position.x + 2, seat.end.x - 6]:
					layer.draw_rect(Rect2(x - 1, back.position.y - 1, 6, px * 0.75), ink)
					layer.draw_rect(Rect2(x, back.position.y, 4, px * 0.72), Color("3a3a40"))
				for r in [back, seat]:
					layer.draw_rect((r as Rect2).grow(2.0), ink)
					layer.draw_rect(r, Color("7a5434"))
			"birdbath":
				var foot := c + Vector2(0, px * 0.35)
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.1, -px * 0.5), Vector2(px * 0.2, px * 0.5)).grow(2.0), ink)
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.1, -px * 0.5), Vector2(px * 0.2, px * 0.5)), Color("8a8a84"))
				var bowl := Rect2(foot + Vector2(-px * 0.4, -px * 0.72), Vector2(px * 0.8, px * 0.24))
				layer.draw_rect(bowl.grow(2.0), ink)
				layer.draw_rect(bowl, Color("b8733a"))
				layer.draw_rect(bowl.grow(-3.0), Color("9a9a94") if winter else Color("5a7a9a"))
			"weathervane":
				var base := c + Vector2(0, px * 0.4)
				layer.draw_line(base, base + Vector2(0, -px * 2.0), ink, 6.0)
				layer.draw_line(base, base + Vector2(0, -px * 2.0), Color("3a3a40"), 3.0)
				var top := base + Vector2(0, -px * 2.0)
				layer.draw_line(top + Vector2(-px * 0.35, px * 0.3), top + Vector2(px * 0.35, px * 0.3), ink, 3.0)
				var bird := PackedVector2Array([top + Vector2(-px * 0.4, 0), top + Vector2(px * 0.1, -px * 0.25), top + Vector2(px * 0.4, -px * 0.1), top + Vector2(px * 0.15, px * 0.1)])
				layer.draw_colored_polygon(bird, Color("b8733a"))
				layer.draw_polyline(bird + PackedVector2Array([bird[0]]), ink, 2.0)
			"torch":
				var foot := c + Vector2(0, px * 0.35)
				layer.draw_line(foot, foot + Vector2(0, -px * 0.9), ink, 6.0)
				layer.draw_line(foot, foot + Vector2(0, -px * 0.9), Color("6b4a30"), 3.0)
				var tip := foot + Vector2(0, -px * 1.0)
				layer.draw_circle(tip, 7.0, ink)
				layer.draw_circle(tip, 5.5, Color(1.9, 1.1, 0.4))
				layer.draw_circle(tip + Vector2(0, -3), 3.0, Color(2.0, 1.7, 0.9))
			"snare":
				var peg := c + Vector2(px * 0.2, px * 0.2)
				layer.draw_line(peg, peg + Vector2(-px * 0.3, -px * 0.55), ink, 5.0)
				layer.draw_line(peg, peg + Vector2(-px * 0.3, -px * 0.55), Color("7a5a38"), 2.0)
				layer.draw_arc(c + Vector2(-px * 0.12, px * 0.05), px * 0.2, 0.0, TAU, 12, Color("c8b080"), 2.0)
				if snared.has(t):
					var catch_col := Color("8a7058") if snared[t] == "hare" else Color("1d1d22")
					layer.draw_circle(c + Vector2(-px * 0.12, px * 0.05), px * 0.17, ink)
					layer.draw_circle(c + Vector2(-px * 0.12, px * 0.05), px * 0.13, catch_col)
			"scarecrow":
				var foot := c + Vector2(0, px * 0.4)
				layer.draw_line(foot, foot + Vector2(0, -px * 1.6), ink, 7.0)
				layer.draw_line(foot, foot + Vector2(0, -px * 1.6), Color("6b4a30"), 4.0)
				layer.draw_line(foot + Vector2(-px * 0.5, -px * 1.15), foot + Vector2(px * 0.5, -px * 1.15), ink, 7.0)
				layer.draw_line(foot + Vector2(-px * 0.5, -px * 1.15), foot + Vector2(px * 0.5, -px * 1.15), Color("6b4a30"), 4.0)
				var coat := Rect2(foot + Vector2(-px * 0.28, -px * 1.25), Vector2(px * 0.56, px * 0.6))
				layer.draw_rect(coat.grow(2.0), ink)
				layer.draw_rect(coat, Color("5a4a6a"))
				layer.draw_circle(foot + Vector2(0, -px * 1.5), px * 0.2, ink)
				layer.draw_circle(foot + Vector2(0, -px * 1.5), px * 0.16, Color("c8a868"))
				layer.draw_rect(Rect2(foot + Vector2(-px * 0.3, -px * 1.72), Vector2(px * 0.6, px * 0.1)), Color("8a6a38"))
			"shutters":
				# A pair of plank shutters on the wall; barred tonight, a dark bar across them.
				for side in [-1.0, 1.0]:
					var leaf := Rect2(c + Vector2(px * 0.02 * side - (px * 0.34 if side < 0 else 0.0), -px * 0.4), Vector2(px * 0.32, px * 0.7))
					layer.draw_rect(leaf.grow(2.0), ink)
					layer.draw_rect(leaf, Color("4a6a4a"))
					layer.draw_line(leaf.position + Vector2(leaf.size.x * 0.5, 2), leaf.position + Vector2(leaf.size.x * 0.5, leaf.size.y - 2), Color("3a5a3a"), 2.0)
				if _shutters_barred():
					layer.draw_rect(Rect2(c + Vector2(-px * 0.42, -px * 0.1), Vector2(px * 0.84, px * 0.12)), Color("3a2a1c"))
			"bell":
				# A tall post with a crossbar and an iron bell hanging under it.
				var base := c + Vector2(0, px * 0.4)
				layer.draw_rect(Rect2(base + Vector2(-px * 0.3, -px * 0.15), Vector2(px * 0.6, px * 0.15)).grow(2.0), ink)
				layer.draw_rect(Rect2(base + Vector2(-px * 0.3, -px * 0.15), Vector2(px * 0.6, px * 0.15)), Color("7a7a7a"))
				layer.draw_line(base, base + Vector2(0, -px * 2.6), ink, 10.0)
				layer.draw_line(base, base + Vector2(0, -px * 2.6), Color("5a3f2c"), 7.0)
				layer.draw_line(base + Vector2(-px * 0.5, -px * 2.4), base + Vector2(px * 0.5, -px * 2.4), ink, 8.0)
				layer.draw_line(base + Vector2(-px * 0.5, -px * 2.4), base + Vector2(px * 0.5, -px * 2.4), Color("5a3f2c"), 5.0)
				var b := base + Vector2(px * 0.3, -px * 2.35)
				var bell := PackedVector2Array([b + Vector2(-4, 0), b + Vector2(4, 0), b + Vector2(9, px * 0.45), b + Vector2(-9, px * 0.45)])
				layer.draw_colored_polygon(bell, Color("4a4a50"))
				layer.draw_polyline(bell + PackedVector2Array([bell[0]]), ink, 2.0)
				layer.draw_circle(b + Vector2(0, px * 0.5), 3.0, Color("2a2a30"))
	# Torn fence rails: a dark gap with a splintered end, over the fence.
	for t in broken:
		var c := m._tile_center(t.x, t.y)
		layer.draw_rect(Rect2(c + Vector2(-px * 0.3, -px * 0.3), Vector2(px * 0.6, px * 0.5)), Color(0.12, 0.09, 0.07, 0.75))
		layer.draw_line(c + Vector2(-px * 0.45, -px * 0.15), c + Vector2(-px * 0.05, px * 0.1), ink, 5.0)
		layer.draw_line(c + Vector2(-px * 0.45, -px * 0.15), c + Vector2(-px * 0.05, px * 0.1), Color("b89a6a"), 2.0)
		layer.draw_line(c + Vector2(px * 0.1, -px * 0.25), c + Vector2(px * 0.4, px * 0.2), ink, 5.0)
		layer.draw_line(c + Vector2(px * 0.1, -px * 0.25), c + Vector2(px * 0.4, px * 0.2), Color("b89a6a"), 2.0)
