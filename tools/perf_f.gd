extends "res://tools/capture.gd"

# CCH-CONSOLIDATED-003 Phase F: frame-time benchmark with real cave combat. Takes every tools/capture.gd option
# (pass perf to time it); in the cave (cave ctile=16,19 face=right lantern=3) it first sets five live creatures (two
# bats, a lizard, two snakes) round the farmer, chasing and striking as in play, and the farmer swings his sword
# every 0.4 s while they are timed. Works unchanged in older builds (it only uses combat_sys._new_foe and _swing),
# so the same scene can be timed BEFORE and AFTER:
#   godot --path . -s tools/perf_f.gd -- out=builds/review/perf.png cave ctile=16,19 face=right lantern=3 perf
# Prints the same "PERF" line as capture.gd's perf. Plays in capture.gd's slot; never touches slots 1-3.


func _perf() -> void:
	var main = root.get_child(root.get_child_count() - 1)
	var fighting: bool = main.in_cave
	var full_hp: int = main.hp
	if fighting:
		main.foes = []
		var kinds := ["bat", "bat", "lizard", "snake", "snake"]
		for i in kinds.size():
			var a := TAU * float(i) / kinds.size()
			var foe: Dictionary = main.combat_sys._new_foe(kinds[i], Vector2i.ZERO)
			foe["pos"] = main.player.position + Vector2(cos(a), sin(a)) * 2.2 * main.PX
			foe["home"] = foe["pos"]
			foe["hp"] = 9999
			main.foes.append(foe)
		main.active_slot = 0
		main.equipment["hand_r"] = "iron_sword"
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for i in 60:
		await process_frame
	var frames: Array = []
	var proc := 0.0
	var last := Time.get_ticks_usec()
	for i in 300:
		if fighting and i % 24 == 0:
			main.hp = full_hp   # keep the farmer standing through the run (timing only)
			main.swing_cool = 0.0
			main._swing()
		await process_frame
		var now := Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		proc += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	frames.sort()
	var mean := 0.0
	for f in frames:
		mean += f
	mean /= frames.size()
	print("PERF frame_ms_mean=%.2f frame_ms_p95=%.2f process_ms_mean=%.2f fps=%.0f foes=%d" % [mean, frames[int(frames.size() * 0.95)], proc / 300.0, 1000.0 / mean, main.foes.size()])
