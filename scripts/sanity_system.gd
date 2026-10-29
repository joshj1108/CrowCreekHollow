class_name SanitySystem
extends RefCounted

var m: MainGame

# The vicar's blessing, the way back from the bottom: waking under BLESS_BELOW, the vicar is at the gate that day
# (at most once every BLESS_WAIT days). Taking it costs BLESS_CROPS crops for the chapel's poor box and gives back
# BLESS_SANITY, lifts BLESS_LIMIT of the lost limit, and halves what that night takes, like a crow charm.
const BLESS_BELOW := 20.0
const BLESS_WAIT := 7
const BLESS_CROPS := 3
const BLESS_SANITY := 30.0
const BLESS_LIMIT := 5

var bless_offer_day := -1   # saved: the day the vicar waits at the gate
var bless_day := -100       # saved: the day his blessing was last taken


# Sleep heals more the lower you have fallen (LOW_REST_GAIN for each point under LOW_REST), so a run of bad
# nights settles into a trough instead of spiralling to nothing.
const LOW_REST := 60.0
const LOW_REST_GAIN := 0.2


func _init(main: MainGame) -> void:
	m = main


func _sleep_gain() -> float:
	return m.SLEEP_SANITY + m.estate._sleep_bonus() + LOW_REST_GAIN * maxf(0.0, LOW_REST - m.sanity)


# The morning: low enough, and the vicar has heard. Returns a note for the morning message.
func _morning_bless() -> String:
	if m.sanity >= BLESS_BELOW or m.day - bless_day < BLESS_WAIT or bless_offer_day == m.day:
		return ""
	bless_offer_day = m.day
	return " The vicar has walked up from the chapel: someone told him you haven't been sleeping. He waits at the gate today to bless the house (House section)."


func _can_bless() -> bool:
	return bless_offer_day == m.day and bless_day != m.day and m.farm._crop_total() >= BLESS_CROPS


func _blessed_tonight() -> bool:
	return bless_day == m.day


func _take_blessing() -> void:
	if not _can_bless():
		m._show_message("The vicar's blessing needs %d crops for the poor box, on a day he waits at the gate." % BLESS_CROPS)
		return
	m.farm._spend_crops(BLESS_CROPS)
	bless_day = m.day
	m.play_sfx("cleanse")
	m.sanity_penalty = maxi(0, m.sanity_penalty - BLESS_LIMIT)
	_change_sanity(BLESS_SANITY)
	m._show_message("The vicar walks the rooms with you, saying the old words at every door. The house feels like yours again. +%d sanity, and tonight will be easier." % int(BLESS_SANITY))


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
	if m.sanity < AchievementSystem.DEEP:
		m.stats["deep_madness"] = 1   # Back From Under (AchievementSystem): the last madness tier reached


# hours: game hours since the last call. The rates are per game hour, so a longer day doesn't change them.
func _update_sanity(darkness: float, hours: float) -> void:
	var rate := 0.0                  # daylight outdoors neither drains nor restores
	if m.inside:
		rate = m.INDOOR_SANITY_RATE + (m.SHELTER_SANITY_RATE if m.house_stage >= 1 else 0.0)   # the house is shelter
	elif darkness > 0.5 and not m.projects._lit(m._player_tile()):   # a lamp post's light holds the dark off
		rate = -m.DARK_SANITY_DRAIN * (0.5 if _event_active("ward") else 1.0)   # the dark wears on you; lanterns ward it on All Hallows
		rate *= m.nights._season_mult()   # the long dark of winter
	_change_sanity(rate * hours)


func _low_sanity_boost() -> float:
	# Low sanity makes everything darker, a visible warning.
	return maxf(0.0, (m.LOW_SANITY - m.sanity) / m.LOW_SANITY) * 0.25

