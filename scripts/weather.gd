class_name Weather
extends CanvasLayer

## The weather over the farm. Each morning the game picks a kind of weather for the season, and this
## overlay shows it: a grey wash, drifting clouds, a darkened edge, and rain, drizzle, or snow.
## Indoors and in the cave the overlay is hidden.
##
## With the SpriteCook art (art/farm/weather_*.png) rain falls as crisp pixel streaks that splash where
## they land, snow falls as flakes and clumps, and fog rolls by in wisps. Without it the old soft shapes
## are drawn.

const MAX_DROPS := 320
const CLOUDS := 6
const WIND := 30.0          # sideways drift of the rain, in pixels per second
const ART := "res://art/farm/"
const CELL := 16            # each cell of the drops and splash strips
const PIX := 3.0            # one art pixel on screen, matching the world's 3x scale
const SPLASH_FPS := 14.0
const SPLASH_SCALE := 2.0
const FOG_WISPS := 7

# How each kind of weather looks. Rain speeds are already halved from the first version.
const PRESETS := {
	"sunny":    {"wash": 0.0,  "edge": 0.0,  "clouds": 0.05, "drops": 0,   "speed": Vector2(0, 0),     "snow": false},
	"cloudy":   {"wash": 0.12, "edge": 0.22, "clouds": 0.22, "drops": 0,   "speed": Vector2(0, 0),     "snow": false},
	"fog":      {"wash": 0.42, "edge": 0.55, "clouds": 0.10, "drops": 0,   "speed": Vector2(0, 0),     "snow": false},
	"drizzle":  {"wash": 0.20, "edge": 0.30, "clouds": 0.25, "drops": 90,  "speed": Vector2(120, 170), "snow": false},
	"rain":     {"wash": 0.30, "edge": 0.50, "clouds": 0.30, "drops": 170, "speed": Vector2(210, 310), "snow": false},
	"downpour": {"wash": 0.40, "edge": 0.65, "clouds": 0.36, "drops": 300, "speed": Vector2(300, 420), "snow": false},
	"snow":     {"wash": 0.22, "edge": 0.35, "clouds": 0.25, "drops": 140, "speed": Vector2(40, 70),   "snow": true},
}

var kind := ""
var drops: Array = []       # each: {"p": Vector2, "v": falling speed}
var clouds: Array = []      # each: {"c": Vector2, "r": radius, "v": drift speed}
var active_drops := 0
var snowing := false
var cloud_alpha := 0.25
var wash_rect: ColorRect
var edge_rect: TextureRect
var rain_canvas: Control
var rng := RandomNumberGenerator.new()
var splashes: Array = []    # each: {"p": Vector2, "t": seconds since it landed}
var wisps: Array = []       # each: {"p": Vector2, "v": drift speed, "s": scale, "a": alpha}
var drops_tex: Texture2D
var splash_tex: Texture2D
var fog_tex: Texture2D


func _ready() -> void:
	# Layer 0 puts the weather over the world but under the HUD and menus, so the panels stay clear.
	layer = 0
	rng.randomize()
	var size := get_viewport().get_visible_rect().size

	wash_rect = ColorRect.new()
	wash_rect.color = Color(0.3, 0.34, 0.4, 1.0)
	_fill(wash_rect)
	add_child(wash_rect)

	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0.03, 0.04, 0.06, 0.6)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	edge_rect = TextureRect.new()
	edge_rect.texture = tex
	edge_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	edge_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_fill(edge_rect)
	add_child(edge_rect)

	rain_canvas = Control.new()
	_fill(rain_canvas)
	rain_canvas.draw.connect(_draw_weather)
	add_child(rain_canvas)

	drops_tex = _art("weather_drops")
	splash_tex = _art("weather_splash")
	fog_tex = _art("weather_fog")
	for i in MAX_DROPS:
		drops.append({"p": Vector2(rng.randf() * size.x, rng.randf() * size.y), "v": 250.0})
		_new_landing(drops[i], size)
	for i in FOG_WISPS:
		wisps.append({
			"p": Vector2(rng.randf_range(-400.0, size.x), rng.randf_range(-40.0, size.y)),
			"v": rng.randf_range(6.0, 16.0),
			"s": rng.randf_range(2.5, 4.0),
			"a": rng.randf_range(0.16, 0.3),
		})
	for i in CLOUDS:
		clouds.append({
			"c": Vector2(rng.randf() * size.x, rng.randf_range(-40.0, 120.0)),
			"r": rng.randf_range(160.0, 280.0),
			"v": rng.randf_range(8.0, 18.0),
		})
	set_condition("rain")


# Shows one kind of weather. Speeds are reset so rain, drizzle, and snow fall at their own pace.
func set_condition(new_kind: String) -> void:
	if not PRESETS.has(new_kind):
		new_kind = "cloudy"
	kind = new_kind
	var p: Dictionary = PRESETS[kind]
	wash_rect.color = Color(0.3, 0.34, 0.4, float(p["wash"]))
	edge_rect.modulate.a = float(p["edge"])
	cloud_alpha = float(p["clouds"])
	active_drops = int(p["drops"])
	snowing = bool(p["snow"])
	var speed: Vector2 = p["speed"]
	for d in drops:
		d["v"] = rng.randf_range(speed.x, speed.y)


func _art(name: String) -> Texture2D:
	var path := ART + name + ".png"
	return load(path) if ResourceLoader.exists(path) else null


# Where a drop will hit the ground, somewhere on the screen, and how it is drawn: snow picks one of the
# flake cells, mostly the small clump, and some flakes are nearer and bigger.
func _new_landing(d: Dictionary, size: Vector2) -> void:
	d["land"] = rng.randf_range(size.y * 0.15, size.y + 20.0)
	d["len"] = rng.randi_range(4, 6)
	var r := rng.randf()
	d["cell"] = 1 if r < 0.12 else (3 if r < 0.22 else 2)
	d["near"] = rng.randf() < 0.3


func _fill(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	var size := get_viewport().get_visible_rect().size
	for i in active_drops:
		var d: Dictionary = drops[i]
		var p: Vector2 = d["p"]
		p.y += float(d["v"]) * delta
		p.x += WIND * delta
		# Rain with art lands at its own spot and splashes; snow and the old rain fall off the bottom.
		var lands := drops_tex != null and not snowing
		if (lands and p.y > float(d["land"])) or p.y > size.y + 20.0:
			if lands and splash_tex != null and splashes.size() < 120:
				splashes.append({"p": p, "t": 0.0})
			p.y = rng.randf_range(-40.0, -10.0)
			p.x = rng.randf() * size.x
			_new_landing(d, size)
		if p.x > size.x:
			p.x -= size.x
		d["p"] = p
	for c in clouds:
		var centre: Vector2 = c["c"]
		centre.x += float(c["v"]) * delta
		var r := float(c["r"])
		if centre.x - r > size.x:
			centre.x = -r
		c["c"] = centre
	if active_drops == 0 or snowing:
		splashes.clear()
	for s in splashes.duplicate():
		s["t"] = float(s["t"]) + delta
		if float(s["t"]) * SPLASH_FPS >= 3.0:
			splashes.erase(s)
	if kind == "fog":
		for w in wisps:
			var wp: Vector2 = w["p"]
			wp.x += float(w["v"]) * delta
			if wp.x > size.x:
				wp.x = -128.0 * float(w["s"])
				wp.y = rng.randf_range(-40.0, size.y)
			w["p"] = wp
	rain_canvas.queue_redraw()


func _draw_weather() -> void:
	for c in clouds:
		var centre: Vector2 = c["c"]
		var r := float(c["r"])
		var cloud := Color(0.18, 0.2, 0.24, cloud_alpha)
		for i in 4:
			var offset := Vector2((i - 1.5) * r * 0.45, sin(float(i)) * r * 0.12)
			rain_canvas.draw_circle(centre + offset, r * 0.55, cloud)
	if kind == "fog" and fog_tex != null:
		for w in wisps:
			var sc := float(w["s"])
			var wp: Vector2 = w["p"]
			rain_canvas.draw_texture_rect(fog_tex, Rect2(wp.snapped(Vector2(PIX, PIX)), fog_tex.get_size() * sc),
				false, Color(1, 1, 1, float(w["a"])))
	if drops_tex == null:
		for i in active_drops:
			var p: Vector2 = drops[i]["p"]
			if snowing:
				rain_canvas.draw_circle(p, 2.2, Color(0.95, 0.97, 1.0, 0.7))
			else:
				rain_canvas.draw_line(p, p + Vector2(WIND * 0.05, 14.0), Color(0.75, 0.82, 0.9, 0.35), 1.0)
		return
	for i in active_drops:
		var d: Dictionary = drops[i]
		var p: Vector2 = (d["p"] as Vector2).snapped(Vector2(PIX, PIX))
		if snowing:
			# The flake cells at 1x (a clump is a few pixels; a full flake is a near one); some clumps nearer, at 2x.
			var sc := 2.0 if bool(d["near"]) and int(d["cell"]) == 2 else 1.0
			var src := Rect2(int(d["cell"]) * CELL, 0, CELL, CELL)
			rain_canvas.draw_texture_rect_region(drops_tex, Rect2(p, Vector2(CELL, CELL) * sc), src, Color(1, 1, 1, 0.85))
		else:
			# A crisp streak one art pixel wide: a pale head over a fading tail.
			var n := int(d["len"])
			for k in n:
				var a := 0.55 * (1.0 - float(k) / float(n))
				rain_canvas.draw_rect(Rect2(p - Vector2(0, k * PIX), Vector2(PIX, PIX)), Color(0.72, 0.8, 0.9, a))
	for s in splashes:
		# Frame 0 is a standing drop; a landing streak goes straight to the burst, ring and ripple.
		var f := mini(3, 1 + int(float(s["t"]) * SPLASH_FPS))
		var box := Vector2(CELL, CELL) * SPLASH_SCALE
		var at: Vector2 = (s["p"] as Vector2) - Vector2(box.x * 0.5, box.y * 0.75)
		rain_canvas.draw_texture_rect_region(splash_tex, Rect2(at.snapped(Vector2(2, 2)), box),
			Rect2(f * CELL, 0, CELL, CELL), Color(1, 1, 1, 0.7))
