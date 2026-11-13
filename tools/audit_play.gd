extends SceneTree

# CCH-PLAYABLE-001: plays the real game from the title menu with injected input only, as a player would press it.
# Every action is a key, mouse button or Xbox button/axis event (Input.parse_input_event); the bot never calls a
# game function to do something. It reads game state only to steer (where the farmer is, what tile is where),
# to log what the game tells the player (every message line, with the day and hour) and to note results.
# It is NOT a human player: discoverability is judged from its screenshots and message log, not from the bot.
# Run windowed (it needs a renderer), in a throwaway profile so the owner's saves are never opened:
#   APPDATA=<scratch> godot --path . --fixed-fps 60 --disable-vsync -s tools/audit_play.gd -- scenario=week dev=kbm
# Options after "--":
#   scenario=NAME   start (title to the first minute), week (the first seven days), or a probe scenario (see _run)
#   dev=kbm|pad     keyboard and mouse (default), or an Xbox controller (buttons, sticks and triggers)
#   out=DIR         where the log and screenshots go (default art/style_tests/CCH-PLAYABLE-001/play_<dev>)
#   size=WxH        window size (default 1280x720)
#   days=N          for week: how many days to play (default 7)
# The log is <out>/log.txt: "MSG" lines are the game's own messages, "ACT" what the bot pressed for, "OBS" state
# it read, "PROBLEM" anything that did not work as the on-screen instructions said.

const DIRS := {"up": Vector2i(0, -1), "down": Vector2i(0, 1), "left": Vector2i(-1, 0), "right": Vector2i(1, 0)}
const KEYS := {"up": KEY_W, "down": KEY_S, "left": KEY_A, "right": KEY_D}
const PADS := {"up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN, "left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT}

var m: MainGame
var opt := {"scenario": "start", "dev": "kbm", "out": "", "size": "1280x720", "days": "7"}
var pad := false
var logf: FileAccess
var last_msg := ""
var held := {}
var shots := 0
var problems := 0
var last_card := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := str(a).split("=")
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	pad = opt["dev"] == "pad"
	if opt["out"] == "":
		opt["out"] = "art/style_tests/CCH-PLAYABLE-001/play_%s" % opt["dev"]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + opt["out"]))
	logf = FileAccess.open("res://" + opt["out"] + "/log_%s.txt" % opt["scenario"], FileAccess.WRITE)
	var win: PackedStringArray = str(opt["size"]).split("x")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)
	process_frame.connect(_poll)
	_main.call_deferred()


func _main() -> void:
	await frames(40)
	_isolate_hardware()
	await call("_sc_" + str(opt["scenario"]))
	note("END", "problems=%d shots=%d" % [problems, shots])
	logf.close()
	quit()


# --- Logging ----------------------------------------------------------------------------------------

func stamp() -> String:
	if m == null or not m.world_started:
		return "[title]"
	var h := float(m.current_hour)
	return "[D%d %02d:%02d]" % [m.day, int(h) % 24, int(fmod(h, 1.0) * 60.0)]


func note(kind: String, text: String) -> void:
	var line := "%s %s: %s" % [stamp(), kind, text]
	logf.store_line(line)
	logf.flush()
	if kind == "PROBLEM":
		problems += 1
		print(line)


func _poll() -> void:
	if m == null or not m.world_started or m.message_label == null:
		return
	var t: String = m.message_label.text
	if t != last_msg:
		last_msg = t
		if t != "":
			note("MSG", t)
	if m.card_label != null and m.card_label.text != last_card:
		last_card = m.card_label.text
		if last_card != "":
			note("CARD", last_card)


func frames(n: int) -> void:
	for i in n:
		await process_frame


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.resize(img.get_width() / 2, img.get_height() / 2, Image.INTERPOLATE_NEAREST)
	shots += 1
	var path := "%s/%02d_%s.png" % [opt["out"], shots, name]
	img.save_png("res://" + path)
	note("SHOT", path)


# CCH-PLAYABLE-002: this machine's built-in controller sends button presses of its own while the bot plays (Start,
# then A, B, X and Y together, every few seconds; seen with a spy script). So the bot's buttons come from their own
# device id, every action's pad buttons are pinned to it, and pad buttons from any other device are dropped before
# the game sees them. Stick axes stay on device 0 (the hardware's sticks rest at zero and the wheel reads pad 0).
const BOT_PAD := 7


class HardwareFilter extends Node:
	func _input(e: InputEvent) -> void:
		if e is InputEventJoypadButton and e.device != 7:
			get_viewport().set_input_as_handled()


func _isolate_hardware() -> void:
	var pinned := 0
	for action in InputMap.get_actions():
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton:
				InputMap.action_erase_event(action, ev)
				var mine: InputEventJoypadButton = ev.duplicate()
				mine.device = BOT_PAD
				InputMap.action_add_event(action, mine)
				pinned += 1
	root.add_child(HardwareFilter.new())
	note("OBS", "hardware pad buttons isolated: %d action bindings pinned to the bot's device" % pinned)


# --- Raw input --------------------------------------------------------------------------------------

func key_set(k: int, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = k
	ev.keycode = k
	ev.pressed = down
	Input.parse_input_event(ev)


func pad_set(b: int, down: bool) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = BOT_PAD
	ev.button_index = b
	ev.pressed = down
	Input.parse_input_event(ev)


func axis_set(axis: int, v: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = v
	Input.parse_input_event(ev)


func tap_key(k: int, hold := 3) -> void:
	key_set(k, true)
	await frames(hold)
	key_set(k, false)
	await frames(3)


func tap_pad(b: int, hold := 3) -> void:
	pad_set(b, true)
	await frames(hold)
	pad_set(b, false)
	await frames(3)


func mouse_move(p: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = p
	ev.global_position = p
	Input.parse_input_event(ev)
	await frames(2)


func mouse_click(p: Vector2, button := MOUSE_BUTTON_LEFT, hold := 3) -> void:
	await mouse_move(p)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = button
		ev.position = p
		ev.global_position = p
		ev.pressed = down
		Input.parse_input_event(ev)
		await frames(hold)


# The hold of a direction: the keyboard's WASD, or the left stick on a controller.
func dir_set(d: String, down: bool) -> void:
	if held.get(d, false) == down:
		return
	held[d] = down
	if not pad:
		key_set(KEYS[d], down)
		return
	var x := (1.0 if held.get("right", false) else 0.0) - (1.0 if held.get("left", false) else 0.0)
	var y := (1.0 if held.get("down", false) else 0.0) - (1.0 if held.get("up", false) else 0.0)
	axis_set(JOY_AXIS_LEFT_X, x)
	axis_set(JOY_AXIS_LEFT_Y, y)


func release_dirs() -> void:
	for d in DIRS:
		dir_set(d, false)


# --- Player verbs -----------------------------------------------------------------------------------

# The hand action: Space or A.
func use() -> void:
	if pad:
		await tap_pad(JOY_BUTTON_A)
	else:
		await tap_key(KEY_SPACE)
	await frames(6)


# The tool action: a left click on the farm (well clear of the HUD), or RT.
func tool() -> void:
	if pad:
		axis_set(JOY_AXIS_TRIGGER_RIGHT, 1.0)
		await frames(4)
		axis_set(JOY_AXIS_TRIGGER_RIGHT, 0.0)
		await frames(4)
	else:
		var p := Vector2(root.size) * Vector2(0.5, 0.42)
		await mouse_move(p)
		var over := root.gui_get_hovered_control()
		if over != null:
			note("OBS", "mouse over UI control %s at screen centre; the click may not reach the farm" % over.name)
		await mouse_click(p)
	await frames(6)


# Picks a hotbar tool by id: its number key, or LB/RB steps on a controller.
func pick_tool(id: String) -> bool:
	var want := -1
	for i in m.HOTBAR_TOOLS.size():
		if str(m.HOTBAR_TOOLS[i]["id"]) == id:
			want = i
	if want < 0:
		return false
	if not pad:
		await tap_key(KEY_1 + want)
	else:
		for i in 12:
			if m.active_slot == want:
				break
			await tap_pad(JOY_BUTTON_RIGHT_SHOULDER)
	await frames(3)
	if m._active_tool() != id:
		note("PROBLEM", "could not select the %s (active tool is %s)" % [id, m._active_tool()])
		return false
	return true


func back() -> void:
	if pad:
		await tap_pad(JOY_BUTTON_B)
	else:
		await tap_key(KEY_ESCAPE)
	await frames(8)


func open_bag() -> void:
	if pad:
		await tap_pad(JOY_BUTTON_Y)
	else:
		await tap_key(KEY_TAB)
	await frames(12)


func open_wheel() -> void:
	if pad:
		await tap_pad(JOY_BUTTON_LEFT_STICK)
	else:
		await tap_key(KEY_SHIFT)
	await frames(20)


# Closes anything open, one Esc/B at a time, as a player would.
func close_all() -> void:
	for i in 6:
		if m.open_tab == "" and not m._bag_open() and not m._wheel_open():
			return
		await back()
	if m.open_tab != "" or m._bag_open() or m._wheel_open():
		note("PROBLEM", "a panel would not close with Esc/B: tab=%s bag=%s wheel=%s" % [m.open_tab, m._bag_open(), m._wheel_open()])


# --- Buttons in menus -------------------------------------------------------------------------------

func _buttons(node: Node, out: Array) -> void:
	for c in node.get_children():
		if c is BaseButton and (c as Control).is_visible_in_tree():
			out.append(c)
		_buttons(c, out)


func find_button(text: String, exact := false) -> BaseButton:
	var all: Array = []
	_buttons(root, all)
	for b in all:
		var t := str(b.get("text")) if b is Button else ""
		if (exact and t == text) or (not exact and t.findn(text) >= 0):
			return b
	return null


func button_texts() -> String:
	var all: Array = []
	_buttons(root, all)
	var names: Array = []
	for b in all:
		if b is Button and str(b.text) != "":
			names.append(("%s" if not b.disabled else "(%s)") % str(b.text).replace("\n", " / "))
	return " | ".join(names)


# Presses a visible button by its label: a mouse click on it, or on a controller the focus is walked to it with
# the D-pad and A pressed. Returns false when no such enabled button can be reached.
func press(text: String, exact := false) -> bool:
	var b := find_button(text, exact)
	if b == null:
		note("PROBLEM", "no visible button \"%s\"; buttons: %s" % [text, button_texts()])
		return false
	if b.disabled:
		note("OBS", "button \"%s\" is disabled" % text)
		return false
	if not pad:
		await mouse_click(b.get_global_rect().get_center())
		await frames(10)
		return true
	for step in 60:
		if root.gui_get_focus_owner() == b:
			await tap_pad(JOY_BUTTON_A)
			await frames(10)
			return true
		var f := root.gui_get_focus_owner()
		var order := ["down", "right", "up", "left"]
		var d := "down"
		if f != null and is_instance_valid(b):
			var delta: Vector2 = b.get_global_rect().get_center() - f.get_global_rect().get_center()
			if absf(delta.y) > 12.0:
				d = "down" if delta.y > 0 else "up"
			else:
				d = "right" if delta.x > 0 else "left"
		elif step > 40:
			d = order[step % 4]
		await tap_pad(PADS[d])
		if not is_instance_valid(b):
			b = find_button(text, exact)
			if b == null:
				break
	note("PROBLEM", "controller focus never reached the button \"%s\" (focus on %s)" % [text, str(root.gui_get_focus_owner())])
	return false


# --- Walking ----------------------------------------------------------------------------------------

func here() -> Vector2i:
	return m._player_tile()


func tile_free(t: Vector2i) -> bool:
	return not m._is_blocked_world(m._tile_center(t.x, t.y)) and not m._is_blocked_world(m._tile_center(t.x, t.y) + Vector2(0, 8))


# Tiles that take the farmer somewhere else when stepped on: only walked onto on purpose.
func _warp(t: Vector2i) -> bool:
	var k: int = m._kind_at(t)
	return k == m.Tile.DOOR or k == m.Tile.EXIT or k == m.Tile.CAVE_MOUTH or k == m.Tile.CAVE_EXIT


func _area(t: Vector2i) -> bool:
	if m.in_cave:
		return t.x >= 0 and t.y >= 0 and t.x < 200 and t.y < 200
	return m._in_interior(t) if m.inside else m._in_bounds(t)


# On a trek the trail is what a player follows (the walker loses nerve off it), so the trail is tried first.
func path_to(goals: Array) -> Array:
	if m.trek.active:
		var on_trail := _path_to(goals, true)
		if not on_trail.is_empty():
			return on_trail
	return _path_to(goals, false)


func _trail(t: Vector2i) -> bool:
	var k: int = m._kind_at(t)
	return k == m.Tile.PATH or k == m.Tile.CAVE_EXIT or k == m.Tile.EXIT


func _path_to(goals: Array, trail_only: bool) -> Array:
	var start := here()
	var want := {}
	for g in goals:
		want[g] = true
	var prev := {start: start}
	var queue: Array = [start]
	var found := Vector2i(-999, -999)
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		if want.has(t):
			found = t
			break
		for d in DIRS.values():
			var n: Vector2i = t + d
			if prev.has(n) or not _area(n) or not tile_free(n):
				continue
			if _warp(n) and not want.has(n):
				continue
			if trail_only and not _trail(n) and not want.has(n):
				continue
			prev[n] = t
			queue.append(n)
	if found.x == -999:
		return []
	var path: Array = [found]
	while path[0] != start:
		path.push_front(prev[path[0]])
	return path


# Walks to one of the goal tiles by holding direction keys. False if no way exists or the farmer gets stuck.
func walk(goals: Array, what := "") -> bool:
	if goals.has(here()):
		return true
	var path := path_to(goals)
	if path.is_empty():
		note("PROBLEM", "no walkable way from %s to %s (%s)" % [here(), goals.slice(0, 3), what])
		return false
	var warp_goal := _warp(path[-1])
	var inside0: bool = m.inside
	var cave0: bool = m.in_cave
	for i in range(1, path.size()):
		var target: Vector2 = m._tile_center(path[i].x, path[i].y)
		var stuck := 0
		var best := 1e9
		while true:
			if m.inside != inside0 or m.in_cave != cave0:
				release_dirs()
				await frames(20)
				return warp_goal
			if m.transitioning:
				release_dirs()
				await frames(30)
				return false
			var delta: Vector2 = target - m.player.position
			if absf(delta.x) <= 4.0 and absf(delta.y) <= 4.0:
				break
			dir_set("right", delta.x > 4.0)
			dir_set("left", delta.x < -4.0)
			dir_set("down", delta.y > 4.0)
			dir_set("up", delta.y < -4.0)
			await process_frame
			var dist := delta.length()
			if dist < best - 0.5:
				best = dist
				stuck = 0
			elif not m.player.paused:
				stuck += 1
			else:
				stuck += 1
				if stuck > 240:
					note("OBS", "walking held: the game is paused (tab=%s scene=%s)" % [m.open_tab, m.folk._in_scene()])
					release_dirs()
					return false
			if stuck > 300:
				release_dirs()
				note("PROBLEM", "stuck walking at %s toward %s (%s)" % [here(), path[i], what])
				return false
	release_dirs()
	await frames(2)
	return true


func free_neighbours(t: Vector2i) -> Array:
	var out: Array = []
	for d in DIRS.values():
		var n: Vector2i = t + d
		if _area(n) and tile_free(n) and not _warp(n):
			out.append(n)
	return out


func face(d: String) -> void:
	dir_set(d, true)
	await frames(1)
	dir_set(d, false)
	await frames(2)


# Stands beside a tile and faces it, ready to press a hand or tool action on it.
func approach(t: Vector2i, what := "") -> bool:
	var spots := free_neighbours(t)
	if spots.is_empty():
		note("PROBLEM", "nowhere to stand beside %s (%s)" % [t, what])
		return false
	if not await walk(spots, what):
		return false
	var d: Vector2i = t - here()
	for name in DIRS:
		if DIRS[name] == d:
			await face(name)
	if m._tile_in_front() != t:
		# A one-frame nudge may not turn the farmer when the tile ahead is free; step back to the spot and retry.
		for name in DIRS:
			if DIRS[name] == d:
				await face(name)
	if m._tile_in_front() != t:
		note("OBS", "facing %s, wanted %s (%s)" % [m._tile_in_front(), t, what])
		return false
	return true


# Every tile of a kind in the current area, nearest first.
func tiles_of(kind: int) -> Array:
	var out: Array = []
	if m.inside:
		for y in m.INT_H:
			for x in m.INT_W:
				var t := Vector2i(m.INT_ORIGIN.x + x, m.INT_ORIGIN.y + y)
				if m._kind_at(t) == kind:
					out.append(t)
	elif m.in_cave:
		for y in m.cave.size():
			for x in m.cave[y].size():
				if m.cave[y][x] == kind:
					out.append(Vector2i(x, y))
	else:
		for y in m.MAP_H:
			for x in m.MAP_W:
				if m.map[y][x] == kind:
					out.append(Vector2i(x, y))
	return nearest(out)


func nearest(list: Array) -> Array:
	var p := here()
	var out := list.duplicate()
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return absi(a.x - p.x) + absi(a.y - p.y) < absi(b.x - p.x) + absi(b.y - p.y))
	return out


func wait_until_hour(h: float, shot_name := "") -> void:
	var last := -1.0
	var held_for := 0
	while m.current_hour < h and not m.transitioning:
		await frames(30)
		# The clock only stops while something holds the day (a panel, a scene, an ending). A player would see it
		# on screen and answer it; the bot says what it is and presses the hand action or Esc, as the prompt asks.
		if m.current_hour == last:
			held_for += 1
			if held_for % 4 == 1:
				note("OBS", "the clock is held: tab=%s bag=%s wheel=%s scene=%s ending=%s paused=%s msg=\"%s\"" % [m.open_tab, m._bag_open(), m._wheel_open(), m.folk._in_scene(), m.act.playing(), m.player.paused, m.message_label.text])
				if held_for == 1:
					await shot("clock_held_d%d" % m.day)
			if m.folk._in_scene() or m.act.playing():
				await use()
			elif m.open_tab != "" or m._bag_open() or m._wheel_open():
				await back()
			if held_for > 60:
				note("PROBLEM", "the day stayed held for 30 s of presses (tab=%s scene=%s)" % [m.open_tab, m.folk._in_scene()])
				return
		else:
			held_for = 0
		last = m.current_hour
	if shot_name != "":
		await shot(shot_name)


func wait_transition() -> void:
	await frames(10)
	var n := 0
	while m.transitioning and n < 60 * 120:
		await process_frame
		n += 1
	if m.transitioning:
		note("PROBLEM", "a transition never ended (stuck fade)")
	await frames(20)


func state() -> String:
	return "coins=%d hp=%d food=%d water=%d warmth=%d sanity=%d tool=%s inside=%s tile=%s pack=%s mats=%s" % [
		m.money, m.hp, int(m.food), int(m.water), int(m.warmth), int(m.sanity), m._active_tool(), m.inside, here(),
		JSON.stringify(_nonzero(m.inventory)), JSON.stringify(_nonzero(m.materials))]


func _nonzero(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d:
		if (d[k] is int or d[k] is float) and d[k] != 0:
			out[k] = d[k]
	return out


# --- Scenarios --------------------------------------------------------------------------------------

# Title menu to a new game, as the menu's own hint says ("Up and down to choose, Enter or A to pick").
func start_new_game() -> void:
	await frames(30)
	await shot("title")
	note("OBS", "title buttons: %s" % button_texts())
	var accept := func() -> void:
		if pad:
			await tap_pad(JOY_BUTTON_A)
		else:
			await tap_key(KEY_ENTER)
		await frames(15)
	var f := root.gui_get_focus_owner()
	note("OBS", "title focus on open: %s" % (str(f.get("text")) if f != null else "nothing"))
	# Move down to New Game if the focus isn't already on it.
	for i in 5:
		f = root.gui_get_focus_owner()
		if f != null and str(f.get("text")) == "New Game":
			break
		if pad:
			await tap_pad(JOY_BUTTON_DPAD_DOWN)
		else:
			await tap_key(KEY_DOWN)
	await accept.call()
	await shot("title_slots")
	note("OBS", "slot page buttons: %s" % button_texts())
	await accept.call()
	await shot("title_name")
	note("OBS", "name page buttons: %s" % button_texts())
	if pad:
		# The name field holds the focus; the hint says "press Enter or Begin". A controller has no Enter.
		await tap_pad(JOY_BUTTON_DPAD_DOWN)
		await accept.call()
	else:
		await accept.call()
	await frames(60)
	if not m.world_started:
		note("PROBLEM", "the new game did not start from the title menu by %s; buttons: %s" % [opt["dev"], button_texts()])
		if await press("Begin"):
			await frames(60)
	note("OBS", "world started=%s day=%d slot=%d %s" % [m.world_started, m.day, m.save_slot, state()])
	var pads: Array = []
	for id in Input.get_connected_joypads():
		pads.append(Input.get_joy_name(id))
	note("OBS", "joypads the engine reports connected: %s" % str(pads))


func _sc_start() -> void:
	await start_new_game()
	await frames(20)
	await shot("first_frame")
	await frames(60 * 20)
	await shot("after_20s")
	await frames(60 * 80)
	await shot("after_100s")
	note("OBS", state())


# --- Panels -----------------------------------------------------------------------------------------

func _action_buttons(node: Node, out: Array) -> void:
	for c in node.get_children():
		if c is Button and (c as Control).is_visible_in_tree() and str(c.get_meta("action", "")) != "":
			out.append(c)
		_action_buttons(c, out)


# What a panel offers: every visible button with its label and action, disabled ones in brackets.
func dump_ui(what: String) -> void:
	var all: Array = []
	_action_buttons(m.action_bar, all)
	var parts: Array = []
	for b in all:
		var t := "%s=%s" % [str(b.text).replace("\n", "/").substr(0, 28), str(b.get_meta("action"))]
		parts.append("(%s)" % t if b.disabled else t)
	note("UI", "%s [tab=%s]: %s" % [what, m.open_tab, "  ".join(parts)])


func action_button(id: String) -> Button:
	var all: Array = []
	_action_buttons(m.action_bar, all)
	for b in all:
		if str(b.get_meta("action")) == id:
			return b
	return null


# Presses a panel button by its action: a mouse click, or on a controller the focus walked to it and A.
func press_action(id: String, quiet := false) -> bool:
	var b := action_button(id)
	if b == null:
		if not quiet:
			note("OBS", "no button for \"%s\" on screen (tab=%s)" % [id, m.open_tab])
		return false
	if b.disabled:
		if not quiet:
			note("OBS", "button \"%s\" (%s) is disabled" % [id, str(b.text).replace("\n", "/")])
		return false
	if not pad:
		await mouse_click(b.get_global_rect().get_center())
		await frames(10)
		return true
	for step in 80:
		var f := root.gui_get_focus_owner()
		if f == b:
			await tap_pad(JOY_BUTTON_A)
			await frames(10)
			return true
		var d := "down"
		if f != null:
			var delta: Vector2 = b.get_global_rect().get_center() - f.get_global_rect().get_center()
			if absf(delta.y) > 10.0:
				d = "down" if delta.y > 0 else "up"
			else:
				d = "right" if delta.x > 0 else "left"
		if step > 50:
			d = ["down", "right", "up", "left"][step % 4]
		await tap_pad(PADS[d])
		b = action_button(id)
		if b == null:
			break
	note("PROBLEM", "controller focus never reached \"%s\" (tab=%s)" % [id, m.open_tab])
	return false


# A Craft sub-tab: a click on its tab, or RB steps on a controller (the tab strip shows the keys at its ends).
func craft_tab(name: String) -> void:
	var want := name.to_lower()
	for i in 5:
		if str(m.craft_tab) == want:
			return
		if pad:
			await tap_pad(JOY_BUTTON_RIGHT_SHOULDER)
			await frames(10)
		else:
			await press(name, true)
	if str(m.craft_tab) != want:
		note("PROBLEM", "the Craft tab %s could not be opened (on %s)" % [name, str(m.craft_tab)])


# Opens a section from the wheel: Shift / left stick click, step to it, Enter / A.
func open_section(name: String) -> bool:
	await close_all()
	await open_wheel()
	if not m._wheel_open():
		note("PROBLEM", "the section wheel did not open")
		return false
	var want := -1
	for i in m.wheel.SECTIONS.size():
		if str(m.wheel.SECTIONS[i]["name"]) == name:
			want = i
	for i in 10:
		if m.wheel.highlight == want:
			break
		if pad:
			await tap_pad(JOY_BUTTON_DPAD_RIGHT)
		else:
			await tap_key(KEY_RIGHT)
	if pad:
		await tap_pad(JOY_BUTTON_A)
	else:
		await tap_key(KEY_ENTER)
	await frames(20)
	if m.open_tab != name:
		note("PROBLEM", "the wheel did not open %s (tab=%s, highlight=%d)" % [name, m.open_tab, m.wheel.highlight])
		return false
	return true


# --- World chores, each done by walking there and pressing the action the game names ------------------

func enter_house() -> bool:
	if m.inside:
		return true
	var ok := await walk(tiles_of(m.Tile.DOOR), "the farmhouse door")
	await frames(20)
	if not m.inside:
		note("PROBLEM", "walking into the farmhouse door did not go inside")
	return ok and m.inside


func leave_house() -> bool:
	if not m.inside:
		return true
	await walk(tiles_of(m.Tile.EXIT), "the exit mat")
	await frames(20)
	if m.inside:
		note("PROBLEM", "walking onto the exit mat did not leave the house")
	return not m.inside


func reachable(t: Vector2i) -> bool:
	var spots := free_neighbours(t)
	return spots.has(here()) or not path_to(spots).is_empty()


func use_tile_kind(kind: int, what: String) -> bool:
	for t in tiles_of(kind):
		if reachable(t) and await approach(t, what):
			await use()
			return true
	note("PROBLEM", "could not reach %s" % what)
	return false


func gather_brush(n: int) -> int:
	var got := 0
	for i in n:
		var done := false
		for t in nearest(m.brush.keys()).slice(0, 6):
			if reachable(t) and await approach(t, "a brush pile"):
				var before := int(m.stats["gathered"])
				await use()
				await frames(20)
				if int(m.stats["gathered"]) > before:
					got += 1
					done = true
				else:
					note("PROBLEM", "pressing the hand action at a brush pile gathered nothing")
				break
		if not done:
			break
	return got


func soil_tiles(empty: bool) -> Array:
	var out: Array = []
	for t in tiles_of(m.Tile.SOIL):
		if m.crops.has(t) != empty and not m.projects._blocks(t):
			out.append(t)
	return out


func plant(n: int) -> int:
	if not await pick_tool("trowel"):
		return 0
	var done := 0
	for t in soil_tiles(true).slice(0, n + 3):
		if done >= n:
			break
		if await approach(t, "a soil tile"):
			var before := m.crops.size()
			await tool()
			await frames(30)
			if m.crops.size() > before:
				done += 1
	return done


func _watered(t: Vector2i) -> bool:
	return m.crops.has(t) and int(m.crops[t].get("watered_day", 0)) == m.day


func water_crops() -> int:
	var dry: Array = []
	for t in m.crops:
		if not _watered(t) and int(m.crops[t]["stage"]) < m.MAX_STAGE:
			dry.append(t)
	if dry.is_empty():
		return 0
	if not await pick_tool("hose"):
		return 0
	var done := 0
	for t in nearest(dry):
		if not m.crops.has(t) or not await approach(t, "a crop to water"):
			continue
		await tool()
		await frames(50)
		if _watered(t):
			done += 1
			continue
		# The game says what is wrong (an empty bucket, say); a player would read it and fetch water.
		note("OBS", "watering did not take: \"%s\"; water held=%s" % [m.message_label.text, str(m.get("well_water"))])
		if not await refill():
			break
		await pick_tool("hose")
		if await approach(t, "a crop to water"):
			await tool()
			await frames(50)
			if _watered(t):
				done += 1
	return done


func refill() -> bool:
	var tries := 0
	for t in tiles_of(m.Tile.WATER).slice(0, 60):
		if reachable(t) and await approach(t, "the pond"):
			var w0: float = m.water
			var drank0 := int(m.stats["drank"])
			await use()
			await frames(30)
			if int(m.stats["drank"]) > drank0 or m.water > w0:
				return true
			# The water here answered with something else (a fishing spot asks for the pole): try along the bank.
			tries += 1
			note("OBS", "hand action at pond tile %s (fish spot=%s) did not drink: \"%s\"" % [t, m.fish_spots.has(t), m.message_label.text])
			if tries >= 4:
				return false
	note("PROBLEM", "could not reach the pond")
	return false


func harvest_ripe() -> int:
	var ripe: Array = []
	for t in m.crops:
		if int(m.crops[t]["stage"]) >= m.MAX_STAGE:
			ripe.append(t)
	if ripe.is_empty():
		return 0
	await pick_tool("hoe")
	var n := 0
	for t in nearest(ripe):
		if await approach(t, "a ripe crop"):
			var before := int(m.stats["harvested"])
			await tool()
			await frames(40)
			var w := 0
			while m.farm._is_harvesting() and w < 600:
				await process_frame
				w += 1
			if int(m.stats["harvested"]) > before:
				n += 1
	return n


func chop_tree() -> bool:
	if not await pick_tool("axe"):
		return false
	var trees: Array = []
	for s in m.GROVE_SPOTS:
		var t: Vector2i = s + Vector2i(m.BORDER_X, m.BORDER_Y)
		if m.map[t.y][t.x] == m.Tile.TREE:
			trees.append(t)
	for t in nearest(trees).slice(0, 8):
		if not reachable(t) or not await approach(t, "a tree to chop"):
			continue
		var before := int(m.stats["felled"])
		await tool()
		var w := 0
		while int(m.stats["felled"]) == before and w < 60 * 40:
			await process_frame
			w += 1
			if w % 180 == 0 and not m.farm._is_harvesting():
				await tool()   # "keep chopping until it falls"
		await frames(20)
		if int(m.stats["felled"]) > before:
			return true
		note("PROBLEM", "the tree at %s did not fall after 40 s of chopping" % t)
		return false
	note("PROBLEM", "no tree could be reached to chop")
	return false


func pick_forage() -> int:
	var n := 0
	for t in nearest(m.forage.spots.keys()):
		if not m.forage.spots.has(t) or not reachable(t):
			continue
		if await approach(t, "forage"):
			await use()
			await frames(20)
			if not m.forage.spots.has(t):
				n += 1
	return n


# Eats from the bag until the hunger bar is comfortable: Tab / Y, then a slot holding food.
func eat_from_bag() -> void:
	if m.food > 55.0:
		return
	await open_bag()
	if not m._bag_open():
		note("PROBLEM", "the bag did not open")
		return
	var items: Array = m._bag_items()
	var names: Array = []
	for it in items:
		names.append(str(it.get("name", it.get("id", "?"))))
	note("OBS", "bag holds: %s (hunger %d)" % [", ".join(names), int(m.food)])
	var before: float = m.food
	for i in items.size():
		if m.food > 70.0 or i >= m.bag.slots.size():
			break
		var b: Button = m.bag.slots[i]
		if b == null or not b.is_visible_in_tree() or b.disabled:
			continue
		var f0: float = m.food
		if pad:
			var tries := 0
			while root.gui_get_focus_owner() != b and tries < 20:
				await tap_pad(JOY_BUTTON_DPAD_RIGHT)
				tries += 1
			await tap_pad(JOY_BUTTON_A)
		else:
			await mouse_click(b.get_global_rect().get_center())
		await frames(15)
		if m.food > f0:
			note("ACT", "ate from bag slot %d: hunger %d -> %d (\"%s\")" % [i, int(f0), int(m.food), m.message_label.text])
		if not m._bag_open():
			await open_bag()
	if m.food <= before:
		note("OBS", "nothing in the bag fed the farmer (hunger %d): \"%s\"" % [int(m.food), m.message_label.text])
	await close_all()


func drink() -> void:
	var before: float = m.water
	if await refill() and m.water <= before and before < 95.0:
		note("PROBLEM", "the hand action at the pond did not raise thirst (%d): \"%s\"" % [int(m.water), m.message_label.text])


func sleep_in_bed() -> bool:
	if not await enter_house():
		return false
	var day0: int = m.day
	for t in tiles_of(m.Tile.BED):
		if reachable(t) and await approach(t, "the bed"):
			await use()
			await frames(30)
			break
	await wait_transition()
	if m.day == day0:
		note("PROBLEM", "the bed did not end the day: \"%s\"" % m.message_label.text)
		return false
	return true


func read_diary(shot_name := "") -> void:
	if pad:
		await open_section("Diary")
	else:
		await tap_key(KEY_J)
		await frames(40)
	if m.open_tab != "Diary":
		note("PROBLEM", "the diary did not open (found=%s)" % m.diary_found)
		return
	if shot_name != "":
		await frames(60)
		await shot(shot_name)
	var step: Dictionary = m._guide_step()
	note("OBS", "diary open; guide step=%s chapter=%s unread=%s" % [str(step.get("title", "(guide over)")), str(m._current_chapter().get("title", "-")), str(m.diary_new)])
	await close_all()


# --- The first week ---------------------------------------------------------------------------------

func _sc_week() -> void:
	await start_new_game()
	await shot("d1_first_frame")
	# Nothing on screen says what to do yet; a new player waits or wanders. The first hint comes by itself.
	var n := 0
	while not m.message_label.text.contains("diary") and n < 60 * 30:
		await process_frame
		n += 1
	note("OBS", "first objective hint after %.0f s of play: \"%s\"" % [n / 60.0, m.message_label.text])
	await shot("d1_diary_hint")
	await enter_house()
	await shot("d1_inside")
	await use_tile_kind(m.Tile.DESK, "the desk")
	await frames(60)
	await shot("d1_diary_found")
	note("OBS", "after the desk: diary_found=%s tab=%s" % [m.diary_found, m.open_tab])
	await close_all()
	await leave_house()
	for d in int(opt["days"]):
		await _play_day()
		if m.day > int(opt["days"]):
			break
	note("OBS", "week over: " + state())
	note("OBS", "stats: " + JSON.stringify(m.stats))
	note("OBS", "quests done: %s; tips seen: %s" % [str(m.quests_done.keys()), str(m.tips_seen.keys())])


var guide_seen := {}


# One day as a new player who does what the current diary step and the messages of the day say.
func _play_day() -> void:
	var day: int = m.day
	note("OBS", "--- day %d begins: %s; weather %s" % [day, state(), m.weather_kind])
	await shot("d%d_morning" % day)
	if m.inside:
		await leave_house()
	# The guided first day, one step at a time, re-reading the diary after each as it asks.
	for i in 12:
		var step: Dictionary = m._guide_step()
		if step.is_empty():
			break
		var id := str(step["id"])
		if guide_seen.has(id):
			note("PROBLEM", "guide step \"%s\" was done as written but is still the current step" % str(step["title"]))
			break
		guide_seen[id] = true
		await read_diary("d%d_guide_%s" % [day, id] if id in ["g_plant", "g_hatchet"] else "")
		note("ACT", "guide step: %s: %s" % [str(step["title"]), m._fill_controls(str(step["text"]))])
		match id:
			"g_walk":
				await walk(nearest(soil_tiles(true)).slice(0, 1), "the plot")
			"g_plant":
				note("OBS", "planted %d" % await plant(3))
			"g_bag":
				await open_bag()
				await shot("d1_bag")
				await open_bag()
				if m._bag_open():
					await close_all()
			"g_brush":
				note("OBS", "gathered %d brush piles" % await gather_brush(3))
			"g_wheel":
				await open_wheel()
				await shot("d1_wheel")
				await close_all()
			"g_hatchet":
				if await open_section("Craft"):
					await dump_ui("Craft on open")
					await craft_tab("Tools")
					await press_action("craft_pick:tool:hatchet", true)
					await frames(10)
					await shot("d1_craft_hatchet")
					await dump_ui("Craft hatchet picked")
					if not await press("Make", true):
						note("PROBLEM", "the crude hatchet could not be made: mats %s" % JSON.stringify(_nonzero(m.materials)))
					await close_all()
			"g_chop":
				await chop_tree()
			"g_drink":
				await drink()
		await frames(90)
	if m._guide_step().is_empty() and day == 1:
		note("OBS", "guided first day finished at %s" % stamp())
		await read_diary("d1_after_guide")
	# From here the player has the diary pages, the Quests section and the messages of the day to go on.
	await _chores()
	# Evening: indoors by dark. On day 1 the kbm run waits up for 22:00 to see the first night; otherwise bed at 19:00.
	await wait_until_hour(17.5)
	await eat_from_bag()
	await enter_house()
	if m.inside:
		for t in tiles_of(m.Tile.FIREPLACE):
			if reachable(t) and await approach(t, "the hearth"):
				await use()
				await frames(30)
				note("OBS", "hearth: fire lit=%s (\"%s\")" % [m.firewood._fire_lit(), m.message_label.text])
				break
	if day == 1 and not pad:
		await wait_until_hour(22.2, "d1_first_night_22h")
		await frames(60 * 12)
		await shot("d1_first_night_later")
	else:
		await wait_until_hour(19.0)
	await sleep_in_bed()
	note("OBS", "slept: now day %d, %s" % [m.day, state()])


func _chores() -> void:
	var day: int = m.day
	note("OBS", "watered %d crops" % await water_crops())
	note("OBS", "harvested %d" % await harvest_ripe())
	if soil_tiles(true).size() > 0 and int(m.inventory.get("seeds", 0)) > 0:
		note("OBS", "planted %d more" % await plant(int(m.inventory.get("seeds", 0))))
		note("OBS", "watered %d crops" % await water_crops())
	note("OBS", "picked %d forage" % await pick_forage())
	await eat_from_bag()
	if m.water < 60.0:
		await drink()
	note("OBS", "gathered %d brush piles" % await gather_brush(6))
	if int(m.tool_tier["hatchet"]) > 0:
		await chop_tree()
		await chop_tree()
	# The mailbox: a player goes when the flag is up.
	if m.mail._flag_up():
		note("OBS", "mailbox flag is up")
		if await use_tile_kind(m.Tile.MAILBOX, "the mailbox"):
			await frames(30)
			await shot("d%d_mailbox" % day)
			await dump_ui("Mailbox")
			note("OBS", "mailbox: %d unread, letters: %s" % [m.mail._unread_count(), str(m.desk_mail.map(func(l): return str(l.get("title", "?"))))])
			await close_all()
			note("OBS", "after closing the mailbox: %d unread, flag up=%s" % [m.mail._unread_count(), m.mail._flag_up()])
	# The Quests and House sections, as the day-2 diary pages point to.
	if day >= 2 and await open_section("Quests"):
		await dump_ui("Quests")
		if day == 2:
			await shot("d2_quests")
		await close_all()
	if day >= 2 and await open_section("House"):
		await dump_ui("House")
		if day == 2:
			await shot("d2_house")
		var stage0: int = m.house_stage
		if await ledger_tab_with("repair") and await ledger_do("repair"):
			note("ACT", "House, Repair pressed: stage %d -> %d (\"%s\")" % [stage0, m.house_stage, m.message_label.text])
		for chore in ["tidy", "mend", "job"]:
			if await ledger_tab_with(chore):
				if day == 2 and chore == "tidy":
					await shot("d2_house_chores")
					await dump_ui("House chores")
				if await ledger_do(chore):
					note("ACT", "House, %s pressed: \"%s\"" % [chore, m.message_label.text])
		await close_all()
	if day >= 2 and await open_section("Craft"):
		await craft_tab("Other")
		await press_action("craft_pick:lantern", true)
		await dump_ui("Craft other")
		var tier0: int = m.lantern_tier
		var make := find_button("Build", true)
		if make != null and not make.disabled and await press("Build", true) and m.lantern_tier > tier0:
			note("ACT", "built a lantern: tier %d (\"%s\")" % [m.lantern_tier, m.message_label.text])
		await close_all()
	# The farm stand, once there is something to sell.
	if int(m.stats["harvested"]) > 0 or day >= 3:
		if await use_tile_kind(m.Tile.STALL, "the farm stand"):
			await frames(30)
			await dump_ui("Farm stand")
			if day <= 3 or int(m.stats["harvested"]) > 0:
				await shot("d%d_stand" % day)
			for b in _sell_actions():
				var coins: int = m.money
				if await ledger_do(b):
					note("ACT", "stand %s: coins %d -> %d (\"%s\")" % [b, coins, m.money, m.message_label.text])
			await close_all()
	if m.water < 70.0:
		await drink()
	# Old Maren (or another walker) at the east gate, when the morning message says she waits.
	if m.trek._any_waiting() and m.current_hour < 14.0:
		await do_trek()
	if day >= 5 and int(opt.get("cave", "1")) == 1 and not cave_seen:
		cave_seen = true
		await visit_cave(false)


var cave_seen := false


func _sell_actions() -> Array:
	var all: Array = []
	_action_buttons(m.action_bar, all)
	var out: Array = []
	for b in all:
		var id := str(b.get_meta("action"))
		if id.begins_with("sell") and not b.disabled and not out.has(id):
			out.append(id)
	return out


# A ledger line: a click picks it and Space presses its action ("Space Select" in the footer); A on a controller.
func ledger_do(id: String) -> bool:
	if not await press_action(id, true):
		return false
	if not pad:
		await tap_key(KEY_SPACE)
		await frames(10)
	return true


# A ledger tab: E / Q on the keyboard, RB / LB on a controller, until the wanted entry shows.
func ledger_tab_with(id: String) -> bool:
	for i in 8:
		if action_button(id) != null:
			return true
		if pad:
			await tap_pad(JOY_BUTTON_RIGHT_SHOULDER)
		else:
			await tap_key(KEY_E)
		await frames(12)
	return action_button(id) != null


func continue_game() -> bool:
	await frames(30)
	note("OBS", "title buttons: %s" % button_texts())
	if not await press("Continue", true):
		return false
	await frames(120)
	note("OBS", "continued: world=%s day=%d %s" % [m.world_started, m.day, state()])
	return m.world_started


# --- Treks ------------------------------------------------------------------------------------------

func _walker_gap() -> float:
	return m.trek.walker_pos.distance_to(m.player.position) / float(m.PX)


# Walks whoever waits at the gate through the wood, doing what the messages on the way say.
func do_trek() -> bool:
	var id := ""
	for r in m.trek.ROUTES:
		if m.trek._waiting(r):
			id = r
	if id == "":
		return false
	var w: Vector2i = m.trek._walker_tile(id)
	note("ACT", "a walker waits (%s) at %s; walking over" % [id, w])
	if not await approach(w, "the walker at the gate"):
		if not await walk([w + Vector2i(0, 1)], "below the walker"):
			return false
		await face("up")
	await shot("trek_%s_gate" % id)
	await use()
	await frames(40)
	note("OBS", "walker says: \"%s\"" % m.message_label.text)
	if m.folk._in_scene():
		note("OBS", "a scene opened at the gate")
		for i in 12:
			if not m.folk._in_scene():
				break
			await use()
			await frames(20)
	if not m.trek.active:
		await use()
		await frames(60)
	if not m.trek.active:
		await use()
		await frames(60)
	if not m.trek.active:
		note("OBS", "the trek did not start: \"%s\"" % m.message_label.text)
		return false
	note("OBS", "trek started: route=%s nerve=%d oil=%d clearings=%d events=%s" % [m.trek.route_id, int(m.trek.nerve), int(m.materials["lamp_oil"]), m.trek.route.size(), str(m.trek.events)])
	await shot("trek_%s_start" % id)
	var ticks := 0
	var last_clearing := -1
	var shot_events := {}
	while m.trek.active and ticks < 60 * 60 * 6:
		ticks += 1
		if m.trek.clearing != last_clearing:
			last_clearing = m.trek.clearing
			note("OBS", "clearing %d of %d: event=%s nerve=%d sanity=%d lit=%s" % [m.trek.clearing + 1, m.trek.route.size(), m.trek._event(), int(m.trek.nerve), int(m.sanity), m.trek.lit])
		# What comes at you: the tall one is driven off with the hand action when close, the crows near the walker.
		if m.trek.tall_on and m.trek.tall_pos.distance_to(m.player.position) <= 2.8 * m.PX:
			if not shot_events.has("tall"):
				shot_events["tall"] = true
				await shot("trek_%s_tall" % id)
			await use()
		if m.trek._crows_mobbing():
			if not shot_events.has("crows"):
				shot_events["crows"] = true
				await shot("trek_%s_crows" % id)
			if _walker_gap() > 2.0:
				await walk(free_neighbours(Vector2i(floori(m.trek.walker_pos.x / m.PX), floori(m.trek.walker_pos.y / m.PX))), "the walker")
			await use()
			await frames(20)
			continue
		if m.trek.frozen or _walker_gap() > 3.0:
			# Wait for the walker; a frozen one needs a word (or a ration) from close by.
			if m.trek.frozen:
				var wt := Vector2i(floori(m.trek.walker_pos.x / m.PX), floori(m.trek.walker_pos.y / m.PX))
				if await approach(wt, "the frozen walker"):
					await use()
					await frames(30)
					note("OBS", "walker frozen (nerve %d): \"%s\"" % [int(m.trek.nerve), m.message_label.text])
			else:
				await frames(20)
			continue
		var exits := tiles_of(m.Tile.CAVE_EXIT)
		# Only the trail: when it is blocked, what blocks it is dealt with, as a player facing a trunk would.
		var path := _path_to(exits, true)
		var blockers := 0
		for bt in m.trek.blocked:
			if m.cave[bt.y][bt.x] == m.Tile.FENCE:
				blockers += 1
		if path.is_empty() and blockers == 0:
			path = _path_to(exits, false)
		if path.is_empty():
			# The trail is blocked: face what blocks it and press the hand action, as its message says.
			var done := false
			for t in nearest(m.trek.blocked):
				if m.cave[t.y][t.x] == m.Tile.FENCE and reachable(t) and await approach(t, "what blocks the trail"):
					if not shot_events.has("block%d" % m.trek.clearing):
						shot_events["block%d" % m.trek.clearing] = true
						await shot("trek_%s_blocked_%s" % [id, m.trek._event()])
					await use()
					await frames(30)
					note("OBS", "blocked by %s: \"%s\"" % [m.trek._event(), m.message_label.text])
					await use()
					await frames(30)
					done = true
					break
			if not done:
				await frames(60)
				if ticks % 20 == 0:
					note("OBS", "no way on and nothing to clear (event=%s, \"%s\")" % [m.trek._event(), m.message_label.text])
			continue
		# A few tiles at a time, so the walker keeps up and stays in the light.
		var hop: Vector2i = path[mini(3, path.size() - 1)]
		if not await walk([hop], "along the trail"):
			await frames(30)
		await frames(10)
	note("OBS", "trek over: active=%s in_cave=%s \"%s\"" % [m.trek.active, m.in_cave, m.message_label.text])
	note("OBS", state())
	await frames(120)
	await shot("trek_%s_home" % id)
	return not m.trek.active


# --- The cave ---------------------------------------------------------------------------------------

func _foe_tile(f: Dictionary) -> Vector2i:
	return Vector2i(floori(f["pos"].x / m.PX), floori(f["pos"].y / m.PX))


func visit_cave(fight: bool) -> void:
	note("ACT", "walking to the cave at the west edge")
	if not await walk(tiles_of(m.Tile.CAVE_MOUTH), "the cave mouth"):
		return
	await frames(40)
	if not m.in_cave:
		note("PROBLEM", "stepping on the cave mouth did not enter the cave")
		return
	await shot("cave_entry_d%d" % m.day)
	var ores := tiles_of(m.Tile.ORE_COPPER) + tiles_of(m.Tile.ORE_IRON)
	note("OBS", "in the cave: lantern tier %d, %d foes (%s), %d ore nodes, weapon=%s, pick tier %d" % [m.lantern_tier, m.foes.size(),
		", ".join(m.foes.map(func(f): return str(f["kind"]))), ores.size(), str(m.equipment["hand_r"]), int(m.tool_tier["pick"])])
	# Mining: face ore and use the pick.
	if int(m.tool_tier["pick"]) > 0:
		await pick_tool("pick")
		var mined := 0
		for t in nearest(ores).slice(0, 4):
			if not reachable(t) or not await approach(t, "an ore node"):
				continue
			var before: int = int(m.materials["copper_ore"]) + int(m.materials["iron_ore"])
			await tool()
			var w := 0
			while m.cave[t.y][t.x] != m.Tile.FLOOR and w < 60 * 30 and m.in_cave:
				await process_frame
				w += 1
				if w % 180 == 0 and not m.farm._is_harvesting():
					await tool()
			if int(m.materials["copper_ore"]) + int(m.materials["iron_ore"]) > before:
				mined += 1
			if not m.in_cave:
				break
		note("OBS", "mined %d ore nodes: copper_ore=%d iron_ore=%d (\"%s\")" % [mined, int(m.materials["copper_ore"]), int(m.materials["iron_ore"]), m.message_label.text])
	else:
		var t0: Array = nearest(ores).slice(0, 1)
		if not t0.is_empty() and reachable(t0[0]) and await approach(t0[0], "an ore node"):
			await tool()
			await frames(30)
			note("OBS", "ore with no pick: \"%s\"" % m.message_label.text)
	if fight and m.in_cave:
		await fight_foes()
	if m.in_cave:
		await walk(tiles_of(m.Tile.CAVE_EXIT), "the way out")
		await frames(40)
		if m.in_cave:
			note("PROBLEM", "could not leave the cave by its exit")
	note("OBS", "after the cave: in_cave=%s %s" % [m.in_cave, state()])


func block_set(down: bool) -> void:
	if pad:
		axis_set(JOY_AXIS_TRIGGER_LEFT, 1.0 if down else 0.0)
	else:
		var p := Vector2(root.size) * Vector2(0.5, 0.42)
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_RIGHT
		ev.position = p
		ev.global_position = p
		ev.pressed = down
		Input.parse_input_event(ev)
	await frames(2)


func _face_foe(f: Dictionary) -> void:
	var d: Vector2 = f["pos"] - m.player.position
	if absf(d.x) > absf(d.y):
		await face("right" if d.x > 0 else "left")
	else:
		await face("down" if d.y > 0 else "up")


# Fights what the cave holds with the weapon in hand: walk up, face it, swing (left click / RT), and for the
# first blows hold the guard (right click / LT) to see whether a blow from the front is turned aside.
func fight_foes() -> void:
	if not m._has_weapon():
		note("OBS", "no weapon equipped; swinging says: ")
		await pick_tool("sword")
		await tool()
		note("OBS", "\"%s\"" % m.message_label.text)
		return
	if not await pick_tool("sword"):
		return
	var kills0 := int(m.stats["defeated"])
	var swings := 0
	var hits := 0
	var blocks := 0
	var hurts := 0
	var t := 0
	var shot_done := false
	while m.in_cave and not m.foes.is_empty() and t < 60 * 150:
		var f: Dictionary = nearest_foe()
		var gap: float = (f["pos"] - m.player.position).length() / float(m.PX)
		if gap > 1.3:
			var ft := _foe_tile(f)
			var spots := free_neighbours(ft)
			if spots.is_empty() or (path_to(spots).is_empty() and not spots.has(here())):
				await frames(20)
				t += 20
				continue
			var p := path_to(spots)
			if p.size() > 1:
				await walk([p[mini(2, p.size() - 1)]], "toward a %s" % str(f["kind"]))
			t += 30
			continue
		await _face_foe(f)
		# Guard test: hold the block until the creature has struck once, and see what the blow did.
		if blocks + hurts < 2:
			var hp0: int = m.hp
			await block_set(true)
			var w := 0
			var inv0: float = m.invuln
			while w < 240 and m.in_cave and m.hp == hp0 and m.invuln <= inv0:
				await process_frame
				w += 1
				inv0 = minf(inv0, m.invuln)
			await block_set(false)
			if not m.in_cave:
				break
			if m.hp < hp0:
				hurts += 1
				note("OBS", "guard held, facing the %s, but the blow landed: hp %d -> %d (blocking=%s tool=%s)" % [str(f["kind"]), hp0, m.hp, m.blocking, m._active_tool()])
			elif w < 240:
				blocks += 1
				note("OBS", "guard turned a blow from the %s (hp stays %d)" % [str(f["kind"]), m.hp])
			t += w
			continue
		var fhp := int(f["hp"])
		var n0 := m.foes.size()
		if not shot_done:
			shot_done = true
			await shot("cave_fight_d%d" % m.day)
		await tool()
		swings += 1
		await frames(14)
		if m.foes.size() < n0 or int(f["hp"]) < fhp:
			hits += 1
		t += 40
	note("OBS", "fight: %d swings, %d hit, %d blows blocked, %d blows taken with the guard up, kills %d, hp %d/%d, foes left %d, in_cave=%s (\"%s\")" % [
		swings, hits, blocks, hurts, int(m.stats["defeated"]) - kills0, m.hp, m.max_hp(), m.foes.size(), m.in_cave, m.message_label.text])


func nearest_foe() -> Dictionary:
	var best: Dictionary = m.foes[0]
	for f in m.foes:
		if (f["pos"] - m.player.position).length() < (best["pos"] - m.player.position).length():
			best = f
	return best


# --- Later scenarios: each continues the newest save of its profile from the title menu ---------------

# The systems the first week points at but a new player has to find alone: the pause menu and its controls
# list, the desk and its catalog, fishing, a first weapon, and the cave with its creatures.
func _sc_extras() -> void:
	if not await continue_game():
		note("PROBLEM", "Continue did not load the save")
		return
	await shot("continue_first_frame")
	if m.inside:
		# Still indoors: the desk first.
		pass
	# The pause menu.
	if pad:
		await tap_pad(JOY_BUTTON_START)
	else:
		await tap_key(KEY_ESCAPE)
	await frames(20)
	await dump_ui("Pause menu")
	await shot("pause_menu")
	var all: Array = []
	_action_buttons(m.action_bar, all)
	for b in all:
		if str(b.get_meta("action")).findn("control") >= 0:
			await ledger_do(str(b.get_meta("action")))
			await frames(20)
			await shot("pause_controls")
			await dump_ui("Controls")
			break
	await close_all()
	# The desk: what it offers after the diary has been found.
	if await enter_house() and await use_tile_kind(m.Tile.DESK, "the desk"):
		await frames(30)
		note("OBS", "desk opened tab=%s" % m.open_tab)
		await dump_ui("Desk first tab")
		await shot("desk_tab1")
		for i in 3:
			if pad:
				await tap_pad(JOY_BUTTON_RIGHT_SHOULDER)
			else:
				await tap_key(KEY_E)
			await frames(15)
			await dump_ui("Desk tab %d" % (i + 2))
		await shot("desk_catalog")
		var coins: int = m.money
		if await ledger_do("order:seeds_turnip"):
			note("ACT", "ordered turnip seeds: coins %d -> %d (\"%s\")" % [coins, m.money, m.message_label.text])
		await close_all()
	await leave_house()
	# Fishing with no rod made: the pole is on the hotbar, drawn locked.
	note("OBS", "rod tier %d; hotbar shows the fishing pole unlocked=%s" % [int(m.tool_tier["rod"]), m._hotbar_unlocked("rod")])
	if await pick_tool("rod"):
		var spots: Array = nearest(m.fish_spots.keys())
		var cast := false
		for t in spots:
			if reachable(t) and await approach(t, "a fishing spot"):
				await shot("fishing_locked_slot")
				var caught0 := int(m.stats["caught"])
				await tool()
				await frames(30)
				note("OBS", "cast with rod tier %d: \"%s\" fishing=%s" % [int(m.tool_tier["rod"]), m.message_label.text, m.fishing._is_fishing()])
				var w := 0
				while m.fishing._is_fishing() and int(m.stats["caught"]) == caught0 and w < 60 * 90:
					await process_frame
					w += 1
				note("OBS", "after %d s at the spot: caught %d (\"%s\"), Fishing level %d" % [w / 60, int(m.stats["caught"]) - caught0, m.message_label.text, m.progression._level("Fishing")])
				if m.fishing._is_fishing():
					await use()
				cast = true
				break
		if not cast:
			note("OBS", "no fishing spot could be reached (%d spots)" % spots.size())
	# The cave with no weapon: what does the game say when something attacks?
	await visit_cave(true)
	# A first weapon, from Craft (Gear tab), then the cave again.
	if await open_section("Craft"):
		await craft_tab("Gear")
		await press_action("craft_pick:gear:sharpened_stick", true)
		await frames(10)
		await shot("craft_sharpened_stick")
		var make := find_button("Make", true)
		if make != null and not make.disabled:
			await press("Make", true)
			note("ACT", "made a weapon: hand_r=%s (\"%s\")" % [str(m.equipment["hand_r"]), m.message_label.text])
		else:
			note("OBS", "the sharpened stick cannot be made yet: Bushcrafting %d, mats %s" % [m.progression._level("Bushcrafting"), JSON.stringify(_nonzero(m.materials))])
		await close_all()
	if m._has_weapon():
		await eat_from_bag()
		await visit_cave(true)
	note("OBS", "extras over: " + state())


# The walk with whoever waits at the gate, from the newest save: waits out mornings (eating, drinking, sleeping)
# until a walker is there, up to four days.
func _sc_trek() -> void:
	if not await continue_game():
		note("PROBLEM", "Continue did not load the save")
		return
	for d in 4:
		note("OBS", "--- day %d: walker waiting=%s lantern=%d edge_done=%s %s" % [m.day, m.trek._any_waiting(), m.lantern_tier, m.trek.edge_done, state()])
		if m.inside:
			await leave_house()
		if m.trek._any_waiting() and m.current_hour < 14.0:
			await eat_from_bag()
			var ok := await do_trek()
			note("OBS", "trek finished=%s edge_done=%s treks_done=%d chapter now=%s" % [ok, m.trek.edge_done, m.trek.treks_done, str(m._current_chapter().get("title", "-"))])
			if m.trek.edge_done or m.trek.treks_done > 0:
				break
		note("OBS", "picked %d forage" % await pick_forage())
		await eat_from_bag()
		await drink()
		await wait_until_hour(18.2)
		await sleep_in_bed()
	note("OBS", "trek scenario over: " + state())
	await wait_until_hour(18.2)
	await sleep_in_bed()

