class_name FishingSystem
extends RefCounted

var m: MainGame

# What bites in the pond, and when. The fish themselves (name, price, food) are in Foods.LIST under the same id.
# seasons: empty means all year. time: "day" (06:00 to dusk), "night" (dusk to 03:00), "late" (22:00 on), or "any".
# level is the Fishing level needed to hook one; weight is how often it bites among the fish that can.
const FISH := [
	{"id": "perch", "seasons": [], "time": "any", "level": 1, "weight": 40},
	{"id": "bluegill", "seasons": ["Summer"], "time": "day", "level": 1, "weight": 35},
	{"id": "trout", "seasons": ["Spring", "Autumn"], "time": "day", "level": 2, "weight": 22},
	{"id": "crappie", "seasons": ["Winter", "Spring"], "time": "any", "level": 2, "weight": 28},
	{"id": "bullhead", "seasons": ["Summer", "Autumn"], "time": "night", "level": 3, "weight": 40},
	{"id": "lamprey", "seasons": ["Winter", "Spring"], "time": "night", "level": 4, "weight": 22},
	{"id": "pale_carp", "seasons": [], "time": "late", "level": 5, "weight": 7},
	{"id": "sturgeon", "seasons": [], "time": "day", "level": 6, "weight": 3},
]
const PALE_SANITY := 3.0   # landing a pale carp


func _init(main: MainGame) -> void:
	m = main


# Fishing level 3 and up adds spots: one more at 3, another at 5.
func _fish_spot_count() -> int:
	return m.FISH_SPOT_COUNT + (m.progression._level("Fishing") - 1) / 2


func _update_fish_spots(delta: float) -> void:
	# Each spot runs down its life. When it goes quiet, it moves to a new place.
	for tile in m.fish_spots.keys():
		m.fish_spots[tile] -= delta
		if m.fish_spots[tile] <= 0.0:
			m.fish_spots.erase(tile)
			if tile == m.fishing_tile:
				_stop_fishing("The fish have moved on from your spot.")
	# Refill up to the count for the current Fishing level.
	while m.fish_spots.size() < _fish_spot_count() and _spawn_fish_spot():
		pass
	# The sparkle pulses and fades, so the layer redraws every frame.
	if m.fish_layer != null:
		m.fish_layer.queue_redraw()


func _spawn_fish_spot() -> bool:
	var options: Array = []
	for edge in m.pond_edges:
		if not m.fish_spots.has(edge):
			options.append(edge)
	if options.is_empty():
		return false
	var pick: Vector2i = options.pick_random()
	m.fish_spots[pick] = randf_range(m.FISH_SPOT_MIN_LIFE, m.FISH_SPOT_MAX_LIFE)
	return true


func _is_fishing() -> bool:
	return m.fishing_tile != m.NO_SPOT


func _start_fishing(tile: Vector2i) -> void:
	if m.stall._pack_free() <= 0:
		m._show_message("Your pack is full. Store fish in the cooler, or sell or cook them first.")
		return
	m.fishing_tile = tile
	m.fish_timer = m.FISH_TICK_SECONDS
	m.play_sfx("cast", 0.05)
	m._show_message("You cast your line. Biting now: %s." % ", ".join(PackedStringArray(_biting_names())).to_lower())


func _stop_fishing(reason: String) -> void:
	m.fishing_tile = m.NO_SPOT
	if reason != "":
		m.play_sfx("reel", 0.05)
		m._show_message(reason)


# While fishing, roll for a catch every tick. Moving, going inside, or
# opening a panel reels the line in.
func _update_fishing(delta: float) -> void:
	if not _is_fishing():
		return
	var moved := Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO
	if moved or m.inside or m.open_tab != "" or m._tile_in_front() != m.fishing_tile:
		_stop_fishing("You reel in your line.")
		return
	m.fish_timer -= delta
	if m.fish_timer > 0.0:
		return
	m.fish_timer = m.FISH_TICK_SECONDS
	if m.stall._pack_free() <= 0:
		_stop_fishing("Your pack is full. Store fish in the cooler, or sell or cook them.")
		return
	_fish_roll()


func _fish_roll() -> void:
	m.stats["fished"] += 1
	var chance := clampf(m.FISH_BASE_CHANCE + m.FISH_CHANCE_PER_LEVEL * float(m.progression._level("Fishing") - 1) + m._rod_bonus() + m.happenings._fish_bonus(), 0.0, m.FISH_CHANCE_CAP)
	if randf() < chance:
		var id := _pick_fish()
		var f := Foods.find(id)
		var key := str(f["held"])
		if not m.stall._pack_room(int(m.inventory[key]), 1):
			_stop_fishing("A %s, but there's no room in your pack for it. You let it go." % str(f["name"]).to_lower())
			return
		m.stats["caught"] += 1
		m.progression._bump("fish_" + id)   # Every Fish in the Pond (AchievementSystem)
		if _is_night():
			m.stats["night_fish"] += 1
		m.inventory[key] += 1
		m.play_sfx("splash", 0.08)
		# Rarer fish are worth more to the skill: the base XP, plus 5 a level above the first.
		var xp: int = m.XP_FISH + 5 * (int(_spec(id)["level"]) - 1)
		m.progression._grant_xp("Fishing", xp)
		var note := ""
		if id == "pale_carp":
			m.sanity_sys._change_sanity(-PALE_SANITY)
			note = " It doesn't fight. It just looks at you. -%d sanity." % int(PALE_SANITY)
		m._show_message("You land a %s! +%d Fishing XP%s" % [str(f["name"]).to_lower(), xp, note])
	else:
		m._show_message("Nothing yet. Keep still.")


func _spec(id: String) -> Dictionary:
	for s in FISH:
		if s["id"] == id:
			return s
	return {}


func _is_night() -> bool:
	return m.current_hour >= m.DUSK_HOUR


# True when this fish bites now: its season, its hour, and your Fishing level.
func _biting(s: Dictionary) -> bool:
	var seasons: Array = s["seasons"]
	if not seasons.is_empty() and not seasons.has(m._season_today()):
		return false
	if m.progression._level("Fishing") < int(s["level"]):
		return false
	match str(s["time"]):
		"day":
			return not _is_night()
		"night":
			return _is_night()
		"late":
			return m.current_hour >= m.EVENT_HOUR
	return true


# One of the fish biting now, by weight. Perch always bite, so there is always something.
func _pick_fish() -> String:
	var pool: Array = []
	var total := 0
	for s in FISH:
		if _biting(s):
			pool.append(s)
			total += int(s["weight"])
	if total <= 0:
		return "perch"
	var roll := randi() % total
	for s in pool:
		roll -= int(s["weight"])
		if roll < 0:
			return str(s["id"])
	return "perch"


# The fish biting right now, by name, for the Skills panel and the pond.
func _biting_names() -> Array:
	var out: Array = []
	for s in FISH:
		if _biting(s):
			out.append(str(Foods.find(str(s["id"]))["name"]))
	return out


# --- The cooler: any fish, COOLER_CAP in all. The dearest go in first and come out first. ---

func _cooler_total() -> int:
	var total := 0
	for key in m.cooler:
		total += int(m.cooler[key])
	return total


# The fish's pack keys, dearest first.
func _fish_keys() -> Array:
	var keys := Foods.group("any_fish")
	keys.sort_custom(func(a, b) -> bool: return m.stall._food_price(str(Foods.by_held(a)["id"])) > m.stall._food_price(str(Foods.by_held(b)["id"])))
	return keys


func _store_fish() -> void:
	var stored := 0
	for key in _fish_keys():
		var amount := mini(int(m.inventory[key]), m.COOLER_CAP - _cooler_total())
		if amount <= 0:
			continue
		m.inventory[key] -= amount
		m.cooler[key] = int(m.cooler.get(key, 0)) + amount
		stored += amount
	if stored <= 0:
		m._show_message("Nothing to store, or the cooler is full.")
		return
	m._show_message("You store %d fish in the cooler." % stored)


func _take_fish() -> void:
	var taken := 0
	for key in _fish_keys():
		while int(m.cooler.get(key, 0)) > 0 and m.stall._pack_room(int(m.inventory[key]), 1):
			m.inventory[key] += 1
			m.cooler[key] = int(m.cooler[key]) - 1
			taken += 1
	if taken <= 0:
		m._show_message("Your pack is full, or the cooler is empty.")
		return
	m._show_message("You take %d fish from the cooler." % taken)


# Stores (or takes) amount of one fish, or all of it when amount is -1, up to the cooler's room or the pack's.
func _move_fish(key: String, amount: int, storing: bool) -> void:
	if not key in _fish_keys():
		return
	var name := str(Foods.by_held(key).get("name", key)).to_lower()
	var want := int(m.inventory[key]) if storing else int(m.cooler.get(key, 0))
	if amount >= 0:
		want = mini(want, amount)
	var moved := 0
	for i in want:
		if storing and _cooler_total() >= m.COOLER_CAP:
			break
		if not storing and not m.stall._pack_room(int(m.inventory[key]), 1):
			break
		m.inventory[key] += -1 if storing else 1
		m.cooler[key] = int(m.cooler.get(key, 0)) + (1 if storing else -1)
		moved += 1
	if moved <= 0:
		m._show_message("The cooler is full." if storing else "Your pack is full.")
		return
	m._show_message("You %s %d %s." % ["store" if storing else "take", moved, name])


func _cooler_text() -> String:
	var parts: Array = []
	for key in _fish_keys():
		var n := int(m.cooler.get(key, 0))
		if n > 0:
			parts.append("%d %s" % [n, str(Foods.by_held(key)["name"]).to_lower()])
	return ", ".join(PackedStringArray(parts)) if not parts.is_empty() else "nothing yet"
