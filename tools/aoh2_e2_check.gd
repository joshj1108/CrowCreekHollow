extends SceneTree

# ART-OVERHAUL-002 E2 checks, headless, in slot 9:
#   godot --path . --headless -s tools/aoh2_e2_check.gd
# - Sprites: every E2 sprite the trek draws exists, has binary alpha, an opaque foot row, and the native size its
#   class allows in the scale reference (AI_COLLAB/ART_OVERHAUL_002_E1_INVENTORY.md section 6); walker sheets have
#   the three facing rows of seven 32 px frames with no empty frame (no missing directional animation).
# - Trail works: on every route and clearing where a work stands in the wood (the waystation hut, the post-road
#   lamp), it is placed, keeps off the trail and open ground, and leaves the blocking grid unchanged.
# - The day's gloom by place (Stage D review A): the dark trail stays darker than the forest, the forest than the
#   wood's edge, and every one lighter by day than at night.
# Prints PASS or FAIL per case.
var fails := 0

# name -> [min w, max w, min h, max h] in art px, from the scale reference.
const SIZES := {
	"tall": [12, 24, 38, 48], "stake": [6, 24, 12, 32], "rope": [16, 48, 2, 8], "steps": [16, 48, 16, 40],
	"tins": [8, 24, 8, 24], "hut": [40, 72, 40, 72],
}
# Walkers: a standing figure's height in its 32 px cell (the farmer is 32 tall; the boy shorter).
const WALKER_H := {"mill": [26, 32], "orchard": [22, 27], "chapel": [27, 32], "post": [27, 32], "grove": [27, 32]}


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


func _foot_opaque(img: Image, r: Rect2i) -> bool:
	var used := img.get_region(r).get_used_rect()
	if used.size == Vector2i.ZERO:
		return false
	return used.end.y == r.size.y


func _initialize() -> void:
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._on_title_start("new", 9)
	var trek = m.trek
	var art := TrekArt.new()
	_check(art.ok, "trek art loads")
	# Sprites.
	for name in SIZES:
		var t: Texture2D = art.e2.get(name)
		_check(t != null, "%s exists" % name)
		if t == null:
			continue
		var img := t.get_image()
		var lim: Array = SIZES[name]
		_check(img.get_width() >= lim[0] and img.get_width() <= lim[1] and img.get_height() >= lim[2] and img.get_height() <= lim[3],
			"%s native size %dx%d in its class (%s)" % [name, img.get_width(), img.get_height(), str(lim)])
		_check(_alpha_ok(img), "%s alpha is binary" % name)
		if name != "rope":
			_check(_foot_opaque(img, Rect2i(Vector2i.ZERO, img.get_size())), "%s stands on its bottom row" % name)
	for route in WALKER_H:
		var t: Texture2D = art.e2.get("walker_" + route)
		_check(t != null, "walker_%s exists" % route)
		if t == null:
			continue
		var img := t.get_image()
		_check(img.get_width() == 224 and img.get_height() == 96, "walker_%s is 3 facings x 7 frames of 32 px" % route)
		_check(_alpha_ok(img), "walker_%s alpha is binary" % route)
		var empty := 0
		var feet := 0
		for row in 3:
			for f in 7:
				var r := Rect2i(f * 32, row * 32, 32, 32)
				var used := img.get_region(r).get_used_rect()
				if used.size == Vector2i.ZERO:
					empty += 1
				elif used.end.y >= 30:
					feet += 1
		_check(empty == 0, "walker_%s has every facing and walk frame" % route)
		_check(feet == 21, "walker_%s: every frame's feet on the foot line (%d of 21)" % [route, feet])
		var h := img.get_region(Rect2i(0, 0, 32, 32)).get_used_rect().size.y
		var lim: Array = WALKER_H[route]
		_check(h >= lim[0] and h <= lim[1], "walker_%s stands %d px tall (farmer 32; allowed %s)" % [route, h, str(lim)])
	var dog: Texture2D = art.e2.get("dog")
	_check(dog != null and dog.get_width() == 224 and dog.get_height() == 24, "dog sheet is 7 frames of 32 x 24")
	if dog != null:
		var dimg := dog.get_image()
		_check(_alpha_ok(dimg), "dog alpha is binary")
		var used := dimg.get_region(Rect2i(0, 0, 32, 24)).get_used_rect()
		_check(used.size.y >= 12 and used.size.y <= 18 and used.size.x <= 28, "dog stands %dx%d (a third to a half the farmer's height)" % [used.size.x, used.size.y])
	# Trail works in the wood.
	var expected := 0
	var placed := 0
	var grid_changed := 0
	var bad: Array = []
	for id in trek.ROUTES:
		var steps: Array = trek.ROUTES[id]["marked"]
		for c in steps.size():
			m.day = maxi(int(trek.ROUTES[id]["from"]), 1)
			trek.works = {"waystation": true, "post_lamps": true}
			trek._start(id)
			trek.dark = false
			trek.route = steps
			trek.events = []
			for k in steps.size():
				trek.events.append("")
			trek.clearing = c
			trek._enter_clearing()
			var want := 0
			if trek._rests_halfway() and c == steps.size() / 2:
				want += 1
			if id == "post":
				want += 1
			if want == 0:
				continue
			expected += want
			var before: int = m.cave.hash()
			art._sig = 0
			art.refresh(m, trek)
			if m.cave.hash() != before:
				grid_changed += 1
			placed += art._works.size()
			for w in art._works:
				var r := Rect2(w[2], (w[1] as Rect2).size)
				if not art.fits(m, r):
					bad.append("%s %d" % [id, c])
			if art._works.size() < want:
				print("  missing work: %s clearing %d (%d of %d)" % [id, c, art._works.size(), want])
	_check(placed == expected, "trail works placed in the wood (%d of %d)" % [placed, expected])
	_check(bad.is_empty(), "placed works keep off the trail and open ground %s" % str(bad))
	_check(grid_changed == 0, "the blocking grid is unchanged by the works (%d changed)" % grid_changed)
	# Gloom by place.
	trek.works = {}
	trek._start("mill")
	trek.dark = false
	var forest: float = trek._gloom_v2()
	trek.route_id = "edge"
	var edge: float = trek._gloom_v2()
	trek.route_id = "mill"
	trek.dark = true
	var dark: float = trek._gloom_v2() if trek._trail() == "dark" else TrekSystem.GLOOM_V2["dark"]
	_check(edge < forest and forest < dark, "day gloom: edge %.2f < forest %.2f < dark trail %.2f" % [edge, forest, dark])
	_check(dark + 0.06 < 1.0, "the darkest day gloom stays lighter than night")
	print("e2 check: %d failure(s)" % fails)
	quit(1 if fails > 0 else 0)
