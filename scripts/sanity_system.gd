class_name SanitySystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


# How many days into an event the current day is. Negative values mean the event is still to come.
func _event_offset(ev: Dictionary) -> int:
	var today := m._calendar_date(m.day)
	var now := m._day_of_year(int(today["month"]), int(today["day"]))
	var start := m._day_of_year(m.MONTH_NAMES.find(ev["month"]), int(ev["day"]))
	return posmod(now - start, 365)


func _active_events() -> Array:
	var out: Array = []
	for ev in m.SEASON_EVENTS:
		if _event_offset(ev) < int(ev["span"]):
			out.append(ev)
	return out


func _event_active(effect: String) -> bool:
	for ev in _active_events():
		if ev["effect"] == effect:
			return true
	return false


# Runs as a new day begins. Events that start today announce themselves and may give something once.
func _begin_day_events() -> String:
	var note := ""
	for ev in _active_events():
		if _event_offset(ev) != 0:
			continue
		m.stats["events_seen"] += 1
		if ev["effect"] == "supper":
			m.inventory["turnip_hash"] += 2
			_change_sanity(10.0)
		elif ev["effect"] == "fair":
			m.inventory["seeds"] += 5
		elif ev["effect"] == "feast":
			m.inventory["fish_meal"] += 2
			m.inventory["bandage"] += 1
		note += " %s: %s" % [ev["title"], ev["text"]]
	return note


func _can_tidy() -> bool:
	return m.house_stage >= 2 and m.tidied_day != m.day


func _tidy_house() -> void:
	if not _can_tidy():
		m._show_message("The house is already tidy for today.")
		return
	m.tidied_day = m.day
	m.play_sfx("sweep", 0.04)
	m.stats["tidied"] += 1
	m.wear = maxi(0, m.wear - m.WEAR_TIDY)
	m.progression._grant_xp("Cleaning", m.XP_TIDY)
	var bonus := m.TIDY_CLEANING_BONUS if m.progression._level("Cleaning") >= 2 else 0
	_change_sanity(m.TIDY_SANITY + bonus)
	m._show_message("You tidy the house. The air feels a little lighter. +%d Cleaning XP. %s" % [m.XP_TIDY, m.rewards._tidy_find()])


# Cleansing offers crops to the house to lift the permanent sanity penalty.
func _can_cleanse() -> bool:
	return m.sanity_penalty > 0 and m.cleanse_day != m.day \
		and m.progression._level("Cleaning") >= m.CLEANSE_LEVEL \
		and m.farm._crop_total() >= m.CLEANSE_CROPS


func _cleanse_house() -> void:
	if not _can_cleanse():
		m._show_message("Cleansing needs Cleaning %d, %d crops, and one try a day." % [m.CLEANSE_LEVEL, m.CLEANSE_CROPS])
		return
	m.farm._spend_crops(m.CLEANSE_CROPS)
	m.cleanse_day = m.day
	m.play_sfx("cleanse")
	m.sanity_penalty = maxi(0, m.sanity_penalty - m.CLEANSE_RELIEF)
	m.sanity = minf(m.sanity, _sanity_max())
	m.stats["cleansed"] += 1
	m._show_message("You burn the offering and open the windows. Your limit recovers by %d." % m.CLEANSE_RELIEF)


func _night_relief() -> float:
	# The restored house dims the night overall. The lantern lights a ring instead.
	var relief := 0.0
	if m.house_stage >= 3:
		relief += m.HOUSE_RELIEF
	return minf(relief, 0.9)


func _sanity_max() -> float:
	return m.SANITY_MAX - m.sanity_penalty - m.boredom_loss


func _change_sanity(amount: float) -> void:
	m.sanity = clampf(m.sanity + amount, 0.0, _sanity_max())


func _update_sanity(darkness: float, delta: float) -> void:
	var rate := 0.02                 # slow recovery outdoors in daylight
	if m.inside:
		rate = 0.1 + (0.05 if m.house_stage >= 1 else 0.0)   # the house is shelter
	elif darkness > 0.5 and not m.projects._lit(m._player_tile()):   # a lamp post's light holds the dark off
		rate = -0.05 * (0.5 if _event_active("ward") else 1.0)   # the dark wears on you; lanterns ward it on All Hallows
	_change_sanity(rate * delta)


func _low_sanity_boost() -> float:
	# Low sanity makes everything darker, a visible warning.
	return maxf(0.0, (m.LOW_SANITY - m.sanity) / m.LOW_SANITY) * 0.25

