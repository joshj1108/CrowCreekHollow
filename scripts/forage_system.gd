class_name ForageSystem
extends RefCounted

# Wild food at the edges of things: each morning a few forageables come up on open grass beside the farm's
# trees, and each trek clearing has one or two beside the trail. Face one and press Space to pick it, for
# Bushcrafting XP. What grows depends on the season and on Bushcrafting. The foods themselves (name, price,
# what they restore) are in Foods.LIST under the same id.

# seasons: when it can come up. level: the Bushcrafting level that knows to look for it. weight: how common.
const FORAGE := [
	{"id": "nettles", "seasons": ["Spring"], "level": 1, "weight": 30},
	{"id": "fiddleheads", "seasons": ["Spring"], "level": 1, "weight": 24},
	{"id": "salmonberries", "seasons": ["Spring", "Summer"], "level": 1, "weight": 24},
	{"id": "blackberries", "seasons": ["Summer", "Autumn"], "level": 1, "weight": 30},
	{"id": "rosehips", "seasons": ["Autumn", "Winter"], "level": 1, "weight": 30},
	{"id": "chanterelles", "seasons": ["Autumn"], "level": 2, "weight": 20},
	{"id": "yellowfoot", "seasons": ["Winter"], "level": 2, "weight": 22},
	{"id": "huckleberries", "seasons": ["Summer"], "level": 3, "weight": 18},
	{"id": "oyster_mushrooms", "seasons": ["Winter", "Spring"], "level": 3, "weight": 16},
	{"id": "morels", "seasons": ["Spring"], "level": 4, "weight": 8},
	{"id": "ghost_pipe", "seasons": ["Summer", "Autumn"], "level": 5, "weight": 5},
]
const PER_MORNING := 2            # on the farm each morning, plus one per three Bushcrafting levels
const MAX_PER_MORNING := 5
const PER_CLEARING := 2           # on each trek clearing
const XP_BASE := 8                # Bushcrafting XP a pick, plus XP_PER_LEVEL for each level the find needs
const XP_PER_LEVEL := 3

var m: MainGame
var layer: Node2D
var spots := {}        # farm world tile -> forage id, for today
var spots_day := -1    # the day the spots were laid
var trek_spots := {}   # trek clearing tile -> forage id
var _rng := RandomNumberGenerator.new()


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	layer = Node2D.new()
	layer.draw.connect(_draw)
	m.add_child(layer)
	if spots_day != m.day:
		_new_day()


var _was_in_cave := false


func _update() -> void:
	if layer == null:
		return
	var show := (not m.inside and not m.in_cave) or m.trek.active
	if layer.visible != show or _was_in_cave != m.in_cave:
		layer.visible = show
		_was_in_cave = m.in_cave
		layer.queue_redraw()


# What can come up today, by weight.
func _pool() -> Array:
	var season := m._season_today()
	var level := m.progression._level("Bushcrafting")
	return FORAGE.filter(func(f) -> bool: return (f["seasons"] as Array).has(season) and level >= int(f["level"]))


func _roll(pool: Array) -> String:
	var total := 0
	for f in pool:
		total += int(f["weight"])
	var roll := _rng.randi_range(0, total - 1)
	for f in pool:
		roll -= int(f["weight"])
		if roll < 0:
			return str(f["id"])
	return str(pool[0]["id"])


# Lays the day's forage on open grass beside the farm's trees. Yesterday's that wasn't picked has gone over.
func _new_day() -> void:
	spots.clear()
	spots_day = m.day
	_rng.seed = hash(m.day * 7919 + 13)
	var pool := _pool()
	if pool.is_empty():
		_redraw()
		return
	var options: Array = []
	for y in range(m.BORDER_Y + 1, m.BORDER_Y + m.INNER_H - 1):
		for x in range(m.BORDER_X + 1, m.BORDER_X + m.INNER_W - 1):
			var t := Vector2i(x, y)
			if m.happenings._open_grass(t) and m.happenings._beside_tree(t) and not m.fish_spots.has(t):
				options.append(t)
	var n := mini(MAX_PER_MORNING, PER_MORNING + m.progression._level("Bushcrafting") / 3)
	for i in n:
		if options.is_empty():
			break
		var t: Vector2i = options[_rng.randi_range(0, options.size() - 1)]
		options.erase(t)
		spots[t] = _roll(pool)
	_redraw()


# One or two finds beside the trail in a trek clearing. Called once the clearing is laid out in the cave grid.
func _lay_trek() -> void:
	trek_spots.clear()
	var pool := _pool()
	if pool.is_empty():
		return
	_rng.randomize()
	var T := MainGame.Tile
	var options: Array = []
	for y in range(1, m.CAVE_H - 1):
		for x in range(1, m.CAVE_W - 1):
			if m.cave[y][x] != T.GRASS:
				continue
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if m.cave[y + d.y][x + d.x] == T.TREE:
					options.append(Vector2i(x, y))
					break
	for i in PER_CLEARING:
		if options.is_empty():
			break
		var t: Vector2i = options[_rng.randi_range(0, options.size() - 1)]
		options.erase(t)
		trek_spots[t] = _roll(pool)
	_redraw()


# Picks the forage on the tile in front, on the farm. False when there is none there.
func _try_pick(t: Vector2i) -> bool:
	if not spots.has(t):
		return false
	if _pick(str(spots[t])):
		spots.erase(t)
		_redraw()
	return true


func _try_pick_trek(t: Vector2i) -> bool:
	if not trek_spots.has(t):
		return false
	if _pick(str(trek_spots[t])):
		trek_spots.erase(t)
		_redraw()
	return true


func _pick(id: String) -> bool:
	var f := Foods.find(id)
	var key := str(f["held"])
	if not m.stall._pack_room(int(m.inventory[key]), 1):
		m._show_message("Your pack is full. There's no room for the %s." % str(f["name"]).to_lower())
		return false
	m.inventory[key] += 1
	m.stats["foraged"] += 1
	var xp := XP_BASE + XP_PER_LEVEL * int(_spec(id)["level"])
	m.progression._grant_xp("Bushcrafting", xp)
	m.play_sfx("gather", 0.06)
	m._show_message("You pick %s. +%d Bushcrafting XP" % [str(f["name"]).to_lower(), xp])
	return true


func _spec(id: String) -> Dictionary:
	for f in FORAGE:
		if f["id"] == id:
			return f
	return {}


func _to_save() -> Array:
	var out: Array = []
	for t in spots:
		out.append([t.x, t.y, spots[t]])
	return out


func _from_save(arr: Variant, day: int) -> void:
	spots.clear()
	spots_day = day
	if typeof(arr) != TYPE_ARRAY:
		spots_day = -1
		return
	for e in arr:
		if typeof(e) == TYPE_ARRAY and e.size() == 3 and not _spec(str(e[2])).is_empty():
			spots[Vector2i(int(e[0]), int(e[1]))] = str(e[2])


func _redraw() -> void:
	if layer != null:
		layer.queue_redraw()


func _draw() -> void:
	var list: Dictionary = trek_spots if m.in_cave else spots
	if m.in_cave and not m.trek.active:
		return
	for t in list:
		_draw_one(m._tile_center(t.x, t.y), str(list[t]))


# A small plant, mushroom cluster or berry cane, in the find's own colour, low on the tile.
func _draw_one(c: Vector2, id: String) -> void:
	var f := Foods.find(id)
	var tint := Color(str(f["tint"]))
	var ink := Color("1d1611")
	var px := float(m.PX)
	var base := c + Vector2(0, px * 0.28)
	match str(f["icon"]):
		"mushroom":
			for k in 3:
				var p := base + Vector2((float(k) - 1.0) * px * 0.2, -float(k % 2) * px * 0.08)
				layer.draw_rect(Rect2(p + Vector2(-1.5, -px * 0.16), Vector2(3, px * 0.16)), Color("e8dcc0"))
				layer.draw_circle(p + Vector2(0, -px * 0.17), px * 0.1, ink)
				layer.draw_circle(p + Vector2(0, -px * 0.18), px * 0.08, tint)
		"berry", "hip":
			for k in 4:
				var a := -2.2 + float(k) * 0.5
				layer.draw_line(base, base + Vector2(cos(a), sin(a)) * px * 0.42, Color("4a6a2a"), 2.0)
			for p in [Vector2(-0.18, -0.26), Vector2(0.1, -0.34), Vector2(0.22, -0.18), Vector2(-0.04, -0.14)]:
				layer.draw_circle(base + p * px, px * 0.07, ink)
				layer.draw_circle(base + p * px, px * 0.055, tint)
		"fern":
			for k in 3:
				var p := base + Vector2((float(k) - 1.0) * px * 0.18, 0)
				layer.draw_line(p, p + Vector2(0, -px * 0.3), tint.darkened(0.2), 2.0)
				layer.draw_arc(p + Vector2(px * 0.05, -px * 0.32), px * 0.06, PI * 0.5, PI * 2.2, 8, tint, 2.0)
		"pipe":
			for k in 3:
				var p := base + Vector2((float(k) - 1.0) * px * 0.14, 0)
				layer.draw_line(p, p + Vector2(0, -px * 0.36), ink, 4.0)
				layer.draw_line(p, p + Vector2(0, -px * 0.36), tint, 2.0)
				layer.draw_circle(p + Vector2(px * 0.04, -px * 0.38), px * 0.06, tint)
		_:
			# Leafy greens: a low rosette of pointed leaves.
			for k in 5:
				var a := -PI * 0.5 + (float(k) - 2.0) * 0.55
				var tip := base + Vector2(cos(a), sin(a)) * px * 0.34
				layer.draw_line(base, tip, ink, 5.0)
				layer.draw_line(base, tip, tint, 3.0)
