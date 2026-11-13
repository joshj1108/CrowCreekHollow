extends SceneTree

# Rasterises SVG files to PNG (CCH-LOOP-001 charts): godot --headless -s tools/svg_to_png.gd -- a.svg b.svg
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var img := Image.new()
		var err := img.load_svg_from_string(FileAccess.get_file_as_string(a), 1.0)
		if err != OK:
			print("could not read ", a)
			continue
		img.save_png(a.get_basename() + ".png")
		print("wrote ", a.get_basename() + ".png")
	quit()
