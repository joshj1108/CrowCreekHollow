class_name AchievementSystem
extends RefCounted

# The achievements (DESIGN.md, Achievements): the game's signature moments in six groups, each with a Steam API
# name as its id. They pay nothing in the game; earning one plays the chime, says so, and tells Steam
# (SteamAchievements, which does nothing without the GodotSteam plugin). Each one reads a value (_value) that
# must reach its goal. Most values are the game's own state; the rest are counters in m.stats, bumped where
# the thing happens, so they save with the stats and need no keys of their own.
# - Hidden ones show as "???" in the panel until earned, and are hidden on Steam.
# - steam_achievements.csv lists them for Steamworks; tools/export_achievements.gd writes it from LIST.
# - "All three endings" reads every save on this machine: the endings any save has reached are kept in
#   PROFILE_PATH as well (not in headless runs, so the sim and the save test never write it).

var m: MainGame

const GROUPS := ["Story", "The wood", "Nights", "Folk", "The farm", "Secrets"]
const CHECK_EVERY := 0.4      # seconds between checks while playing
const DEEP := 20.0            # sanity under this is the last madness tier (MadnessSystem.TIERS)
const BACK := 60.0            # ... and back above this, sane again
const CLEAN_HARVESTS := 10    # a season "with crops growing" for the shadow's season: this many harvests in it
const PROFILE_PATH := "user://profile.cfg"
const SEASONS := ["Winter", "Spring", "Summer", "Autumn"]
const ROUTES := ["mill", "orchard", "chapel", "post"]   # the walkers' own routes (not the edge or the grove)

# goal 0: the size of what the value counts (_goal), so the list never asks for more than the game has.
const LIST := [
	# Story
	{"id": "ACH_FIRST_YEAR", "group": 0, "title": "The First Year", "text": "Finish the first ten chapters, up to A Home Worth Keeping.", "stat": "story_year1", "goal": 0},
	{"id": "ACH_HOUSE_PAGES", "group": 0, "title": "Whoever Has This Farm Next", "text": "Find all ten of Agnes Rook's torn pages about the farm.", "stat": "house_pages", "goal": 0},
	{"id": "ACH_KNOCK", "group": 0, "title": "His Knock", "text": "Face the Hollow when it knocks at your door like Elias.", "stat": "knock_faced", "goal": 1, "hidden": true},
	{"id": "ACH_MEETING", "group": 0, "title": "Thirty-One Hands", "text": "Have the vote on the bell put again at the mill, and win it.", "stat": "meeting_won", "goal": 1},
	{"id": "ACH_DAVY", "group": 0, "title": "Not Your Turn", "text": "Find Davy Tull in the roots of the great tree before he goes.", "stat": "davy_stopped", "goal": 1, "hidden": true},
	{"id": "ACH_ALL_CHAPTERS", "group": 0, "title": "The Second All Hallows", "text": "Finish every story chapter.", "stat": "story", "goal": 0},
	{"id": "ACH_END_BELL", "group": 0, "title": "The Hollow Sleeps", "text": "Reach the ending The Hollow Sleeps.", "stat": "ending_bell", "goal": 1},
	{"id": "ACH_END_ELIAS", "group": 0, "title": "Two Came Home", "text": "Reach the ending Two Came Home.", "stat": "ending_elias", "goal": 1, "hidden": true},
	{"id": "ACH_END_HOLLOW", "group": 0, "title": "The Line Under the Rooks", "text": "Reach the ending The Line Under the Rooks.", "stat": "ending_hollow", "goal": 1, "hidden": true},
	{"id": "ACH_END_ALL", "group": 0, "title": "Every Way It Could Go", "text": "Reach all three endings, in any of your saves.", "stat": "endings_all", "goal": 3},
	# The wood
	{"id": "ACH_EDGE", "group": 1, "title": "To the Wood's Edge", "text": "Walk Old Maren to the edge of the Rookery Wood.", "stat": "edge_walked", "goal": 1},
	{"id": "ACH_DARK_TRAIL", "group": 1, "title": "The Arm With the Crow", "text": "Take the dark trail at the fingerpost, and arrive.", "stat": "dark_treks", "goal": 1},
	{"id": "ACH_NIGHT_TREK", "group": 1, "title": "After Dark in the Rookery", "text": "Set out with a walker after 18:00, and arrive.", "stat": "night_treks", "goal": 1},
	{"id": "ACH_ALL_ROUTES", "group": 1, "title": "Every Way Through", "text": "Walk Maren to the mill, Davy to the orchard, and the vicar and the postman to the chapel.", "stat": "routes", "goal": 0},
	{"id": "ACH_WOOD_PAGES", "group": 1, "title": "Left in the Hollow Trees", "text": "Find all five of Agnes's pages from the wood.", "stat": "trek_pages", "goal": 0},
	{"id": "ACH_GROVE", "group": 1, "title": "Round and Round", "text": "Walk the woman in grey to the Hollow's grove.", "stat": "grove_walked", "goal": 1},
	{"id": "ACH_DREAD", "group": 1, "title": "The Wood Knows You", "text": "Walk the wood until its dread is at its height.", "stat": "dread", "goal": 0},
	{"id": "ACH_BARE", "group": 1, "title": "Nothing in the Pack", "text": "Walk someone past the wood's edge without giving them a ration or a loaf.", "stat": "bare_treks", "goal": 1},
	{"id": "ACH_DARK_NIGHT", "group": 1, "title": "Darker Than the Dark", "text": "Take the dark trail by night, and arrive.", "stat": "dark_night_treks", "goal": 1, "hidden": true},
	# Nights
	{"id": "ACH_FIRST_NIGHT", "group": 2, "title": "Something Walks This Farm", "text": "Live through your first night.", "stat": "events", "goal": 1},
	{"id": "ACH_SIGHTING", "group": 2, "title": "Hundreds of Them", "text": "See the Hollow at the far edge of the field.", "stat": "sighting", "goal": 1},
	{"id": "ACH_FACE_FIELD", "group": 2, "title": "Like Smoke", "text": "Hold the thing at the field's edge in your light until it thins away.", "stat": "faced_field", "goal": 1},
	{"id": "ACH_FACE_KNOCK", "group": 2, "title": "Hold the Door", "text": "Hold the door shut while the latch rattles.", "stat": "faced_knock", "goal": 1},
	{"id": "ACH_FACE_CROWS", "group": 2, "title": "Not One Crop", "text": "Drive the crows off your crops in the night.", "stat": "faced_crows", "goal": 1},
	{"id": "ACH_FACE_POND", "group": 2, "title": "Something Cold", "text": "Reach into the pond on the lights' third swell.", "stat": "faced_pond", "goal": 1},
	{"id": "ACH_FACE_WATCHER", "group": 2, "title": "Taller in the Light", "text": "Face the tall figure watching from beside the house.", "stat": "faced_watcher", "goal": 1},
	{"id": "ACH_FACE_STEPS", "group": 2, "title": "Don't Look Back", "text": "Outlast the footsteps behind you, indoors or in a lamp's light.", "stat": "faced_footsteps", "goal": 1},
	{"id": "ACH_HOLLOW", "group": 2, "title": "A Hundred Crows", "text": "Hold the Hollow in your light at your own door until it comes apart.", "stat": "faced_hollow", "goal": 1},
	{"id": "ACH_RAID", "group": 2, "title": "Not Tonight", "text": "Catch something at the coop or the barn in your own light.", "stat": "raids_won", "goal": 1},
	{"id": "ACH_WINTER", "group": 2, "title": "All Through the Long Dark", "text": "Keep every hen and goat you have through a whole winter.", "stat": "winter_kept", "goal": 1},
	{"id": "ACH_CLEAN_SEASON", "group": 2, "title": "Only a Field", "text": "Grow crops through a whole season without the shadow blighting one.", "stat": "clean_season", "goal": 1},
	{"id": "ACH_BACK", "group": 2, "title": "Back From Under", "text": "Let your sanity fall under 20, and bring it back above 60.", "stat": "madness_back", "goal": 1},
	{"id": "ACH_FACED_50", "group": 2, "title": "Into the Dark", "text": "Face fifty things that come in the night.", "stat": "faced", "goal": 50},
	# Folk
	{"id": "ACH_FRIEND", "group": 3, "title": "A Friend Down the Lane", "text": "Earn four hearts with one of the walkers.", "stat": "best_hearts", "goal": 4},
	{"id": "ACH_REQUEST", "group": 3, "title": "Good Neighbour", "text": "Bring a walker what they asked you for.", "stat": "requests_all", "goal": 1},
	{"id": "ACH_MAREN", "group": 3, "title": "The Minute Book", "text": "See Old Maren's last scene.", "stat": "scene_maren_book", "goal": 1},
	{"id": "ACH_DAVY_SCENE", "group": 3, "title": "Someone Should Walk for Him", "text": "See Davy Tull's last scene.", "stat": "scene_davy_turn", "goal": 1},
	{"id": "ACH_VICAR", "group": 3, "title": "The Register", "text": "See the vicar's last scene.", "stat": "scene_vicar_register", "goal": 1},
	{"id": "ACH_POST", "group": 3, "title": "In Your Own Hand", "text": "See the postman's last scene.", "stat": "scene_post_hand", "goal": 1, "hidden": true},
	{"id": "ACH_HEARTS", "group": 3, "title": "Ten Hearts, Four Doors", "text": "Earn ten hearts with Maren, Davy, the vicar and the postman.", "stat": "full_hearts", "goal": 0},
	{"id": "ACH_REQUESTS_ALL", "group": 3, "title": "Nothing Left Wanting", "text": "Bring the walkers everything they ask for, every request.", "stat": "requests_all", "goal": 0},
	# The farm
	{"id": "ACH_FIRST_HARVEST", "group": 4, "title": "Food Takes Time", "text": "Harvest your first crop.", "stat": "harvested", "goal": 1},
	{"id": "ACH_FIRST_CATCH", "group": 4, "title": "Hook and Line", "text": "Catch a fish.", "stat": "caught", "goal": 1},
	{"id": "ACH_FIRST_MEAL", "group": 4, "title": "Warm Meal", "text": "Cook a meal at the fire.", "stat": "cooked", "goal": 1},
	{"id": "ACH_LANTERN", "group": 4, "title": "Tin Light", "text": "Build a Tin Lantern.", "stat": "lantern_tier", "goal": 1},
	{"id": "ACH_RESTORED", "group": 4, "title": "A Home Worth Keeping", "text": "Restore the farmhouse fully.", "stat": "house_stage", "goal": 3},
	{"id": "ACH_HOLLOW_LANTERN", "group": 4, "title": "Hollow Light", "text": "Build a Hollow Lantern.", "stat": "lantern_tier", "goal": 3},
	{"id": "ACH_YARD", "group": 4, "title": "A Full Yard", "text": "Keep four hens and three goats at once.", "stat": "yard", "goal": 7},
	{"id": "ACH_ALL_CROPS", "group": 4, "title": "Every Row", "text": "Harvest every kind of crop.", "stat": "crops_all", "goal": 0},
	{"id": "ACH_ALL_FISH", "group": 4, "title": "Every Fish in the Pond", "text": "Catch every kind of fish.", "stat": "fish_all", "goal": 0},
	{"id": "ACH_ALL_RECIPES", "group": 4, "title": "Agnes's Kitchen", "text": "Cook every recipe at least once.", "stat": "recipes_all", "goal": 0},
	{"id": "ACH_EXTENDED", "group": 4, "title": "Under a New Roof", "text": "Build the cellar room, the covered porch and the second storey.", "stat": "extensions", "goal": 0},
	{"id": "ACH_DEED", "group": 4, "title": "The Land Is Yours", "text": "Pay off the land deed.", "stat": "deed", "goal": 1},
	{"id": "ACH_MASTER", "group": 4, "title": "A Lifetime's Trade", "text": "Reach level 10 in every skill.", "stat": "skills_maxed", "goal": 0},
	# Secrets
	{"id": "ACH_PALE_CARP", "group": 5, "title": "Let Go of a Fish", "text": "Land a pale carp from the pond after 22:00.", "stat": "fish_pale_carp", "goal": 1, "hidden": true},
	{"id": "ACH_COLLAPSE", "group": 5, "title": "Where You Stand", "text": "Be out on your feet when the night takes you.", "stat": "collapses", "goal": 1, "hidden": true},
	{"id": "ACH_WADE", "group": 5, "title": "To the Waist in Winter", "text": "Wade a flooded hollow in winter with your walker on your back.", "stat": "winter_wade", "goal": 1, "hidden": true},
	{"id": "ACH_LIGHTS", "group": 5, "title": "They Led You True", "text": "Follow the lights off the path, and come out where you meant to.", "stat": "lights_true", "goal": 1, "hidden": true},
	{"id": "ACH_CAIRN", "group": 5, "title": "A Toll for the Crows", "text": "Leave something on the cairn of crow skulls.", "stat": "cairn_offered", "goal": 1, "hidden": true},
	{"id": "ACH_FORTY", "group": 5, "title": "Forty in the Great Tree", "text": "Hold forty crow feathers at once.", "stat": "feathers", "goal": 40, "hidden": true},
]

# The old tiered list (save version 15 and before), by id, to the new id an earned one carries over to.
# Old ids with no match are dropped; the new ones re-check from the saved stats on the next frame.
const OLD_IDS := {
	"first_fruit": "ACH_FIRST_HARVEST", "first_catch": "ACH_FIRST_CATCH", "first_meal": "ACH_FIRST_MEAL",
	"tin_light": "ACH_LANTERN", "first_sleep": "ACH_FIRST_NIGHT", "watcher": "ACH_FIRST_NIGHT",
	"restored": "ACH_RESTORED", "hollow_light": "ACH_HOLLOW_LANTERN", "story_end": "ACH_ALL_CHAPTERS",
}

var _last_check := -1000.0
var _synced := false          # earned ones are sent to Steam once a session, in case they were earned without it
var _profile_endings := {}    # from PROFILE_PATH: every ending any save on this machine has reached
var _profile_read := false


func _init(main: MainGame) -> void:
	m = main


static func find(id: String) -> Dictionary:
	for a in LIST:
		if a["id"] == id:
			return a
	return {}


static func _headless() -> bool:
	return DisplayServer.get_name() == "headless"


# Each frame from main, throttled to CHECK_EVERY; force checks now (the balance sim, once a day).
func _check(force := false) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if not force and now - _last_check < CHECK_EVERY:
		return
	_last_check = now
	_note_sanity()
	var earned: Array = []
	for a in LIST:
		if not m.achievements_done.has(a["id"]) and _value(a) >= _goal(a):
			m.achievements_done[a["id"]] = true
			earned.append(a)
	# The first check of a session also sends Steam the ones earned before, in case they were earned without it.
	var send: Array = earned.map(func(a: Dictionary) -> String: return str(a["id"]))
	if not _synced:
		_synced = true
		send = m.achievements_done.keys()
	for id in send:
		SteamAchievements.unlock(str(id), false)
	if not send.is_empty():
		SteamAchievements.store()
	if earned.is_empty():
		return
	m.play_sfx("chime")
	m.music.sting("sting_achievement")
	# Several at once (an old save re-checking on load) share one message.
	if earned.size() == 1:
		m._show_message("Achievement: %s. %s" % [earned[0]["title"], earned[0]["text"]])
	else:
		var titles: Array = []
		for a in earned:
			titles.append(str(a["title"]))
		m._show_message("Achievements: %s." % ", ".join(titles))


func _goal(a: Dictionary) -> int:
	if int(a["goal"]) > 0:
		return int(a["goal"])
	match str(a["stat"]):
		"story_year1":
			return _year_one_size()
		"house_pages":
			return m.mystery.PAGES.size()
		"trek_pages":
			return m.mystery.TREK_PAGES.size()
		"story":
			return m.STORY.size()
		"routes":
			return ROUTES.size()
		"dread":
			return m.trek.MAX_DREAD
		"full_hearts":
			return FolkSystem.IDS.size()
		"requests_all":
			return FolkSystem.REQUESTS.size()
		"crops_all":
			return m.CROPS.size()
		"fish_all":
			return FishingSystem.FISH.size()
		"recipes_all":
			return Foods.RECIPES.size()
		"extensions":
			return EstateSystem.EXTENSIONS.size()
		"skills_maxed":
			return m.SKILLS.size()
	return 1


# The first year's chapters: every one up to and including "home".
func _year_one_size() -> int:
	for i in m.STORY.size():
		if m.STORY[i]["id"] == "home":
			return i + 1
	return m.STORY.size()


func _value(a: Dictionary) -> int:
	var stat := str(a["stat"])
	match stat:
		"story_year1":
			var n := 0
			for i in _year_one_size():
				if m.quests_done.has(m.STORY[i]["id"]):
					n += 1
			return n
		"house_pages":
			return m.mystery._count(m.mystery.PAGES)
		"trek_pages":
			return m.mystery._count(m.mystery.TREK_PAGES)
		"meeting_won":
			return 1 if m.act.meeting == "won" else 0
		"knock_faced":
			return 1 if m.act._lived("knock") else 0   # not closed quietly by the bell
		"davy_stopped":
			return 1 if m.act.davy == "stopped" else 0
		"endings_all":
			return _all_endings().size()
		"routes":
			var n := 0
			for id in ROUTES:
				if int(m.trek.walked.get(id, 0)) > 0:
					n += 1
			return n
		"dread":
			return m.trek._dread()
		"sighting":
			return 1 if m.nights.sighting_seen else 0
		"faced_field":
			return int(m.stats.get("faced_field", 0)) + int(m.stats.get("faced_first", 0))
		"best_hearts":
			var best := 0
			for id in FolkSystem.IDS:
				best = maxi(best, m.folk._hearts(id))
			return best
		"full_hearts":
			var n := 0
			for id in FolkSystem.IDS:
				if m.folk._points(id) >= FolkSystem.MAX_POINTS:
					n += 1
			return n
		"requests_all":
			return m.folk.requests_done.size()
		"yard":
			return mini(m.hens, m.COOP_HENS_MAX) + mini(m.goats, m.BARN_GOATS_MAX)
		"crops_all":
			return _kinds("crop_", m.CROPS.keys())
		"fish_all":
			var ids: Array = []
			for f in FishingSystem.FISH:
				ids.append(f["id"])
			return _kinds("fish_", ids)
		"recipes_all":
			var ids: Array = []
			for r in Foods.RECIPES:
				ids.append(r["food"])
			return _kinds("cook_", ids)
		"extensions":
			return m.estate.built.size()
		"deed":
			return 1 if m.estate._deed_owned() else 0
		"skills_maxed":
			var n := 0
			for skill in m.SKILLS:
				if m.progression._level(skill) >= ProgressionSystem.LEVEL_CAP:
					n += 1
			return n
		"feathers":
			return int(m.materials["feathers"])
	if stat.begins_with("ending_"):
		return 1 if m.act.endings.has(stat.trim_prefix("ending_")) else 0
	if stat.begins_with("scene_"):
		return 1 if m.folk.seen.has(stat.trim_prefix("scene_")) else 0
	return m.progression._stat_value(stat)


# How many of ids have a counter (prefix + id) above nothing.
func _kinds(prefix: String, ids: Array) -> int:
	var n := 0
	for id in ids:
		if int(m.stats.get(prefix + str(id), 0)) > 0:
			n += 1
	return n


# --- The night's tolls ---------------------------------------------------------------------------

# The last madness tier, and coming back from it: counters, so they save with the stats.
func _note_sanity() -> void:
	if m.sanity < DEEP:
		m.stats["deep_madness"] = 1
	elif m.sanity >= BACK and int(m.stats.get("deep_madness", 0)) > 0:
		m.stats["madness_back"] = 1


# Each morning (main's _end_day, after the day turns): when the season changes, the one just ended is judged.
# The season's start is kept in the stats as counters: its number (1-4, 0 before the first morning), and the
# blight, harvests, animals and animal losses at its start.
func _morning() -> void:
	var now := SEASONS.find(m._season_today()) + 1
	var was := int(m.stats.get("season_now", 0))
	if now == was:
		return
	if was > 0:
		var stock := m.hens + m.goats
		if SEASONS[was - 1] == "Winter" and int(m.stats.get("season_stock", 0)) > 0 and stock > 0 \
				and int(m.stats.get("animals_lost", 0)) == int(m.stats.get("season_lost", 0)):
			m.stats["winter_kept"] = 1
		if not m.trek.grove_done and int(m.stats.get("blighted", 0)) == int(m.stats.get("season_blight", 0)) \
				and int(m.stats["harvested"]) - int(m.stats.get("season_harvest", 0)) >= CLEAN_HARVESTS:
			m.stats["clean_season"] = 1
	m.stats["season_now"] = now
	m.stats["season_stock"] = m.hens + m.goats
	m.stats["season_lost"] = int(m.stats.get("animals_lost", 0))
	m.stats["season_blight"] = int(m.stats.get("blighted", 0))
	m.stats["season_harvest"] = int(m.stats["harvested"])


# --- Every save's endings ------------------------------------------------------------------------

func _all_endings() -> Dictionary:
	var all := _read_profile().duplicate()
	var fresh := false
	for id in m.act.endings:
		if not all.has(id):
			all[id] = true
			fresh = true
	if fresh:
		_write_profile(all)
	return all


func _read_profile() -> Dictionary:
	if _profile_read or _headless():
		return _profile_endings
	_profile_read = true
	var cfg := ConfigFile.new()
	if cfg.load(PROFILE_PATH) == OK:
		for id in cfg.get_value("endings", "reached", []):
			_profile_endings[str(id)] = true
	return _profile_endings


func _write_profile(all: Dictionary) -> void:
	_profile_endings = all.duplicate()
	if _headless():
		return
	var cfg := ConfigFile.new()
	cfg.load(PROFILE_PATH)
	cfg.set_value("endings", "reached", all.keys())
	cfg.save(PROFILE_PATH)


# --- The panel -----------------------------------------------------------------------------------

func _row(a: Dictionary) -> Dictionary:
	var done: bool = m.achievements_done.has(a["id"])
	var goal := _goal(a)
	var shown := mini(_value(a), goal)
	if bool(a.get("hidden", false)) and not done:
		return {"name": "???", "status": "Hidden", "status_kind": "info", "value": "A secret of the farm. It shows itself once earned.", "progress": 0.0}
	return {
		"name": str(a["title"]),
		"status": "Done" if done else "%d/%d" % [shown, goal],
		"status_kind": "done" if done else "info",
		"value": str(a["text"]),
		"progress": 1.0 if done else float(shown) / float(goal),
	}


# Old saves: earned ids from the tiered list carried over (SaveSystem._migrate, version 16).
static func migrate_ids(old: Variant) -> Dictionary:
	var out := {}
	if typeof(old) != TYPE_DICTIONARY:
		return out
	for id in old:
		var key := str(id)
		if not find(key).is_empty():
			out[key] = true
		elif OLD_IDS.has(key):
			out[OLD_IDS[key]] = true
	return out
