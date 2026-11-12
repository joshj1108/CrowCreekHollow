class_name DebugMenu
extends CanvasLayer

# CCH-CONSOLIDATED-003 Phase A: the developer's world-state panel. Debug builds only (running from the editor or the
# command line; release builds never build it), opened and closed with the backquote key (`). It sets the central
# state every system already reads each frame (main's clock, day, weather_kind and _temperature()), so lighting, the
# HUD clock, weather and its particles, seasonal art, interior windows, curtains, frost and fog all follow at once.
#
# What is temporary and what is not:
#   - Forced weather, forced temperature and the paused clock are overrides. They are never saved: the save writes
#     the day's real (rolled) weather, and a load starts with no overrides.
#   - Setting the time or date is a jump, like the F4 tools. "Revert time & date" puts back the clock and day from
#     before the first jump. Saving (or sleeping, which autosaves) while jumped keeps the jumped day, as any save does.
# The panel shows "DEBUG OVERRIDES" in the HUD's corner while any override or jump is active, even when closed.

const TOGGLE_KEY := KEY_QUOTELEFT
const TIME_PRESETS := ["06:00", "09:00", "12:00", "17:00", "19:00", "22:00", "00:00"]
const TEMP_PRESETS := {"Cold": 20.0, "Mild": 55.0, "Hot": 90.0}

var m: Node                       # main
var panel: PanelContainer
var badge: Label                  # "DEBUG OVERRIDES", shown while anything here is in force
var status: Label
var time_edit: LineEdit
var month_pick: OptionButton
var dom_spin: SpinBox
var year_spin: SpinBox
var temp_spin: SpinBox
var weather_pick: OptionButton
var pause_button: Button
var first_focus: Control
var swallow_frame := -1           # the frame the panel closed on: main ignores that frame's keys

# Override state, read by main.
var time_paused := false
var forced_weather := ""          # "" = the day's own weather
var real_weather := ""            # the rolled weather under a forced one (what the save writes)
var temp_on := false
var temp_value := 55.0
var jumped := false               # the clock or day was set from here
var jump_clock := 0.0
var jump_day := 1


static func allowed() -> bool:
	return OS.is_debug_build()


func _init(main: Node) -> void:
	m = main
	layer = 90
	visible = true
	_build()
	panel.visible = false


func is_open() -> bool:
	return panel.visible


func overrides_active() -> bool:
	return time_paused or forced_weather != "" or temp_on or jumped


func toggle() -> void:
	if is_open():
		close()
	else:
		open()


func open() -> void:
	_sync_fields()
	panel.visible = true
	first_focus.grab_focus()


func close() -> void:
	panel.visible = false
	swallow_frame = Engine.get_process_frames()
	var f := panel.get_viewport().gui_get_focus_owner()
	if f != null:
		f.release_focus()


func _input(event: InputEvent) -> void:
	if not is_open():
		return
	var k := event as InputEventKey
	var esc := (k != null and k.pressed and not k.echo and k.physical_keycode == KEY_ESCAPE) or event.is_action_pressed("ui_cancel")
	if esc:
		# Esc in a text box only leaves the box; a second Esc closes the panel.
		var f := panel.get_viewport().gui_get_focus_owner()
		if f is LineEdit or (f != null and f.get_parent() is SpinBox):
			first_focus.grab_focus()
		else:
			close()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	badge.visible = overrides_active() and m.world_started
	if is_open():
		status.text = _status_text()


# --- Building ---------------------------------------------------------------------------------------------------

func _build() -> void:
	var theme := UiTheme.get_theme()
	badge = Label.new()
	badge.theme = theme
	badge.theme_type_variation = "HudNote"
	badge.text = "DEBUG OVERRIDES"
	badge.add_theme_color_override("font_color", UiTheme.HUD_WARN)
	# Under the clock plate, clear of the corner cards, the minimap and the Bag and Menu buttons.
	badge.set_anchors_preset(Control.PRESET_CENTER_TOP)
	badge.grow_horizontal = Control.GROW_DIRECTION_BOTH
	badge.offset_top = 74
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.visible = false
	add_child(badge)

	panel = PanelContainer.new()
	panel.theme = theme
	panel.theme_type_variation = "DialogPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.offset_left = 24
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	panel.add_child(col)
	var title := Label.new()
	title.theme_type_variation = "SectionHeading"
	title.text = "Developer: world state"
	col.add_child(title)
	var hint := Label.new()
	hint.theme_type_variation = "Hint"
	hint.text = "Debug builds only.  `  or  Esc  closes.  Overrides are not saved."
	col.add_child(hint)

	# Time of day.
	col.add_child(_heading("Time of day"))
	var trow := _row(col)
	time_edit = LineEdit.new()
	time_edit.placeholder_text = "HH:MM"
	time_edit.custom_minimum_size.x = 76
	time_edit.text_submitted.connect(func(t: String) -> void: _set_time_text(t))
	trow.add_child(time_edit)
	first_focus = time_edit
	trow.add_child(_button("Set", func() -> void: _set_time_text(time_edit.text)))
	var prow := _row(col)
	for t in TIME_PRESETS:
		prow.add_child(_button(t, func() -> void: _set_time_text(t), true))

	# Calendar.
	col.add_child(_heading("Date"))
	var drow := _row(col)
	month_pick = OptionButton.new()
	for i in m.MONTH_NAMES.size():
		month_pick.add_item(str(m.MONTH_NAMES[i]).substr(0, 3), i)
	month_pick.item_selected.connect(func(_i: int) -> void: _clamp_dom())
	drow.add_child(month_pick)
	dom_spin = _spin(1, 31, 1)
	drow.add_child(dom_spin)
	var ylab := Label.new()
	ylab.theme_type_variation = "Hint"
	ylab.text = "Year"
	drow.add_child(ylab)
	year_spin = _spin(1, 20, 1)
	drow.add_child(year_spin)
	drow.add_child(_button("Set date", _apply_date))
	var srow := _row(col)
	for s in [["Winter", 0, 15], ["Spring", 3, 15], ["Summer", 6, 15], ["Autumn", 9, 15]]:
		srow.add_child(_button(s[0], func() -> void: _jump_to(int(s[1]), int(s[2])), true))

	# Weather.
	col.add_child(_heading("Weather"))
	var wrow := _row(col)
	weather_pick = OptionButton.new()
	for k in m.WEATHER_NAMES:
		weather_pick.add_item(str(m.WEATHER_NAMES[k]))
		weather_pick.set_item_metadata(weather_pick.item_count - 1, k)
	wrow.add_child(weather_pick)
	wrow.add_child(_button("Force", func() -> void: force_weather(str(weather_pick.get_item_metadata(weather_pick.selected)))))
	wrow.add_child(_button("Normal weather", release_weather, true))

	# Temperature.
	col.add_child(_heading("Temperature (°F)"))
	var crow := _row(col)
	temp_spin = _spin(-30, 120, 1)
	crow.add_child(temp_spin)
	crow.add_child(_button("Set", func() -> void: set_temperature(temp_spin.value)))
	for name in TEMP_PRESETS:
		crow.add_child(_button(name, func() -> void: set_temperature(TEMP_PRESETS[name]), true))
	crow.add_child(_button("Normal", release_temperature, true))

	# Simulation.
	col.add_child(_heading("Simulation"))
	var mrow := _row(col)
	pause_button = _button("Pause time", func() -> void: set_paused(not time_paused))
	mrow.add_child(pause_button)
	mrow.add_child(_button("Revert time & date", revert_jump, true))
	mrow.add_child(_button("Refresh visuals", refresh, true))
	mrow.add_child(_button("Clear all", clear_all, true))

	col.add_child(HSeparator.new())
	status = Label.new()
	status.theme_type_variation = "Hint"
	col.add_child(status)


func _heading(text: String) -> Label:
	var l := Label.new()
	l.theme_type_variation = "GroupHeading"
	l.text = text
	return l


func _row(parent: Node) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 4)
	parent.add_child(r)
	return r


func _button(text: String, cb: Callable, secondary := false) -> Button:
	var b := Button.new()
	b.text = text
	if secondary:
		b.theme_type_variation = "SecondaryButton"
	b.pressed.connect(cb)
	return b


func _spin(lo: float, hi: float, step: float) -> SpinBox:
	var s := SpinBox.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.custom_minimum_size.x = 84
	return s


func _sync_fields() -> void:
	time_edit.text = _hhmm(m.current_hour)
	var d: Dictionary = m._calendar_date(m.day)
	month_pick.select(int(d["month"]))
	_clamp_dom()
	dom_spin.value = int(d["day"])
	year_spin.value = year_of(m.day)
	temp_spin.value = roundf(m._temperature())
	for i in weather_pick.item_count:
		if str(weather_pick.get_item_metadata(i)) == m.weather_kind:
			weather_pick.select(i)
	pause_button.text = "Resume time" if time_paused else "Pause time"


func _clamp_dom() -> void:
	dom_spin.max_value = int(m.MONTH_DAYS[month_pick.selected])


func _status_text() -> String:
	var d: Dictionary = m._calendar_date(m.day)
	var flags: Array = []
	if time_paused:
		flags.append("time paused")
	if forced_weather != "":
		flags.append("weather forced (real: %s)" % m.WEATHER_NAMES.get(real_weather, real_weather))
	if temp_on:
		flags.append("temperature forced")
	if jumped:
		flags.append("time/date jumped")
	return "Now: Day %d (year %d), %s %d, %s.  %s.  %s, %s.\nOverrides: %s" % [
		m.day, year_of(m.day), str(m.MONTH_NAMES[d["month"]]).substr(0, 3), d["day"], m._season_today(),
		_hhmm(m.current_hour), m.WEATHER_NAMES.get(m.weather_kind, m.weather_kind), "%d°F" % roundi(m._temperature()),
		", ".join(flags) if not flags.is_empty() else "none"]


# --- Time and calendar -------------------------------------------------------------------------------------------

static func _hhmm(hour: float) -> String:
	var h := fposmod(hour, 24.0)
	return "%02d:%02d" % [int(h), int(fmod(h, 1.0) * 60.0)]


# Parses "HH:MM" (or "H") into the game's hour: the day runs 06:00 to 03:00 the next morning, so 00:00-02:59
# are hours 24-27. Times from 03:00 to 05:59 don't exist in a day and are refused.
static func parse_hour(text: String) -> float:
	var parts := text.strip_edges().split(":")
	if parts.is_empty() or not parts[0].is_valid_int():
		return -1.0
	var h := int(parts[0])
	var mins := int(parts[1]) if parts.size() > 1 and parts[1].is_valid_int() else 0
	if h < 0 or h > 23 or mins < 0 or mins > 59:
		return -1.0
	var hour := h + mins / 60.0
	if hour < 3.0:
		hour += 24.0
	elif hour < 6.0:
		return -1.0
	return hour


func _set_time_text(text: String) -> void:
	var hour := parse_hour(text)
	if hour < 0.0:
		m._show_message("Debug: \"%s\" isn't a time in the day (06:00 to 02:59)." % text)
		return
	set_hour(hour)


func _remember_jump() -> void:
	if not jumped:
		jumped = true
		jump_clock = m.clock
		jump_day = m.day


func set_hour(hour: float) -> void:
	_remember_jump()
	hour = clampf(hour, m.START_HOUR, m.DAY_END_HOUR - 0.02)
	m.clock = (hour - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	m.current_hour = hour
	refresh()


# The in-game year: year 1 runs from day 1 (October 1st) to day 365 (September 30th).
static func year_of(day_number: int) -> int:
	return (day_number - 1) / 365 + 1


# The day number for a month, day of the month and in-game year. Month lengths are the real ones (no leap years).
func day_number_for(month: int, dom: int, year: int) -> int:
	dom = clampi(dom, 1, int(m.MONTH_DAYS[month]))
	var start: int = m._day_of_year(m.START_MONTH, m.START_DAY_OF_MONTH)
	var off: int = posmod(m._day_of_year(month, dom) - start, 365)
	return (maxi(1, year) - 1) * 365 + off + 1


func _apply_date() -> void:
	set_day(day_number_for(month_pick.selected, int(dom_spin.value), int(year_spin.value)))


func _jump_to(month: int, dom: int) -> void:
	set_day(day_number_for(month, dom, year_of(m.day)))


func set_day(n: int) -> void:
	_remember_jump()
	m.day = maxi(1, n)
	refresh()


func revert_jump() -> void:
	if not jumped:
		return
	m.clock = jump_clock
	m.day = jump_day
	m.current_hour = m.START_HOUR + m.clock / m.DAY_LENGTH * (m.DAY_END_HOUR - m.START_HOUR)
	jumped = false
	refresh()


func set_paused(on: bool) -> void:
	time_paused = on
	if pause_button != null:
		pause_button.text = "Resume time" if on else "Pause time"


# --- Weather and temperature ------------------------------------------------------------------------------------

func force_weather(kind: String) -> void:
	if not m.WEATHER_NAMES.has(kind):
		return
	if forced_weather == "":
		real_weather = m.weather_kind
	forced_weather = kind
	m.weather_kind = kind
	refresh()


func release_weather() -> void:
	if forced_weather == "":
		return
	forced_weather = ""
	m.weather_kind = real_weather
	refresh()


# Called by main after each morning's roll: the roll becomes the real weather under the forced one.
func after_roll() -> void:
	if forced_weather != "":
		real_weather = m.weather_kind
		m.weather_kind = forced_weather
		if m.weather != null:
			m.weather.set_condition(forced_weather)


# The weather the save should write: the day's own, never a forced one.
func saved_weather() -> String:
	return real_weather if forced_weather != "" else m.weather_kind


func set_temperature(f: float) -> void:
	temp_on = true
	temp_value = f
	refresh()


func release_temperature() -> void:
	temp_on = false
	refresh()


# Drops every override without touching the world (a load has just set it from the save).
func forget() -> void:
	forced_weather = ""
	real_weather = ""
	temp_on = false
	jumped = false
	set_paused(false)


func clear_all() -> void:
	release_weather()
	release_temperature()
	revert_jump()
	set_paused(false)
	refresh()


# Pushes the current state through the central updates: the weather overlay, the HUD, the seasonal art (re-checked
# by FarmScenery each frame) and the world redraw. Lighting, windows, frost and the grade read the state each frame.
func refresh() -> void:
	if m.weather != null:
		m.weather.set_condition(m.weather_kind)
	if m.farm_scenery != null:
		m.farm_scenery._season_shown = ""
	m.last_cam_tile = Vector2i(-9999, -9999)
	m.queue_redraw()
	if m.has_method("_update_hud"):
		m._update_hud()
	if is_open():
		_sync_fields()
