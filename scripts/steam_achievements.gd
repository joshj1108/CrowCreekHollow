class_name SteamAchievements
extends RefCounted

# The bridge to Steam's achievements. With the GodotSteam plugin in the build, its "Steam" singleton is
# there and an unlock calls setAchievement and storeStats; without it (the editor, test builds, the sim)
# every call does nothing. The plugin itself is not part of the project. The API names are the achievement
# ids in AchievementSystem.LIST, and steam_achievements.csv lists them for Steamworks.


static func _steam() -> Object:
	if Engine.has_singleton("Steam"):
		return Engine.get_singleton("Steam")
	return null


static func available() -> bool:
	return _steam() != null


# store: send it to Steam's servers now (false when several unlock together, followed by one store()).
static func unlock(api_name: String, store_now := true) -> void:
	var steam := _steam()
	if steam == null:
		return
	steam.call("setAchievement", api_name)
	if store_now:
		steam.call("storeStats")


static func store() -> void:
	var steam := _steam()
	if steam != null:
		steam.call("storeStats")
