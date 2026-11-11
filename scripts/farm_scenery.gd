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
# ART-OVERHAUL-001 Stage B: the north-west cave exterior (a cliff of rock strata with a recessed mouth, its mossy
# lip, rubble and undergrowth), made by tools/aoh_cave_ext.py into art/farm/cave_ext/. On, it replaces the
# FARM-001R cave pieces of scenery.json (the five hillside mounds, the mouth, the hill-foot fringe and its ferns).
# Off, the farm is the FARM-001R picture. Art only: the C tile, collision and the cave's way in are unchanged.
const CAVE_EXT_V2 := true
const CAVE_EXT := "res://art/farm/cave_ext/pieces.json"
# The night: the owner's final "Balanced Night Lighting" (2026-11-06), between ART-003's bright R3-1 night
# (8592b8) and the near-black 1a1f33 tried earlier that day. A dark blue-grey, with the farm's shapes faintly
# readable outside a light. Lights are added on top of this tint (see NIGHT_LIGHT_BOOST in main.gd), so the
# lantern's ring, the windows and the lamps are as bright as before. The grade keeps the day's exposure at night.
const NIGHT_TINT := Color("30384f")
const NIGHT_GRADE := {"saturation": 0.7, "exposure": 0.84, "contrast": 1.12, "shadow_cool": 0.07, "vignette": 0.62, "warmth": 0.06}
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
var gate_lamp: Sprite2D
const GATE_LAMP_AT := Vector2(3438, 1872)   # world px: its post one tile west of the east gate's north gatepost
const GATE_LAMP_BASE := 34.0
# ART-OVERHAUL-002 E3: the farmhouse by repair stage, its extensions, and the well's states (tools/aoh2_e3.py, art in
# art/farm/e3/). Stages 0-2 are PixelLab edits of the P1 cabin with its footprint, door and windows; stage 3 is the
# P1 cabin itself. The extensions are overlays on the cabin, shown once built. Off (or the art missing), the farm
# draws scenery.json's one cabin for every stage, as before. Art only.
const E3_ART := true
const E3 := "res://art/farm/e3/"
const HOUSE_PIECES := ["gen_be4b3d8247.png", "farmhouse_stage0.png"]   # the cabin's entry in scenery.json
const HOUSE_REC := {"x": 2568.0, "y": 513.0, "s": 1.5}   # the P1 cabin, where the window lights were measured
const HOUSE_H := 320.0                                   # the cabin sprite's height (px at scale 1)
const HOUSE_DAY := ["res://art/farm/e3/house_stage_0.png", "res://art/farm/e3/house_stage_1.png",
	"res://art/farm/e3/house_stage_2.png", "res://art/farm/concept/gen_be4b3d8247.png"]
const HOUSE_NIGHT := ["res://art/farm/e3/house_stage_0.png", "res://art/farm/e3/house_stage_1.png",
	"res://art/farm/e3/house_stage_2_night.png", "res://art/farm/concept/gen_d037a9b61e.png"]   # lit from Patched
const HOUSE_EXT := {"cellar_room": "cellar", "porch": "porch", "second_storey": "storey"}   # estate id -> art
const WELL_BROKEN := "res://art/farm/e3/well_broken.png"
var house_pieces: Array = []      # the cabin's day and night pieces, for the paint tint
var house_ext := {}               # estate id -> Sprite2D
var _house_shown := -1
var _paint_shown := ""
var well_piece: Sprite2D
var well_rec := {}
var cistern: Sprite2D
var hose: Sprite2D
var _well_shown := -1
# ART-OVERHAUL-002 E5: the farm by season (tools/aoh2_e5.py, art/farm/e5/). The concept art is autumn; spring and summer
# swap in green-leaved copies of the deciduous pieces, winter bare ones (and dormant brambles and litter). The windfall
# fruit lies only in summer and autumn. The ground keeps its baked chunks under shaders/season_ground.gdshader, which
# shifts the grass by season and dusts it with snow on snowy days. Textures only: no piece moves, nothing blocks.
const E5_SEASONS := true
const E5 := "res://art/farm/e5/"
const SEASONAL := ["gen_833b1e3652", "src_maple", "w4_orchard_pear_a", "w4_orchard_pear_b", "w4_orchard_apple_a",
	"w4_orchard_apple_b", "src_undergrowth", "bramble_0", "bramble_1", "ivy_0", "ivy_1", "litter_0", "litter_1", "litter_2"]
const WINDFALLS := ["w4_orchard_windfall_apple", "w4_orchard_windfall_pear"]
# Hue shift, saturation and value scale, frost mix; the same numbers as SEASON_GRASS in tools/aoh2_e5.py.
const SEASON_GRASS := {"Spring": [0.02, 1.1, 1.06, 0.0], "Summer": [0.0, 1.06, 1.0, 0.0],
	"Autumn": [-0.035, 0.88, 0.99, 0.0], "Winter": [-0.02, 0.62, 0.9, 0.1]}
# The baked leaf litter out of autumn: [amount, colour]. Green under the grass in spring and summer, dull in winter.
const SEASON_LITTER := {"Spring": [1.0, Color(0.22, 0.33, 0.17)], "Summer": [1.0, Color(0.2, 0.3, 0.16)],
	"Autumn": [0.0, Color.BLACK], "Winter": [0.85, Color(0.33, 0.28, 0.23)]}
const SNOW_COVER := 0.75
var seasonal: Array = []          # [Sprite2D, base name, autumn texture]
var windfalls: Array = []         # Sprite2D
var ground_mat: ShaderMaterial
var _season_shown := ""


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
	if E5_SEASONS:
		var base := name.get_file().get_basename()
		if SEASONAL.has(base):
			seasonal.append([s, base, s.texture])
		elif WINDFALLS.has(base):
			windfalls.append(s)
	return s


func build() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "scenery.json"))
	house_at = Vector2(data["house_at"][0], data["house_at"][1])
	for c in data["chunks"]:
		var d := _sprite(str(c["t"]), c)
		var n := _sprite(str(c["tn"]), c)
		n.modulate.a = 0.0
		if E5_SEASONS:
			if ground_mat == null:
				ground_mat = ShaderMaterial.new()
				ground_mat.shader = load("res://shaders/season_ground.gdshader")
			d.material = ground_mat
			n.material = ground_mat
		ground.add_child(d)
		ground.add_child(n)
		day_chunks.append(d)
		night_chunks.append(n)
	var grove_tiles := {}
	for g in m.GROVE_SPOTS:
		grove_tiles[Vector2i(g)] = true
	var list: Array = data["sprites"]
	if CAVE_EXT_V2:
		list = list.filter(func(r) -> bool: return not _old_cave(r))
		list.append_array(JSON.parse_string(FileAccess.get_file_as_string(CAVE_EXT))["sprites"])
	list.sort_custom(func(a, b) -> bool: return float(a["b"]) < float(b["b"]))
	var last_forest: Dictionary = {}
	for r in list:
		if E3_ART and HOUSE_PIECES.has(str(r["t"])) and ResourceLoader.exists(HOUSE_DAY[0]):
			_build_house(r)
			continue
		var s := _sprite(str(r["t"]), r)
		if str(r["t"]).ends_with("prop_well.png"):
			well_piece = s
			well_rec = r
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
	# ART-OVERHAUL-002 E2: the "lamp at the gate" trail work, the farm's own lantern post just inside the north
	# gatepost of the east gate. Shown once the work is built (see _process); art only.
	var lamp_rec := {"s": 3, "x": GATE_LAMP_AT.x, "y": GATE_LAMP_AT.y}
	gate_lamp = _sprite("src_lantern_post.png", lamp_rec)
	gate_lamp.visible = false
	add_child(gate_lamp)
	pieces.append([gate_lamp, GATE_LAMP_BASE, Color.WHITE, Color.WHITE])
	if E3_ART and well_piece != null and ResourceLoader.exists(WELL_BROKEN):
		_build_well()
	# Children were added in base order, so pieces at the same depth overlap as the concept drew them.
	pieces.sort_custom(func(a, b) -> bool: return a[1] < b[1])
	for p in pieces:
		if (p[0] as Sprite2D).z_index != 100:
			(p[0] as Sprite2D).z_index = 1
	front_from = 0


# The cabin and its extension overlays (E3). The day sprite and its lit-window night twin swap texture by stage.
func _build_house(r: Dictionary) -> void:
	var base := float(r["b"])
	var day := Color.html(str(r["m"]))
	var night := Color.html(str(r.get("mn", r["m"])))
	var d := _sprite(HOUSE_DAY[3], HOUSE_REC)
	var n := _sprite(HOUSE_NIGHT[3], HOUSE_REC)
	d.modulate = day
	n.modulate = Color(night.r, night.g, night.b, 0.0)
	add_child(d)
	add_child(n)
	var pd := [d, base, day, night]
	var pn := [n, base, Color(day.r, day.g, day.b, 0.0), night]
	pieces.append(pd)
	pieces.append(pn)
	night_only.append([d, n])
	house_pieces = [[pd, day, night], [pn, pn[2], night]]
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(E3 + "sizes.json"))
	var k := 0
	for id in HOUSE_EXT:
		var key := "ext_" + str(HOUSE_EXT[id])
		if not info.has(key):
			continue
		var e: Array = info[key]   # width, height, x and y from the cabin's top-left (cabin px)
		var s: float = HOUSE_REC["s"]
		var rec := {"s": s, "x": float(HOUSE_REC["x"]) + float(e[2]) * s, "y": float(HOUSE_REC["y"]) + float(e[3]) * s}
		var sp := _sprite(E3 + key + ".png", rec)
		sp.visible = false
		sp.modulate = day
		add_child(sp)
		# Below the cabin's foot line the piece sorts by its own foot; on the cabin, just after the cabin.
		k += 1
		var foot := (float(e[3]) + float(e[1]) - HOUSE_H) * s / float(m.PX)
		pieces.append([sp, base + maxf(foot, 0.0) + 0.001 * k, day, night])
		house_ext[id] = sp


# The well's states (E3): broken until repaired, then the concept well; the cistern and hose beside it once built.
func _build_well() -> void:
	var wx := float(well_rec["x"])
	var wy := float(well_rec["y"])
	var base := float(well_rec["b"])
	var cis := _tex(E3 + "cistern.png")
	cistern = _sprite(E3 + "cistern.png", {"s": 3, "x": wx + 29.0 * 3.0, "y": wy + (48.0 - cis.get_height() + 2.0) * 3.0})
	var hz := _tex(E3 + "hose.png")
	hose = _sprite(E3 + "hose.png", {"s": 3, "x": wx - (hz.get_width() - 4.0) * 3.0, "y": wy + (48.0 - hz.get_height() + 1.0) * 3.0})
	for sp in [cistern, hose]:
		(sp as Sprite2D).visible = false
		add_child(sp)
		pieces.append([sp, base + 0.05, Color.html(str(well_rec["m"])), Color.html(str(well_rec.get("mn", well_rec["m"])))])


func _update_e3() -> void:
	if not house_pieces.is_empty():
		var st := clampi(m.house_stage, 0, 3)
		if st != _house_shown:
			_house_shown = st
			(house_pieces[0][0][0] as Sprite2D).texture = _tex(HOUSE_DAY[st])
			(house_pieces[1][0][0] as Sprite2D).texture = _tex(HOUSE_NIGHT[st])
		var paint: String = m.estate.paint
		if paint != _paint_shown:
			# The outside paint (estate), as the old farm's house took it: multiplied into the cabin's tints.
			_paint_shown = paint
			var c: Color = m.estate._paint_tint()
			for h in house_pieces:
				var p: Array = h[0]
				p[2] = Color((h[1] as Color).r * c.r, (h[1] as Color).g * c.g, (h[1] as Color).b * c.b, (h[1] as Color).a)
				p[3] = Color((h[2] as Color).r * c.r, (h[2] as Color).g * c.g, (h[2] as Color).b * c.b, (h[2] as Color).a)
			_dark = -1.0
		for id in house_ext:
			(house_ext[id] as Sprite2D).visible = m.estate._has(id)
	if well_piece != null and cistern != null:
		var w := 1 if m.well_repaired else 0
		if w != _well_shown:
			_well_shown = w
			if m.well_repaired:
				well_piece.texture = _tex(str(well_rec["t"]))
				well_piece.position = Vector2(float(well_rec["x"]), float(well_rec["y"]))
			else:
				var t := _tex(WELL_BROKEN)
				well_piece.texture = t
				well_piece.position = Vector2(float(well_rec["x"]) + (16.0 - t.get_width() * 0.5) * 3.0,
					float(well_rec["y"]) + (48.0 - t.get_height()) * 3.0)
		cistern.visible = m.cistern_built
		hose.visible = m.hose_attached and m.well_repaired


# The FARM-001R cave pieces that CAVE_EXT_V2 replaces.
func _old_cave(r: Dictionary) -> bool:
	var t := str(r["t"])
	return t.ends_with("hillside.png") or t == "cave_mouth_natural.png" or t == "hill_foot.png" 		or (bool(r.get("farm001r", false)) and t.begins_with("fern_"))


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
	if gate_lamp != null:
		gate_lamp.visible = m.trek._has_work("gate_lamp")
	_update_e3()
	_update_season()
	for w in groves:
		var up := not m.grove_felled.has(w)
		for s in groves[w]:
			(s as Sprite2D).visible = up
	var dark: float = smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, m.current_hour)
	if absf(dark - _dark) > 0.01 or (dark != _dark and (dark == 0.0 or dark == 1.0)):
		_dark = dark
		_tint(dark)
	_light(dark)


# The season's textures and ground (E5), swapped only when the season or the snow changes.
func _update_season() -> void:
	if not E5_SEASONS:
		return
	var season: String = m._season_today()
	var snowing: bool = m.weather_kind == "snow"
	var key := season + ("+snow" if snowing else "")
	if key == _season_shown:
		return
	_season_shown = key
	var tag := season.to_lower()
	for e in seasonal:
		var path := E5 + "%s_%s.png" % [e[1], tag]
		(e[0] as Sprite2D).texture = load(path) if season != "Autumn" and ResourceLoader.exists(path) else e[2]
	for w in windfalls:
		(w as Sprite2D).visible = season in ["Summer", "Autumn"]
	if ground_mat != null:
		var g: Array = SEASON_GRASS.get(season, [0.0, 1.0, 1.0, 0.0])
		ground_mat.set_shader_parameter("hue_shift", g[0])
		ground_mat.set_shader_parameter("sat_scale", g[1])
		ground_mat.set_shader_parameter("val_scale", g[2])
		ground_mat.set_shader_parameter("frost", g[3])
		ground_mat.set_shader_parameter("snow", SNOW_COVER if snowing else 0.0)
		var l: Array = SEASON_LITTER.get(season, [0.0, Color.BLACK])
		ground_mat.set_shader_parameter("litter", l[0])
		var lc: Color = l[1]
		ground_mat.set_shader_parameter("litter_color", Vector3(lc.r, lc.g, lc.b))


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
