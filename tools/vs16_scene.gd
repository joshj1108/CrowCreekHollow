extends "res://tools/hc2_density.gd"

# ART-005 VS16 (zero-generation, NON-PRODUCTION): the polished 16 px vertical slice. The HC1/HC2 harness (W-4 layout b,
# F2 fields, the C2 cabin, the game's own camera, scale, grade and the locked R3-1 night) with two switches. Nothing
# in the game, its camera, its art, its lighting or its saves changes; every switch acts on this harness run only.
# Run it in the clean export, as HC1/HC2 were (tools/vs16_run.sh copies this file and the study art in):
#   godot --path builds/review/ART-005/p1_export -s tools/vs16_scene.gd -- mode=wide layout=b grass=1 art=f2 \
#     house=g7:c2 cabin16 style at=38.5,10.5 hour=12 out=builds/review/ART-005/vs16/x.png
# Extra options, on top of hc2_density.gd's:
#   cabin16   C2's sprite is replaced by the VS16 16 px restored cabin (art/style_tests/ART-005/vs16/cabin/
#             house_{day,night}.png, 192x160, tools/vs16_cabin.py) at full scale on the same anchor: the same world
#             rectangle, door and windows as C2 (one art px = 3 screen px at 720p)
#   style     the reversible scene-style STUDY:
#             - daylight only (hour < 18): the grade a little brighter and warmer (exposure 0.84 -> 0.90, warmth
#               0.02 -> 0.045, vignette 0.55 -> 0.42); the night grade, tint and lights are untouched (R3-1 stays)
#             - quieter grass: grass-coloured ground pixels get a 3x3 majority (mode) filter, once (a strong majority, 4 of 9), so the speckle
#               merges into larger clusters using only colours already there; paths, soil, water, litter unchanged
#             - contact shadows: every standing prop and building in view gets a hard-edged pixel shadow at its
#               base (2-3 art rows, one art px toward the lower right, away from the upper-left key light); forest
#               fill trees and the farmer (who has his own) are skipped; fainter at night
#   shadowlog print which sprites got a contact shadow

const VS16 := "res://art/style_tests/ART-005/vs16/"
const SKIP_TEX := ["fir", "maple", "undergrowth", "weather_fog", "forest"]


func _vs_tex(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(VS16 + path)))


func _process(d):
	if o3.has("style") and mainref != null and mainref.grade_mat != null and float(o3["hour"]) < 18.0:
		mainref.grade_mat.set_shader_parameter("exposure", 0.90)
		mainref.grade_mat.set_shader_parameter("warmth", 0.045)
		mainref.grade_mat.set_shader_parameter("vignette", 0.42)
	return super._process(d)


func _finish(main, opt: Dictionary) -> void:
	var night := float(opt["hour"]) >= 18.0
	if o3.has("cabin16"):
		for c in main.get_children():
			if c is Sprite2D and house_tex != null and (c as Sprite2D).texture == house_tex:
				# C2 is 384x320 drawn at 0.5 x S; the VS16 cabin is 192x160 at S: the same rectangle on screen.
				c.texture = _vs_tex("cabin/house_%s.png" % ("night" if night else "day"))
				c.scale = c.scale * 2.0
	if o3.has("style"):
		var view := _view_rect(main)
		_quiet_grass(main, view)
		_contact_shadows(main, view, night)
	await super._finish(main, opt)


# The world rectangle the camera can show during this run, padded (pans walk a few tiles).
func _view_rect(main) -> Rect2:
	var c: Vector2 = main.player.global_position
	var px: float = 16.0 * main.SCALE
	return Rect2(c - Vector2(20, 13) * px, Vector2(40, 26) * px)


func _sprite_rect(s: Sprite2D) -> Rect2:
	var r := s.get_rect()
	return Rect2(s.to_global(r.position), r.size * s.global_scale)


func _quiet_grass(main, view: Rect2) -> void:
	for c in main.get_children():
		if not (c is Sprite2D) or c.z_index != 1 or c.texture == null or c.texture.resource_path != "":
			continue
		if not _sprite_rect(c).intersects(view):
			continue
		var img: Image = c.texture.get_image()
		if img.get_width() < 64:
			continue
		img.convert(Image.FORMAT_RGBA8)
		img = _mode3(img)
		c.texture = ImageTexture.create_from_image(img)


func _is_grass(c: Color) -> bool:
	return c.a > 0.0 and c.g >= c.r * 0.92 and c.g > c.b * 1.25


func _mode3(src: Image) -> Image:
	var w := src.get_width()
	var h := src.get_height()
	var out := src.duplicate() as Image
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			var me := src.get_pixel(x, y)
			if not _is_grass(me):
				continue
			var counts := {}
			var best := me
			var best_n := 0
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var n := src.get_pixel(x + dx, y + dy)
					if not _is_grass(n):
						continue
					var k := n.to_rgba32()
					var cnt: int = counts.get(k, 0) + 1
					counts[k] = cnt
					if cnt > best_n:
						best_n = cnt
						best = n
			if best_n >= 4:
				out.set_pixel(x, y, best)
	return out


func _contact_shadows(main, view: Rect2, night: bool) -> void:
	var shade := Color(0.06, 0.07, 0.03, 0.26 if night else 0.42)
	var list := []
	for c in main.get_children():
		if c is Sprite2D and c.visible and c.texture != null and c.z_index >= 2 and c.modulate.a > 0.9:
			list.append(c)
	for s: Sprite2D in list:
		var path := s.texture.resource_path
		var skip := false
		for k in SKIP_TEX:
			if path.contains(k):
				skip = true
		if skip or not _sprite_rect(s).intersects(view):
			continue
		var img: Image = s.texture.get_image()
		if img == null:
			continue
		img.convert(Image.FORMAT_RGBA8)
		var fw := img.get_width() / maxi(1, s.hframes)
		var fh := img.get_height() / maxi(1, s.vframes)
		var ox := (s.frame % maxi(1, s.hframes)) * fw
		var oy := (s.frame / maxi(1, s.hframes)) * fh
		if s.region_enabled:
			ox = int(s.region_rect.position.x); oy = int(s.region_rect.position.y)
			fw = int(s.region_rect.size.x); fh = int(s.region_rect.size.y)
		if fw < 8 or fh < 10:
			continue
		# The footprint: the widest opaque row in the bottom quarter, and the lowest opaque row.
		var widths := []
		var bottom := -1
		for y in range(fh - 1, -1, -1):
			var a := -1
			var b := -1
			for x in fw:
				if img.get_pixel(ox + x, oy + y).a > 0.5:
					if a < 0:
						a = x
					b = x
			widths.append([y, a, b])
			if a >= 0 and bottom < 0:
				bottom = y
			if bottom >= 0 and y < bottom - fh / 4:
				break
		if bottom < 0:
			continue
		var foot_y := bottom
		var fa := fw
		var fb := -1
		var maxw := 0
		for wr in widths:
			if wr[1] >= 0:
				maxw = maxi(maxw, wr[2] - wr[1] + 1)
		for wr in widths:   # the lowest row at least 60% as wide as the widest: a building's footing, a prop's base
			if wr[1] >= 0 and wr[2] - wr[1] + 1 >= maxw * 0.6:
				foot_y = wr[0]
				fa = wr[1]
				fb = wr[2]
				break
		var tree := path.contains("oak") or path.contains("apple") or path.contains("pear") or path.contains("tree")
		if tree:   # trees: the shadow sits at the trunk's foot (the bottom rows), a little wider
			fa = fw
			fb = -1
			for wr in widths:
				if wr[1] >= 0 and wr[0] >= bottom - 2:
					fa = mini(fa, wr[1]); fb = maxi(fb, wr[2])
			fa -= 3; fb += 3
			foot_y = bottom
		var big := (fb - fa) >= 24
		var rows := 3 if big else 2
		var w := fb - fa + 3
		var sh := Image.create(w, rows + 1, false, Image.FORMAT_RGBA8)
		for r in rows:
			var inset := 0 if r == 0 else (1 if r < rows - 1 else 2 + (1 if big else 0))
			if not big and r == rows - 1:
				inset = 1
			for x in range(inset, w - inset):
				sh.set_pixel(x, r, shade)
		var spr := Sprite2D.new()
		spr.texture = ImageTexture.create_from_image(sh)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = false
		var lx := fa if not s.flip_h else fw - 1 - fb
		# one art px down-right of the footing; the top row tucks under the base
		var local := s.get_rect().position + Vector2(lx + 1, foot_y)
		spr.global_position = s.to_global(local)
		spr.global_scale = s.global_scale.abs()
		spr.z_index = 1
		main.add_child(spr)
		if o3.has("shadowlog"):
			print("shadow ", path if path != "" else "<image>", " w=", w, " rows=", rows)
