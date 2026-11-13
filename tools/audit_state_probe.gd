extends SceneTree

# CCH-PLAYABLE-001: controlled probes of death, collapse and recovery. Each case starts a new game in slot 9 (run it
# in a throwaway profile), puts the farmer somewhere by the game's own functions (_enter_house, _enter_cave,
# trek._start), brings on the death or the 03:00 collapse the way the game does (empty needs, a foe's blow, the
# clock), lets the game run, and then checks the state a player is left in: which area the flags say, which area
# the farmer actually stands in, whether the farmer stands on open ground, and whether a held direction key
# still moves them. These are set-up states, not played ones; the findings say so.
#   godot --path . --headless --fixed-fps 60 -s tools/audit_state_probe.gd
# Prints one RESULT line per case and "state probe: N suspect".

var m: MainGame
var suspect := 0


func _initialize() -> void:
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func _new_game() -> void:
	if m != null:
		m.queue_free()
		await frames(3)
	TitleMenu.pending_name = "probe"
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await frames(3)
	m._on_title_start("new", 9)
	await frames(10)


func _key(k: int, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = k
	ev.keycode = k
	ev.pressed = down
	Input.parse_input_event(ev)


# Holds each direction in turn and reports the furthest the farmer got.
func _moved() -> float:
	var start: Vector2 = m.player.position
	var best := 0.0
	for k in [KEY_D, KEY_A, KEY_S, KEY_W]:
		_key(k, true)
		await frames(20)
		_key(k, false)
		await frames(2)
		best = maxf(best, m.player.position.distance_to(start))
	return best


func _wait_transition() -> void:
	await frames(5)
	var n := 0
	while m.transitioning and n < 60 * 90:
		await process_frame
		n += 1
	await frames(30)


func _report(name: String, expect_area: String) -> void:
	var t: Vector2i = m._player_tile()
	var area := "cave/trek map" if m.in_cave else ("house" if m.inside else "farm")
	var stands := "interior" if m._in_interior(t) else ("farm" if m._in_bounds(t) else "outside every map")
	var blocked: bool = m._is_blocked_world(m.player.position + Vector2(0, 8))
	var moved := await _moved()
	var bad: Array = []
	if area != expect_area:
		bad.append("expected to be on the %s" % expect_area)
	if not m.in_cave and ((m.inside and stands != "interior") or (not m.inside and stands != "farm")):
		bad.append("flags say %s but the farmer stands on %s tiles" % [area, stands])
	if blocked:
		bad.append("standing inside something solid")
	if moved < 8.0:
		bad.append("held direction keys moved the farmer %.0f px" % moved)
	if m.transitioning:
		bad.append("transition never ended")
	if m.trek.active and expect_area != "cave/trek map":
		bad.append("the trek is still active")
	if m.hp <= 0:
		bad.append("hp %d" % m.hp)
	var saved := SaveSystem.read_save(m._save_path())
	var save_note := "no save yet"
	if not saved.is_empty():
		save_note = "save: day %s inside=%s pos=%s" % [str(saved.get("day")), str(saved.get("inside")), str(saved.get("player_pos"))]
	if not bad.is_empty():
		suspect += 1
	print("RESULT %-28s %s | day %d %02d:00 area=%s tile=%s kind=%d hp=%d/%d food=%d water=%d sanity=%d/%d foes=%d trek=%s moved=%.0fpx | %s | msg=\"%s\"%s" % [
		name, "SUSPECT" if not bad.is_empty() else "ok", m.day, int(m.current_hour) % 24, area, t, m._kind_at(t), m.hp, m.max_hp(),
		int(m.food), int(m.water), int(m.sanity), int(m.sanity_sys._sanity_max()), m.foes.size(), m.trek.active, moved, save_note,
		str(m.message_label.text).substr(0, 110), ("  <<< " + "; ".join(bad)) if not bad.is_empty() else ""])


func _starve() -> void:
	m.food = 0.0
	m.hp = 1
	m.starve_timer = m.NEED_HARM_HOURS - 0.01
	await frames(90)


func _to_three() -> void:
	m.clock = m.DAY_LENGTH - 0.2
	await frames(30)
	await _wait_transition()


func _run() -> void:
	await frames(5)
	# --- Death by empty needs ---
	await _new_game()
	await _starve()
	await _report("starve on the farm", "farm")
	await _new_game()
	m._enter_house()
	await frames(10)
	await _starve()
	await _report("starve inside the house", "farm")
	# The Pause menu's Unstick button (its action calls _unstick), then waiting for 03:00, as a stuck player might.
	m._unstick()
	await frames(10)
	await _report("  ...after Unstick", "farm")
	await _to_three()
	await _report("  ...after waiting to 03:00", "farm")
	await _new_game()
	m._enter_cave()
	await frames(10)
	await _starve()
	await _report("starve in the cave", "farm")
	await _new_game()
	m.lantern_tier = 1
	m.trek._start("mill")
	await frames(20)
	await _starve()
	await _report("starve on a trek", "farm")
	# --- Death by a creature ---
	await _new_game()
	m._enter_cave()
	await frames(10)
	if m.foes.is_empty():
		print("note: the day-1 cave spawned no creatures; a blow could not be struck")
	else:
		m.hp = 1
		m.invuln = 0.0
		m.combat_sys._foe_attack(m.foes[0])
		await frames(60)
	await _report("killed by a cave creature", "farm")
	# After falling, the same day goes on: is the farmer fed, and does the next hour kill them again?
	await _new_game()
	m.food = 0.0
	m.water = 0.0
	m.hp = 1
	m.starve_timer = m.NEED_HARM_HOURS - 0.01
	await frames(60)
	var falls := 0
	var hp_low := m.hp
	var msg0: String = m.message_label.text
	for i in 60 * 60:
		await process_frame
		if m.message_label.text != msg0 and m.message_label.text.begins_with("You collapse"):
			falls += 1
		msg0 = m.message_label.text
		hp_low = mini(hp_low, m.hp)
	print("note: with food and water left at 0 after the first fall, one more real minute (3 game hours) brought %d more falls; lowest hp %d; food %d water %d" % [falls, hp_low, int(m.food), int(m.water)])
	# --- The 03:00 collapse ---
	await _new_game()
	await _to_three()
	await _report("03:00 on the farm", "farm")
	await _new_game()
	m._enter_house()
	await frames(10)
	await _to_three()
	await _report("03:00 inside the house", "farm")
	await _new_game()
	m._enter_cave()
	await frames(10)
	await _to_three()
	await _report("03:00 in the cave", "farm")
	if m.in_cave:
		# Can the player at least walk out? Stand on the exit tile as a player would.
		for y in m.cave.size():
			for x in m.cave[y].size():
				if m.cave[y][x] == m.Tile.CAVE_EXIT:
					m.player.position = m._tile_center(x, y)
		await frames(20)
		await _report("  ...then walking out", "farm")
	await _new_game()
	m.lantern_tier = 1
	m.trek._start("mill")
	await frames(20)
	await _to_three()
	await _report("03:00 on a trek", "farm")
	# --- A collapse save loaded again ---
	await _new_game()
	m._enter_cave()
	await frames(10)
	await _to_three()
	m.queue_free()
	await frames(3)
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await frames(3)
	m._on_title_start("load", 9)
	await frames(20)
	await _report("load of the cave-collapse save", "farm")
	SaveSystem.delete_save(m._save_path())
	print("state probe: %d suspect" % suspect)
	quit(suspect)
