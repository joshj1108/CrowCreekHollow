extends "res://tools/concept_farm.gd"

# FARM-001 exporter (one-off, not headless: the concept build needs a renderer). Runs the concept farm build and
# writes what production needs from it, then quits:
#   godot --path . -s tools/concept_export.gd -- layout_out=tools/concept_layout.json
# layout_out: the W-4 grid with the approach path, the drawn-only overlay and every tile a concept prop blocks
# (the harness's c_block), read by tools/concept_grid.py to write tools/farm_grid.txt.


func _finish(main, opt: Dictionary) -> void:
	if o3.has("layout_out"):
		var blocks: Array = []
		for t in c_block:
			blocks.append([t.x, t.y])
		blocks.sort()
		var ov := {}
		for t in overlay:
			ov["%d,%d" % [t.x, t.y]] = overlay[t]
		var f := FileAccess.open(str(o3["layout_out"]), FileAccess.WRITE)
		f.store_string(JSON.stringify({"grid": grid, "blocks": blocks, "overlay": ov,
			"cave": [CAVE_T.x, CAVE_T.y], "stall": [STALL_T.position.x, STALL_T.position.y]}, "  "))
		f.close()
		print("concept_export: wrote ", o3["layout_out"], " (", blocks.size(), " blocked prop tiles)")
		_restore()
		quit()
		return
	await super._finish(main, opt)
