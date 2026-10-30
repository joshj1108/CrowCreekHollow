class_name MusicSystem
extends RefCounted

## The music director. Each frame it asks what the moment calls for (the title, the season's day theme, the
## house, the night, a trek, the cave, a night visitor, the Hollow, an ending) and crossfades to that track.
## Some moments get silence instead, where the horror works better: a "too quiet" night, the edge of sanity,
## and the house after dark. Short stingers mark the big moments (a page found, an achievement, the bell) and
## duck the music under them. A night visitor gets its sting first, then its dread track.
## Everything plays on the Music bus, so the Music volume setting covers it. An open menu lowers it.

var m: MainGame

# Every track. path: where its file lives (a missing loop plays the old dreary loop instead, so the game never
# goes quiet by mistake; a missing stinger is skipped). loop: whether it loops. db: its level at full strength.
# context: when it plays. layer: true for a stem played in time over another track (the trek's tense layer).
# MUSIC_BRIEF.md has the composer's notes for each.
const DIR := "res://audio/music/"
const FALLBACK := "res://audio/dreary_loop.ogg"
const TRACKS := {
	"title": {"path": DIR + "title.ogg", "loop": true, "db": -8.0, "context": "The title screen."},
	"spring": {"path": DIR + "spring.ogg", "loop": true, "db": -10.0, "context": "Outdoors by day, March to May."},
	"summer": {"path": DIR + "summer.ogg", "loop": true, "db": -10.0, "context": "Outdoors by day, June to August."},
	"autumn": {"path": DIR + "autumn.ogg", "loop": true, "db": -10.0, "context": "Outdoors by day, September to November."},
	"winter": {"path": DIR + "winter.ogg", "loop": true, "db": -10.0, "context": "Outdoors by day, December to February."},
	"hearth": {"path": DIR + "hearth.ogg", "loop": true, "db": -14.0, "context": "In the farmhouse by day (silence there after dark)."},
	"night": {"path": DIR + "night.ogg", "loop": true, "db": -12.0, "context": "Outdoors from dusk (19:00)."},
	"trek": {"path": DIR + "trek.ogg", "loop": true, "db": -10.0, "context": "On a trek into the Rookery Wood."},
	"trek_tense": {"path": DIR + "trek_tense.ogg", "loop": true, "db": -9.0, "layer": true,
		"context": "Over the trek, in time: the walker's nerve is low or the tall one is near."},
	"cave": {"path": DIR + "cave.ogg", "loop": true, "db": -11.0, "context": "In the mining cave."},
	"dread": {"path": DIR + "dread.ogg", "loop": true, "db": -9.0, "context": "A night visitor is on the farm, after its sting."},
	"hollow": {"path": DIR + "hollow.ogg", "loop": true, "db": -7.0, "context": "The Hollow at the door, or its first sighting."},
	"ending": {"path": DIR + "ending.ogg", "loop": true, "db": -7.0, "context": "An ending's lines and its credits."},
	"sting_visitor": {"path": DIR + "sting_visitor.ogg", "loop": false, "db": -6.0, "context": "A night visitor appears."},
	"sting_hollow": {"path": DIR + "sting_hollow.ogg", "loop": false, "db": -4.0, "context": "The Hollow appears."},
	"sting_page": {"path": DIR + "sting_page.ogg", "loop": false, "db": -8.0, "context": "One of Agnes Rook's pages is found."},
	"sting_achievement": {"path": DIR + "sting_achievement.ogg", "loop": false, "db": -9.0, "context": "An achievement is earned."},
	"sting_bell": {"path": DIR + "sting_bell.ogg", "loop": false, "db": -5.0, "context": "The crow bell rings for the first time."},
}
const SEASON_TRACKS := {"Spring": "spring", "Summer": "summer", "Autumn": "autumn", "Winter": "winter"}
const ENCOUNTER_TRACKS := ["dread", "hollow"]
const FADE_SECONDS := 3.0       # a crossfade between tracks
const LAYER_SECONDS := 2.0      # the trek's tense layer coming in or going out
const SILENT_FEAR := 0.85       # below 15% sanity the music stops, and the heartbeat and whispers have the dark
const TENSE_NERVE := 40.0       # the walker's nerve under this brings in the tense layer
const MENU_DB := -6.0           # an open menu lowers the music this far
const STING_DB := -10.0         # the music under a stinger
const DUCK_PER_SECOND := 24.0   # how fast the ducking moves, in decibels a second
const BED_DUCK_DB := -3.0       # the ambience's steady beds, under music at full strength
const BEDS := ["wind", "night", "crickets", "house", "cave"]

var players: Array = []         # two AudioStreamPlayers, for crossfades
var cur := 0                    # the player carrying the wanted track
var gains := [0.0, 0.0]         # each player's strength, 0 to 1
var ids := ["", ""]             # the track on each player ("" when none)
var layer: AudioStreamPlayer    # the trek's tense layer
var layer_gain := 0.0
var sting_player: AudioStreamPlayer
var streams := {}               # path -> stream, loaded once
var want := ""                  # what the moment calls for ("" is silence)
var hold := 0.0                 # seconds of quiet before an encounter's track, while its sting plays
var duck_db := 0.0


func _init(main: MainGame) -> void:
	m = main


func setup() -> void:
	for i in 2:
		players.append(_player())
	layer = _player()
	sting_player = _player()


func _player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "Music"   # the Music bus carries the volume setting, and is muted at 0
	p.volume_db = -80.0
	m.add_child(p)
	return p


# The track's stream, or the dreary loop for a missing loop, or null for a missing stinger or layer.
func _stream(id: String) -> AudioStream:
	var t: Dictionary = TRACKS[id]
	var path := str(t["path"])
	if not ResourceLoader.exists(path):
		if not t["loop"] or t.get("layer", false):
			return null
		path = FALLBACK
	if not streams.has(path):
		var s := load(path) as AudioStreamOggVorbis
		if s != null:
			s.loop = bool(t["loop"]) or path == FALLBACK
		streams[path] = s
	return streams[path]


# What the moment calls for, highest priority first. "" is silence.
func _pick() -> String:
	if not m.world_started:
		return "title"
	if m.act.playing():
		return "ending"
	if m.nights._active():
		var vid := str(m.nights.visitor["id"])
		if vid in ["hollow", "sighting"]:
			return "hollow"
		return "" if vid == "quiet" else "dread"
	if m.trek.active:
		return "trek"
	if m.in_cave:
		return "cave"
	if m.ambience.hush_left > 0.0 or m.ambience._fear() >= SILENT_FEAR:
		return ""
	var night := m.current_hour >= m.DUSK_HOUR or m.current_hour < 5.0
	if m.inside:
		return "" if night else "hearth"
	if night:
		return "night"
	return str(SEASON_TRACKS.get(m._season_of(m._calendar_date(m.day)["month"]), "autumn"))


func update(delta: float) -> void:
	if players.is_empty():
		return
	var next := _pick()
	if next != want:
		# A visitor's sting comes first, alone; its dread track waits until the sting has rung out.
		if next in ENCOUNTER_TRACKS and not (want in ENCOUNTER_TRACKS):
			hold = sting("sting_hollow" if next == "hollow" else "sting_visitor", true)
		want = next
	hold = maxf(0.0, hold - delta)
	var target := "" if hold > 0.0 else want
	if target != ids[cur]:
		_switch(target)
	var step := delta / FADE_SECONDS
	for i in 2:
		gains[i] = move_toward(float(gains[i]), 1.0 if i == cur and ids[i] != "" else 0.0, step)
	# The trek's tense layer, in time with the trek.
	var tense: bool = ids[cur] == "trek" and m.trek.active and (m.trek.nerve < TENSE_NERVE or m.trek.tall_on)
	layer_gain = move_toward(layer_gain, 1.0 if tense else 0.0, delta / LAYER_SECONDS)
	# Ducking: under a stinger, and lowered while a menu is open.
	var duck := 0.0
	if sting_player.playing:
		duck = STING_DB
	elif m.world_started and m.player != null and (m.open_tab != "" or m._bag_open() or m._wheel_open()):
		duck = MENU_DB
	duck_db = move_toward(duck_db, duck, DUCK_PER_SECOND * delta)
	for i in 2:
		_level(players[i], str(ids[i]), float(gains[i]))
	_level(layer, "trek_tense" if layer.stream != null else "", layer_gain * float(gains[cur]) if ids[cur] == "trek" else 0.0)


func _level(p: AudioStreamPlayer, id: String, gain: float) -> void:
	if id == "" or gain <= 0.001:
		if p.playing:
			p.stop()
		p.volume_db = -80.0
		return
	if not p.playing:
		p.play(_sync_from(p))
	p.volume_db = float(TRACKS[id]["db"]) + linear_to_db(gain) + duck_db


# Where a player starts: the tense layer starts at the trek's place so they stay in time; tracks from the top.
func _sync_from(p: AudioStreamPlayer) -> float:
	if p == layer and players[cur].playing:
		return fmod(players[cur].get_playback_position(), maxf(0.01, layer.stream.get_length()))
	return 0.0


# Crossfades to a track: the one playing fades out on its player while the new one fades in on the other.
func _switch(target: String) -> void:
	# Two tracks that both fall back to the dreary loop are the same music: it keeps playing.
	if target != "" and ids[cur] != "" and _stream(target) == _stream(str(ids[cur])):
		ids[cur] = target
		_prepare_layer(target)
		return
	cur = 1 - cur
	ids[cur] = target
	var p: AudioStreamPlayer = players[cur]
	p.stop()
	gains[cur] = 0.0
	p.stream = _stream(target) if target != "" else null
	if p.stream == null:
		ids[cur] = ""
	_prepare_layer(target)


func _prepare_layer(target: String) -> void:
	if target != "trek":
		layer.stop()
		layer_gain = 0.0
		return
	if layer.stream == null:
		layer.stream = _stream("trek_tense")


# Plays a stinger over the music, which ducks under it. Returns its length in seconds (0 when it didn't play).
# One already ringing isn't cut off, unless force.
func sting(id: String, force := false) -> float:
	if sting_player == null or not m.world_started:
		return 0.0
	if sting_player.playing and not force:
		return 0.0
	var s := _stream(id)
	if s == null:
		return 0.0
	sting_player.stream = s
	sting_player.volume_db = float(TRACKS[id]["db"])
	sting_player.play()
	return s.get_length()


# How far the ambience's steady beds drop under the music, so the two don't fight.
func bed_duck_db(loop_name: String) -> float:
	if not (loop_name in BEDS) or players.is_empty() or GameSettings.music_volume <= 0:
		return 0.0
	return BED_DUCK_DB * float(gains[cur]) if ids[cur] != "" else 0.0


# For tools/capture.gd's sound option: what is playing and how loud.
func describe() -> String:
	var out := "music want=%s playing=%s gain=%.2f db=%.1f duck=%.1f" % [want, ids[cur], gains[cur], players[cur].volume_db, duck_db]
	if ids[cur] != "":
		out += " file=%s" % (players[cur].stream.resource_path if players[cur].stream != null else "none")
	if layer.playing:
		out += " tense_layer=%.2f" % layer_gain
	return out
