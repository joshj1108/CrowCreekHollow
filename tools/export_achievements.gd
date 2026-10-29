extends SceneTree

# Writes steam_achievements.csv from AchievementSystem.LIST, for filling in Steamworks (App Admin, Stats &
# Achievements): one row per achievement with its API name, display name, description, whether it is hidden,
# the icon file names (achieved and unachieved, 256 x 256 JPG or PNG; not drawn yet) and its group in the game.
# Run it after changing the list, headless, from the project folder:
#   godot --path . --headless -s tools/export_achievements.gd

const OUT := "res://steam_achievements.csv"


func _initialize() -> void:
	var f := FileAccess.open(OUT, FileAccess.WRITE)
	f.store_line("api_name,display_name,description,hidden,icon,icon_locked,group")
	for a in AchievementSystem.LIST:
		var slug := str(a["id"]).trim_prefix("ACH_").to_lower()
		f.store_line(",".join([a["id"], _q(a["title"]), _q(a["text"]), "1" if bool(a.get("hidden", false)) else "0",
			"ach_%s.png" % slug, "ach_%s_locked.png" % slug, _q(AchievementSystem.GROUPS[int(a["group"])])]))
	f.close()
	print("Wrote %d achievements to %s" % [AchievementSystem.LIST.size(), OUT])
	quit()


func _q(text: Variant) -> String:
	return "\"%s\"" % str(text).replace("\"", "\"\"")
