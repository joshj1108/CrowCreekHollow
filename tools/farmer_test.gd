extends SceneTree

# CCH-CONSOLIDATED-003 Phase D: checks the farmer's PixelLab sheets and every animation state.
# Run headless, from the project folder:
#   godot --path . --headless -s tools/farmer_test.gd
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Cases:
#   - sheets: every sheet FarmerFrames lists loads, is CELL tall and CELL x its frame count wide, every frame has the
#     figure in it, the walk and idle keep their boots on FEET and their heads steady, and the old SpriteCook sheets
#     are not used;
#   - states: every state (idle, walk, each tool action and loop, each weapon's attack and guard, the flinch, the
#     gather, with and without the lantern) in every facing picks an existing sheet and a frame inside it, left
#     mirrors right, and nothing is left over once each ends (no stuck state);
#   - lantern: lit and idle or walking, it is in the hand (the carrying sheets) and the light sits on its flame; a
#     tool or a weapon puts it on the belt within LAMP_SWAP while the action's own frame shows at once; it comes
#     back to the hand after; unlit, nothing is drawn and the light stays off; main's light follows the lantern;
#   - combat: the swing shows its contact frame at STRIKE_AT of SWING_TIME and the hit event fires on that frame (a real
#     foe loses HP, flashes and flinches only then, never on the press; cooldown unchanged), it never steps back;
#     the guard is down while a swing plays and back up after it; the guard rises
#     in BLOCK_RAISE and holds, a blow from the front is still turned aside (same safety, no damage) and jolts the
#     guard, one from behind still lands and starts the flinch, and the combat and movement numbers are unchanged.
# Prints PASS or FAIL per case and a total; the exit code is the number of failures.

const SLOT := 9
const FACINGS := {"down": Vector2.DOWN, "up": Vector2.UP, "right": Vector2.RIGHT, "left": Vector2.LEFT}

var m: MainGame
var p
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
	p = m.player
	p.set_process(false)
	_sheets()
	_states()
	_lantern()
	_combat()
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, "" if ok or detail == "" else "  (" + detail + ")"])


func _reset() -> void:
	p.act = ""
	p.act_t = 0.0
	p.loop_kind = ""
	p.hold_loop = ""
	p.blocking = false
	p.held = ""
	p.held_item = ""
	p.hurt_t = 0.0
	p.guard_t = 0.0
	p.block_t = 0.0
	p.moving = false
	p.lantern_on = false
	p.lamp_hand = 1.0


func _step(seconds: float) -> void:
	var t := 0.0
	while t < seconds - 0.0001:
		var dt := minf(1.0 / 60.0, seconds - t)
		p._advance_anim(dt)
		t += dt


# The rows of a frame that hold any pixel: [top, bottom], or [] for an empty frame. With body, only the body's
# middle columns count (a carried lantern may swing lower, toward the camera).
func _rows(img: Image, frame: int, body := false) -> Array:
	var c: int = FarmerFrames.CELL
	var top := -1
	var bottom := -1
	for y in c:
		for x in (range(c / 2 - 10, c / 2 + 10) if body else range(c)):
			if img.get_pixel(frame * c + x, y).a > 0.5:
				if top < 0:
					top = y
				bottom = y
				break
	return [] if top < 0 else [top, bottom]


func _sheets() -> void:
	_check("sheets: the farmer uses the PixelLab sheets", not p.sheets.is_empty(), "art/player/d missing")
	if p.sheets.is_empty():
		return
	var bad := []
	var empty := []
	var feet := []
	var heads := []
	for key in FarmerFrames.FRAMES:
		var tex: Texture2D = p.sheets.get(key)
		var n: int = FarmerFrames.FRAMES[key]
		if tex == null or tex.get_width() != FarmerFrames.CELL * n or tex.get_height() != FarmerFrames.CELL:
			bad.append(key)
			continue
		var img := tex.get_image()
		if img.is_compressed():
			img.decompress()
		var tops := []
		for f in n:
			var r := _rows(img, f)
			if r.is_empty():
				empty.append("%s:%d" % [key, f])
				continue
			tops.append(r[0])
			var legs := _rows(img, f, true)
			if (key.begins_with("walk") or key.begins_with("idle")) and (legs.is_empty() or absi(int(legs[1]) - FarmerFrames.FEET) > 1):
				feet.append("%s:%d bottom %s" % [key, f, legs])
		if (key.begins_with("walk") or key.begins_with("idle")) and not tops.is_empty() and int(tops.max()) - int(tops.min()) > 3:
			heads.append("%s %d..%d" % [key, tops.min(), tops.max()])
	_check("sheets: %d sheets load at CELL x frames" % FarmerFrames.FRAMES.size(), bad.is_empty(), str(bad))
	_check("sheets: no empty frame", empty.is_empty(), str(empty.slice(0, 6)))
	_check("sheets: walk and idle boots on FEET in every frame", feet.is_empty(), str(feet.slice(0, 6)))
	_check("sheets: walk and idle heads steady (within 3 art px)", heads.is_empty(), str(heads))
	var old := false
	for key in p.sheets:
		if str((p.sheets[key] as Texture2D).resource_path).contains("farmer_"):
			old = true
	_check("sheets: no old SpriteCook frame is loaded", not old)
	_check("sheets: the belt lantern loads", p.lamp_tex != null)


# Every state in every facing names a sheet that exists and a frame inside it.
func _states() -> void:
	var missing := []
	var setups := {
		"idle": func() -> void: pass,
		"walk": func() -> void: p.moving = true,
		"idle_lantern": func() -> void: p.lantern_on = true,
		"walk_lantern": func() -> void:
			p.lantern_on = true
			p.moving = true,
		"hurt": func() -> void: p.hurt(),
		"fish": func() -> void: p.set_loop("fish"),
		"chop_loop": func() -> void: p.set_loop("chop"),
		"mine_loop": func() -> void: p.set_loop("mine"),
	}
	for a in ["chop", "mine", "hoe", "plant", "water", "cast", "gather"]:
		setups["act_" + a] = func() -> void: p.play_act(a, 0.6)
	for w in p.WEAPON_SHEET:
		setups["swing_" + w] = func() -> void:
			p.held = "sword"
			p.held_item = w
			p.play_act("swing", m.SWING_TIME)
		setups["block_" + w] = func() -> void:
			p.held = "sword"
			p.held_item = w
			p.blocking = true
	for name in setups:
		for fname in FACINGS:
			for t in [0.0, 0.05, 0.15, 0.29, 0.45, 0.59, 1.3]:
				_reset()
				p.facing = FACINGS[fname]
				(setups[name] as Callable).call()
				_step(t)
				var sf: Array = p._sheet_frame()
				var key: String = sf[0]
				if not FarmerFrames.FRAMES.has(key) or int(sf[1]) < 0 or int(sf[1]) >= int(FarmerFrames.FRAMES[key]):
					missing.append("%s %s t=%.2f -> %s:%d" % [name, fname, t, key, sf[1]])
	_check("states: every state and facing has its sheet and frame", missing.is_empty(), str(missing.slice(0, 6)))
	# Left mirrors right: the same sheet and frame, the lantern's x mirrored.
	_reset()
	p.lantern_on = true
	p.moving = true
	p.walk_t = 1.3
	p.facing = Vector2.RIGHT
	var r: Array = p._sheet_frame()
	var off_r: Vector2 = p.lantern_offset()
	p.facing = Vector2.LEFT
	var l: Array = p._sheet_frame()
	var off_l: Vector2 = p.lantern_offset()
	_check("states: facing left mirrors the right-facing sheets", r == l and is_equal_approx(off_l.x, -off_r.x) and is_equal_approx(off_l.y, off_r.y), "%s %s %s %s" % [r, l, off_r, off_l])
	# Nothing sticks: a one-shot ends after its time, a flinch and a guard's jolt fade, a loop stops when cleared.
	var stuck := []
	for a in ["chop", "hoe", "plant", "water", "cast", "gather", "swing"]:
		_reset()
		p.held = "sword"
		p.held_item = "iron_sword"
		p.play_act(a, 0.5)
		_step(0.55)
		if p._kind() != "idle":
			stuck.append(a)
	_reset()
	p.hurt()
	_step(p.HURT_TIME + 0.05)
	if p._kind() != "idle":
		stuck.append("hurt")
	_reset()
	p.set_loop("chop")
	_step(1.0)
	p.set_loop("")
	if p._kind() != "idle":
		stuck.append("loop")
	_reset()
	p.held = "sword"
	p.held_item = "iron_sword"
	p.blocking = true
	_step(0.3)
	p.blocking = false
	_step(0.02)
	if p._kind() != "idle" or p.block_t != 0.0:
		stuck.append("block")
	_check("states: every action ends back at idle", stuck.is_empty(), str(stuck))
	# Interruptions: a tool or a swing during the flinch shows at once and clears it; the flinch shows over a guard.
	_reset()
	p.hurt()
	_step(0.05)
	p.held = "sword"
	p.held_item = "iron_sword"
	p.play_act("swing", m.SWING_TIME)
	var swing_now: String = p._sheet_frame()[0]
	_check("states: a swing during the flinch shows at once", swing_now.begins_with("attack_sword") and p.hurt_t == 0.0, swing_now)
	_reset()
	p.held = "sword"
	p.held_item = "iron_sword"
	p.blocking = true
	_step(0.2)
	p.hurt()
	_check("states: a blow that lands through the guard shows the flinch", str(p._sheet_frame()[0]).begins_with("hurt_"))
	_step(p.HURT_TIME + 0.02)
	_check("states: the guard is back after the flinch while still held", str(p._sheet_frame()[0]).begins_with("block_sword"))


func _lantern() -> void:
	for fname in ["down", "up", "right"]:
		_reset()
		p.facing = FACINGS[fname]
		p.lantern_on = true
		var sf: Array = p._sheet_frame()
		var hand: Vector2 = p.lantern_offset()
		var flame: Vector2 = p._cell_to_local(FarmerFrames.LANTERN[sf[0]][sf[1]])
		_check("lantern %s: idle carries it in the hand (%s)" % [fname, sf[0]], str(sf[0]).begins_with("idle_lantern") and hand == flame)
		p.moving = true
		_step(0.2)
		sf = p._sheet_frame()
		_check("lantern %s: walking carries it in the hand (%s)" % [fname, sf[0]], str(sf[0]).begins_with("walk_lantern"))
		p.moving = false
		p.play_act("chop", 0.6)
		var first: String = p._sheet_frame()[0]
		_check("lantern %s: a tool shows its own frame at once (not delayed)" % fname, first.begins_with("chop_"), first)
		_step(p.LAMP_SWAP + 0.02)
		var belt: Vector2 = p._cell_to_local(p._lamp_cell(p._sheet_frame()[0], p._sheet_frame()[1]))
		var drops: Array = FarmerFrames.BELT_DROP.get(p._sheet_frame()[0], [])
		var expect: Vector2 = p.BELT_LAMP[p._sheet_dir()] + Vector2(0, float(drops[p._sheet_frame()[1]]) if not drops.is_empty() else 0.0)
		_check("lantern %s: on the belt within LAMP_SWAP during a tool" % fname, p.lamp_hand == 0.0 and p.lantern_offset() == p._cell_to_local(expect) and belt == p.lantern_offset())
		_step(0.6)
		_step(p.LAMP_SWAP + 0.02)
		_check("lantern %s: back in the hand after" % fname, p.lamp_hand == 1.0 and str(p._sheet_frame()[0]).begins_with("idle_lantern"))
		p.held = "sword"
		p.held_item = "iron_sword"
		p.blocking = true
		_step(p.LAMP_SWAP + 0.02)
		_check("lantern %s: on the belt while guarding" % fname, p.lamp_hand == 0.0 and str(p._sheet_frame()[0]).begins_with("block_"))
		p.blocking = false
		p.play_act("swing", m.SWING_TIME)
		_step(0.05)
		_check("lantern %s: going to the belt for a swing" % fname, p.lamp_hand < 1.0 and str(p._sheet_frame()[0]).begins_with("attack_"))
	# Unlit: nothing drawn, plain sheets.
	_reset()
	p.lantern_on = false
	_check("lantern: unlit, the plain idle (no lantern drawn)", str(p._sheet_frame()[0]).begins_with("idle_") and not str(p._sheet_frame()[0]).contains("lantern"))
	# main's light follows the lantern, keeps its tier's radius, and stays off by day.
	m.lantern_tier = 2
	m._apply_lantern_radius()
	m.trek.active = false
	_reset()
	p.facing = Vector2.DOWN
	m._update_lantern(1.0)
	_check("lantern: lit in the dark, the farmer shows it", p.lantern_on and m.lantern_light.enabled)
	_check("lantern: the light sits on the lantern's flame", m.lantern_light.position.distance_to(p.lantern_offset()) < 0.01 if m.LANTERN_SMOOTH else m.lantern_light.position.distance_to(p.lantern_offset()) <= m.PX, "%s vs %s" % [m.lantern_light.position, p.lantern_offset()])
	var scale_before: float = m.lantern_light.texture_scale
	p.play_act("chop", 0.6)
	_step(0.2)
	m._update_lantern(1.0)
	_check("lantern: the light follows it to the belt", m.lantern_light.position.distance_to(p.lantern_offset()) < 0.01 if m.LANTERN_SMOOTH else true)
	_check("lantern: radius unchanged by where it hangs", m.lantern_light.texture_scale == scale_before)
	m._update_lantern(0.0)
	_check("lantern: by day it is off and not shown", not p.lantern_on and not m.lantern_light.enabled)


# Lantern swaps (Final Polish): through a swing, a hoe, the guard, watering and a chop, and back to idle, in every
# facing, the lantern (and the light on its flame) never moves more than 3.5 art px in one 60 Hz frame: no teleport
# between hand and belt, and it is always somewhere (never a frame without it).
func _lamp_swaps() -> void:
	var bad := ""
	for fname in FACINGS:
		for seq in [["act", "swing", 0.3], ["act", "hoe", 0.4], ["block", "", 0.5], ["act", "water", 0.5], ["loop", "chop", 1.4]]:
			_reset()
			p.facing = FACINGS[fname]
			p.lantern_on = true
			p.held = "sword"
			p.held_item = "iron_sword"
			p.lamp_hand = 1.0
			_step(0.5)
			var prev: Vector2 = p.lantern_offset()
			if seq[0] == "act":
				p.play_act(seq[1], seq[2])
			elif seq[0] == "block":
				p.blocking = true
			else:
				p.set_loop(seq[1])
			var t := 0.0
			while t < float(seq[2]) + 0.4:
				if t >= float(seq[2]):
					p.blocking = false
					p.loop_kind = ""
				p._advance_anim(1.0 / 60.0)
				t += 1.0 / 60.0
				var o: Vector2 = p.lantern_offset()
				if o.distance_to(prev) / p.ART_SCALE > 3.5:
					bad += "%s %s %.2fs %.1f; " % [fname, seq[1], t, o.distance_to(prev) / p.ART_SCALE]
				prev = o
	p.lantern_on = false
	_check("lantern: hand and belt swaps move smoothly (<= 3.5 art px a frame) in every facing", bad == "", bad)


# A real swing at a lizard: nothing on the press; the HP, the flash and the flinch all come on the contact frame.
func _swing_sync() -> void:
	_reset()
	m._enter_cave()
	m.set_process(false)
	m.foes = []
	p.facing = Vector2.DOWN
	m.active_slot = 0
	m.equipment["hand_r"] = "iron_sword"
	p.held = "sword"
	p.held_item = "iron_sword"
	var foe: Dictionary = m.combat_sys._new_foe("lizard", Vector2i.ZERO)
	foe["pos"] = p.position + Vector2.DOWN * m.PX
	foe["hp"] = 99
	m.foes.append(foe)
	m.swing_cool = 0.0
	m._tool_press = true
	m._swing()
	m._tool_press = false
	_check("sync: the press starts the swing and its cooldown, the foe is untouched", p.act == "swing" and m.swing_cool == m.SWING_COOLDOWN and int(foe["hp"]) == 99 and float(foe["flash"]) == 0.0 and m.swing_pending)
	var t := 0.0
	while m.swing_pending and t < 1.0:
		p._advance_anim(1.0 / 60.0)
		t += 1.0 / 60.0
	var key: String = p._sheet_frame()[0]
	var strike: int = p.STRIKE_FRAME["sword_south"]
	_check("sync: the hit lands at %.3f s, on the contact frame %d" % [t, p._sheet_frame()[1]], int(foe["hp"]) < 99 and float(foe["flash"]) > 0.0 and absf(t - p.STRIKE_AT * m.SWING_TIME) <= 1.0 / 60.0 + 0.001 and p._sheet_frame()[1] == strike and key == "attack_sword_south")
	_check("sync: the foe flinches with it", CaveFoeArt.pick(foe, 0.0)[0] == "hurt")
	# Out of reach at contact: nothing, and the swing still finishes on time.
	foe["hp"] = 99
	foe["flash"] = 0.0
	foe["pos"] = p.position + Vector2.DOWN * m.PX * 3.0
	m.swing_cool = 0.0
	m._tool_press = true
	m._swing()
	m._tool_press = false
	_step(m.SWING_TIME + 0.02)
	_check("sync: a miss does nothing and the swing ends after SWING_TIME", int(foe["hp"]) == 99 and p.act == "" and not m.swing_pending)
	# The guard and the swing: held block drops while the swing plays and comes back up after.
	Input.action_press("block")
	m.swing_cool = 0.0
	m._tool_press = true
	m._swing()
	m._tool_press = false
	var down_mid := not m._guard_up()
	_step(m.SWING_TIME + 0.02)
	_check("sync: the guard is down during the swing and up again after it", down_mid and m._guard_up())
	Input.action_release("block")
	m.foes = []
	m.in_cave = false


func _combat() -> void:
	# The swing: frame 0 at the press, the strike frame by STRIKE_AT, never stepping back, the last at the end.
	for w in p.WEAPON_SHEET:
		for fname in ["down", "up", "right"]:
			_reset()
			p.facing = FACINGS[fname]
			p.held = "sword"
			p.held_item = w
			p.play_act("swing", m.SWING_TIME)
			var key: String = p._sheet_frame()[0]
			var n: int = FarmerFrames.FRAMES[key]
			var strike: int = mini(p.STRIKE_FRAME["%s_%s" % [p.WEAPON_SHEET[w], p._sheet_dir()]], n - 1)
			var frames := []
			var strike_at := -1.0
			var event_at := [-1.0]
			var t := 0.0
			var clock := [0.0]
			var on_struck := func(k: String) -> void:
				if k == "swing" and event_at[0] < 0.0:
					event_at[0] = clock[0]
			p.struck.connect(on_struck)
			while p.act != "":
				var f: int = p._sheet_frame()[1]
				frames.append(f)
				if f >= strike and strike_at < 0.0:
					strike_at = t
				p._advance_anim(1.0 / 60.0)
				t += 1.0 / 60.0
				clock[0] = t
			p.struck.disconnect(on_struck)
			# The contact frame is first drawn on the step the hit event fires (one 60 Hz frame apart at most).
			_check("attack %s %s: hit event on the contact frame (event %.3f s, frame %.3f s)" % [w, fname, event_at[0], strike_at], event_at[0] >= 0.0 and absf(event_at[0] + 1.0 / 60.0 - strike_at) <= 1.0 / 60.0 + 0.001 and absf(strike_at - p.STRIKE_AT * m.SWING_TIME) <= 1.0 / 60.0 + 0.001)
			var mono := true
			for i in range(1, frames.size()):
				if frames[i] < frames[i - 1]:
					mono = false
			_check("attack %s %s: strike frame by %.2f s (at %.3f), in order, all %d frames" % [w, fname, p.STRIKE_AT * m.SWING_TIME, strike_at, n], frames[0] == 0 and strike_at >= 0.0 and strike_at <= p.STRIKE_AT * m.SWING_TIME + 0.02 and strike_at <= 0.2 and mono and frames.max() == n - 1, str(frames))
	_swing_sync()
	_lamp_swaps()
	# The guard: up within BLOCK_RAISE, then held.
	_reset()
	p.held = "sword"
	p.held_item = "iron_sword"
	p.blocking = true
	_step(p.BLOCK_RAISE + 0.02)
	var raised: Array = p._sheet_frame()
	_step(1.0)
	_check("block: raised within BLOCK_RAISE and held", raised[1] == FarmerFrames.FRAMES[raised[0]] - 1 and p._sheet_frame() == raised, str(raised))
	# Real blows through CombatSystem: a guarded blow from the front is turned aside, one from behind lands.
	m.active_slot = 0
	m.equipment["hand_r"] = "iron_sword"
	m.blocking = true
	p.blocking = true
	p.facing = Vector2.DOWN
	m.hp = m.max_hp()
	m.invuln = 0.0
	var foe: Dictionary = m.combat_sys._new_foe("lizard", Vector2i.ZERO)
	foe["pos"] = p.position + Vector2.DOWN * m.PX
	m.combat_sys._foe_attack(foe)
	_check("block: a blow from the front does no harm and gives half the safety", m.hp == m.max_hp() and is_equal_approx(m.invuln, m.INVULN_TIME * 0.5))
	_check("block: the guard jolts", p.guard_t > 0.0 and str(p._sheet_frame()[0]).begins_with("block_"))
	m.invuln = 0.0
	foe["pos"] = p.position + Vector2.UP * m.PX
	m.combat_sys._foe_attack(foe)
	_check("block: a blow from behind still lands and the farmer flinches", m.hp < m.max_hp() and is_equal_approx(m.invuln, m.INVULN_TIME) and p.hurt_t > 0.0)
	m.blocking = false
	# The numbers the animations must not change.
	_check("numbers: swing 0.3 s, cooldown 0.5 s, reach 1.5 tiles", m.SWING_TIME == 0.3 and m.SWING_COOLDOWN == 0.5 and m.SWING_REACH == 1.5)
	_check("numbers: 0.9 s of safety after a hit", m.INVULN_TIME == 0.9)
	_check("numbers: walking speed and the feet's box", p.SPEED == 180.0 and p.CORNERS == [Vector2(-15, -6), Vector2(15, -6), Vector2(-15, 6), Vector2(15, 6)] and p.FEET_OFFSET == Vector2(0, 8))
	_check("numbers: the farmer's feet stay where props sort against them", is_equal_approx(p.ground_y() - p.position.y, 18.0))
