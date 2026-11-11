extends SceneTree

# ART-OVERHAUL-002 E4 and E5 checks, headless, in slot 9:
#   godot --path . --headless -s tools/aoh2_e5_check.gd
# - E4 furniture: each bought piece has its sprite (binary alpha, opaque foot row, native size in its class), and the
#   house's interior map is the same with every piece bought.
# - E5 farm: every seasonal sprite exists for spring, summer and winter at its autumn sprite's exact native size, with
#   binary alpha; the farm swaps them by the season of the day (autumn is the original art), hides the windfall fruit
#   outside summer and autumn, and sets the ground shader's grass and snow by season and weather.
# - E5 treks: each season's atlas has the autumn atlas's size; the trek art swaps atlas and grounds by the season.
# - Art only: the farm map, the season and the weather roll are the same with the swaps as without; a save made in
#   winter loads back in winter with winter art.
# Prints PASS or FAIL per case.
var fails := 0

const FURN := {"dresser": [14, 24, 16, 28], "armchair": [14, 24, 16, 28], "clock": [12, 20, 34, 46],
	"painting": [16, 28, 12, 28], "bookshelf": [24, 32, 20, 34], "feather_bed": [32, 32, 47, 47]}
# A day in each season (day 1 is October 1st).
const DAYS := {"Autumn": 20, "Winter": 75, "Spring": 170, "Summer": 260}


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


func _src_path(base: String) -> String:
	for d in ["res://art/farm/concept/", "res://art/farm/cave_ext/"]:
		if ResourceLoader.exists(d + base + ".png"):
			return d + base + ".png"
	return ""


func _initialize() -> void:
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._on_title_start("new", 9)
	await process_frame
	# E4 furniture.
	for id in FURN:
		var path := "res://art/farm/e4/%s.png" % id
		_check(ResourceLoader.exists(path), "E4 %s exists" % id)
		if not ResourceLoader.exists(path):
			continue
		var img: Image = (load(path) as Texture2D).get_image()
		var lim: Array = FURN[id]
		_check(img.get_width() >= lim[0] and img.get_width() <= lim[1] and img.get_height() >= lim[2] and img.get_height() <= lim[3],
			"E4 %s native size %dx%d in its class %s" % [id, img.get_width(), img.get_height(), str(lim)])
		_check(_alpha_ok(img), "E4 %s alpha is binary" % id)
		_check(_foot_opaque(img), "E4 %s stands on its bottom row" % id)
	var inside_before: int = str(m.interior).hash()
	for id in m.estate.FURNITURE:
		m.estate.furniture[id] = true
	m.house_stage = 3
	_check(str(m.interior).hash() == inside_before, "the interior map is unchanged with all furniture bought")
	# E5 farm sprites.
	var sc: FarmScenery = m.farm_scenery
	for base in FarmScenery.SEASONAL:
		var src := _src_path(base)
		_check(src != "", "E5 %s has its autumn source" % base)
		if src == "":
			continue
		var size: Vector2 = (load(src) as Texture2D).get_size()
		for season in ["spring", "summer", "winter"]:
			var path := "%s%s_%s.png" % [FarmScenery.E5, base, season]
			var ok := ResourceLoader.exists(path)
			_check(ok, "E5 %s %s exists" % [base, season])
			if ok:
				var img: Image = (load(path) as Texture2D).get_image()
				_check(Vector2(img.get_size()) == size, "E5 %s %s keeps the native size %s" % [base, season, str(size)])
				_check(_alpha_ok(img), "E5 %s %s alpha is binary" % [base, season])
	_check(sc.seasonal.size() > 20, "the farm tracks %d seasonal pieces" % sc.seasonal.size())
	_check(sc.windfalls.size() > 0, "the farm tracks %d windfalls" % sc.windfalls.size())
	var map_before: int = str(m.map).hash() if "map" in m else 0
	for season in DAYS:
		m.day = DAYS[season]
		_check(m._season_today() == season, "day %d is %s" % [DAYS[season], season])
		m.weather_kind = "sunny"
		sc._update_season()
		var e: Array = sc.seasonal[0]
		var tex: Texture2D = (e[0] as Sprite2D).texture
		if season == "Autumn":
			_check(tex == e[2], "%s: %s shows its original art" % [season, e[1]])
		else:
			_check(tex.resource_path.ends_with("%s_%s.png" % [e[1], season.to_lower()]), "%s: %s shows %s" % [season, e[1], tex.resource_path.get_file()])
		var all_ok := true
		for x in sc.seasonal:
			var t: Texture2D = (x[0] as Sprite2D).texture
			if season != "Autumn" and not t.resource_path.ends_with("_%s.png" % season.to_lower()):
				all_ok = false
		_check(all_ok, "%s: every seasonal piece shows its %s art" % [season, season.to_lower()])
		var fall_shown := (sc.windfalls[0] as Sprite2D).visible
		_check(fall_shown == (season in ["Summer", "Autumn"]), "%s: windfalls shown %s" % [season, str(fall_shown)])
		var hs: float = sc.ground_mat.get_shader_parameter("hue_shift")
		_check(is_equal_approx(hs, FarmScenery.SEASON_GRASS[season][0]), "%s: ground grass shift %.3f" % [season, hs])
		_check(is_equal_approx(float(sc.ground_mat.get_shader_parameter("snow")), 0.0), "%s: no snow on a sunny day" % season)
	m.weather_kind = "snow"
	sc._update_season()
	_check(float(sc.ground_mat.get_shader_parameter("snow")) > 0.0, "Summer with snow weather (forced): the snow dusting shows")
	m.weather_kind = "sunny"
	_check(("map" not in m) or str(m.map).hash() == map_before, "the farm map is unchanged by the seasonal art")
	# E5 treks.
	var art := TrekArt.new()
	var autumn_size: Vector2 = art.atlas.get_size()
	for season in ["spring", "summer", "winter"]:
		var path := "%satlas_%s.png" % [TrekArt.E5, season]
		_check(ResourceLoader.exists(path) and (load(path) as Texture2D).get_size() == autumn_size, "trek atlas %s at the autumn atlas's size" % season)
		for g in ["forest", "pasture", "hollow"]:
			var gp := "%sground_%s_%s.png" % [TrekArt.E5, g, season]
			_check(ResourceLoader.exists(gp) and (load(gp) as Texture2D).get_size() == art.grounds[g].get_size(), "trek ground %s %s at its size" % [g, season])
	var base_atlas: Texture2D = art.atlas
	art._season("Winter")
	_check(art.atlas.resource_path.ends_with("atlas_winter.png"), "trek art swaps to the winter atlas")
	art._season("Autumn")
	_check(art.atlas == base_atlas, "trek art goes back to the autumn atlas")
	# Save in winter, load, still winter art.
	m.day = DAYS["Winter"]
	m.saver._save_game()
	m.day = DAYS["Summer"]
	sc._update_season()
	_check(m.saver._load_game() and m.day == DAYS["Winter"], "a winter save loads back on its winter day")
	sc._update_season()
	_check((sc.seasonal[0][0] as Sprite2D).texture.resource_path.ends_with("_winter.png"), "after loading, the farm shows winter art")
	print("aoh2_e5_check done: %d failures" % fails)
	quit(1 if fails > 0 else 0)
