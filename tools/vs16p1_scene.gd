extends "res://tools/vs16_scene.gd"

# ART-005 VS16-P1 (zero-generation, NON-PRODUCTION): VS16's harness with one more switch. Nothing in the game changes.
#   p1   with cabin16: draw the VS16-P1 finishing-pass cabin (art/style_tests/ART-005/vs16p1/cabin/
#        house_{day,night}.png, tools/vs16p1_cabin.py) instead of the VS16 cabin, on the same anchor and scale.
# Run by tools/vs16p1_run.sh in the clean export, exactly as VS16 was.

const VS16P1 := "res://art/style_tests/ART-005/vs16p1/"


func _vs_tex(path: String) -> Texture2D:
	var root: String = VS16P1 if o3.has("p1") else VS16
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(root + path)))
