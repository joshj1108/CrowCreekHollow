class_name GameFeel
extends RefCounted

# Small touches that make everyday actions land:
# - Bursts: each action's sound also throws a puff of particles at the tile you work: dirt from the hoe,
#   chips and leaves from the axe, stone from the pick, droplets from the can, sparkles from a harvest.
# - Shake: felling a tree or breaking a rock jolts the camera harder than a single strike.
# - Pop-ups: what you gain floats up over the farmer: XP, coins and items, picked up from any source by
#   watching the totals, so nothing has to remember to announce itself. They stay quiet while a menu is open.

var m: MainGame

const GRAVITY := 260.0
const POP_SECONDS := 1.1
const POP_RISE := 34.0
const POP_STACK := 15.0          # pixels between pop-ups that start together
const POP_FONT := 14

# The burst for each sound: particle kinds and counts. shake is [seconds, strength].
const BURSTS := {
	"hoe": {"dirt": 9},
	"plant": {"dirt": 5},
	"water": {"drops": 8},
	"harvest": {"sparkle": 7, "leaves": 5},
	"chop": {"chips": 6, "leaves": 3},
	"tree_fall": {"leaves": 18, "chips": 8, "shake": [0.3, 4.0]},
	"pick": {"stone": 7},
	"rock_break": {"stone": 16, "shake": [0.22, 3.0]},
	"gather": {"leaves": 8},
	"splash": {"drops": 12, "sparkle": 4},
	"hit": {"spark": 7},
	"split": {"chips": 8},
	"repair": {"chips": 6},
}
const COLORS := {
	"dirt": [Color("6b4a32"), Color("8a6440"), Color("4a3424")],
	"chips": [Color("c8a070"), Color("a07a4a"), Color("e0c090")],
	"stone": [Color("8a8a8a"), Color("6a6a6a"), Color("b0aca0")],
	"drops": [Color("8fc8e8"), Color("c8e8f8"), Color("5fa0d0")],
	"sparkle": [Color("f2d27a"), Color("fff0b0"), Color("ffffff")],
	"spark": [Color("fff0c0"), Color("ffffff"), Color("f2d27a")],
}
const LEAVES := {"Spring": ["7fbf5a", "a0d070"], "Summer": ["4a8a3a", "6aa04a"], "Autumn": ["d0703a", "e0a040", "b04a2a"], "Winter": ["8a7a5a", "6a5a4a"]}
const ITEM_NAMES := {"crops": "Turnip", "seeds": "Turnip seed", "corn_seeds": "Corn seed", "pumpkin_seeds": "Pumpkin seed",
	"pumpkins": "Pumpkin", "eggs": "Egg", "crow_charm": "Crow charm"}

var layer: Node2D               # the particles, in the world under the day's light
var pop_layer: Node2D           # the pop-ups, on their own canvas so the night tint doesn't dim them
var parts: Array = []            # {pos, vel, life, max, color, size, kind}
var pops: Array = []             # {pos, text, color, age}
var _seen := {}                  # last totals of money, the pack and materials
var _watching := false


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	layer = Node2D.new()
	layer.z_index = 30
	layer.draw.connect(_draw)
	m.add_child(layer)
	var canvas := CanvasLayer.new()
	canvas.follow_viewport_enabled = true
	m.add_child(canvas)
	pop_layer = Node2D.new()
	pop_layer.draw.connect(_draw_pops)
	canvas.add_child(pop_layer)


# From play_sfx: the sound's burst, at the tile being worked.
func _on_sound(sound: String) -> void:
	if not BURSTS.has(sound) or layer == null or not m.world_started:
		return
	var at := _work_point(sound)
	var b: Dictionary = BURSTS[sound]
	for kind in b:
		if kind == "shake":
			m._shake_camera(float(b[kind][0]), float(b[kind][1]))
		else:
			_burst(at, str(kind), int(b[kind]))


func _work_point(sound: String) -> Vector2:
	if sound == "splash" and m.fishing_tile != m.NO_SPOT:
		return m._tile_center(m.fishing_tile.x, m.fishing_tile.y)
	var t: Vector2i = m._tile_in_front()
	return m._tile_center(t.x, t.y) + Vector2(0, m.PX * 0.15)


func _burst(at: Vector2, kind: String, count: int) -> void:
	var palette: Array = COLORS.get(kind, [])
	if kind == "leaves":
		palette = []
		for h in LEAVES.get(m._season_of(m._calendar_date(m.day)["month"]), ["6aa04a"]):
			palette.append(Color(h))
	for i in count:
		var a := randf_range(-PI, 0.0)          # mostly upward
		var speed := randf_range(50.0, 120.0)
		var p := {"pos": at + Vector2(randf_range(-8, 8), randf_range(-6, 4)), "vel": Vector2(cos(a), sin(a)) * speed,
			"life": 0.0, "max": randf_range(0.45, 0.8), "color": palette[randi() % palette.size()], "size": [3.0, 3.0, 6.0].pick_random(), "kind": kind}
		match kind:
			"leaves":
				p["vel"] = Vector2(randf_range(-50, 50), randf_range(-90, -30))
				p["max"] = randf_range(0.9, 1.4)
			"sparkle", "spark":
				var r := randf_range(0.0, TAU)
				p["vel"] = Vector2(cos(r), sin(r)) * randf_range(40.0, 100.0 if kind == "spark" else 60.0)
				p["max"] = randf_range(0.35, 0.6)
		parts.append(p)


# A line of text rising over the farmer.
func pop(text: String, color: Color) -> void:
	var stacked := 0
	for p in pops:
		if float(p["age"]) < 0.3:
			stacked += 1
	pops.append({"pos": m.player.position + Vector2(0, -m.PX * 1.3 - stacked * POP_STACK), "text": text, "color": color, "age": 0.0})


# From _grant_xp.
func _xp(skill: String, amount: int) -> void:
	if amount > 0 and _quiet() == false:
		pop("+%d %s XP" % [amount, skill], Color("d8b050"))


func _quiet() -> bool:
	return not m.world_started or m.open_tab != "" or m._bag_open() or m.transitioning


# Each frame: move the particles and pop-ups, and pop up whatever was gained since the last frame.
func _update(delta: float) -> void:
	_watch_totals()
	if parts.is_empty() and pops.is_empty():
		return
	for p in parts:
		p["life"] += delta
		var g := GRAVITY * (0.25 if p["kind"] == "leaves" else (0.0 if p["kind"] in ["sparkle", "spark"] else 1.0))
		var vel: Vector2 = p["vel"] + Vector2(0, g * delta)
		if p["kind"] == "leaves":
			vel.x += sin(float(p["life"]) * 8.0) * 120.0 * delta   # leaves see-saw as they fall
		p["vel"] = vel
		p["pos"] += vel * delta
	parts = parts.filter(func(p: Dictionary) -> bool: return float(p["life"]) < float(p["max"]))
	for p in pops:
		p["age"] += delta
	pops = pops.filter(func(p: Dictionary) -> bool: return float(p["age"]) < POP_SECONDS)
	layer.queue_redraw()
	pop_layer.queue_redraw()


func _watch_totals() -> void:
	var now := {"coins": m.money}
	for k in m.inventory:
		now["i:" + k] = int(m.inventory[k])
	for k in m.materials:
		now["m:" + k] = int(m.materials[k])
	if _watching and not _quiet():
		for k in now:
			var gained := int(now[k]) - int(_seen.get(k, now[k]))
			if gained <= 0:
				continue
			if k == "coins":
				pop("+%d coins" % gained, Color("f2d27a"))
			else:
				pop("+%d %s" % [gained, _name(k)], Color("e8dcc0"))
	_seen = now
	_watching = m.world_started


func _name(key: String) -> String:
	var k := key.substr(2)
	if key.begins_with("m:") and m.MATERIAL_INFO.has(k):
		return str(m.MATERIAL_INFO[k]["name"])
	return str(ITEM_NAMES.get(k, k.replace("_", " ").capitalize()))


func _draw() -> void:
	for p in parts:
		var fade := 1.0 - clampf((float(p["life"]) / float(p["max"]) - 0.6) / 0.4, 0.0, 1.0)
		var col: Color = p["color"]
		col.a = fade
		var s := float(p["size"])
		if p["kind"] in ["sparkle", "spark"]:
			layer.draw_line(p["pos"] - Vector2(s, 0), p["pos"] + Vector2(s, 0), col, 3.0)
			layer.draw_line(p["pos"] - Vector2(0, s), p["pos"] + Vector2(0, s), col, 3.0)
		else:
			layer.draw_rect(Rect2(p["pos"] - Vector2(s, s) * 0.5, Vector2(s, s)), col)


func _draw_pops() -> void:
	var font := ThemeDB.fallback_font
	for p in pops:
		var t := float(p["age"]) / POP_SECONDS
		var alpha := 1.0 - clampf((t - 0.6) / 0.4, 0.0, 1.0)
		var w := font.get_string_size(p["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, POP_FONT).x
		# Rises quickly, then eases to a stop.
		var at: Vector2 = p["pos"] + Vector2(-w * 0.5, -POP_RISE * (1.0 - pow(1.0 - minf(t * 1.6, 1.0), 2.0)))
		var col: Color = p["color"]
		col.a = alpha
		pop_layer.draw_string_outline(font, at, p["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, POP_FONT, 4, Color(0.05, 0.04, 0.03, 0.92 * alpha))
		pop_layer.draw_string(font, at, p["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, POP_FONT, col)
