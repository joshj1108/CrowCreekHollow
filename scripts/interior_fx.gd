class_name InteriorFX
extends Node2D

# FARMHOUSE-INTERIOR-001: what moves and glows in the farmhouse, drawn over the house's standing art and under
# the farmer (the front windows, in the south wall, go on `front`, over him). Everything is derived from existing
# state each frame (the fire's hours, the clock, the weather, the season, the house stage, the shutters and the
# clock bought); it changes nothing in play: warmth, comfort and the fire's fuel are as before.
#   the hearth   flame frames picked out of order at uneven intervals, lower as the fuel runs down, glowing
#                embers and a few short-lived sparks (at most MAX_SPARKS); one amber PointLight2D, only while it
#                burns, flickering on two slow waves and a smoothed noise
#   candles      each lit candle (from CANDLE_HOUR) has its own flame and a small PointLight2D, each on its own
#                phase, so no two flicker together; several close together stay soft (low energy each)
#   windows      boarded and broken (Decrepit), one board and a patched pane (Boarded), glazed from Patched:
#                open with the curtains stirring on a mild dry day from spring to autumn; shut, with rain running
#                down the glass, in rain; misted with frost at the edges in winter or a cold snap; shut at night;
#                the outside shutters seen through the glass once they are barred. The view beyond shows the
#                season, the weather and the hour. A soft daylight PointLight2D falls in front of each
#   the clock    the long-case clock's pendulum swings once a second, once it is bought

const MAX_SPARKS := 4
const CANDLE_HOUR := 17.5
const FIRE_COLOR := Color(1.0, 0.6, 0.28)
const CANDLE_COLOR := Color(1.0, 0.74, 0.42)
const SKY := {"sunny": "9ab6cc", "cloudy": "8a939b", "fog": "b6bbbb", "drizzle": "7b858b", "rain": "6c767e",
	"downpour": "596168", "snow": "a8b0b8"}
const DAYLIGHT := {"sunny": 1.0, "cloudy": 0.7, "fog": 0.55, "drizzle": 0.55, "rain": 0.45, "downpour": 0.35, "snow": 0.65}
const GROUND := {"Spring": "6a8a4a", "Summer": "7f8b42", "Autumn": "8c6a3a", "Winter": "6c6c5e"}
const TREES := {"Spring": "34502c", "Summer": "3a4a24", "Autumn": "6a3c22", "Winter": "3a3a36"}
const CURTAINS := [
	["5e584c", "3e3a32", "726a5a"],   # tattered rag
	["8a7a5c", "5e523e", "a08e6c"],   # sackcloth
	["56677e", "3a4658", "6e819a"],   # faded blue
	["8a3a3a", "5e2428", "a85050"],   # deep red, cream trim
]
const WET := ["drizzle", "rain", "downpour"]
const OPEN_TEMP := 50.0    # deg F (the game's temperatures are Fahrenheit): mild enough to open a window
const FROST_TEMP := 37.0   # deg F: cold enough for frost on the glass

var m: MainGame
var art: InteriorArt
var front: Node2D
var fire_light: PointLight2D
var candle_lights := {}
var window_lights: Array = []
var t := 0.0
var fire_frame := 0
var fire_next := 0.0
var fire_noise := 0.0
var sparks: Array = []
var rng := RandomNumberGenerator.new()


func setup(main: MainGame, interior_art: InteriorArt) -> void:
	m = main
	art = interior_art
	rng.seed = 1101
	front = Node2D.new()
	front.z_index = 1
	front.draw.connect(_draw_front)
	m.add_child(front)


func _light(color: Color, scale: float) -> PointLight2D:
	var l := PointLight2D.new()
	l.color = color
	m._glow(l, scale)
	l.enabled = false
	add_child(l)
	return l


func _process(delta: float) -> void:
	var on := m != null and m.inside and not m.in_cave
	visible = on
	if front != null:
		front.visible = on
	if not on:
		if fire_light != null and fire_light.enabled:
			fire_light.enabled = false
			for l in candle_lights.values():
				(l as PointLight2D).enabled = false
			for l in window_lights:
				(l as PointLight2D).enabled = false
		return
	if fire_light == null:
		# The lights are made on the first visit inside, not at start-up.
		fire_light = _light(FIRE_COLOR, 1.45)
		for w in InteriorArt.WINDOWS.size() + InteriorArt.FRONT_WINDOWS.size():
			window_lights.append(_light(Color(0.86, 0.9, 1.0), 1.0))
	t += delta
	_update_fire(delta)
	_update_lights()
	queue_redraw()
	front.queue_redraw()


# --- State, from the game ---------------------------------------------------------------------------------

func fire_lit() -> bool:
	return m.firewood._fire_lit()


func _fuel() -> float:
	return clampf(m.fire_hours / 2.0, 0.0, 1.0)


func candles_lit() -> bool:
	return m.current_hour >= CANDLE_HOUR


# 0 at night, 1 in full day.
func daylight() -> float:
	var h := m.current_hour
	return smoothstep(6.0, 7.5, h) * (1.0 - smoothstep(m.DUSK_HOUR - 1.0, m.DUSK_HOUR + 1.5, h))


# A window's look: "boards" (Decrepit), "patched" (Boarded), or a glazed window with flags.
func window_state() -> Dictionary:
	var s := m.house_stage
	var kind := m.weather_kind
	var st := {"stage": s, "open": false, "rain": false, "snow": false, "fog": false, "frost": false, "shutters": false, "breeze": 0.0}
	var winter := m._season_today() == "Winter"
	var temp := m._temperature()
	st["rain"] = kind in WET
	st["snow"] = kind == "snow"
	st["fog"] = kind == "fog"
	if s <= 1:
		# Drafts through the broken glass stir the old curtains in bad weather.
		st["breeze"] = 1.2 if (st["rain"] or st["snow"] or winter) else 0.0
		return st
	st["frost"] = winter or temp < FROST_TEMP
	st["shutters"] = m.projects._shutters_barred()
	var night := m.current_hour >= 21.0 or m.current_hour < 7.0
	st["open"] = not winter and not night and not st["shutters"] and kind in ["sunny", "cloudy"] and temp >= OPEN_TEMP
	st["breeze"] = 2.0 if st["open"] else 0.0
	return st


# --- Fire -------------------------------------------------------------------------------------------------------

func _update_fire(delta: float) -> void:
	if not fire_lit():
		sparks.clear()
		return
	fire_next -= delta
	if fire_next <= 0.0:
		var f := rng.randi_range(0, 8)
		fire_frame = f + 1 if f >= fire_frame else f   # never the same frame twice running
		fire_next = rng.randf_range(0.07, 0.15)
	fire_noise = lerpf(fire_noise, rng.randf_range(-1.0, 1.0), 0.12)
	if sparks.size() < MAX_SPARKS and rng.randf() < delta * 0.9 * _fuel():
		sparks.append({"x": rng.randf_range(4.0, 16.0), "y": 6.0, "vy": rng.randf_range(10.0, 18.0), "vx": rng.randf_range(-3.0, 3.0), "life": rng.randf_range(0.5, 1.1)})
	for sp in sparks:
		sp["y"] -= sp["vy"] * delta
		sp["x"] += sp["vx"] * delta
		sp["life"] -= delta
	sparks = sparks.filter(func(sp: Dictionary) -> bool: return sp["life"] > 0.0 and sp["y"] > -8.0)


func _update_lights() -> void:
	var day := daylight()
	var lit := fire_lit()
	fire_light.enabled = lit
	if lit:
		var h := art.hearth_origin()
		var box := InteriorArt.FIREBOX
		fire_light.position = m._light_snap(h + (box.position + Vector2(box.size.x * 0.5, box.size.y * 0.6)) * m.SCALE + Vector2(0, m.PX * 0.9))
		var wave := 0.86 + 0.07 * sin(t * 7.1) + 0.05 * sin(t * 12.7 + 1.3) + 0.05 * fire_noise
		fire_light.energy = lerpf(0.7, 0.28, day) * lerpf(0.55, 1.0, _fuel()) * wave
	# Candles: one light each, on its own phase.
	var want := {}
	if candles_lit():
		var i := 0
		for c in art.candles():
			want[str(c["id"])] = c
			i += 1
	for id in candle_lights.keys():
		if not want.has(id):
			(candle_lights[id] as PointLight2D).enabled = false
	var k := 0
	for id in want:
		if not candle_lights.has(id):
			candle_lights[id] = _light(CANDLE_COLOR, 0.62)
		var l: PointLight2D = candle_lights[id]
		l.enabled = true
		l.position = m._light_snap((want[id]["p"] as Vector2) + Vector2(0, -m.SCALE * 2))
		var ph := float(k) * 2.39 + float(id.hash() % 97) * 0.13
		l.energy = lerpf(0.5, 0.22, day) * (0.9 + 0.06 * sin(t * (8.3 + k * 0.7) + ph) + 0.05 * sin(t * (14.9 + k * 1.3) + ph * 1.7))
		k += 1
	# Daylight through each window: none at night, less in rain, little through boards.
	var st := window_state()
	var wf: float = DAYLIGHT.get(m.weather_kind, 0.7)
	var board := 0.25 if st["stage"] == 0 else (0.55 if st["stage"] == 1 else (0.15 if st["shutters"] else 1.0))
	var season := m._season_today()
	var tint := Color(1.0, 0.97, 0.9) if season == "Summer" else (Color(0.84, 0.9, 1.0) if season == "Winter" else Color(0.92, 0.94, 0.98))
	var j := 0
	for w in InteriorArt.WINDOWS:
		var l: PointLight2D = window_lights[j]
		var r := art.window_rect(int(w["x"]))
		var opened := 1.0 if (str(w["id"]) != "parlor" or art.room_open(2)) else 0.5
		l.position = m._light_snap(r.get_center() + Vector2(0, m.PX * 2.2))
		l.color = tint
		l.energy = 0.32 * day * wf * board * opened
		l.enabled = l.energy > 0.01
		j += 1
	for x in InteriorArt.FRONT_WINDOWS:
		var l: PointLight2D = window_lights[j]
		l.position = m._light_snap(art._cell(Vector2i(int(x) + 1, InteriorArt.H - 2)).position)
		l.color = tint
		l.energy = 0.22 * day * wf * board
		l.enabled = l.energy > 0.01
		j += 1


# --- Drawing ----------------------------------------------------------------------------------------------------

func _px(origin: Vector2, x: float, y: float, c: Color, w := 1.0, h := 1.0) -> void:
	draw_rect(Rect2(origin + Vector2(roundf(x), roundf(y)) * m.SCALE, Vector2(w, h) * m.SCALE), c)


func _draw() -> void:
	if m == null or not m.inside:
		return
	var st := window_state()
	for w in InteriorArt.WINDOWS:
		_draw_window(art.window_rect(int(w["x"])).position, st, str(w["id"]))
	_draw_fire()
	_draw_candles()
	_draw_pendulum()


func _hash(a: int, b: int) -> int:
	return absi((a * 73856093) ^ (b * 19349663)) % 1000


func _draw_window(o: Vector2, st: Dictionary, id: String) -> void:
	var stage: int = st["stage"]
	if id == "parlor" and not art.room_open(2):
		stage = mini(stage, 0)   # the shut-up wash room's window stays boarded until the room opens
	var pane := Rect2(4, 4, 24, 19)
	_draw_view(o, pane, st)
	var glazed := stage >= 2
	var mid := pane.position.y + floorf(pane.size.y / 2.0)
	var open: bool = glazed and st["open"]
	# weather on and through the glass
	if st["rain"]:
		for i in 6:   # rain beyond, slanting
			var x := fmod(float(_hash(i, 3)) + t * 40.0, pane.size.x)
			var y := fmod(float(_hash(i, 5)) + t * 70.0, pane.size.y - 2.0)
			_px(o, pane.position.x + x, pane.position.y + y, Color(0.8, 0.85, 0.9, 0.35), 1, 2)
	if st["snow"]:
		for i in 7:
			var x := fmod(float(_hash(i, 7)) + sin(t * 0.8 + i) * 2.0 + t * 3.0, pane.size.x)
			var y := fmod(float(_hash(i, 9)) + t * 6.0, pane.size.y)
			_px(o, pane.position.x + x, pane.position.y + y, Color(0.95, 0.97, 1.0, 0.8))
	if glazed and not open:
		# a pale reflection across the glass
		for k in 6:
			_px(o, pane.position.x + 3 + k, pane.position.y + 15 - k * 2, Color(1, 1, 1, 0.13), 1, 2)
	if glazed and st["frost"]:
		draw_rect(Rect2(o + pane.position * m.SCALE, pane.size * m.SCALE), Color(0.86, 0.89, 0.93, 0.26))
	if st["rain"] and not open and stage >= 1:
		for i in 7:   # drops running down the glass, each at its own pace
			var x := float(_hash(i, 11) % int(pane.size.x))
			var speed := 4.0 + float(_hash(i, 13) % 7)
			var y := fmod(float(_hash(i, 17)) + t * speed, pane.size.y + 4.0) - 2.0
			if y >= 0.0 and y < pane.size.y - 1.0:
				_px(o, pane.position.x + x, pane.position.y + y, Color(0.85, 0.9, 0.95, 0.55))
				if y >= 1.0:
					_px(o, pane.position.x + x, pane.position.y + y - 1.0, Color(0.85, 0.9, 0.95, 0.22))
	var frame_tint: Color = InteriorArt.STAGE_TINT[stage]
	var frame := "win_open" if open else "win_frame"
	draw_texture_rect(art._tex(frame), Rect2(o, InteriorArt.WIN_SIZE * m.SCALE), false, frame_tint)
	if glazed and st["frost"]:
		draw_texture_rect(art._tex("win_frost"), Rect2(o, InteriorArt.WIN_SIZE * m.SCALE), false)
	if stage == 0:
		draw_texture_rect(art._tex("win_boards0"), Rect2(o, InteriorArt.WIN_SIZE * m.SCALE), false, frame_tint)
	elif stage == 1:
		draw_texture_rect(art._tex("win_boards1"), Rect2(o, InteriorArt.WIN_SIZE * m.SCALE), false, frame_tint)
	_draw_curtains(o, stage, float(st["breeze"]), id)


# What's beyond the glass: the sky for the hour and weather, a line of trees and the field in the season's colour,
# or the barred shutters.
func _draw_view(o: Vector2, pane: Rect2, st: Dictionary) -> void:
	var at := o + pane.position * m.SCALE
	if st["shutters"]:
		for k in int(pane.size.y):
			var c := Color("3a2a1e") if k % 5 != 4 else Color("1d1611")
			draw_rect(Rect2(at + Vector2(0, k * m.SCALE), Vector2(pane.size.x * m.SCALE, m.SCALE)), c)
		return
	var day := daylight()
	var h := m.current_hour
	var kind := m.weather_kind
	var sky := Color(SKY.get(kind, "8a939b"))
	var dusk := smoothstep(m.DUSK_HOUR - 1.5, m.DUSK_HOUR, h) * (1.0 - smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, h))
	if kind in ["sunny", "cloudy"]:
		sky = sky.lerp(Color("c48a64"), dusk * 0.7)
	var night := Color("141a28")
	sky = night.lerp(sky, day)
	var season := m._season_today()
	var ground := Color(GROUND[season])
	if season == "Winter" and (kind == "snow" or m._temperature() < 0.0):
		ground = Color("c4c8cc")
	var trees := Color(TREES[season])
	ground = Color("0e1210").lerp(ground, maxf(day, 0.12))
	trees = Color("0b0e0c").lerp(trees, maxf(day, 0.1))
	var w := pane.size.x * m.SCALE
	draw_rect(Rect2(at, Vector2(w, 6 * m.SCALE)), sky.darkened(0.08))
	draw_rect(Rect2(at + Vector2(0, 6 * m.SCALE), Vector2(w, 6 * m.SCALE)), sky)
	if day < 0.3 and kind in ["sunny", "cloudy"]:
		for k in 3:
			_px(o, pane.position.x + 3 + _hash(k, 21) % 18, pane.position.y + 1 + _hash(k, 23) % 6, Color(0.9, 0.9, 0.8, 0.7 * (1.0 - day / 0.3)))
	for x in int(pane.size.x):
		var th := 2 + _hash(x / 2, 31) % 3
		draw_rect(Rect2(at + Vector2(x * m.SCALE, (12 - th) * m.SCALE), Vector2(m.SCALE, th * m.SCALE)), trees)
	draw_rect(Rect2(at + Vector2(0, 12 * m.SCALE), Vector2(w, (pane.size.y - 12) * m.SCALE)), ground)
	draw_rect(Rect2(at + Vector2(0, 12 * m.SCALE), Vector2(w, m.SCALE)), ground.darkened(0.2))
	if st["fog"]:
		draw_rect(Rect2(at, pane.size * m.SCALE), Color(0.78, 0.8, 0.8, 0.62 * maxf(day, 0.3)))


func _draw_curtains(o: Vector2, stage: int, breeze: float, id: String) -> void:
	var pal: Array = CURTAINS[stage]
	var base := Color(pal[0])
	var dark := Color(pal[1])
	var light := Color(pal[2])
	# the rod
	_px(o, -2, 1, Color("2e2018"), 36, 1)
	var fin := Color("a08040") if stage >= 2 else Color("2e2018")
	_px(o, -3, 0, fin, 2, 2)
	_px(o, 33, 0, fin, 2, 2)
	var ph := float(id.hash() % 100) * 0.07
	var length := 24 if stage >= 1 else 20
	for side in 2:
		if stage == 0 and side == 1:
			# only a shred of the right curtain is left
			for j in 9:
				_px(o, 29, 2 + j, dark if j % 3 == 0 else base)
				if j < 6:
					_px(o, 30, 2 + j, base)
			continue
		var x0 := 0 if side == 0 else 24
		var dir := 1.0 if side == 0 else -1.0
		for j in length:
			var u := float(j) / float(length - 1)
			var dx := 0.0
			if breeze > 0.0:
				dx = breeze * pow(u, 1.6) * (0.7 * sin(t * 1.7 + j * 0.22 + ph + side) + 0.3 * sin(t * 0.63 + ph * 2.0 + side * 1.3))
				dx = roundf(dx * dir)
			for c in 8:
				if stage == 0:
					if _hash(c * 7 + side, j) % 11 == 0 or j > length - 1 - _hash(c, 41) % 5:
						continue
				var fold := posmod(c + side, 4)
				var col := dark if fold == 0 else (light if fold == 2 else base)
				if j == length - 1:
					col = dark
				if stage == 3 and (c == (7 if side == 0 else 0)):
					col = Color("d8c8a0")
				_px(o, x0 + c + dx, 2 + j, col)


func _draw_fire() -> void:
	var h := art.hearth_origin()
	var box := InteriorArt.FIREBOX
	if not fire_lit():
		return
	var fh := 14
	var rows := clampi(roundi(14.0 * (0.45 + 0.55 * _fuel())), 6, 14)
	var src := Rect2(fire_frame * 22, fh - rows, 22, rows)
	var at := h + Vector2(box.position.x - 1, box.end.y - rows) * m.SCALE
	draw_texture_rect_region(art._tex("fire"), Rect2(at, src.size * m.SCALE), src)
	# embers along the log bed, blinking on their own
	for k in 5:
		var on := sin(t * (3.0 + k * 0.9) + k * 1.7) > 0.2
		if on:
			_px(h, box.position.x + 2 + k * 4, box.end.y - 1, Color("ffb050"))
	for sp in sparks:
		var a := clampf(float(sp["life"]) * 1.5, 0.0, 1.0)
		var c := Color("ffd27a").lerp(Color("c0502a"), 1.0 - a)
		_px(h, box.position.x + float(sp["x"]), box.position.y + float(sp["y"]), Color(c, a))


func _draw_candles() -> void:
	var lit := candles_lit()
	var k := 0
	for c in art.candles():
		var p: Vector2 = c["p"]
		if c.get("stick", false):
			# a brass stick and a cream candle on the mantel
			_px(p, -1, 4, Color("a08040"), 3, 1)
			_px(p, 0, 1, Color("e8dcc0"), 1, 3)
			_px(p, 0, 4, Color("6a5020"))
		if lit:
			var ph := float(k) * 1.9 + float(str(c["id"]).hash() % 50) * 0.21
			var f := int(floorf(t * (7.0 + k * 0.6) + ph * 5.0))
			var lean: int = [0, 0, -1, 0, 1, 0][posmod(f * 7 + k, 6)]
			var tall := posmod(f * 3 + k * 5, 4) != 0
			_px(p, 0, 0, Color("6a3a1a"))
			_px(p, 0, -1, Color("fff4c8"))
			_px(p, lean, -2, Color("ffd27a"))
			if tall:
				_px(p, lean, -3, Color("f0a040", 0.85))
			if posmod(f + k, 3) == 0:
				_px(p, -lean if lean != 0 else 1, -1, Color("f0a040", 0.6))
		k += 1


func _draw_pendulum() -> void:
	if not m.estate.furniture.has("clock") or m.house_stage < int(m.estate.FURNITURE["clock"]["stage"]):
		return
	var cell := art._cell(m.estate._furniture_spot("clock"))
	var size := InteriorArt.CLOCK_SIZE * m.SCALE
	var o := Vector2(cell.position.x + (m.PX - size.x) * 0.5, cell.end.y - size.y).snapped(Vector2(m.SCALE, m.SCALE))
	var pivot := InteriorArt.CLOCK_PIVOT
	var length := InteriorArt.CLOCK_BOB.y - pivot.y
	var ang := 0.12 * sin(TAU * t / 2.0)   # one swing each second
	for j in int(length):
		_px(o, pivot.x + roundf(sin(ang) * j), pivot.y + j, Color("9a7a3a"))
	var bx := pivot.x + roundf(sin(ang) * length)
	_px(o, bx - 1, pivot.y + length - 1, Color("1d1611"), 3, 3)
	_px(o, bx - 1, pivot.y + length - 1, Color("d8b050"), 2, 2)
	_px(o, bx - 1, pivot.y + length - 1, Color("f0d890"))


# The front windows, in the south wall, seen from above: a deep sill, a strip of glass with the sky in it, and the
# boards across while the house is derelict. Drawn over the wall tops (which are in front of the farmer).
func _draw_front() -> void:
	if m == null or not m.inside:
		return
	var stage := m.house_stage
	var day := daylight()
	var sky := Color("141a28").lerp(Color(SKY.get(m.weather_kind, "8a939b")), day)
	for x in InteriorArt.FRONT_WINDOWS:
		var cell := art._cell(Vector2i(int(x), InteriorArt.H - 1))
		var o := cell.position
		front.draw_rect(Rect2(o + Vector2(1, 4) * m.SCALE, Vector2(30, 9) * m.SCALE), Color("1d1611"))
		front.draw_rect(Rect2(o + Vector2(2, 5) * m.SCALE, Vector2(28, 2) * m.SCALE), Color("6e4f37").lerp(Color("3a2a1e"), 0.5 if stage == 0 else 0.0))
		front.draw_rect(Rect2(o + Vector2(3, 8) * m.SCALE, Vector2(26, 3) * m.SCALE), sky.lerp(Color(0.9, 0.92, 0.95), 0.2))
		front.draw_rect(Rect2(o + Vector2(16, 8) * m.SCALE, Vector2(1, 3) * m.SCALE), Color("5a4030"))
		if stage <= 1:
			var n := 3 if stage == 0 else 1
			for b in n:
				var bx := 4 + b * 9 if stage == 0 else 11
				front.draw_rect(Rect2(o + Vector2(bx, 6) * m.SCALE, Vector2(5, 7) * m.SCALE), Color("1d1611"))
				front.draw_rect(Rect2(o + Vector2(bx + 1, 6) * m.SCALE, Vector2(3, 7) * m.SCALE), Color("5e4630"))
		elif m.weather_kind in WET:
			for i in 4:
				var y := fmod(float(_hash(i, 51)) + t * 5.0, 3.0)
				front.draw_rect(Rect2(o + Vector2(5 + i * 6, 8 + y) * m.SCALE, Vector2(1, 1) * m.SCALE), Color(0.85, 0.9, 0.95, 0.5))
