class_name HudIcon
extends Control

## Small hand-drawn icons for the info bar: a heart, moon, coin, and weather marks.
## Each is drawn in code, so the bar needs no image files.

var kind := "coin"


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.46
	var gold := Color("e0b35a")
	var dark := Color("3a2a1c")
	match kind:
		"heart":
			var red := Color("d9534f")
			draw_circle(c + Vector2(-r * 0.5, -r * 0.2), r * 0.55, red)
			draw_circle(c + Vector2(r * 0.5, -r * 0.2), r * 0.55, red)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-r, -r * 0.05), c + Vector2(r, -r * 0.05), c + Vector2(0, r)]), red)
		"moon":
			draw_circle(c, r, gold)
			draw_circle(c + Vector2(r * 0.5, -r * 0.25), r * 0.85, dark)
		"coin":
			draw_circle(c, r, gold)
			draw_arc(c, r * 0.6, 0.0, TAU, 18, Color("8a6428"), 1.5)
		"sun":
			var sun := Color("f2d27a")
			draw_circle(c, r * 0.5, sun)
			for i in 8:
				var a := TAU * float(i) / 8.0
				draw_line(c + Vector2(cos(a), sin(a)) * r * 0.7, c + Vector2(cos(a), sin(a)) * r, sun, 1.6)
		"rain":
			var grey := Color("b9c4cf")
			draw_circle(c + Vector2(-r * 0.35, -r * 0.2), r * 0.45, grey)
			draw_circle(c + Vector2(r * 0.25, -r * 0.25), r * 0.55, grey)
			draw_circle(c + Vector2(r * 0.05, -r * 0.45), r * 0.5, grey)
			for x in [-r * 0.45, 0.0, r * 0.45]:
				draw_line(c + Vector2(x, r * 0.35), c + Vector2(x - r * 0.15, r * 0.9), Color("7fb8e0"), 1.6)
		_:
			# Clouds, and anything else.
			var cloud := Color("c9ccd4")
			draw_circle(c + Vector2(-r * 0.4, 0.0), r * 0.5, cloud)
			draw_circle(c + Vector2(r * 0.2, -r * 0.2), r * 0.6, cloud)
			draw_circle(c + Vector2(r * 0.6, r * 0.1), r * 0.4, cloud)
