class_name MadnessSystem
extends RefCounted

# Low sanity changes the world, in three tiers (TIERS). Under 60, the crows watch you by day and you hear things
# that aren't there (the false sounds are AmbienceSystem.EVENTS with a "fear"). Under 40, figures stand at the edge
# of the screen and are gone when you look, and the tool in your hand is not the one you picked up. Under 20, the
# HUD lies: the clock shows the wrong hour for a moment, and a ripe crop stands in the field that isn't there. Below
# that, the vicar comes to bless the house (SanitySystem._morning_bless). None of it costs anything by itself: it
# shows how far gone you are, so the player knows to get inside, sleep, and face the nights.

var m: MainGame

const TIERS := [60.0, 40.0, 20.0]
const WATCH_CROWS := [0, 2, 3, 5]                 # crows watching you by day, at each tier
const FIGURE_EVERY := [Vector2.ZERO, Vector2.ZERO, Vector2(30, 70), Vector2(12, 30)]   # seconds between figures
const FIGURE_SECONDS := 1.8
const FIGURE_NEAR := 5.0                          # tiles: walk this close and it is gone
const SWAP_EVERY := Vector2(90, 240)              # seconds before the tool in your hand changes, once a day
const LIE_EVERY := Vector2(25, 60)
const LIE_SECONDS := 4.0
const FAKE_EVERY := Vector2(40, 100)
const FAKE_NEAR := 2.0

var layer: Node2D
var figure_pos := Vector2.ZERO
var figure_left := 0.0
var figure_wait := 20.0
var swap_wait := 120.0
var swap_day := -1
var lie_wait := 30.0
var lie_left := 0.0
var lie_hours := 0
var fake_crop := Vector2i(-1, -1)
var fake_wait := 40.0


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	layer = Node2D.new()
	layer.z_index = 19
	layer.draw.connect(_draw)
	m.add_child(layer)


# 0 while sane, then 1, 2 and 3 as sanity falls under each of TIERS.
func _tier() -> int:
	var tier := 0
	for i in TIERS.size():
		if m.sanity < float(TIERS[i]):
			tier = i + 1
	return tier


func _update(delta: float) -> void:
	var tier := _tier()
	var out := m.world_started and not m.inside and not m.in_cave and not m.trek.active
	layer.visible = out
	# Figures at the edge of the screen.
	if tier >= 2 and out:
		if figure_left > 0.0:
			figure_left -= delta
			if (m.player.position - figure_pos).length() < FIGURE_NEAR * float(m.PX):
				figure_left = minf(figure_left, 0.15)
		else:
			figure_wait -= delta
			if figure_wait <= 0.0:
				_spawn_figure()
				figure_wait = randf_range(FIGURE_EVERY[tier].x, FIGURE_EVERY[tier].y)
	else:
		figure_left = 0.0
	# The tool in your hand is not the one you picked up, once a day.
	if tier >= 2 and out and swap_day != m.day and m.open_tab == "":
		swap_wait -= delta
		if swap_wait <= 0.0:
			_swap_tool()
	# The HUD lies.
	if tier >= 3:
		if lie_left > 0.0:
			lie_left -= delta
		else:
			lie_wait -= delta
			if lie_wait <= 0.0:
				lie_left = LIE_SECONDS
				lie_hours = (1 + randi() % 3) * (1 if randf() < 0.5 else -1)
				lie_wait = randf_range(LIE_EVERY.x, LIE_EVERY.y)
		if out:
			if fake_crop.x >= 0:
				if (m.player.position - m._tile_center(fake_crop.x, fake_crop.y)).length() < FAKE_NEAR * float(m.PX):
					fake_crop = Vector2i(-1, -1)
					m._show_message("There was a pumpkin here, ripe and heavy. You're sure there was.")
			else:
				fake_wait -= delta
				if fake_wait <= 0.0:
					fake_wait = randf_range(FAKE_EVERY.x, FAKE_EVERY.y)
					fake_crop = _fake_spot()
	else:
		lie_left = 0.0
		fake_crop = Vector2i(-1, -1)
	if tier >= 1:
		layer.queue_redraw()


func _spawn_figure() -> void:
	var view := m.get_viewport_rect().size / m.camera.zoom
	var centre := m.camera.get_screen_center_position()
	var side := -1.0 if randf() < 0.5 else 1.0
	figure_pos = centre + Vector2(side * view.x * 0.44, randf_range(-0.3, 0.3) * view.y)
	figure_left = FIGURE_SECONDS
	if randf() < 0.5:
		m.ambience.play_side("whisper", -12.0)


func _swap_tool() -> void:
	swap_day = m.day
	swap_wait = randf_range(SWAP_EVERY.x, SWAP_EVERY.y)
	var options: Array = []
	for i in m.HOTBAR_TOOLS.size():
		if i != m.active_slot and m._hotbar_unlocked(str(m.HOTBAR_TOOLS[i]["id"])):
			options.append(i)
	if options.is_empty() or m.active_slot >= m.HOTBAR_TOOLS.size():
		return
	var was := str(m.TOOL_LABELS[m.HOTBAR_TOOLS[m.active_slot]["id"]])
	m.active_slot = int(options.pick_random())
	m._show_message("Weren't you holding the %s? It's the %s in your hand." % [was, str(m.TOOL_LABELS[m.HOTBAR_TOOLS[m.active_slot]["id"]])])


# An empty soil tile on a plot, for a crop that isn't there.
func _fake_spot() -> Vector2i:
	var spots: Array = []
	for plot in [m.PLOT_ONE, m.PLOT_TWO]:
		var r: Rect2i = plot
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var t := m._world_tile(x, y)
				if m.map[t.y][t.x] == MainGame.Tile.SOIL and not m.crops.has(t):
					spots.append(t)
	return Vector2i(-1, -1) if spots.is_empty() else spots.pick_random()


# The hour the HUD shows: now and then, at the lowest tier, the wrong one.
func _clock_hour(hour: float) -> float:
	return fposmod(hour + (lie_hours if lie_left > 0.0 else 0), 24.0)


func _draw() -> void:
	var tier := _tier()
	if tier == 0:
		return
	var ci := layer
	var px := float(m.PX)
	# The crows watching by day, from the roof and the tree tops, their heads turned to you.
	if m.current_hour < m.DUSK_HOUR and not m.crow_perches.is_empty():
		for k in int(WATCH_CROWS[tier]):
			var perch: Dictionary = m.crow_perches[hash([m.day, "watch", k]) % m.crow_perches.size()]
			var p: Vector2 = perch["ground"] - Vector2(0, float(perch["alt"])) + Vector2(float(k % 3) * 9.0 - 9.0, 0)
			var face := 1.0 if m.player.position.x >= p.x else -1.0
			ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-px * 0.25 * face, 0), p + Vector2(px * 0.12 * face, -px * 0.2), p + Vector2(px * 0.22 * face, 0), p + Vector2(0, px * 0.08)]), Color(0.04, 0.03, 0.05))
			ci.draw_circle(p + Vector2(px * 0.17 * face, -px * 0.2), px * 0.1, Color(0.04, 0.03, 0.05))
			ci.draw_circle(p + Vector2(px * 0.2 * face, -px * 0.23), 1.6, Color(1.6, 0.3, 0.2) if tier >= 3 else Color(0.95, 0.9, 0.75))
	# A figure at the edge of the screen, gone when you look.
	if figure_left > 0.0:
		var a := clampf(figure_left / 0.4, 0.0, 1.0) * 0.8
		var s := figure_pos
		ci.draw_colored_polygon(PackedVector2Array([s + Vector2(-px * 0.35, px * 0.4), s + Vector2(px * 0.35, px * 0.4), s + Vector2(px * 0.2, -px * 0.7), s + Vector2(-px * 0.2, -px * 0.7)]), Color(0.02, 0.01, 0.05, a))
		ci.draw_circle(s + Vector2(0, -px * 0.75), px * 0.26, Color(0.02, 0.01, 0.05, a))
		ci.draw_circle(s + Vector2(-5, -px * 0.78), 2.0, Color(2.4, 0.3, 0.2, a))
		ci.draw_circle(s + Vector2(5, -px * 0.78), 2.0, Color(2.4, 0.3, 0.2, a))
	# The crop that isn't there: a ripe pumpkin on its vine.
	if fake_crop.x >= 0:
		var c := m._tile_center(fake_crop.x, fake_crop.y)
		ci.draw_line(c + Vector2(-px * 0.4, px * 0.2), c + Vector2(px * 0.4, px * 0.15), Color(0.25, 0.4, 0.2), 3.0)
		ci.draw_circle(c + Vector2(-px * 0.3, px * 0.1), px * 0.13, Color(0.3, 0.48, 0.24))
		ci.draw_circle(c + Vector2(0, px * 0.05), px * 0.3, Color(0.2, 0.1, 0.05))
		ci.draw_circle(c + Vector2(0, px * 0.05), px * 0.27, Color(0.85, 0.48, 0.16))
		ci.draw_line(c + Vector2(0, -px * 0.2), c + Vector2(0, px * 0.3), Color(0.62, 0.32, 0.1), 2.0)
		ci.draw_rect(Rect2(c + Vector2(-2, -px * 0.3), Vector2(4, 6)), Color(0.3, 0.25, 0.12))
