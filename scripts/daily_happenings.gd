class_name DailyHappenings
extends RefCounted

# One surprise a day on the farm. Each morning from day 2, a happening is picked by the day (never the same
# one two days running) and announced in the morning message. Most leave something in the yard to walk up
# to and press Space on: a pedlar, a glint in the grass, a fallen branch, the crows' gifts, a mushroom ring.
# Leaving the house reminds you while it waits. A happening left alone is simply gone the next morning.

var m: MainGame

const PEDLAR_LEAVES := 18.0     # the pedlar packs up at the stall's closing hour
const FRENZY_BONUS := 0.25      # extra catch chance on a fish frenzy day
const PEDLAR_SPOT := Vector2i(37, 12)   # inner tile beside the farm stand

const HAPPENINGS := [
	{"id": "pedlar", "weight": 3,
		"morning": "A pedlar with a heavy pack has stopped by the farm stand.",
		"remind": "The pedlar is still waiting by the farm stand, until six."},
	{"id": "glint", "weight": 3,
		"morning": "Something glints in the grass of the yard this morning.",
		"remind": "Something still glints in the grass of the yard."},
	{"id": "branch", "weight": 2,
		"morning": "A big branch came down across the path in the night.",
		"remind": "The fallen branch still lies across the path."},
	{"id": "crow_gifts", "weight": 2,
		"morning": "The crows were busy at dawn. Small bright things lie under the great tree.",
		"remind": "Bright things still lie under the great tree."},
	{"id": "mushrooms", "weight": 1,
		"morning": "A ring of pale mushrooms has come up at the edge of the wood overnight.",
		"remind": "The mushroom ring is still at the edge of the wood."},
	{"id": "frenzy", "weight": 2,
		"morning": "The pond is boiling with fish this morning. Catches come easier all day."},
	{"id": "neighbour", "weight": 2,
		"morning": ""},
	# The crow bell's parts: storm oak for its frame in spring, wild flax for its rope in summer.
	{"id": "storm_oak", "weight": 3, "season": "Spring",
		"morning": "Lightning split an oak at the edge of the wood in the night. Its heartwood lies open.",
		"remind": "The storm-split oak still lies at the edge of the wood."},
	{"id": "flax", "weight": 3, "season": "Summer",
		"morning": "Wild flax is in blue flower at the edge of the wood.",
		"remind": "The wild flax is still in flower at the edge of the wood."},
]
const PEDLAR_GOODS := [
	{"name": "a crow charm", "price": 25, "item": "crow_charm", "amount": 1},
	{"name": "three pumpkin seeds", "price": 18, "item": "pumpkin_seeds", "amount": 3},
	{"name": "a sudoku book", "price": 6, "book": true},
	{"name": "three crow feathers", "price": 12, "material": "feathers", "amount": 3},
	{"name": "five turnip seeds", "price": 8, "item": "seeds", "amount": 5},
]
const NEIGHBOUR_GIFTS := [
	{"text": "Old Maren from down the lane stops by with two eggs. \"Agnes Rook kept hens here, before,\" she says. \"Don't stay out after dark.\"", "item": "eggs", "amount": 2},
	{"text": "A neighbour's boy runs up with a jar of turnip hash from his mother, then runs off without a word.", "item": "turnip_hash", "amount": 1},
	{"text": "The postman lingers to say the crows have never liked this farm, not since the Rooks. He leaves 5 coins owed for an old delivery.", "coins": 5},
	{"text": "A neighbour drops off a bundle of kindling. \"Your fire was out last winter,\" she says, \"before you came.\"", "item": "firewood", "amount": 3},
]

var today: Dictionary = {}      # today's happening, or empty
var tile := Vector2i(-1, -1)    # where it is, for the ones in the yard
var done_day := 0               # saved: the day today's was dealt with
var layer: Node2D
var _rng := RandomNumberGenerator.new()
var _picks: Array[int] = []     # the happening for each day from day 2


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	layer = Node2D.new()
	layer.draw.connect(_draw)
	m.add_child(layer)


func _raw_pick(day: int) -> int:
	_rng.seed = hash([day, "happening"])
	var weights := PackedFloat32Array()
	for h in HAPPENINGS:
		weights.append(float(h["weight"]) if _in_season(h, day) else 0.0)
	return _rng.rand_weighted(weights)


# A happening with a season only comes in that season.
func _in_season(h: Dictionary, day: int) -> bool:
	return not h.has("season") or m._season_of(m._calendar_date(day)["month"]) == str(h["season"])


# The day's happening: its own roll, moved on by one when it would repeat yesterday's. Each day depends on
# the one before, so the picks are worked out forward from day 2 and kept.
func _pick(day: int) -> Dictionary:
	if day < 2:
		return {}
	while _picks.size() < day - 1:
		var d := _picks.size() + 2
		var i := _raw_pick(d)
		if not _picks.is_empty() and i == _picks[-1]:
			i = (i + 1) % HAPPENINGS.size()
			while not _in_season(HAPPENINGS[i], d):
				i = (i + 1) % HAPPENINGS.size()
		_picks.append(i)
	return HAPPENINGS[_picks[day - 2]]


func _pending() -> bool:
	return not today.is_empty() and done_day != m.day and today["id"] in ["pedlar", "glint", "branch", "crow_gifts", "mushrooms", "storm_oak", "flax"] \
		and not (today["id"] == "pedlar" and m.current_hour >= PEDLAR_LEAVES)


# Sets up today's happening. morning is true when a new day has just begun, so it is announced and a
# neighbour's gift is handed over; on loading a save it is only put back in place.
func _start_day(morning: bool) -> String:
	today = _pick(m.day)
	tile = Vector2i(-1, -1)
	if today.is_empty():
		_redraw()
		return ""
	_rng.seed = hash([m.day, "happening_place"])
	match str(today["id"]):
		"pedlar":
			tile = m._world_tile(PEDLAR_SPOT.x, PEDLAR_SPOT.y)
		"glint":
			tile = _random_tile(func(t: Vector2i) -> bool: return _open_grass(t))
		"branch":
			tile = _random_tile(func(t: Vector2i) -> bool: return m.map[t.y][t.x] == MainGame.Tile.PATH and not m.crops.has(t))
		"crow_gifts":
			var base := m._big_tree_origin()
			tile = base + Vector2i(1, 3)
		"mushrooms", "storm_oak", "flax":
			tile = _random_tile(func(t: Vector2i) -> bool: return _open_grass(t) and _beside_tree(t))
	_redraw()
	if not morning:
		return ""
	var note := " " + str(today["morning"])
	if today["id"] == "pedlar":
		note += " They're selling %s for %d coins." % [_goods()["name"], int(_goods()["price"])]
	if today["id"] == "neighbour":
		note = " " + _neighbour_gift()
		done_day = m.day
	return note


func _open_grass(t: Vector2i) -> bool:
	return m.map[t.y][t.x] == MainGame.Tile.GRASS and not m.brush.has(t) and not m.rocks.has(t) and not m.crops.has(t) and not m.projects.decor.has(t)


func _beside_tree(t: Vector2i) -> bool:
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var n: Vector2i = t + d
		if m._in_bounds(n) and m.map[n.y][n.x] == MainGame.Tile.TREE:
			return true
	return false


# A tile in the farm's inner area that passes the test, or none.
func _random_tile(test: Callable) -> Vector2i:
	var options: Array = []
	for y in range(m.BORDER_Y + 1, m.BORDER_Y + m.INNER_H - 1):
		for x in range(m.BORDER_X + 1, m.BORDER_X + m.INNER_W - 1):
			if test.call(Vector2i(x, y)):
				options.append(Vector2i(x, y))
	if options.is_empty():
		return Vector2i(-1, -1)
	return options[_rng.randi_range(0, options.size() - 1)]


func _goods() -> Dictionary:
	return PEDLAR_GOODS[hash([m.day, "goods"]) % PEDLAR_GOODS.size()]


func _neighbour_gift() -> String:
	var g: Dictionary = NEIGHBOUR_GIFTS[hash([m.day, "gift"]) % NEIGHBOUR_GIFTS.size()]
	if g.has("coins"):
		m.money += int(g["coins"])
	else:
		m.inventory[g["item"]] += int(g["amount"])
	return str(g["text"])


# Each frame: the yard's thing shows only on the farm, and the pedlar closes up at six.
func _update() -> void:
	if layer != null:
		layer.visible = not m.inside and not m.in_cave and m.zone == MainGame.Zone.HOMESTEAD
	if not today.is_empty() and today["id"] == "pedlar" and done_day != m.day and m.current_hour >= PEDLAR_LEAVES and tile.x >= 0:
		tile = Vector2i(-1, -1)
		_redraw()


# Leaving the house reminds you of anything still waiting in the yard.
func _on_leave_house() -> void:
	# Only by day, so it never talks over the night's visitor.
	if _pending() and m.zone == MainGame.Zone.HOMESTEAD and m.current_hour < m.DUSK_HOUR:
		m._show_message(str(today["remind"]))


func _fish_bonus() -> float:
	return FRENZY_BONUS if not today.is_empty() and today["id"] == "frenzy" else 0.0


# Space on the farm, after the night's visitor. Returns true when the press was used.
func _try_take(t: Vector2i) -> bool:
	if not _pending():
		return false
	var hit := t == tile
	if today["id"] == "crow_gifts":
		hit = m._in_big_tree(t) or t == tile
	if not hit:
		return false
	var text := ""
	_rng.seed = hash([m.day, "happening_take"])
	match str(today["id"]):
		"pedlar":
			var g := _goods()
			if m.money < int(g["price"]):
				m._show_message("The pedlar wants %d coins for %s. You have %d." % [int(g["price"]), g["name"], m.money])
				return true
			m.money -= int(g["price"])
			if g.has("item"):
				m.inventory[g["item"]] += int(g["amount"])
			elif g.has("material"):
				m.materials[g["material"]] += int(g["amount"])
			elif g.has("book"):
				m.sudoku_puzzles += m.SUDOKU_BOOK_PUZZLES
			m.play_sfx("coin", 0.05)
			text = "You buy %s for %d coins. The pedlar tips their hat and heads up the road." % [g["name"], int(g["price"])]
		"glint":
			text = _glint_find()
		"branch":
			m.materials["wood"] += 3
			m.materials["hardwood"] += 1
			m.progression._grant_xp("Forestry", m.XP_GATHER)
			m.play_sfx("chop", 0.05)
			text = "You drag the branch off the path and break it up. +3 wood, +1 hardwood, +%d Forestry XP." % m.XP_GATHER
		"crow_gifts":
			var coins := _rng.randi_range(5, 15)
			m.money += coins
			m.materials["feathers"] += 1
			m.play_sfx("coin", 0.05)
			m.mystery._on_crow_gifts()
			text = "Under the tree: buttons, a bent spoon, a ring of keys to nothing, and %d coins. A feather, too. +1 crow feather." % coins
		"storm_oak":
			if int(m.tool_tier["hatchet"]) < 1:
				m._show_message("The heartwood is too tough to pull free. It needs a hatchet.")
				return true
			m.materials["storm_oak"] += 1
			m.materials["wood"] += 2
			m.progression._grant_xp("Forestry", m.XP_FELL)
			m.play_sfx("chop", 0.05)
			text = "You cut the heartwood out of the split oak. It is still warm. +1 storm oak, +2 wood, +%d Forestry XP." % m.XP_FELL
		"flax":
			m.materials["flax"] += 3
			m.progression._grant_xp("Bushcrafting", m.XP_GATHER)
			m.play_sfx("gather", 0.05)
			text = "You pull the longest stems and leave the rest to seed. +3 wild flax, +%d Bushcrafting XP." % m.XP_GATHER
		"mushrooms":
			m.play_sfx("eat", 0.05)
			if _rng.randf() < 0.67:
				m.food = minf(100.0, m.food + 20.0)
				m.sanity_sys._change_sanity(5.0)
				text = "You eat the mushrooms. Earthy and good. +20 food, +5 sanity."
			else:
				m.sanity_sys._change_sanity(-10.0)
				m.materials["feathers"] += 1
				text = "You eat the mushrooms. The trees lean in and whisper your name for an hour. -10 sanity. A feather is in your hand when it passes."
	done_day = m.day
	_redraw()
	m._show_message(text)
	return true


func _glint_find() -> String:
	var roll := _rng.randi_range(0, 3)
	match roll:
		0:
			var coins := _rng.randi_range(10, 25)
			m.money += coins
			m.play_sfx("coin", 0.05)
			return "A rotten leather purse. Inside, %d coins." % coins
		1:
			m.materials["feathers"] += 3
			return "Three crow feathers, tied together with red thread. +3 crow feathers."
		2:
			m.inventory["seeds"] += 4
			m.inventory["corn_seeds"] += 2
			return "A rusted seed tin, still sealed. +4 turnip seeds, +2 corn seeds."
	m.sanity_sys._change_sanity(-5.0)
	m.money += 15
	return "A child's tin soldier, still warm, as if someone had just put it down. You don't like holding it. Its paint is real silver, though. -5 sanity, +15 coins."


func _redraw() -> void:
	if layer != null:
		layer.queue_redraw()


# Today's thing in the yard, while it waits.
func _draw() -> void:
	if not _pending() or tile.x < 0:
		return
	var c := m._tile_center(tile.x, tile.y)
	var px := float(m.PX)
	var ink := Color("1d1611")
	match str(today["id"]):
		"pedlar":
			# A traveller the farmer's height: wide hat, plum coat, a staff, and a pack bigger than they are.
			var f := c + Vector2(0, px * 0.42)
			_box(Rect2(f + Vector2(-px * 0.46, -px * 1.3), Vector2(px * 0.42, px * 0.8)), Color("a08458"))
			_box(Rect2(f + Vector2(-px * 0.18, -px * 0.3), Vector2(px * 0.13, px * 0.3)), Color("3a2c22"))
			_box(Rect2(f + Vector2(px * 0.05, -px * 0.3), Vector2(px * 0.13, px * 0.3)), Color("3a2c22"))
			_box(Rect2(f + Vector2(-px * 0.26, -px * 1.05), Vector2(px * 0.52, px * 0.8)), Color("6a4a7a"))
			layer.draw_circle(f + Vector2(0, -px * 1.2), px * 0.2, ink)
			layer.draw_circle(f + Vector2(0, -px * 1.2), px * 0.17, Color("e0c0a0"))
			_box(Rect2(f + Vector2(-px * 0.38, -px * 1.4), Vector2(px * 0.76, px * 0.08)), Color("4a3828"))
			_box(Rect2(f + Vector2(-px * 0.2, -px * 1.62), Vector2(px * 0.4, px * 0.24)), Color("4a3828"))
			layer.draw_line(f + Vector2(px * 0.36, -px * 1.5), f + Vector2(px * 0.36, 0), ink, 5.0)
			layer.draw_line(f + Vector2(px * 0.36, -px * 1.5), f + Vector2(px * 0.36, 0), Color("b08a5a"), 3.0)
		"glint", "crow_gifts":
			var gold := Color(1.0, 0.92, 0.55)
			for k in (3 if today["id"] == "crow_gifts" else 1):
				var p := c + Vector2((k - 1) * px * 0.3, (k % 2) * px * 0.15)
				var r := px * 0.22
				layer.draw_line(p + Vector2(-r, 0), p + Vector2(r, 0), gold, 2.0)
				layer.draw_line(p + Vector2(0, -r), p + Vector2(0, r), gold, 2.0)
				layer.draw_circle(p, 2.5, Color.WHITE)
		"branch":
			# A long limb across the path, with forks and a few dead leaves still on it.
			var bark := Color("9a7048")
			var limbs := [[Vector2(-0.75, 0.25), Vector2(0.75, -0.15), 10.0], [Vector2(-0.15, 0.1), Vector2(-0.4, -0.35), 6.0],
				[Vector2(0.3, -0.03), Vector2(0.55, 0.3), 6.0], [Vector2(0.45, -0.08), Vector2(0.7, -0.4), 4.0]]
			for l in limbs:
				layer.draw_line(c + l[0] * px, c + l[1] * px, ink, float(l[2]) + 3.0)
			for l in limbs:
				layer.draw_line(c + l[0] * px, c + l[1] * px, bark, float(l[2]))
			for p in [Vector2(-0.4, -0.35), Vector2(0.7, -0.4), Vector2(0.55, 0.3)]:
				layer.draw_circle(c + p * px, px * 0.11, ink)
				layer.draw_circle(c + p * px, px * 0.08, Color("c07a3a"))
		"storm_oak":
			# A fallen trunk, split along its length, pale heartwood showing and a scorch at the break.
			var bark := Color("4a3426")
			_box(Rect2(c + Vector2(-px * 0.8, -px * 0.2), Vector2(px * 1.6, px * 0.4)), bark)
			layer.draw_line(c + Vector2(-px * 0.7, 0), c + Vector2(px * 0.6, -px * 0.02), Color("d8c08a"), 4.0)
			layer.draw_circle(c + Vector2(px * 0.72, 0), px * 0.16, Color("1d1611"))
			layer.draw_circle(c + Vector2(px * 0.72, 0), px * 0.1, Color("2a2420"))
		"flax":
			# A clump of thin green stems with small blue flowers.
			for k in 6:
				var p := c + Vector2((float(k) - 2.5) * px * 0.14, px * 0.3)
				var top := p + Vector2(sin(float(k)) * px * 0.08, -px * (0.5 + 0.08 * float(k % 3)))
				layer.draw_line(p, top, Color("1d1611"), 3.0)
				layer.draw_line(p, top, Color("6a9a4a"), 1.5)
				layer.draw_circle(top, 3.5, Color("1d1611"))
				layer.draw_circle(top, 2.5, Color("7a9ad8"))
		"mushrooms":
			for k in 7:
				var a := TAU * float(k) / 7.0
				var p := c + Vector2(cos(a) * px * 0.32, sin(a) * px * 0.2)
				layer.draw_rect(Rect2(p + Vector2(-1.5, -2), Vector2(3, 5)), Color("d8d0c0"))
				layer.draw_circle(p + Vector2(0, -3), 4.0, ink)
				layer.draw_circle(p + Vector2(0, -3), 3.0, Color("e8e0d0"))


# A filled rectangle with a dark outline, like the icons.
func _box(r: Rect2, col: Color) -> void:
	layer.draw_rect(r.grow(2.0), Color("1d1611"))
	layer.draw_rect(r, col)
