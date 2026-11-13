extends SceneTree

# CCH-PLAYABLE-002 review shots (windowed, throwaway profile): the day-4 morning report from the keyboard play log
# with an everyday line under it, the desk prompt, and the diary's "What the day said" page. Half-size PNGs.
#   godot --path . -s tools/playable002_shots.gd -- report=<file with the report text> out=<dir>
var m: MainGame
var opt := {"report": "", "out": "art/style_tests/CCH-PLAYABLE-002/review/after"}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := str(a).split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else ""
	DisplayServer.window_set_size(Vector2i(1280, 720))
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.resize(img.get_width() / 2, img.get_height() / 2, Image.INTERPOLATE_NEAREST)
	img.save_png("res://%s/%s.png" % [opt["out"], name])
	print("SHOT ", name)


func _run() -> void:
	TitleMenu.pending_name = "probe"
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await frames(3)
	m._on_title_start("new", 9)
	await frames(30)
	m.day = 4
	m._enter_house()
	await frames(10)
	m._show_morning_report(FileAccess.get_file_as_string(opt["report"]).strip_edges())
	m._show_message("You step inside. The air is cold and smells of old wood.")
	await frames(30)
	await shot("d4_morning_report_held")
	# The next part, once the first has been held.
	await frames(60 * 11)
	await shot("d4_morning_report_part2")
	# The desk prompt, before the diary is found.
	for y in m.INT_H:
		for x in m.INT_W:
			if m.interior[y][x] == MainGame.Tile.DESK:
				var stand := m.INT_ORIGIN + Vector2i(x, y + 1)
				m.player.position = m._tile_center(stand.x, stand.y)
				m.player.facing = Vector2.UP
	await frames(20)
	await shot("desk_prompt")
	m._find_diary()
	await frames(30)
	# Turn to the "What the day said" section: it is the second section.
	var ab: ActionBar = m.action_bar
	ab.book_section = 1
	ab.book_spread = 0
	ab._turn_to(true, false, false)
	await frames(30)
	await shot("diary_what_the_day_said")
	SaveSystem.delete_save(m._save_path())
	quit()
