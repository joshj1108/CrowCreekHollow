extends "res://tools/art003_wide.gd"

# ART-005 HC1 Step 1 (audit only, non-production): the ART-003 W-4 homestead harness (art003_wide.gd) with three
# evidence-only switches. Nothing in the game, its camera, its art, its lighting or its saves changes; the switches
# act on this harness run only. Not headless (needs a renderer). Run it in the clean export, as C3 was:
#   godot --path builds/review/ART-005/p1_export -s tools/hc1_audit.gd -- mode=wide layout=b grass=1 art=f2 \
#     house=g7:c2 at=45,13 hour=12 out=builds/review/ART-005/hc1/x.png
# Extra options, on top of art003_wide.gd's:
#   nofarmer        hide the farmer's sprite (the camera still sits on the farmer's spot), for the stitched overview;
#                   use lantern=0 at night so no lantern pool is left behind
#   fhd=today       a borderless 1920x1080 window at the screen's corner: the game's own canvas_items stretch, so one
#                   art px is 4.5 screen px (what a 1080p player sees today, non-integer)
#   fhd=int         the same window with the stretch off and the harness camera at 4/3 zoom: tile = 64 px, one art px
#                   = 4 screen px (the house's = 2), the ART-005 harness's "integer framing". Harness-only framing
#   camlog          write <out>_cam.txt: per frame, the camera's screen centre in world units (for the pan analysis)


func _initialize() -> void:
	var o := _opts()
	if o.has("fhd"):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	await super._initialize()


var cam_lines: PackedStringArray = []


func _process(d):
	if o3.has("camlog") and mainref != null and mainref.camera != null:
		var c: Vector2 = mainref.camera.get_screen_center_position()
		cam_lines.append("%d %.4f %.4f" % [Engine.get_process_frames(), c.x, c.y])
	return false


func _finish(main, opt: Dictionary) -> void:
	if o3.has("fhd"):
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		DisplayServer.window_set_position(Vector2i(0, 0))
		if str(o3["fhd"]) == "int":
			root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
			main.camera.zoom = Vector2(4.0 / 3.0, 4.0 / 3.0)
	if o3.has("nofarmer"):
		main.player.visible = false
	if o3.has("camlog"):
		tree_exiting_log()
	await super._finish(main, opt)


func tree_exiting_log() -> void:
	# Written when the run quits (main leaves the tree), so the whole recording is in it.
	mainref.tree_exiting.connect(func() -> void:
		var out := ProjectSettings.globalize_path("res://" + str(o3["out"])).get_basename() + "_cam.txt"
		DirAccess.make_dir_recursive_absolute(out.get_base_dir())
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string("\n".join(cam_lines))
		f.close())
