class_name Weather
extends CanvasLayer

## Dreary weather over the farm: a grey wash, clouds drifting across the top, a darkened edge,
## and steady rain. It is always rainy for now; weather that changes can come later.

const DROPS := 170
const CLOUDS := 6
const WIND := 30.0          # sideways drift of the rain, in pixels per second

var drops: Array = []       # each: {"p": Vector2, "v": falling speed}
var clouds: Array = []      # each: {"c": Vector2, "r": radius, "v": drift speed}
var rain_canvas: Control
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	# Layer 0 puts the weather over the world but under the HUD and menus, so the panels stay clear.
	layer = 0
	rng.randomize()
	var size := get_viewport().get_visible_rect().size

	var wash := ColorRect.new()
	wash.color = Color(0.3, 0.34, 0.4, 0.2)
	_fill(wash)
	add_child(wash)

	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0.03, 0.04, 0.06, 0.6)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	var edge := TextureRect.new()
	edge.texture = tex
	edge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	edge.stretch_mode = TextureRect.STRETCH_SCALE
	_fill(edge)
	add_child(edge)

	rain_canvas = Control.new()
	_fill(rain_canvas)
	rain_canvas.draw.connect(_draw_weather)
	add_child(rain_canvas)

	for i in DROPS:
		drops.append({"p": Vector2(rng.randf() * size.x, rng.randf() * size.y), "v": rng.randf_range(210.0, 310.0)})
	for i in CLOUDS:
		clouds.append({
			"c": Vector2(rng.randf() * size.x, rng.randf_range(-40.0, 120.0)),
			"r": rng.randf_range(160.0, 280.0),
			"v": rng.randf_range(8.0, 18.0),
		})


func _fill(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	var size := get_viewport().get_visible_rect().size
	for d in drops:
		var p: Vector2 = d["p"]
		p.y += float(d["v"]) * delta
		p.x += WIND * delta
		if p.y > size.y:
			p.y = -20.0
			p.x = rng.randf() * size.x
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
	rain_canvas.queue_redraw()


func _draw_weather() -> void:
	for c in clouds:
		var centre: Vector2 = c["c"]
		var r := float(c["r"])
		var cloud := Color(0.18, 0.2, 0.24, 0.2)
		for i in 4:
			var offset := Vector2((i - 1.5) * r * 0.45, sin(float(i)) * r * 0.12)
			rain_canvas.draw_circle(centre + offset, r * 0.55, cloud)
	for d in drops:
		var p: Vector2 = d["p"]
		rain_canvas.draw_line(p, p + Vector2(WIND * 0.05, 14.0), Color(0.75, 0.82, 0.9, 0.35), 1.0)
