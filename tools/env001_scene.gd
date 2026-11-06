extends "res://tools/vs16p1_scene.gd"

# ENV-001 (zero-generation, NON-PRODUCTION): the whole-farm environment study. VS16-P1's harness (W-4 layout b, F2
# fields, the P1 cabin, the game's own camera, scale, grade and the locked R3-1 night) with three separate, reversible
# switches. Nothing in the game, its art, lighting, shaders, camera, collision or saves changes; every switch repaints
# this harness run's ground image only. Run it in the clean export (tools/env001_run.sh copies it and the art in):
#   godot --path builds/review/ART-005/p1_export -s tools/env001_scene.gd -- mode=wide layout=b grass=1 art=f2 \
#     house=g7:c2 cabin16 p1 terrain shadows day at=38.5,10.5 hour=12 out=builds/review/ENV-001/x.png
# Extra options, on top of vs16p1_scene.gd's:
#   terrain   the ground is redrawn from the hand-composed ENV-001 tile family (art/style_tests/ENV-001/terrain/,
#             tools/env001_art.py) on the same material map, so every path, bank, field and the pond keep their exact
#             tiles: calm grass fills G0/G1, a blade-clump G2 and an autumn G3 toward the forest; a grass/path dual-grid
#             set with a turf bank, its shadow, a lit lip and a worn centre; the old white tufts, big leaf decals and
#             speckled base are gone. Accents (muted clumps, clover, pebbles, leaves, mushrooms) are placed by zone:
#             none in the calm zones (cabin front/well/crossroads, round the fields, the road), clustered on verges,
#             more at the forest edge. The leaf-litter drifts, worn stone, pond banks and ruts are kept.
#   shadows   authored contact shadows (art/style_tests/ENV-001/shadows/) under the cabin, the golden oak, the well,
#             one orchard tree (apple_b at 9,19), the log pile at 35.5,15 and the fields' east-west fence runs. Day:
#             contact + cast; night: contact only, weaker (no sun). Darkens the ground in its own colours.
#   day       the noon value/colour key: a per-material colour key on the ground only (grass lighter and a touch warmer,
#             paths lighter warm ochre, leaves and stone a little lighter), at full strength in the clearing and fading
#             to nothing inside the forest, so the forest edge frames a lit homestead. Off after 18:00 unless daynight.
#   daynight  apply day at night as well (what an albedo key would do in production: the regression check)
#   all       terrain + shadows + day
#   probe     print the standing sprites the shadow study looks for

const ENV := "res://art/style_tests/ENV-001/"
const CALM := [Rect2i(33, 11, 23, 8), Rect2i(41, 17, 21, 15), Rect2i(12, 33, 47, 3)]

var big: Image             # the whole ground, before it is cut back into chunks
var big_origin := Vector2.ZERO
var gsprites := []         # the ground chunk sprites


func _on(k: String) -> bool:
	return o3.has(k) or o3.has("all")


func _env_img(path: String) -> Image:
	var im := Image.load_from_file(ProjectSettings.globalize_path(ENV + path))
	im.convert(Image.FORMAT_RGBA8)
	return im


func _build(main, night: bool) -> void:
	super._build(main, night)
	if not (_on("terrain") or _on("shadows") or _on("day")):
		return
	var S: int = main.SCALE
	var x0 := -MARGIN
	var y0 := -MARGIN
	big_origin = inner_origin + Vector2(x0, y0) * px
	var cw := ceili(float(GW + 2 * MARGIN) / CH)
	var chh := ceili(float(GH + 2 * MARGIN) / CH)
	big = Image.create(cw * CH * 16, chh * CH * 16, false, Image.FORMAT_RGBA8)
	for c in main.get_children():
		if c is Sprite2D and c.z_index == 1 and c.texture != null and c.texture.resource_path == "" \
				and c.texture.get_width() == CH * 16 and c.texture.get_height() == CH * 16:
			gsprites.append(c)
			var at := Vector2i(((c.position - big_origin) / S).round())
			big.blit_rect(c.texture.get_image(), Rect2i(0, 0, CH * 16, CH * 16), at)
	if _on("terrain"):
		_env_ground(night)
	if _on("shadows"):
		_env_shadows(main, night)
	if _on("day") and (not night or o3.has("daynight")):
		_env_day()
	for c in gsprites:
		var at := Vector2i(((c.position - big_origin) / S).round())
		(c as Sprite2D).texture = ImageTexture.create_from_image(big.get_region(Rect2i(at, Vector2i(CH * 16, CH * 16))))
	print("ENV-001: ", gsprites.size(), " ground chunks; terrain=", _on("terrain"), " shadows=", _on("shadows"),
		" day=", _on("day") and (not night or o3.has("daynight")))


# --- Terrain ---------------------------------------------------------------------------------------------------------
func _calm(x: int, y: int) -> bool:
	for r in CALM:
		if (r as Rect2i).has_point(Vector2i(x, y)):
			return true
	return false


func _greenish(c: Color) -> bool:
	return c.a > 0.0 and c.g >= c.r * 0.92 and c.g > c.b * 1.25


func _env_ground(night: bool) -> void:
	var x0 := -MARGIN
	var y0 := -MARGIN
	var grass := _env_img("terrain/grass.png")
	var dirt := _env_img("terrain/dirt.png")
	var wang := _env_img("terrain/path_wang.png")
	var acc := _strip(ENV + "terrain/accents.png", 4).map(func(t): var i: Image = t.get_image(); i.convert(Image.FORMAT_RGBA8); return i)
	var g0 := grass.get_region(Rect2i(0, 0, 16, 16))
	var path_ref := Color(0.45, 0.33, 0.22)
	var grass_ref := Color(0.27, 0.29, 0.13)
	var wear := _wang_set(R3 + "wear_tileset", path_ref)
	var litter := _wang_set("res://art/style_tests/ART-003/r2/litter_tileset", grass_ref)
	var iw: Image = (wear[0] as ImageTexture).get_image()
	var il: Image = (litter[0] as ImageTexture).get_image()
	iw.convert(Image.FORMAT_RGBA8)
	il.convert(Image.FORMAT_RGBA8)
	var water_a := _wang_set(W3 + "pond/water_tileset", grass_ref)
	var water_b := _wang_set(W3 + "pond/water2_tileset", grass_ref)
	var iwa: Image = (water_a[0] as ImageTexture).get_image()
	var iwb: Image = (water_b[0] as ImageTexture).get_image()
	iwa.convert(Image.FORMAT_RGBA8)
	iwb.convert(Image.FORMAT_RGBA8)
	var bnoise := FastNoiseLite.new()
	bnoise.seed = 61
	bnoise.frequency = 0.12
	var lnoise := FastNoiseLite.new()
	lnoise.seed = 5
	lnoise.frequency = 0.15
	var wnoise := FastNoiseLite.new()
	wnoise.seed = 29
	wnoise.frequency = 0.35
	var vnoise := FastNoiseLite.new()   # groups verge accents into runs with gaps
	vnoise.seed = 7
	vnoise.frequency = 0.22
	var M := func(x: int, y: int) -> String:
		return _mat(_code(x, y))
	# The same worn-stone and leaf-litter tiles as the control (copied rules), so only the texture changes.
	var stone := {}
	var leaves := {}
	for y in range(-MARGIN, GH + MARGIN):
		for x in range(-MARGIN, GW + MARGIN):
			var ring := true
			var open := true
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if M.call(x + dx, y + dy) != "p":
						ring = false
					if M.call(x + dx, y + dy) != "g":
						open = false
			if ring and (_code(x, y) == "c" or _code(x, y) == "W" or wnoise.get_noise_2d(x, y) > 0.35):
				stone[Vector2i(x, y)] = true
			elif open and ((_near(x, y, "rB", 1) and lnoise.get_noise_2d(x, y) > 0.3) or (_near(x, y, "To", 1) and lnoise.get_noise_2d(x, y) > 0.38)):
				leaves[Vector2i(x, y)] = true
	var paint := Image.create(big.get_width(), big.get_height(), false, Image.FORMAT_RGBA8)
	# overlay only the pixels a test accepts (litter leaves, worn stone), never the old tiles' grass or dirt
	var over := func(src: Image, rect: Rect2i, mx: int, my: int, keep: Callable) -> void:
		for yy in rect.size.y:
			for xx in rect.size.x:
				var c := src.get_pixel(rect.position.x + xx, rect.position.y + yy)
				if c.a > 0.5 and keep.call(c):
					paint.set_pixel(mx + xx, my + yy, c)
	for vy in range(y0 + 1, GH + MARGIN):
		for vx in range(x0 + 1, GW + MARGIN):
			var cells := [Vector2i(vx - 1, vy - 1), Vector2i(vx, vy - 1), Vector2i(vx - 1, vy), Vector2i(vx, vy)]
			var key := ""
			for c in cells:
				key += "1" if M.call(c.x, c.y) == "p" else "0"
			var mx := (vx - x0) * 16 - 8
			var my := (vy - y0) * 16 - 8
			var h := _hash(vx, vy, 19)
			if key == "0000":
				var v := h % 2
				if not _calm(vx, vy):
					if _near(vx, vy, "T", 1):
						v = [3, 2, 0, 1][h % 4]
					elif h % 4 == 0:
						v = 2
					elif h % 9 == 0:
						v = 3
				paint.blit_rect(grass, Rect2i(v * 16, 0, 16, 16), Vector2i(mx, my))
			elif key == "1111":
				paint.blit_rect(dirt, Rect2i(16, 0, 16, 16), Vector2i(mx, my))
			else:
				paint.blit_rect(wang, Rect2i(key.bin_to_int() * 16, (_hash(vx, vy, 11) % 2) * 16, 16, 16), Vector2i(mx, my))
			var skey := ""
			var lkey := ""
			for c in cells:
				skey += "1" if stone.has(c) else "0"
				lkey += "1" if leaves.has(c) else "0"
			if key == "1111" and skey != "0000":
				over.call(iw, Rect2i(wear[1][skey]), mx, my, func(c: Color) -> bool: return c.s < 0.3)
			if key == "0000" and lkey != "0000":
				over.call(il, Rect2i(litter[1][lkey]), mx, my, func(c: Color) -> bool: return c.r > c.g * 1.25)
			# The pond: the same PixelLab banks and water; their grass pixels take the calm fill instead.
			var wkey := ""
			for c in cells:
				wkey += "1" if M.call(c.x, c.y) == "w" else "0"
			if wkey != "0000":
				var use_wb := bnoise.get_noise_2d(vx, vy) > 0.0
				var src: Image = iwb if use_wb else iwa
				var r := Rect2i((water_b if use_wb else water_a)[1][wkey])
				if wkey == "1111":
					src = iwa
					r = Rect2i(water_a[1]["1111"])
				for yy in 16:
					for xx in 16:
						var c := src.get_pixel(r.position.x + xx, r.position.y + yy)
						if _greenish(c) and c.v > 0.18:
							c = g0.get_pixel(xx, yy)
						paint.set_pixel(mx + xx, my + yy, c)
	# Accents by zone, on whole grass tiles only.
	var n_acc := 0
	for y in range(y0, GH + MARGIN):
		for x in range(x0, GW + MARGIN):
			if M.call(x, y) != "g" or _calm(x, y) or (_code(x, y) == "T" and _depth(x, y) > 1.0):
				continue
			var h := _hash(x, y, 3)
			var pick := -1
			if _near(x, y, "T", 2) and _code(x, y) != "T":
				if h % 4 == 0:
					pick = [0, 1, 4, 5, 0, 2][(h >> 3) % 6]
			elif _near(x, y, "oBr", 1):
				if h % 5 == 0:
					pick = 4
			elif _near(x, y, "PgRkcWw", 1):
				if vnoise.get_noise_2d(x, y) > 0.15 and h % 3 == 0:
					pick = [0, 1, 2][(h >> 3) % 3]
			elif h % 9 == 0:
				pick = [2, 3, 4, 1][(h >> 3) % 4]
			if pick < 0:
				continue
			var a: Image = acc[pick % acc.size()]
			var ax := (x - x0) * 16 + 2 + (h >> 4) % maxi(1, 13 - a.get_width())
			var ay := (y - y0) * 16 + 2 + (h >> 8) % maxi(1, 13 - a.get_height())
			# only on grass: all four corners of the accent's box must be grass
			var ok := true
			for p in [Vector2i(ax, ay), Vector2i(ax + a.get_width() - 1, ay), Vector2i(ax, ay + a.get_height() - 1), Vector2i(ax + a.get_width() - 1, ay + a.get_height() - 1)]:
				if not _greenish(paint.get_pixelv(p)):
					ok = false
			if ok:
				paint.blend_rect(a, Rect2i(Vector2i.ZERO, a.get_size()), Vector2i(ax, ay))
				n_acc += 1
	# Ruts along the road (the control's rule).
	for x in range(12, 59):
		if _code(x, 34) != "P" or _code(x, 35) != "P":
			continue
		for lane in [9, 19]:
			for xx in 16:
				var wob := 1 if _hash(x * 4 + xx / 4, lane, 67) % 5 == 0 else 0
				for k in 2:
					var p := Vector2i((x - x0) * 16 + xx, (34 - y0) * 16 + lane + wob + k)
					var c := paint.get_pixelv(p)
					paint.set_pixelv(p, c.lerp(Color(0.1, 0.07, 0.04), 0.32))
	# The forest's shade (the control's rule and strength).
	for y in range(y0, GH + MARGIN):
		for x in range(x0, GW + MARGIN):
			var f := _shade_at(x, y)
			if f >= 0.999:
				continue
			var sh := Image.create(16, 16, false, Image.FORMAT_RGBA8)
			sh.fill(Color(0.02, 0.03, 0.05, 1.0 - f))
			paint.blend_rect(sh, Rect2i(0, 0, 16, 16), Vector2i((x - x0) * 16, (y - y0) * 16))
	big = paint
	print("ENV-001 terrain: accents placed ", n_acc)


# --- Contact shadows -------------------------------------------------------------------------------------------------
func _darken(bx: int, by: int, mul: Color) -> void:
	if bx < 0 or by < 0 or bx >= big.get_width() or by >= big.get_height():
		return
	var c := big.get_pixel(bx, by)
	big.set_pixel(bx, by, Color(c.r * mul.r, c.g * mul.g, c.b * mul.b, c.a))


func _apply_mask(s: Sprite2D, name: String, pad: Array, night: bool) -> void:
	var m := _env_img("shadows/%s.png" % name)
	var S: float = s.global_scale.x
	var tl := Vector2i(((s.global_position - big_origin) / S).round()) - Vector2i(int(pad[0]), int(pad[1]))
	var cast := Color(0.64, 0.67, 0.78)
	var contact := Color(0.50, 0.52, 0.62) if not night else Color(0.74, 0.74, 0.80)
	for y in m.get_height():
		for x in m.get_width():
			var a := m.get_pixel(x, y).a
			if a > 0.9:
				_darken(tl.x + x, tl.y + y, contact)
			elif a > 0.3 and not night:
				_darken(tl.x + x, tl.y + y, cast)
	print("ENV-001 shadow: ", name)


func _env_shadows(main, night: bool) -> void:
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ENV + "shadows/shadows.json"))
	for e in sorted:
		var s: Sprite2D = e[0]
		var base: float = e[1]
		if s.texture == null:
			continue
		var w := s.texture.get_width()
		var h := s.texture.get_height()
		var cx := ((s.position.x - inner_origin.x) + w * s.scale.x / 2.0) / px
		if o3.has("probe") and (w >= 16 or h >= 16):
			print("probe ", w, "x", h, " cx=", snappedf(cx, 0.01), " base=", snappedf(base, 0.01), " flip=", s.flip_h, " ", s.texture.resource_path)
		var name := ""
		if s.texture == house_tex:
			name = "cabin"
		elif w == 192 and h == 192:
			name = "oak"
		elif s.texture.resource_path.ends_with("prop_well.png"):
			name = "well"
		elif w == 48 and h == 64 and absf(cx - 9.5) < 0.2 and absf(base - 20.0) < 0.1:
			name = "apple_b"
		elif w == 19 and h == 16 and absf(cx - 35.5) < 0.2 and absf(base - 15.0) < 0.1:
			name = "logpile_flip"
		elif (absf(base - 19.0) < 0.05 or absf(base - 31.0) < 0.05) and cx > 42.0 and cx < 61.0 and h >= 16 and h <= 40:
			_fence_shadow(s, night)
			continue
		if name == "":
			continue
		if name == "cabin":   # C2 at half scale: the same rectangle as the 192x160 P1 cabin at full scale
			var tmp := Sprite2D.new()
			tmp.global_position = s.global_position
			tmp.global_scale = s.global_scale * 2.0
			_apply_mask(tmp, name, meta[name]["pad"], night)
			tmp.free()
		else:
			_apply_mask(s, name, meta[name]["pad"], night)


# The fields' east-west fence runs: each opaque pixel h rows above the sprite's base throws a shadow h/2 right and
# h/4 down on the ground (rails become two thin offset lines, posts short slanted strokes); contact under each post.
func _fence_shadow(s: Sprite2D, night: bool) -> void:
	var img: Image = s.texture.get_image()
	img.convert(Image.FORMAT_RGBA8)
	var S: float = s.global_scale.x
	var tl := Vector2i(((s.global_position - big_origin) / S).round())
	var w := img.get_width()
	var h := img.get_height()
	var low := -1
	for y in range(h - 1, -1, -1):
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				low = y
				break
		if low >= 0:
			break
	var done := {}
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a < 0.5:
				continue
			var xx := x if not s.flip_h else w - 1 - x
			var hh := low - y
			if hh <= 1:
				var p := Vector2i(tl.x + xx, tl.y + low + 1)
				if not done.has(p):
					done[p] = true
					_darken(p.x, p.y, Color(0.50, 0.52, 0.62) if not night else Color(0.74, 0.74, 0.80))
			elif not night:
				var q := Vector2i(tl.x + xx + hh / 2, tl.y + low + 1 + hh / 4)
				if not done.has(q):
					done[q] = true
					_darken(q.x, q.y, Color(0.66, 0.69, 0.80))


# --- The noon key ----------------------------------------------------------------------------------------------------
func _env_day() -> void:
	var x0 := -MARGIN
	var y0 := -MARGIN
	var wmap := {}
	for y in big.get_height():
		for x in big.get_width():
			var t := Vector2i(x / 16 + x0, y / 16 + y0)
			if not wmap.has(t):
				wmap[t] = clampf((_shade_at(t.x, t.y) - 0.55) / 0.45, 0.0, 1.0)
			var w: float = wmap[t]
			if w <= 0.0:
				continue
			var c := big.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var hh := c.h
			var ss := c.s
			var vv := c.v
			if c.b > c.r and c.b > c.g * 0.9:
				continue   # water
			if hh >= 0.14 and hh <= 0.36 and ss > 0.22:          # grass: lighter, a touch warmer, darks kept
				vv = vv + w * 0.22 * vv * smoothstep(0.08, 0.34, vv)
				hh -= 0.010 * w
			elif hh >= 0.025 and hh < 0.14 and ss < 0.66:        # dirt and paths: a lighter, warm ochre
				vv = vv + w * 0.20 * vv * smoothstep(0.12, 0.40, vv)
				hh += 0.004 * w
			elif ss >= 0.5:                                      # leaves and fallen fruit: a little lighter
				vv *= 1.0 + 0.10 * w
			else:                                                # stone, wear
				vv *= 1.0 + 0.14 * w
			big.set_pixel(x, y, Color.from_hsv(hh, ss, minf(vv, 1.0), c.a))
