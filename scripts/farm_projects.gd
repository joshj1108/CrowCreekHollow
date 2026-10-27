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
	"lamp": {"name": "Lamp post", "cost": {"wood": 3, "iron_bar": 1}, "skill": "Smithing", "level": 2, "max": 8, "blocks": true,
		"desc": "Lights the ground around it at night. In its light the dark doesn't wear on your sanity."},
	"flowers": {"name": "Flower bed", "cost": {"wood": 1, "seeds": 2}, "skill": "Farming", "level": 2, "max": 6, "blocks": true,
		"desc": "Each bed gives +1 sanity every morning, except in winter."},
	"path": {"name": "Gravel path", "cost": {"stone": 1}, "skill": "", "level": 0, "max": 400, "blocks": false,
		"desc": "Turns a tile of grass into path. Keeps placing until you run out of stone or press B."},
	"bell": {"name": "Crow bell", "cost": {"hardwood": 6, "iron_bar": 4, "feathers": 20, "coins": 150}, "skill": "Carpentry", "level": 4, "max": 1, "blocks": true,
		"desc": "A tall post with an iron bell. While it stands, the field shadow can't reach the house, so the Hollow stops coming, and the night takes a quarter less from your sanity."},
}
const LAMP_RADIUS := 3.0        # tiles of light around a lamp post
const BELL_NIGHT_MULT := 0.75
const STEP_COINS := 20          # paid for each homestead step done
const REMOVE_SECONDS := 4.0     # time to press Space again to take something down

var decor := {}                 # saved: world tile -> kind
var steps_done := {}            # saved: step id -> true
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
		{"id": "boarded", "title": "Board up the house", "how": "House section: repair to Boarded.", "done": m.house_stage >= 1},
		{"id": "coop", "title": "Build the coop", "how": "Buildings section: 6 wood, 4 fiber, Carpentry 2.", "done": m.coop_built},
		{"id": "patched", "title": "Patch the house", "how": "House section: repair to Patched.", "done": m.house_stage >= 2},
		{"id": "smokehouse", "title": "Build the smokehouse", "how": "Buildings section, in the workshop.", "done": m.smokehouse_built},
		{"id": "plot_two", "title": "Open the second plot", "how": "Opens at Farming 2.", "done": m.plot_two_open},
		{"id": "furnace", "title": "Build the furnace", "how": "Buildings section, in the workshop.", "done": m.furnace_built},
		{"id": "woodshed", "title": "Build the firewood store", "how": "Buildings section, after the smokehouse or furnace.", "done": m.woodshed_built},
		{"id": "lamp", "title": "Light the yard", "how": "Place a lamp post (Buildings, Decor): 3 wood, 1 iron bar, Smithing 2.", "done": _count("lamp") >= 1},
		{"id": "barn", "title": "Build the barn", "how": "Buildings section: 10 wood, 6 fiber, Carpentry 4.", "done": m.barn_built},
		{"id": "restored", "title": "Restore the house", "how": "House section: repair to Restored.", "done": m.house_stage >= 3},
		{"id": "flowers", "title": "Plant four flower beds", "how": "Buildings, Decor: 1 wood and 2 turnip seeds each, Farming 2.", "done": _count("flowers") >= 4},
		{"id": "plot_three", "title": "Open the third plot", "how": "Opens at Farming 4 once the house is Patched.", "done": m.plot_three_open},
		{"id": "hollow_lantern", "title": "Make the Hollow Lantern", "how": "Craft section, Other tab: the lantern's third tier.", "done": m.lantern_tier >= 3},
		{"id": "bell", "title": "Hang the crow bell", "how": "Buildings, Decor: 6 hardwood, 4 iron bars, 20 crow feathers, 150 coins, Carpentry 4.", "done": _has_bell()},
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
	return _level_ok(kind) and _can_afford(kind) and _count(kind) < int(DECOR[kind]["max"])


func _cost_text(kind: String) -> String:
	var parts: Array = []
	var cost: Dictionary = DECOR[kind]["cost"]
	for key in cost:
		var label := "turnip seeds" if key == "seeds" else ("crow feathers" if key == "feathers" else str(key).replace("_", " "))
		parts.append("%d %s" % [int(cost[key]), label])
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


# The Buildings section's rows: progress, then the decor.
func _rows() -> Array:
	var rows: Array = [{"section": "Homestead"}]
	var nxt := _next_step()
	rows.append({"name": "Progress", "value": "%d of %d steps done" % [steps_done.size(), _steps().size()]})
	if nxt.is_empty():
		rows.append({"note": "Every step is done. The farm is yours."})
	else:
		rows.append({"name": "Next: %s" % nxt["title"], "value": str(nxt["how"])})
	rows.append({"section": "Decor"})
	for kind in ["lamp", "flowers", "path", "bell"]:
		var d: Dictionary = DECOR[kind]
		var have := _count(kind)
		var label := str(d["name"]) + ((" (%d placed)" % have) if have > 0 else "")
		if have >= int(d["max"]):
			rows.append({"name": label, "value": "as many as there's room for"})
			continue
		rows.append({"name": label, "value": "%s. %s" % [_cost_text(kind), d["desc"]], "button": "Place", "action": "decor:" + kind, "enabled": _can_place(kind)})
	rows.append({"note": "Face something you placed and press Space twice to take it down and get its materials back."})
	return rows


func _start_place(kind: String) -> void:
	if m.inside or m.in_cave or m._in_village():
		m._show_message("You can only place things on the farm.")
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
	var on := not m.inside and not m.in_cave and not m._in_village() and darkness > 0.1
	for l in lights.values():
		(l as PointLight2D).enabled = on
		(l as PointLight2D).energy = m.WINDOW_ENERGY * (0.7 + 0.5 * darkness)
	if layer != null:
		layer.visible = not m.inside and not m.in_cave and not m._in_village()


# The morning's lift from the flower beds.
func _morning() -> String:
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
