class_name FarmScenery
extends Node2D

# The farm's look since FARM-001: the playable concept's art, exported once by tools/concept_export.gd into
# art/farm/concept/ (scenery.json lists every piece). main.gd keeps drawing what changes in play (the fields' soil
# and crops, brush, rocks, stumps, the coop, barn, workshop, decor, forage and fish spots); this node draws the rest:
#   - the ground, baked into 16 by 16 tile chunks (grass, paths, the pond, the forest floor, contact shadows), a day
#     set and a night set crossfaded as night falls, under main's own drawing;
#   - every standing piece (the forest, the P1 cabin, the oak, the well, the stand, fences and the east gate, the
#     orchard, the hillside and cave mouth, props), each with its day and night tint, behind the farmer while the
#     farmer is south of its base and in front of the farmer otherwise;
#   - the R3-1 night (the reviewed night tint and grade) and a small daytime warmth, on the farm only.
# Grove trees hide while felled. Nothing here blocks: collision is the map's.

const DIR := "res://art/farm/concept/"
# The reviewed R3-1 night (ART-003 Round 3, chosen 2026-11-02): a lighter night tint and its colour grade.
const NIGHT_TINT := Color("8592b8")
const NIGHT_GRADE := {"saturation": 0.7, "exposure": 1.0, "contrast": 1.12, "shadow_cool": 0.07, "vignette": 0.62, "warmth": 0.06}
const WEATHER_DIM := 0.6    # rain, snow and fog take the night tint darkened to this share
const FRONT_MARGIN := 0.45  # a piece is drawn over the farmer once its base is this far (tiles) below the feet
# The grade's own values by day (shaders/grade.gdshader); the night grade blends in as darkness falls.
const DAY_GRADE := {"exposure": 0.84, "contrast": 1.1, "shadow_cool": 0.035, "vignette": 0.55, "warmth": 0.02}
const DAY_WARMTH := 0.03    # extra grade warmth at midday, gone by dusk
# The evening (FARM-001 review, priority 3): the farm's light by the clock from late afternoon until night takes over,
# multiplied into the weather's daylight. Golden late afternoon, amber dusk around sunset, a cool blue twilight, then
# the R3-1 night. Colour and brightness only: the darkness that drives lamps, sanity and the night is unchanged.
const EVENING := [
	[16.5, Color(1.0, 1.0, 1.0)],
	[18.0, Color(1.0, 0.93, 0.8)],      # golden hour
	[19.0, Color(0.93, 0.78, 0.66)],    # sunset amber, a little dimmer
	[19.75, Color(0.76, 0.68, 0.74)],   # the sun gone: rose fading to lilac
	[20.5, Color(0.6, 0.62, 0.78)],     # blue twilight, close to the night tint
]
const EVENING_WARMTH := 0.05   # extra grade warmth at the golden hour and sunset
const TWILIGHT_COOL := 0.04    # extra shadow coolness in the blue twilight
const RAIN_LIFT := 0.06        # extra exposure in rain, snow and fog by day, so crops and paths stay readable
const DULL_WEATHER := ["fog", "drizzle", "rain", "downpour", "snow"]

var m: MainGame
var ground := Node2D.new()          # the chunks and contact shadows, under main's drawing
var day_chunks: Array = []
var night_chunks: Array = []
var pieces: Array = []              # [Sprite2D, base row, day tint, night tint], sorted by base
var ground_tinted: Array = []      # [Sprite2D, day tint, night tint] ground decals that darken with the night
var night_only: Array = []          # [day sprite, night sprite] pairs that swap textures at night (the cabin's lit windows)
var groves := {}                    # world tile -> Array of Sprite2D standing on that grove tree
var front_from := 0                 # pieces[front_from..] are in front of the farmer
var _dark := -1.0
var house_at := Vector2.ZERO


func _init(main: MainGame) -> void:
	m = main
	ground.z_index = -1
	process_priority = 1000   # after main has set its own tint and grade for the frame


func _tex(name: String) -> Texture2D:
	return load(name if name.begins_with("res://") else DIR + name)


func _sprite(name: String, rec: Dictionary) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = _tex(name)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.centered = false
	s.scale = Vector2.ONE * float(rec["s"])
	s.flip_h = bool(rec.get("fh", false))
	s.position = Vector2(float(rec["x"]), float(rec["y"]))
	return s


func build() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "scenery.json"))
	house_at = Vector2(data["house_at"][0], data["house_at"][1])
	for c in data["chunks"]:
		var d := _sprite(str(c["t"]), c)
		var n := _sprite(str(c["tn"]), c)
		n.modulate.a = 0.0
		ground.add_child(d)
		ground.add_child(n)
		day_chunks.append(d)
		night_chunks.append(n)
	var grove_tiles := {}
	for g in m.GROVE_SPOTS:
		grove_tiles[Vector2i(g)] = true
	var list: Array = data["sprites"]
	list.sort_custom(func(a, b) -> bool: return float(a["b"]) < float(b["b"]))
	var last_forest: Dictionary = {}
	for r in list:
		var s := _sprite(str(r["t"]), r)
		var day := Color.html(str(r["m"]))
		var night := Color.html(str(r.get("mn", r["m"])))
		s.modulate = day
		var base := float(r["b"])
		if base < -999.0:
			# Not sorted: contact shadows lie on the ground; the drifting fog is over everything.
			if int(r["z"]) >= 100:
				s.z_index = 100
				add_child(s)
				pieces.append([s, INF, day, night])
			else:
				ground.add_child(s)
				if r.has("mn"):
					ground_tinted.append([s, day, night])
			continue
		add_child(s)
		pieces.append([s, base, day, night])
		if r.has("tn"):
			var n := _sprite(str(r["tn"]), r)
			n.modulate = Color(night.r, night.g, night.b, 0.0)
			add_child(n)
			pieces.append([n, base, Color(day.r, day.g, day.b, 0.0), night])
			night_only.append([s, n])
		if bool(r.get("forest", false)):
			last_forest = r
			var t := Vector2i(int(r["tx"]), int(r["ty"]))
			if grove_tiles.has(t):
				var w: Vector2i = t + Vector2i(m.BORDER_X, m.BORDER_Y)
				if not groves.has(w):
					groves[w] = []
				groves[w].append(s)
	# A grove tree the concept left as open forest floor gets a maple of its own, so there is a tree to fell.
	for g in grove_tiles:
		var w: Vector2i = g + Vector2i(m.BORDER_X, m.BORDER_Y)
		if groves.has(w) or last_forest.is_empty():
			continue
		var tex := _tex("src_maple.png")
		var rec := {"s": 3, "x": (g.x + 0.5) * m.PX + m.BORDER_X * m.PX - tex.get_width() * 1.5,
			"y": (g.y + 1.0) * m.PX + m.BORDER_Y * m.PX - tex.get_height() * 3.0}
		var s := _sprite("src_maple.png", rec)
		var day := Color.html(str(last_forest["m"]))
		var night := Color.html(str(last_forest.get("mn", last_forest["m"])))
		add_child(s)
		pieces.append([s, float(g.y + 1), day, night])
		groves[w] = [s]
	# Children were added in base order, so pieces at the same depth overlap as the concept drew them.
	pieces.sort_custom(func(a, b) -> bool: return a[1] < b[1])
	for p in pieces:
		if (p[0] as Sprite2D).z_index != 100:
			(p[0] as Sprite2D).z_index = 1
	front_from = 0


# The house's window lights and the porch lamp, placed on the P1 cabin as the concept placed them.
func place_lights() -> void:
	var origin := Vector2(m.BORDER_X, m.BORDER_Y) * m.PX
	for i in m.window_lights.size():
		if i < m.HOUSE_SPRITE_WINDOWS.size():
			(m.window_lights[i] as PointLight2D).position = origin + (house_at + (m.HOUSE_SPRITE_WINDOWS[i] as Vector2) + Vector2(0, m.WINDOW_SPILL)) * m.PX
	if m.porch_light != null:
		var door := Vector2(house_at.x + 6.0, house_at.y + 10.0 - 22.0 / 32.0)
		m.porch_light.position = origin + (door + Vector2(0, 0.5)) * m.PX


func _process(_delta: float) -> void:
	if m.player == null:
		return
	var on_farm := not m.inside and not m.in_cave
	visible = on_farm
	ground.visible = on_farm
	if not on_farm:
		return
	_sort()
	for w in groves:
		var up := not m.grove_felled.has(w)
		for s in groves[w]:
			(s as Sprite2D).visible = up
	var dark: float = smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, m.current_hour)
	if absf(dark - _dark) > 0.01 or (dark != _dark and (dark == 0.0 or dark == 1.0)):
		_dark = dark
		_tint(dark)
	_light(dark)


# Pieces whose base is below the farmer's feet go in front (z 1 over the farmer's 0); the rest stay behind.
func _sort() -> void:
	var feet: float = (m.player.position.y / m.PX) - m.BORDER_Y + FRONT_MARGIN
	while front_from > 0 and pieces[front_from - 1][1] > feet:
		front_from -= 1
		(pieces[front_from][0] as Sprite2D).z_index = 1 if pieces[front_from][1] != INF else 100
	while front_from < pieces.size() and pieces[front_from][1] <= feet:
		(pieces[front_from][0] as Sprite2D).z_index = 0
		front_from += 1


func _tint(dark: float) -> void:
	for c in night_chunks:
		(c as Sprite2D).modulate.a = dark
	for p in pieces:
		(p[0] as Sprite2D).modulate = (p[2] as Color).lerp(p[3], dark)
	for g in ground_tinted:
		(g[0] as Sprite2D).modulate = (g[1] as Color).lerp(g[2], dark)


# The R3-1 night over the game's dusk, and a little warmth at midday. Colour and grade only: the game's darkness
# (lamps, sanity, the night's events) is untouched.
func _light(dark: float) -> void:
	var lamp_dark: float = dark * (1.0 - m.sanity_sys._night_relief())
	var gloom: float = m.sanity_sys._low_sanity_boost() / 0.25
	var h: float = m.current_hour
	var relief: float = m.sanity_sys._night_relief()
	var dull: float = 1.0 if m.weather_kind in DULL_WEATHER else 0.0
	# The evening light, by the clock; under cloud it keeps its dimming but loses most of its colour.
	var ev := _evening(h)
	var ev_grey := ev.r * 0.3 + ev.g * 0.55 + ev.b * 0.15
	ev = ev.lerp(Color(ev_grey, ev_grey, ev_grey), 0.7 * dull)
	ev = Color.WHITE.lerp(ev, 1.0 - relief)
	var day_sky: Color = m._light_tint()
	var sky := Color(day_sky.r * ev.r, day_sky.g * ev.g, day_sky.b * ev.b)
	sky = sky.lerp(NIGHT_TINT, smoothstep(0.35, 1.0, lamp_dark))
	sky = sky.lerp(m.SANITY_TINT, gloom * 0.5)
	var noon: float = smoothstep(7.0, 9.0, h) * (1.0 - smoothstep(16.5, m.DUSK_HOUR, h))
	if noon > 0.0:
		sky = Color(sky.r, sky.g * (1.0 - 0.015 * noon), sky.b * (1.0 - 0.06 * noon), sky.a)
	m.canvas_modulate.color = sky
	var dim := lerpf(1.0, WEATHER_DIM, lamp_dark)
	m.weather.night_tint = Color(sky.r * dim, sky.g * dim, sky.b * dim)
	var golden: float = smoothstep(16.5, 18.25, h) * (1.0 - smoothstep(19.0, 19.75, h)) * (1.0 - dull) * (1.0 - relief)
	var twilight: float = smoothstep(19.25, 20.0, h) * (1.0 - lamp_dark) * (1.0 - relief)
	for k in DAY_GRADE:
		var v: float = lerpf(DAY_GRADE[k], NIGHT_GRADE[k], lamp_dark)
		if k == "warmth":
			v += DAY_WARMTH * noon + EVENING_WARMTH * golden
		elif k == "shadow_cool":
			v += TWILIGHT_COOL * twilight
		elif k == "exposure":
			v += RAIN_LIFT * dull * (1.0 - lamp_dark)
		m.grade_mat.set_shader_parameter(k, v)
	var sat_v: Variant = m.grade_mat.get_shader_parameter("saturation")
	var sat: float = 0.62 if sat_v == null else float(sat_v)   # unset until main first writes it
	m.grade_mat.set_shader_parameter("saturation", lerpf(sat, NIGHT_GRADE["saturation"] * (1.0 - m.SANITY_DESAT * gloom), lamp_dark))


# The evening multiplier for this hour: white until late afternoon, then through EVENING's keys (held at the last).
func _evening(h: float) -> Color:
	if h <= EVENING[0][0]:
		return EVENING[0][1]
	for i in range(1, EVENING.size()):
		if h <= EVENING[i][0]:
			var a: Array = EVENING[i - 1]
			var b: Array = EVENING[i]
			return (a[1] as Color).lerp(b[1], smoothstep(a[0], b[0], h))
	return EVENING[-1][1]
