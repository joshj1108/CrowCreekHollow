extends SceneTree

# CCH-CONSOLIDATED-003 Phase E: checks the cave creatures' PixelLab sheets and their attack-state behaviour.
# Run headless, from the project folder:
#   godot --path . --headless -s tools/creature_test.gd
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Cases:
#   - sheets: every kind (bat, lizard, snake) has every state (idle, move, alert, attack, hurt, death), each sheet is
#     CELL tall and CELL x its frame count wide, every frame holds the creature, the standing lizard and snake keep
#     their lowest pixel within 3 rows above FEET, and no pixel is a glowing eye (nothing near white, no saturated red);
#   - numbers: FOES (HP, speed, chase, damage, aggro, cooldown, XP, drop), the cave's seven creatures and the
#     combat timings are unchanged;
#   - attack state, per kind: a foe in reach with its cooldown spent strikes on that frame: the player loses exactly
#     the old damage, the cooldown restarts at FOES' value, and the attack animation starts on frame 0; it runs
#     through its frames in order inside ATTACK_T and never outlasts the cooldown; there is no second blow before
#     the cooldown ends and there is one after it; a blow turned aside by the guard still shows the strike and does
#     no damage; a strike during the farmer's safety shows too but does nothing;
#   - other states: a foe noticing you shows alert (and still chases at its old speed), a moving foe walks, a still
#     one idles, a hit shows the flinch inside the 0.2 s flash, a kill removes the foe at once (nothing can hit or be
#     hit by the body) and plays the fall, which is gone after DEATH_T + FADE_T and is never saved; leaving the cave
#     clears it; the lizard and snake face the way they last moved, the bat never flips;
#   - fallback: with the new sheets switched off the old SpriteCook sheets draw.
# Prints PASS or FAIL per case and a total; the exit code is the number of failures.

const SLOT := 9
const STEP := 1.0 / 60.0

var m: MainGame
var started := false
var failures := 0
var path := ""


func _initialize() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	path = TitleMenu.slot_path(SLOT)
	SaveSystem.delete_save(path)
	m._on_title_start("new", SLOT)
	m.set_process(false)
	m.player.set_process(false)
	_sheets()
	_numbers()
	m._enter_cave()
	m.set_process(false)
	for kind in CaveFoeArt.KINDS:
		_attack_state(kind)
	_other_states()
	_fallback()
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, "" if ok or detail == "" else "  (" + detail + ")"])


# --- Sheets -------------------------------------------------------------------------------------------------------

func _sheets() -> void:
	var c := CaveFoeArt.CELL
	for kind in CaveFoeArt.KINDS:
		var all_ok := true
		var detail := ""
		for state in CaveFoeArt.STATES:
			var name := "cave_foes/%s_%s" % [kind, state]
			if not FarmSprites.has(name):
				all_ok = false
				detail += "%s missing; " % name
				continue
			var img: Image = FarmSprites.tex(name).get_image()
			var n: int = CaveFoeArt.FRAMES[kind][state]
			if img.get_height() != c or img.get_width() != c * n:
				all_ok = false
				detail += "%s is %dx%d; " % [name, img.get_width(), img.get_height()]
				continue
			for f in n:
				var used := img.get_region(Rect2i(f * c, 0, c, c)).get_used_rect()
				if used.size.x < 6 or used.size.y < 2:
					all_ok = false
					detail += "%s frame %d empty; " % [name, f]
			var glow := _glowing(img)
			if glow != "":
				all_ok = false
				detail += "%s %s; " % [name, glow]
		_check("%s: six sheets, sized to their frames, every frame drawn, no glowing eyes" % kind, all_ok, detail)
	for kind in ["lizard", "snake"]:
		var img: Image = FarmSprites.tex("cave_foes/%s_idle" % kind).get_image()
		var bottoms: Array = []
		for f in CaveFoeArt.FRAMES[kind]["idle"]:
			var used := img.get_region(Rect2i(f * c, 0, c, c)).get_used_rect()
			bottoms.append(used.end.y - 1)
		# The lowest pixel is the feet, or in the lizard's first frame the tip of its curled tail, so allow 3 rows.
		_check("%s idle stays on the ground line in every frame" % kind,
			bottoms.all(func(b: int) -> bool: return b <= CaveFoeArt.FEET and b >= CaveFoeArt.FEET - 3), str(bottoms))
	# Anchors (Final Polish): in every state but the fall, the lizard and snake keep their lowest pixel on the ground
	# line (within 3 rows) and every creature keeps its horizontal centre within 4 art px of its idle's; no frame
	# changes its drawn size by more than half against the idle (the bat's tucked attack frame did).
	for kind in CaveFoeArt.KINDS:
		var idle_img: Image = FarmSprites.tex("cave_foes/%s_idle" % kind).get_image()
		var ref := idle_img.get_region(Rect2i(0, 0, c, c)).get_used_rect()
		var ref_px := _opaque(idle_img.get_region(Rect2i(0, 0, c, c)))
		var bad := ""
		for state in CaveFoeArt.STATES:
			if state == "death":
				continue
			var img: Image = FarmSprites.tex("cave_foes/%s_%s" % [kind, state]).get_image()
			for f in CaveFoeArt.FRAMES[kind][state]:
				var cell := img.get_region(Rect2i(f * c, 0, c, c))
				var used := cell.get_used_rect()
				var ratio := float(_opaque(cell)) / float(ref_px)
				if absf(used.get_center().x - ref.get_center().x) > 4.0:
					bad += "%s %d centre %.1f; " % [state, f, used.get_center().x]
				if kind != "bat" and (used.end.y - 1 > CaveFoeArt.FEET or used.end.y - 1 < CaveFoeArt.FEET - 3):
					bad += "%s %d bottom %d; " % [state, f, used.end.y - 1]
				if ratio < 0.75 or ratio > 1.5:
					bad += "%s %d size x%.2f; " % [state, f, ratio]
		_check("%s: anchors and drawn size steady across states" % kind, bad == "", bad)


func _opaque(img: Image) -> int:
	var n := 0
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.5:
				n += 1
	return n


func _glowing(img: Image) -> String:
	for y in img.get_height():
		for x in img.get_width():
			var px := img.get_pixel(x, y)
			if px.a < 0.5:
				continue
			if (px.r + px.g + px.b) / 3.0 > 0.75:
				return "near-white pixel at %d,%d" % [x, y]
			if px.r > px.g + 0.25 and px.r > px.b + 0.25 and px.r > 0.45:
				return "bright red pixel at %d,%d" % [x, y]
	return ""


# --- Numbers --------------------------------------------------------------------------------------------------------

func _numbers() -> void:
	var expect := {
		"bat": {"hp": 4, "speed": 40.0, "chase": 70.0, "dmg": 1, "aggro": 3.5, "cool": 0.9, "xp": 12, "drop": "fiber"},
		"lizard": {"hp": 8, "speed": 22.0, "chase": 44.0, "dmg": 2, "aggro": 3.0, "cool": 1.3, "xp": 18, "drop": "resin"},
		"snake": {"hp": 6, "speed": 30.0, "chase": 56.0, "dmg": 2, "aggro": 3.5, "cool": 1.1, "xp": 16, "drop": "fiber"},
	}
	var ok := true
	for kind in expect:
		for k in expect[kind]:
			if m.FOES[kind][k] != expect[kind][k]:
				ok = false
	_check("FOES numbers unchanged", ok)
	_check("seven cave creatures (3 bats, 2 lizards, 2 snakes)", m.CAVE_CREATURES == ["bat", "bat", "bat", "lizard", "lizard", "snake", "snake"])
	_check("combat timings unchanged", is_equal_approx(m.INVULN_TIME, 0.9) and is_equal_approx(m.SWING_COOLDOWN, 0.5) and is_equal_approx(m.SWING_REACH, 1.5) and is_equal_approx(m.SWING_TIME, 0.3))
	_check("the strike shows inside the shortest cooldown", CaveFoeArt.ATTACK_T < 0.9 and CaveFoeArt.HURT_T == 0.2)


# --- Attack state ---------------------------------------------------------------------------------------------------

# One foe beside the player (in reach), nothing else in the cave.
func _setup(kind: String) -> Dictionary:
	m.foes = []
	m.combat_sys.dying = []
	m.invuln = 0.0
	m.blocking = false
	m.hp = m.max_hp()
	m.player.facing = Vector2.RIGHT
	var foe: Dictionary = m.combat_sys._new_foe(kind, Vector2i.ZERO)
	foe["pos"] = m.player.position + Vector2(m.PX * 0.4, 0)
	foe["home"] = foe["pos"]
	foe["noticed"] = true
	m.foes.append(foe)
	return foe


func _step(n := 1) -> void:
	for i in n:
		m.combat_sys._update_foes(STEP)


func _keep_in_reach(foe: Dictionary) -> void:
	foe["pos"] = m.player.position + Vector2(m.PX * 0.4, 0)


func _attack_state(kind: String) -> void:
	var st: Dictionary = m.FOES[kind]
	var foe := _setup(kind)
	var hp0: int = m.hp
	_step()
	var want := maxi(1, int(st["dmg"]) - m._defense())
	_check("%s: strikes when in reach with its cooldown spent" % kind, m.hp == hp0 - want, "hp %d -> %d, want -%d" % [hp0, m.hp, want])
	_check("%s: the cooldown restarts at its old value" % kind, is_equal_approx(float(foe["cool"]), float(st["cool"])))
	var pick: Array = CaveFoeArt.pick(foe, 0.0)
	_check("%s: the attack animation starts on frame 0 the moment it strikes" % kind, pick[0] == "attack" and pick[1] == 0, str(pick))
	# Through the strike: frames in order, all inside ATTACK_T, then back to the loop. The player's safety stops a
	# second blow from landing, so hp only changes by the first.
	var frames: Array = [0]
	var t := 0.0
	var states_seen := {}
	while t < float(st["cool"]) - STEP * 2:
		_keep_in_reach(foe)
		_step()
		t += STEP
		var pk: Array = CaveFoeArt.pick(foe, t)
		states_seen[pk[0]] = true
		if pk[0] == "attack":
			frames.append(pk[1])
	var ordered := true
	for i in range(1, frames.size()):
		if frames[i] < frames[i - 1]:
			ordered = false
	_check("%s: the strike plays every frame in order" % kind, ordered and frames.has(CaveFoeArt.FRAMES[kind]["attack"] - 1), str(frames))
	_check("%s: the strike ends inside ATTACK_T, before the next blow" % kind,
		frames.size() * STEP <= CaveFoeArt.ATTACK_T + STEP * 2 and states_seen.size() >= 2, "%d frames" % frames.size())
	_check("%s: no second blow before the cooldown ends" % kind, m.hp == hp0 - want)
	# After the cooldown (and the player's safety) the next blow lands and the strike starts over, one cooldown after
	# the first (counted from the first, so the time already stepped counts).
	m.invuln = 0.0
	var hp1: int = m.hp
	var n := 0
	while m.hp == hp1 and n < 300:
		_keep_in_reach(foe)
		_step()
		n += 1
	var gap := t + n * STEP
	_check("%s: the next blow lands once the cooldown is spent, with the strike again" % kind,
		m.hp == hp0 - want * 2 and CaveFoeArt.pick(foe, 0.0) == ["attack", 0] and absf(gap - float(st["cool"])) <= STEP * 2,
		"hp %d (from %d), after %.3f s" % [m.hp, hp0, gap])
	# A guarded blow from the front: no damage, the strike still shows.
	foe = _setup(kind)
	m.blocking = true
	hp0 = m.hp
	_step()
	_check("%s: a blow turned aside by the guard still shows the strike, no damage" % kind,
		m.hp == hp0 and CaveFoeArt.pick(foe, 0.0)[0] == "attack" and m.invuln > 0.0)
	m.blocking = false
	# During the farmer's safety: the cooldown restarts as before, the strike shows, nothing lands.
	foe = _setup(kind)
	m.invuln = 0.5
	hp0 = m.hp
	_step()
	_check("%s: a strike during the farmer's safety shows but does nothing" % kind,
		m.hp == hp0 and is_equal_approx(float(foe["cool"]), float(st["cool"])) and CaveFoeArt.pick(foe, 0.0)[0] == "attack")


# --- Other states ---------------------------------------------------------------------------------------------------

func _other_states() -> void:
	for kind in CaveFoeArt.KINDS:
		var st: Dictionary = m.FOES[kind]
		# Alert: a foe that hasn't noticed you, within aggro but out of reach.
		var foe := _setup(kind)
		foe["noticed"] = false
		foe["pos"] = m.player.position + Vector2(m.PX * 2.0, 0)
		var before: Vector2 = foe["pos"]
		_step()
		var moved: float = before.distance_to(foe["pos"])
		_check("%s: noticing you shows alert" % kind, CaveFoeArt.pick(foe, 0.0)[0] == "alert")
		_check("%s: still chases at its old speed" % kind, absf(moved - float(st["chase"]) * STEP) < 0.01, "%.3f" % moved)
		_step(int(CaveFoeArt.ALERT_T / STEP) + 2)
		_check("%s: after the alert it moves" % kind, CaveFoeArt.pick(foe, 0.0)[0] == "move")
		foe["moving"] = false
		_check("%s: a still foe idles" % kind, CaveFoeArt.pick(foe, 0.0)[0] == "idle")
		# Facing.
		_check("%s: %s" % [kind, "flips to face left" if kind != "bat" else "never flips"], CaveFoeArt.flips(kind) == (kind != "bat"))
		# Hurt: a swing that doesn't kill.
		foe = _setup(kind)
		foe["hp"] = 99
		m.equipment["hand_r"] = "sharpened_stick"
		m.active_slot = 0
		m.swing_cool = 0.0
		m._tool_press = true
		m._swing()
		m._tool_press = false
		_to_contact()
		var pk: Array = CaveFoeArt.pick(foe, 0.0)
		_check("%s: a hit shows the flinch at once, with the flash" % kind, pk[0] == "hurt" and pk[1] == 0 and float(foe["flash"]) > 0.0)
		_step(int(CaveFoeArt.HURT_T / STEP) + 1)
		_check("%s: the flinch ends with the flash" % kind, CaveFoeArt.pick(foe, 0.0)[0] != "hurt")
		# Death.
		foe = _setup(kind)
		foe["hp"] = 1
		m.swing_cool = 0.0
		m._tool_press = true
		m._swing()
		m._tool_press = false
		_to_contact()
		_check("%s: a kill removes the foe at once" % kind, not m.foes.has(foe) and m.foes.is_empty())
		_check("%s: the body falls (death sheet)" % kind, m.combat_sys.dying.size() == 1 and m.combat_sys.dying[0]["kind"] == kind)
		var hp0: int = m.hp
		_step(int((CaveFoeArt.DEATH_T + CaveFoeArt.FADE_T) / STEP) + 2)
		_check("%s: the body hits nothing and is gone after the fade" % kind, m.combat_sys.dying.is_empty() and m.hp == hp0)
	# Saving and leaving.
	var foe2 := _setup("bat")
	foe2["hp"] = 1
	m.swing_cool = 0.0
	m._tool_press = true
	m._swing()
	m._tool_press = false
	_to_contact()
	m.saver._save_game()
	var data := SaveSystem.read_save(path)
	var text := JSON.stringify(data)
	_check("nothing about creatures or bodies is saved", not text.contains("\"dying\"") and not text.contains("atk_t") and not text.contains("alert_t"))
	m.in_cave = false
	m.combat_sys._update_foes(STEP)
	_check("leaving the cave clears the bodies", m.combat_sys.dying.is_empty())
	m.in_cave = true


# Plays the farmer's swing up to its contact frame, where the hit lands (Final Polish: no longer on the press).
func _to_contact() -> void:
	var guard := 0
	while m.swing_pending and guard < 60:
		m.player._advance_anim(STEP)
		guard += 1


func _fallback() -> void:
	CaveFoeArt.enabled = false
	_check("with the new sheets off, the old sheets draw", not CaveFoeArt.has_art("bat") and FarmSprites.has("foe_bat") and m.FOE_ANIMATED.has("bat"))
	CaveFoeArt.enabled = true
	_check("the trek dog keeps its own drawing", not CaveFoeArt.has_art("dog"))
