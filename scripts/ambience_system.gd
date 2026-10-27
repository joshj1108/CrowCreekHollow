class_name AmbienceSystem
extends RefCounted

## The sound of the world around the farmer. Looping beds (wind, rain, the night, the house, the cave) fade in and out
## with where you stand, the hour, the weather and your sanity. Over them, single sounds play now and then from
## somewhere off to one side: crows by day, owls and things in the trees by night, boards creaking in the house,
## and drips and skittering in the cave. They count as sound effects, so the Sound effects setting turns them off.

var m: MainGame

# Each loop in audio/ambience, and how loud it plays at full strength, in decibels.
const LOOP_DB := {
	"wind": -8.0, "night": -7.0, "crickets": -17.0, "dread": -5.0, "rain": -6.0,
	"roof": -4.0, "house": -9.0, "fire": -7.0, "cave": -3.0,
}
const FADE_PER_SECOND := 0.4   # how fast a loop moves toward its level, as a share of full strength
const RAIN_STRENGTH := {"drizzle": 0.4, "rain": 0.7, "downpour": 1.0}

# The occasional sounds. place: out (the farm, road and towns), in (the farmhouse) or cave. time: day, night or any.
# every: the gap between them, in seconds, picked fresh each time. fear: only once sanity has fallen this far (0 to 1).
# weather: only in these kinds. side: true plays it from off to the left or right of the screen.
const EVENTS := [
	{"sounds": ["crow"], "place": "out", "time": "day", "every": Vector2(10, 28), "db": -6.0, "side": true},
	{"sounds": ["crow_far"], "place": "out", "time": "any", "every": Vector2(20, 50), "db": -8.0, "side": true},
	{"sounds": ["owl"], "place": "out", "time": "night", "every": Vector2(22, 55), "db": -7.0, "side": true},
	{"sounds": ["snap_far"], "place": "out", "time": "night", "every": Vector2(25, 70), "db": -6.0, "side": true},
	{"sounds": ["howl"], "place": "out", "time": "night", "every": Vector2(70, 160), "db": -9.0, "side": true},
	{"sounds": ["steps_behind"], "place": "out", "time": "night", "fear": 0.45, "every": Vector2(40, 100), "db": -6.0, "side": true},
	{"sounds": ["whisper"], "place": "out", "time": "any", "fear": 0.6, "every": Vector2(25, 60), "db": -8.0, "side": true},
	{"sounds": ["thunder"], "place": "out", "time": "any", "weather": ["downpour"], "every": Vector2(35, 90), "db": -4.0},
	{"sounds": ["thunder"], "place": "out", "time": "any", "weather": ["rain"], "every": Vector2(120, 260), "db": -8.0},
	{"sounds": ["creak", "creak_high"], "place": "in", "time": "any", "every": Vector2(12, 32), "db": -8.0, "side": true},
	{"sounds": ["creak", "creak_high"], "place": "in", "time": "night", "every": Vector2(10, 24), "db": -6.0, "side": true},
	{"sounds": ["settle"], "place": "in", "time": "any", "every": Vector2(60, 140), "db": -7.0, "side": true},
	{"sounds": ["thunder_in"], "place": "in", "time": "any", "weather": ["downpour"], "every": Vector2(35, 90), "db": -4.0},
	{"sounds": ["thunder_in"], "place": "in", "time": "any", "weather": ["rain"], "every": Vector2(120, 260), "db": -8.0},
	{"sounds": ["whisper"], "place": "in", "time": "night", "fear": 0.7, "every": Vector2(45, 90), "db": -10.0, "side": true},
	{"sounds": ["drip", "drip_low"], "place": "cave", "time": "any", "every": Vector2(1.5, 5.0), "db": -10.0, "side": true},
	{"sounds": ["skitter"], "place": "cave", "time": "any", "every": Vector2(10, 25), "db": -8.0, "side": true},
	{"sounds": ["pebbles"], "place": "cave", "time": "any", "every": Vector2(15, 35), "db": -9.0, "side": true},
	{"sounds": ["cave_moan"], "place": "cave", "time": "any", "every": Vector2(18, 40), "db": -8.0, "side": true},
	{"sounds": ["cave_rumble"], "place": "cave", "time": "any", "every": Vector2(35, 80), "db": -5.0},
	{"sounds": ["whisper"], "place": "cave", "time": "any", "fear": 0.5, "every": Vector2(30, 70), "db": -9.0, "side": true},
]
const HEART_FEAR := 0.75       # below a quarter of your sanity, you start to hear your own heart
const HUSH_SECONDS := 90.0     # a "too quiet" night silences the crickets and the wind for this long

var loops := {}                # loop name -> AudioStreamPlayer
var levels := {}               # loop name -> current strength, 0 to 1
var waits: Array = []          # seconds until each of EVENTS next plays
var spot_players: Array = []   # AudioStreamPlayer2D pool for sounds off to one side
var spot_next := 0
var heart_wait := 0.0
var hush_left := 0.0


func _init(main: MainGame) -> void:
	m = main


func setup() -> void:
	for name in LOOP_DB:
		var path := "res://audio/ambience/%s.ogg" % name
		if not ResourceLoader.exists(path):
			continue
		var stream := load(path) as AudioStreamOggVorbis
		stream.loop = true
		var p := AudioStreamPlayer.new()
		p.stream = stream
		p.volume_db = -80.0
		m.add_child(p)
		loops[name] = p
		levels[name] = 0.0
	for ev in EVENTS:
		waits.append(randf_range(ev["every"].x * 0.3, ev["every"].y))
	for i in 4:
		var s := AudioStreamPlayer2D.new()
		s.max_distance = 6000.0
		s.attenuation = 0.5
		m.add_child(s)
		spot_players.append(s)


# How dark it is, from 0 in the day to 1 at full night.
func _darkness() -> float:
	return smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, m.current_hour)


# How far sanity has fallen, from 0 when calm to 1 at the edge.
func _fear() -> float:
	return clampf(1.0 - m.sanity / maxf(1.0, m.SANITY_MAX), 0.0, 1.0)


func _place() -> String:
	if m.in_cave:
		return "cave"
	return "in" if m.inside else "out"


func update(delta: float) -> void:
	var on := m.sfx_on and m.world_started
	var targets := {}
	if on:
		targets = _loop_targets()
	for name in loops:
		var target := float(targets.get(name, 0.0))
		levels[name] = move_toward(float(levels[name]), target, FADE_PER_SECOND * delta)
		var p: AudioStreamPlayer = loops[name]
		if float(levels[name]) <= 0.001:
			if p.playing:
				p.stop()
			continue
		if not p.playing:
			p.play(randf() * p.stream.get_length())
		p.volume_db = float(LOOP_DB[name]) + linear_to_db(float(levels[name]))
	if not on or m.transitioning:
		return
	hush_left = maxf(0.0, hush_left - delta)
	_update_events(delta)
	_update_heart(delta)


func _loop_targets() -> Dictionary:
	var dark := _darkness()
	var fear := _fear()
	var rain := float(RAIN_STRENGTH.get(m.weather_kind, 0.0))
	var snow := m.weather_kind == "snow"
	var hush := 0.2 if hush_left > 0.0 else 1.0
	var t := {}
	match _place():
		"cave":
			t["cave"] = 1.0
			t["dread"] = 0.25 + 0.6 * fear
		"in":
			t["house"] = 0.55 + 0.45 * dark
			t["roof"] = rain
			t["fire"] = 1.0 if m.firewood._fire_lit() else 0.0
			t["wind"] = 0.3 if snow else 0.0
			t["dread"] = dark * fear * 0.7
		_:
			t["wind"] = lerpf(0.75, 0.25, dark) + (0.35 if snow else 0.0)
			t["night"] = dark * 0.9 * hush
			var season := m._season_of(m._calendar_date(m.day)["month"])
			if season != "Winter" and rain < 0.5 and not snow:
				t["crickets"] = dark * 0.8 * hush
			t["dread"] = dark * (0.25 + 0.75 * fear) + (0.2 if m.weather_kind == "fog" else 0.0)
			t["rain"] = rain
	for k in t:
		t[k] = clampf(float(t[k]), 0.0, 1.0)
	return t


func _update_events(delta: float) -> void:
	var place := _place()
	var night := _darkness() > 0.5
	var fear := _fear()
	for i in EVENTS.size():
		var ev: Dictionary = EVENTS[i]
		waits[i] = float(waits[i]) - delta
		if float(waits[i]) > 0.0:
			continue
		waits[i] = randf_range(ev["every"].x, ev["every"].y)
		if ev["place"] != place:
			continue
		if (ev["time"] == "day" and night) or (ev["time"] == "night" and not night):
			continue
		if fear < float(ev.get("fear", 0.0)):
			continue
		if ev.has("weather") and not (m.weather_kind in ev["weather"]):
			continue
		if place == "out" and hush_left > 0.0:
			continue
		var sounds: Array = ev["sounds"]
		var sound := str(sounds[randi() % sounds.size()])
		if ev.get("side", false):
			play_side(sound, float(ev["db"]))
		else:
			m.play_sfx_at(sound, float(ev["db"]), 0.04)


# Your own heartbeat, faster the further your sanity has fallen.
func _update_heart(delta: float) -> void:
	var fear := _fear()
	if fear < HEART_FEAR:
		heart_wait = 0.0
		return
	heart_wait -= delta
	if heart_wait <= 0.0:
		var t := (fear - HEART_FEAR) / (1.0 - HEART_FEAR)
		heart_wait = lerpf(1.4, 0.75, t)
		m.play_sfx_at("heartbeat", lerpf(-14.0, -6.0, t), 0.02)


# Plays a sound from off to one side of the screen, so it seems to come from the trees, the walls or the dark.
func play_side(sound: String, db: float) -> void:
	if not m.sfx_streams.has(sound) or spot_players.is_empty():
		return
	var s: AudioStreamPlayer2D = spot_players[spot_next]
	spot_next = (spot_next + 1) % spot_players.size()
	var view := m.get_viewport_rect().size / m.camera.zoom
	var side := -1.0 if randf() < 0.5 else 1.0
	var centre := m.camera.get_screen_center_position()
	s.position = centre + Vector2(side * view.x * randf_range(0.25, 0.5), randf_range(-view.y, view.y) * 0.3)
	s.stream = m.sfx_streams[sound]
	s.volume_db = db
	s.pitch_scale = 1.0 + randf_range(-0.05, 0.05)
	s.play()


# A night event's sound. "hush" is the other way round: the night goes quiet.
func night_event(sound: String) -> void:
	if sound == "hush":
		hush_left = HUSH_SECONDS
	elif sound != "":
		m.play_sfx_at(sound, -3.0, 0.0)
