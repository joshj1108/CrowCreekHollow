extends SceneTree

# Saves the shared UI theme (UiTheme.build() in scripts/ui_theme.gd) to art/ui/theme/crow_creek_ui.tres, the
# file the game loads. Run it after changing ui_theme.gd:
#   godot --path . --headless -s tools/build_ui_theme.gd
# scripts/ui_theme.gd is the source; the .tres is its saved form, so it can be opened in the editor.

func _initialize() -> void:
	var theme := UiTheme.build()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(UiTheme.THEME_PATH.get_base_dir()))
	var err := ResourceSaver.save(theme, UiTheme.THEME_PATH)
	if err != OK:
		push_error("build_ui_theme.gd: could not save %s (%d)" % [UiTheme.THEME_PATH, err])
		quit(1)
		return
	# Read it back and check the components are all there.
	var saved := load(UiTheme.THEME_PATH) as Theme
	var missing := 0
	for pair in [["panel", "MenuFrame"], ["panel", "DescriptionPanel"], ["panel", "DialogPanel"], ["panel", "TooltipPanel"],
			["normal", "TabActive"], ["normal", "TabInactive"], ["focus", "Button"], ["disabled", "Button"],
			["normal", "SecondaryButton"], ["focus", "ListEntry"], ["grabber", "VScrollBar"], ["separator", "HSeparator"],
			["normal", "Badge"], ["normal", "BadgeAlert"], ["normal", "KeyGlyph"], ["fill", "InkProgress"]]:
		if not saved.has_stylebox(pair[0], pair[1]):
			print("MISSING stylebox %s/%s" % pair)
			missing += 1
	for type in ["DisplayTitle", "NumberLabel", "InkBody", "InkHeading"]:
		if not saved.has_font("font", type):
			print("MISSING font %s" % type)
			missing += 1
	print("saved %s, %d missing" % [UiTheme.THEME_PATH, missing])
	quit(missing)
