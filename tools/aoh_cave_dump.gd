extends SceneTree

# Prints the mining cave's layout for a day, to pick capture tiles (ART-OVERHAUL-001 Stage C).
#   godot --path . --headless -s tools/aoh_cave_dump.gd -- day=1
# Legend: # wall, . floor, c copper, i iron, E exit, S start.
func _initialize() -> void:
	var opt := {"day": "1"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._on_title_start("new", 9)
	main.day = int(opt["day"])
	main._generate_cave()
	var T = main.Tile
	for y in main.CAVE_H:
		var s := ""
		for x in main.CAVE_W:
			var k: int = main.cave[y][x]
			if Vector2i(x, y) == main.CAVE_START:
				s += "S"
			elif k == T.WALL:
				s += "#"
			elif k == T.ORE_COPPER:
				s += "c"
			elif k == T.ORE_IRON:
				s += "i"
			elif k == T.CAVE_EXIT:
				s += "E"
			else:
				s += "."
		print("%2d %s" % [y, s])
	quit()
