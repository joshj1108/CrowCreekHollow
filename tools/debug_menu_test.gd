extends SceneTree

# Checks the developer's world-state panel (scripts/debug_menu.gd, CCH-CONSOLIDATED-003 Phase A): calendar
# boundaries, the time parser, forced weather and temperature (and that neither is ever saved), pausing the clock,
# reverting a jump, and that the panel holds the day and lets no key through to the farm on close. Headless:
#   godot --path . --headless -s tools/debug_menu_test.gd
# Plays in save slot 9 and deletes it after. Prints ok/FAIL per case and PASS or FAIL; exit code = failures.

const SLOT := 9

var m: MainGame
var d: DebugMenu
var started := false
var failures := 0
var frame := 0
var path := ""


func _initialize() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


func _process(_delta: float) -> bool:
	frame += 1
	if not started:
		started = true
		path = TitleMenu.slot_path(SLOT)
		SaveSystem.delete_save(path)
		m._on_title_start("new", SLOT)
		d = m.debug_menu
		_check("panel exists in a debug build", d != null and DebugMenu.allowed())
		if d == null:
			return _finish()
		_static_checks()
		# Live checks over a few frames: open the panel and see the clock hold.
		d.set_hour(12.0)
		d.open()
		return false
	if frame == 3:
		_live_open_a = m.clock
	if frame == 12:
		_check("open panel holds the clock", is_equal_approx(m.clock, _live_open_a))
		_check("open panel pauses the farmer", m.player.paused)
		d.close()
		d.set_paused(true)
		_live_open_a = m.clock
	if frame == 24:
		_check("paused time: clock holds with the panel closed", is_equal_approx(m.clock, _live_open_a))
		_check("panel closed: farmer free", not m.player.paused)
		_check("badge shows while overrides are active", d.badge.visible)
		d.set_paused(false)
		_live_open_a = m.clock
	if frame == 36:
		_check("resumed: clock runs", m.clock > _live_open_a)
		d.clear_all()
	if frame == 40:
		_check("clear all: badge hidden", not d.badge.visible and not d.overrides_active())
		return _finish()
	return false


var _live_open_a := 0.0


func _static_checks() -> void:
	# Time parsing: the day runs 06:00 to 02:59.
	_check("parse 06:00", is_equal_approx(DebugMenu.parse_hour("06:00"), 6.0))
	_check("parse 17:30", is_equal_approx(DebugMenu.parse_hour("17:30"), 17.5))
	_check("parse 00:00 is hour 24", is_equal_approx(DebugMenu.parse_hour("00:00"), 24.0))
	_check("parse 02:59 is hour 26.98", absf(DebugMenu.parse_hour("2:59") - (26.0 + 59.0 / 60.0)) < 0.001)
	_check("refuse 04:00 (not in a day)", DebugMenu.parse_hour("04:00") < 0.0)
	_check("refuse 25:00 and junk", DebugMenu.parse_hour("25:00") < 0.0 and DebugMenu.parse_hour("noon") < 0.0)
	d.set_hour(DebugMenu.parse_hour("22:00"))
	_check("set 22:00 moves the clock", is_equal_approx(m.current_hour, 22.0) and d.jumped)

	# Calendar: day numbers for dates, month lengths, the year wrap.
	_check("Oct 1 year 1 is day 1", d.day_number_for(9, 1, 1) == 1)
	_check("Dec 31 year 1 is day 92", d.day_number_for(11, 31, 1) == 92)
	_check("Jan 1 year 1 is day 93", d.day_number_for(0, 1, 1) == 93)
	_check("Sep 30 year 1 is day 365", d.day_number_for(8, 30, 1) == 365)
	_check("Oct 1 year 2 is day 366", d.day_number_for(9, 1, 2) == 366)
	_check("Feb 30 clamps to Feb 28", d.day_number_for(1, 30, 1) == d.day_number_for(1, 28, 1))
	_check("Apr 31 clamps to Apr 30", d.day_number_for(3, 31, 1) == d.day_number_for(3, 30, 1))
	for c in [[0, 15, "Winter"], [3, 15, "Spring"], [6, 15, "Summer"], [9, 15, "Autumn"], [11, 1, "Winter"], [2, 1, "Spring"]]:
		d.set_day(d.day_number_for(c[0], c[1], 1))
		var date: Dictionary = m._calendar_date(m.day)
		_check("date %s %d: calendar and season agree (%s)" % [m.MONTH_NAMES[c[0]], c[1], c[2]],
			int(date["month"]) == c[0] and int(date["day"]) == c[1] and m._season_today() == c[2])
	_check("year of day 365 is 1, day 366 is 2", DebugMenu.year_of(365) == 1 and DebugMenu.year_of(366) == 2)
	d.revert_jump()
	_check("revert puts back day 1 and the morning", m.day == 1 and not d.jumped and m.current_hour < 7.0)

	# Weather: forced from the game's own kinds; the save writes the real one.
	var real := m.weather_kind
	var other := "snow" if real != "snow" else "fog"
	d.force_weather(other)
	_check("forced weather is today's weather", m.weather_kind == other and m.weather.kind == other)
	d.force_weather("hail")
	_check("unknown weather refused", m.weather_kind == other)
	m.saver._save_game()
	_check("save writes the real weather, not the forced", str(_raw().get("weather_kind", "")) == real)
	m._roll_weather()
	_check("a morning roll keeps the forced weather showing", m.weather_kind == other and d.real_weather != "")
	var rolled := d.real_weather
	d.release_weather()
	_check("normal weather restores the rolled weather", m.weather_kind == rolled and d.forced_weather == "")

	# Temperature.
	d.set_temperature(-12.0)
	_check("forced temperature", is_equal_approx(m._temperature(), -12.0))
	d.set_temperature(DebugMenu.TEMP_PRESETS["Hot"])
	_check("hot preset", is_equal_approx(m._temperature(), 90.0))
	d.release_temperature()
	_check("normal temperature is simulated again", not is_equal_approx(m._temperature(), 90.0))

	# A load never brings overrides back: they live only in the panel.
	d.force_weather(other)
	d.set_temperature(5.0)
	m.saver._save_game()
	m.saver._load_game()
	_check("load: no forced weather or temperature", d.forced_weather == "" and not d.temp_on and m.weather_kind == str(_raw().get("weather_kind", "")))


func _finish() -> bool:
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _raw() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _check(label: String, ok: bool) -> void:
	print("%s  %s" % ["ok  " if ok else "FAIL", label])
	if not ok:
		failures += 1
