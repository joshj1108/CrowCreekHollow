class_name FarmProjects
extends RefCounted

# The farm's long-term goals and the things you place to make it yours.
# - Progress: a ladder of homestead steps (repairs, buildings, plots, decor, the crow bell). The Buildings
#   section shows how far along you are and the next step; each step done pays a little and names the next.
# - Decor, placed like the coop from the Buildings section: lamp posts that hold back the dark, flower beds
#   that lift your spirits each morning, gravel paths, and the crow bell, the last big project, which keeps
#   the Hollow away for good.

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
const BELL_MONTH := 9           # All Hallows, October 31st: the only day the bell can be hung
const BELL_DOM := 31
const PART_XP := 40
const LAMP_RADIUS := 3.0        # tiles of light around a lamp post
const BELL_NIGHT_MULT := 0.75
const STEP_COINS := 20          # paid for each homestead step done
const REMOVE_SECONDS := 4.0     # time to press Space again to take something down

var decor := {}                 # saved: world tile -> kind
var steps_done := {}            # saved: step id -> true
var bell_day := -1              # the day the bell was hung, so the Hollow comes to it that night
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
	m._show_message("Face open grass where the %s should go and press Space. B cancels." % str(DECOR[kind]["name"]).to_lower())


func _confirm(kind: String, t: Vector2i) -> void:
	if not m._spot_ok(t, Vector2i.ONE):
		m._show_message("That spot isn't open grass.")
		return
	_pay(kind, 1)
	decor[t] = kind
	if kind == "bell":
		bell_day = m.day
	_stamp()
	m.play_sfx("repair" if kind != "path" else "hoe", 0.05)
	if kind == "path" and _can_place("path"):
		# Paths keep going, one tile at a time, until the stone runs out or B is pressed.
		m._show_message("Path laid. Face the next tile and press Space, or B to stop. %d stone left." % int(m.materials["stone"]))
		return
	m.placing = ""
	m._show_message("The %s stands here now." % str(DECOR[kind]["name"]).to_lower() if kind != "path" else "That was the last of your stone.")
	_check(true)


# Space on a placed thing: the first press asks, the second within a few seconds takes it down.
func _try_use(t: Vector2i) -> bool:
	if not decor.has(t):
		return false
	var kind: String = decor[t]
	var now := Time.get_ticks_msec() / 1000.0
	if _remove_tile != t or now > _remove_until:
		_remove_tile = t
		_remove_until = now + REMOVE_SECONDS
		m._show_message("%s. %s Press Space again to take it down." % [DECOR[kind]["name"], DECOR[kind]["desc"]])
		return true
	_remove_tile = Vector2i(-1, -1)
	decor.erase(t)
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
		if decor.get(t, "") != "lamp":
			(lights[t] as Node).queue_free()
			lights.erase(t)
	for t in decor:
		if decor[t] == "lamp" and not lights.has(t):
			var light := PointLight2D.new()
			light.texture = m._glow_texture()
			light.color = Color("ffd27a")
			light.texture_scale = LAMP_RADIUS * m.PX / 128.0
			light.position = m._tile_center(t.x, t.y) + Vector2(0, -m.PX * 1.1)
			light.enabled = false
			m.add_child(light)
			lights[t] = light
	m.queue_redraw()
	if layer != null:
		layer.queue_redraw()


func _blocks(t: Vector2i) -> bool:
	return decor.has(t) and bool(DECOR[decor[t]]["blocks"])


# True when a tile is in a lamp post's light.
func _lit(t: Vector2i) -> bool:
	for l in lights:
		if Vector2(t - (l as Vector2i)).length() <= LAMP_RADIUS:
			return true
	return false


# Each frame: lamps glow after dusk, and only out on the farm.
func _update(darkness: float) -> void:
	var on := not m.inside and not m.in_cave and darkness > 0.1
	for l in lights.values():
		(l as PointLight2D).enabled = on
		(l as PointLight2D).energy = m.WINDOW_ENERGY * (0.7 + 0.5 * darkness)
	if layer != null:
		layer.visible = not m.inside and not m.in_cave


# The morning's lift from the flower beds.
func _morning() -> String:
	return _apples() + _flowers()


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
