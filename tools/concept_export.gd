extends "res://tools/concept_farm.gd"

# FARM-001 exporter (one-off, not headless: the concept build needs a renderer). Runs the concept farm build and
# writes what production needs from it, then quits:
#   godot --path . -s tools/concept_export.gd -- layout_out=tools/concept_layout.json
#   godot --path . -s tools/concept_export.gd -- art_out=art/farm/concept hour=12 tag=day
#   godot --path . -s tools/concept_export.gd -- art_out=art/farm/concept hour=21 tag=night
# then python3 tools/concept_merge.py joins the two into art/farm/concept/scenery.json.
# layout_out: the W-4 grid with the approach path, the drawn-only overlay and every tile a concept prop blocks
#   (the harness's c_block), read by tools/concept_grid.py to write tools/farm_grid.txt.
# art_out: the baked ground chunks (ground_<tag>_<cx>_<cy>.png) and every standing sprite the concept draws, as a
#   list in <tag>.json (texture file, position, scale, flip, tint, base row, the tile it stands on, and whether it is
#   forest). Textures are written once each, named after the file they came from. The F2 fields and their crops
#   are left out: the game draws its own soil and crops on the fields.

var _imgs := {}   # texture file name -> true, written this run


func _tag(t: Texture2D, src: String) -> Texture2D:
	t.set_meta("src", src)
	return t


func _tex(name: String) -> Texture2D:
	return _tag(super._tex(name), SRC + name)


func _w4_tex(path: String) -> Texture2D:
	return _tag(super._w4_tex(path), W4 + path)


func _c_tex(path: String) -> Texture2D:
	return _tag(super._c_tex(path), W3C + path)


func _vs_tex(path: String) -> Texture2D:
	return _tag(super._vs_tex(path), (VS16P1 if o3.has("p1") else VS16) + path)


func _strip(path: String, min_px: int = 10) -> Array:
	var out := super._strip(path, min_px)
	for i in out.size():
		if out[i] is Texture2D:
			_tag(out[i], "%s#%d" % [path, i])
	return out


func _cells(path: String, w: int) -> Array:
	var out := super._cells(path, w)
	for i in out.size():
		_tag(out[i], "%s#%d" % [path, i])
	return out


func _f1_field(add: Callable, b: Vector2i, w: int, hgt: int, bi: int, crops_b: Array) -> void:
	if o3.has("art_out"):
		return
	super._f1_field(add, b, w, hgt, bi, crops_b)


# A file name for a texture: from where it was loaded, or a hash of its pixels for the ones made on the fly
# (contact shadows, the cabin mockup).
func _name(t: Texture2D) -> String:
	var src := ""
	if t.has_meta("src"):
		src = str(t.get_meta("src"))
	elif t.resource_path != "":
		src = t.resource_path
	if src.begins_with("res://art/farm/") and not src.contains("#"):
		return src   # already production art: referenced where it is
	var img := t.get_image()
	if src == "":
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_SHA1)
		ctx.update(img.get_data())
		return "gen_%s.png" % ctx.finish().hex_encode().substr(0, 10)
	var n := src.replace("res://art/style_tests/", "").replace("res://art/", "").replace("ART-003/", "").replace("ART-005/", "")
	n = n.replace("/", "_").replace("#", "_").replace(".png", "")
	return n + ".png"


func _save(t: Texture2D, name: String, dir: String) -> void:
	if name.begins_with("res://") or _imgs.has(name):
		return
	_imgs[name] = true
	var img := t.get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.save_png(ProjectSettings.globalize_path(dir.path_join(name)))


func _finish(main, opt: Dictionary) -> void:
	if o3.has("layout_out"):
		var blocks: Array = []
		for t in c_block:
			blocks.append([t.x, t.y])
		blocks.sort()
		var ov := {}
		for t in overlay:
			ov["%d,%d" % [t.x, t.y]] = overlay[t]
		var f := FileAccess.open(str(o3["layout_out"]), FileAccess.WRITE)
		f.store_string(JSON.stringify({"grid": grid, "blocks": blocks, "overlay": ov,
			"cave": [CAVE_T.x, CAVE_T.y], "stall": [STALL_T.position.x, STALL_T.position.y]}, "  "))
		f.close()
		print("concept_export: wrote ", o3["layout_out"], " (", blocks.size(), " blocked prop tiles)")
		_restore()
		quit()
		return
	if o3.has("art_out"):
		_export_art(main)
		_restore()
		quit()
		return
	await super._finish(main, opt)


func _export_art(main) -> void:
	var dir := str(o3["art_out"])
	var tag := str(o3.get("tag", "day"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var base_of := {}
	for e in sorted:
		base_of[e[0]] = float(e[1])
	var chunks: Array = []
	var sprites: Array = []
	var S: int = main.SCALE
	for c in concept_nodes:
		if not (c is Sprite2D) or c.texture == null or not c.visible:
			continue
		var s: Sprite2D = c
		var big_chunk := s.z_index == 1 and s.texture.resource_path == "" and not s.texture.has_meta("src") \
			and s.texture.get_width() == CH * 16 and s.texture.get_height() == CH * 16
		if big_chunk:
			var cx := int(round((s.position.x - big_origin.x) / (CH * 16 * S)))
			var cy := int(round((s.position.y - big_origin.y) / (CH * 16 * S)))
			var name := "ground_%s_%d_%d.png" % [tag, cx, cy]
			_imgs[name] = true
			s.texture.get_image().save_png(ProjectSettings.globalize_path(dir.path_join(name)))
			chunks.append({"t": name, "x": s.position.x, "y": s.position.y, "s": s.scale.x})
			continue
		var name := _name(s.texture)
		_save(s.texture, name, dir)
		var base: float = base_of.get(s, -1000.0)
		var src := str(s.texture.get_meta("src", ""))
		var cxp: float = (s.position.x - inner_origin.x + s.texture.get_width() * s.scale.x / 2.0) / px
		var rec := {"t": name, "x": s.position.x, "y": s.position.y, "s": s.scale.x, "fh": s.flip_h,
			"m": s.modulate.to_html(true), "z": s.z_index if base < -999.0 else -1, "b": base,
			"tx": floori(cxp), "ty": floori(base - 0.01) if base > -999.0 else -1000,
			"forest": src.ends_with("fir.png") or src.ends_with("maple.png") or src.ends_with("undergrowth.png")}
		sprites.append(rec)
	var f := FileAccess.open(dir.path_join(tag + ".json"), FileAccess.WRITE)
	f.store_string(JSON.stringify({"chunks": chunks, "sprites": sprites, "house_at": [house_at.x, house_at.y],
		"inner_origin": [inner_origin.x, inner_origin.y], "px": px}))
	f.close()
	print("concept_export: %s: %d chunks, %d sprites, %d texture files" % [tag, chunks.size(), sprites.size(), _imgs.size()])
