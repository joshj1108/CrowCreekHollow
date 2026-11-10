extends SceneTree

# ART-OVERHAUL-002 E3 checks, headless, in slot 9:
#   godot --path . --headless -s tools/aoh2_e3_check.gd
# - Sprites: every E3 sprite the farm draws exists, has binary alpha, an opaque foot row, and the native size its
#   class allows in the scale reference (AI_COLLAB/ART_OVERHAUL_002_E1_INVENTORY.md section 6).
# - The farmhouse: each repair stage shows its own sprite with the P1 cabin's exact footprint; the windows are lit at
#   night only from Patched; the paint tint reaches the cabin; each extension shows only once built.
# - The well: broken until repaired, the concept well after; the cistern and hose only once built.
# - Decor, forage, the day's happenings, the raiders, the downed crow and the madness figure all have their art.
# - Art only: the farm's map and the house's interior are the same at every stage with the art as without it.
# Prints PASS or FAIL per case.
var fails := 0

# name -> [min w, max w, min h, max h] in art px, from the scale reference.
const SMALL := [8, 16, 8, 24]
const SIZES := {
	"house_stage_0": [384, 384, 320, 320], "house_stage_1": [384, 384, 320, 320], "house_stage_2": [384, 384, 320, 320],
	"house_stage_2_night": [384, 384, 320, 320],
	"well_broken": [20, 32, 24, 48], "cistern": [16, 32, 16, 32], "hose": [8, 16, 8, 16],
	"flowers_a": SMALL, "flowers_b": SMALL, "flowers_c": SMALL, "flowers_winter": SMALL, "sprinkler": SMALL,
	"sprinkler_big": SMALL, "bench": SMALL, "birdbath": SMALL, "torch": SMALL, "snare": SMALL, "shutters": SMALL,
	"fence_broken": SMALL, "weathervane": [8, 20, 32, 48], "bell": [12, 24, 32, 48], "apple_bare": [12, 32, 24, 48],
	"pedlar": [14, 28, 26, 32], "figure": [12, 20, 28, 32], "fox": [16, 24, 8, 16], "barnthing": [16, 32, 12, 24],
	"branch": [24, 48, 12, 24], "storm_oak": [24, 48, 12, 24], "flax": [8, 16, 8, 16], "mushring": [16, 32, 12, 28],
}


func _check(ok: bool, what: String) -> void:
	if not ok:
		fails += 1
	print(("PASS " if ok else "FAIL ") + what)


func _alpha_ok(img: Image) -> bool:
	for y in img.get_height():
		for x in img.get_width():
			var a := img.get_pixel(x, y).a
			if a > 0.01 and a < 0.99:
				return false
	return true


func _foot_opaque(img: Image) -> bool:
	var used := img.get_used_rect()
	return used.size != Vector2i.ZERO and used.end.y == img.get_height()


func _same_alpha(a: Image, b: Image) -> bool:
	if a.get_size() != b.get_size():
		return false
	for y in range(0, a.get_height()):
		for x in range(0, a.get_width()):
			if (a.get_pixel(x, y).a > 0.5) != (b.get_pixel(x, y).a > 0.5):
				return false
	return true


func _initialize() -> void:
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._on_title_start("new", 9)
	await process_frame
	# Sprites.
	for name in SIZES:
		var path := "res://art/farm/e3/%s.png" % name
		_check(ResourceLoader.exists(path), "%s exists" % name)
		if not ResourceLoader.exists(path):
			continue
		var img: Image = (load(path) as Texture2D).get_image()
		var lim: Array = SIZES[name]
		_check(img.get_width() >= lim[0] and img.get_width() <= lim[1] and img.get_height() >= lim[2] and img.get_height() <= lim[3],
			"%s native size %dx%d in its class (%s)" % [name, img.get_width(), img.get_height(), str(lim)])
		_check(_alpha_ok(img), "%s alpha is binary" % name)
		_check(_foot_opaque(img), "%s stands on its bottom row" % name)
	for ext in ["porch", "storey", "cellar"]:
		var path := "res://art/farm/e3/ext_%s.png" % ext
		_check(ResourceLoader.exists(path) and _alpha_ok((load(path) as Texture2D).get_image()), "ext_%s exists with binary alpha" % ext)
	# The farmhouse.
	var sc: FarmScenery = m.farm_scenery
	_check(sc != null and not sc.house_pieces.is_empty(), "the cabin is built from the E3 stage set")
	if sc != null and not sc.house_pieces.is_empty():
		var day: Sprite2D = sc.house_pieces[0][0][0]
		var night: Sprite2D = sc.house_pieces[1][0][0]
		var p1: Image = (load(FarmScenery.HOUSE_DAY[3]) as Texture2D).get_image()
		var map_before: int = m.map.hash() if "map" in m else 0
		for st in 4:
			m.house_stage = st
			sc._update_e3()
			_check(day.texture.resource_path == FarmScenery.HOUSE_DAY[st], "stage %d shows %s" % [st, FarmScenery.HOUSE_DAY[st].get_file()])
			_check(_same_alpha(day.texture.get_image(), p1), "stage %d keeps the P1 cabin's footprint, door and windows" % st)
			var lit: bool = night.texture.resource_path != day.texture.resource_path
			_check(lit == (st >= 2), "stage %d windows lit at night: %s (lit from Patched)" % [st, str(lit)])
		_check(("map" not in m) or m.map.hash() == map_before, "the farm map is unchanged across the stages")
		m.estate.paint = "barn_red"
		sc._update_e3()
		var want: Color = m.estate._paint_tint()
		_check(is_equal_approx((sc.house_pieces[0][0][2] as Color).g, want.g), "the paint tint reaches the cabin")
		m.estate.paint = "plain"
		sc._update_e3()
		for id in FarmScenery.HOUSE_EXT:
			var sp: Sprite2D = sc.house_ext.get(id)
			_check(sp != null, "%s overlay placed" % id)
			if sp == null:
				continue
			m.estate.built.erase(id)
			sc._update_e3()
			var hidden := not sp.visible
			m.estate.built[id] = true
			sc._update_e3()
			_check(hidden and sp.visible, "%s shows only once built" % id)
			var cabin := Rect2(Vector2(FarmScenery.HOUSE_REC["x"], FarmScenery.HOUSE_REC["y"]), Vector2(384, 320) * 1.5).grow(48)
			_check(cabin.encloses(Rect2(sp.position, sp.texture.get_size() * sp.scale)), "%s sits on the cabin" % id)
			m.estate.built.erase(id)
		m.house_stage = 0
		sc._update_e3()
	# The well.
	_check(sc.well_piece != null and sc.cistern != null and sc.hose != null, "the well, cistern and hose are placed")
	if sc.well_piece != null and sc.cistern != null:
		m.well_repaired = false
		m.cistern_built = false
		m.hose_attached = false
		sc._update_e3()
		_check(sc.well_piece.texture.resource_path == FarmScenery.WELL_BROKEN and not sc.cistern.visible and not sc.hose.visible,
			"unrepaired: the broken well, no cistern or hose")
		m.well_repaired = true
		sc._update_e3()
		_check(sc.well_piece.texture.resource_path.ends_with("prop_well.png"), "repaired: the concept well")
		m.cistern_built = true
		m.hose_attached = true
		sc._update_e3()
		_check(sc.cistern.visible and sc.hose.visible, "the cistern and hose show once built")
		m.well_repaired = false
		m.cistern_built = false
		m.hose_attached = false
		sc._update_e3()
	# Decor.
	for kind in m.projects.DECOR:
		if kind in ["path", "fence"]:
			continue
		for winter in [false, true]:
			var art: String = m.projects._art(kind, Vector2i(3, 4), winter)
			_check(art != "", "decor %s has art%s (%s)" % [kind, " in winter" if winter else "", art])
	for f in [FarmProjects.FENCE_POST, FarmProjects.FENCE_W_END, FarmProjects.FENCE_E_END, "e3/fence_broken"] + FarmProjects.FENCE_MID:
		_check(FarmSprites.has(f), "fence piece %s exists" % f)
	# Forage, happenings, night, madness.
	for f in m.forage.FORAGE:
		_check(FarmSprites.has("e3/forage_" + str(f["id"])), "forage %s has art" % f["id"])
	for id in m.forage.WINDFALLS:
		_check(FarmSprites.has("concept/w4_orchard_windfall_" + str(id)), "windfall %s has art" % id)
	for id in DailyHappenings.E3_ART:
		_check(FarmSprites.has(DailyHappenings.E3_ART[id]), "happening %s has art" % id)
	for n in ["crow_perch", "e3/fox", "e3/barnthing", "e3/figure", "crop_pumpkin"]:
		_check(FarmSprites.has(n), "night/madness art %s exists" % n)
	# Draw every layer once with everything showing, to catch script errors in the new drawing.
	for kind in m.projects.DECOR:
		m.projects.decor[Vector2i(10 + m.projects.decor.size(), 30)] = kind
	m.projects.layer.queue_redraw()
	await process_frame
	await process_frame
	_check(true, "decor layer drew")
	# Every new drawing path once (a script error here prints SCRIPT ERROR in the log).
	var here: Vector2i = m._player_tile()
	m.current_hour = 11.0
	for id in DailyHappenings.E3_ART:
		m.happenings.today = {"id": id}
		m.happenings.tile = here
		m.happenings.done_day = -1
		m.happenings.layer.queue_redraw()
		await process_frame
	m.happenings.today = {}
	var k := 0
	for f in m.forage.FORAGE:
		m.forage.spots[here + Vector2i(k, 3)] = str(f["id"])
		k += 1
	m.forage.spots[here + Vector2i(k, 3)] = "apple"
	m.forage.layer.queue_redraw()
	await process_frame
	for r in ["fox", "barn", "crows"]:
		m.nights.raid = r
		m.nights.raid_live = true
		m.nights.raid_tile = here
		m.nights.layer.queue_redraw()
		await process_frame
	m.nights.raid_live = false
	var keep_sanity: float = m.sanity
	m.sanity = 10.0
	m.madness.figure_pos = m.player.position
	m.madness.figure_left = 1.0
	m.madness.fake_crop = here
	m.madness.layer.queue_redraw()
	await process_frame
	m.madness.figure_left = 0.0
	m.madness.fake_crop = Vector2i(-1, -1)
	m.sanity = keep_sanity
	_check(true, "happenings, forage, raiders and madness drew")
	print("e3 check: %d failure(s)" % fails)
	quit(1 if fails > 0 else 0)
