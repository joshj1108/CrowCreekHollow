extends "res://tools/hc1_audit.gd"

# ART-005 HC1 Step 2 (zero-generation, non-production): the HC1 Step 1 harness (W-4 layout b, F2 fields, the C2
# cabin, the game's own camera, scale, grade and the locked R3-1 night) with two swap switches for the density study.
# Nothing in the game, its camera, its art, its lighting or its saves changes; the swaps act on this harness run only.
# Run it in the clean export, as HC1 Step 1 was (tools/hc2_density_run.sh copies this file and the study art in):
#   godot --path builds/review/ART-005/p1_export -s tools/hc2_density.gd -- mode=wide layout=b grass=1 art=f2 \
#     house=g7:c2 house16 at=45,13 hour=12 out=builds/review/ART-005/hc2/x.png
# Extra options, on top of hc1_audit.gd's:
#   house16   the C2 cabin's sprite is replaced by the EXPERIMENTAL 16 px approximation
#             (art/style_tests/ART-005/hc2/house16/house_{day,night}.png, 192x160), drawn at full scale on the same
#             anchor, so its world size, door and windows sit exactly where C2's do (one art px = 3 screen px at 720p)
#   well32    the 16 px production well is replaced by the 32 px STUDY (hc2/well32/prop_well_32.png, 64x96) at half
#             scale on the same footprint (one art px = 1.5 screen px at 720p, as the C2 cabin's)

const HC2 := "res://art/style_tests/ART-005/hc2/"


func _hc2_tex(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(HC2 + path)))


func _finish(main, opt: Dictionary) -> void:
	var night := float(opt["hour"]) >= 18.0
	for c in main.get_children():
		if not (c is Sprite2D):
			continue
		var s: Sprite2D = c
		if o3.has("house16") and house_tex != null and s.texture == house_tex:
			# C2 is 384x320 drawn at 0.5 x S; the 16 px mockup is 192x160 at S: the same rectangle on screen.
			s.texture = _hc2_tex("house16/house_%s.png" % ("night" if night else "day"))
			s.scale = s.scale * 2.0
		elif o3.has("well32") and s.texture != null and s.texture.resource_path.ends_with("art/farm/prop_well.png"):
			# The well is 32x48 at S, bottom-centred on its footprint; the study is 64x96 at 0.5 x S, so its top-left
			# corner (centred=false) stays where the production well's is.
			s.texture = _hc2_tex("well32/prop_well_32.png")
			s.scale = s.scale * 0.5
	await super._finish(main, opt)
