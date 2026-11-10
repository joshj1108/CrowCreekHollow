class_name HudIcon
extends Control

## Small icons for the HUD: health, sanity, coins, the body needs, the diary, and weather marks.
## UI-OVERHAUL-001 Phase 3: drawn from art/ui/hud_icons.png (10 x 10 pixel art, tools/make_hud_art.py) at the
## largest whole multiple that fits, so they stay crisp. The shapes below are the fallback when the art is missing.

const ATLAS := ["heart", "moon", "coin", "food", "water", "warmth", "nerve", "book", "seal", "sun", "cloud",
	"rain", "snow", "fog"]
const CELL := 10
static var _atlas: Texture2D
static var _atlas_checked := false

var kind := "coin"
var dot := false   # the diary's wax seal, shown while a page is new


static func atlas() -> Texture2D:
	if not _atlas_checked:
		_atlas_checked = true
		var path := "res://art/ui/hud_icons.png"
		_atlas = load(path) if ResourceLoader.exists(path) else null
	return _atlas


func _draw() -> void:
	var tex := atlas()
	var cell := ATLAS.find(kind)
	if tex != null and cell >= 0:
		var k := maxf(1.0, floorf(minf(size.x, size.y) / CELL))
		var side := CELL * k
		var at := ((size - Vector2(side, side)) * 0.5).floor()
		draw_texture_rect_region(tex, Rect2(at, Vector2(side, side)), Rect2(cell * CELL, 0, CELL, CELL))
		if kind == "book" and dot:
			draw_texture_rect_region(tex, Rect2(at, Vector2(side, side)), Rect2(ATLAS.find("seal") * CELL, 0, CELL, CELL))
		return
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
		"book":
			# A brown leather diary with cream page edges and a ribbon.
			var cover := Rect2(c + Vector2(-r * 0.75, -r * 0.95), Vector2(r * 1.5, r * 1.9))
			draw_rect(cover, Color("1e140c"))
			draw_rect(cover.grow(-1.0), Color("7a4a2a"))
			draw_rect(Rect2(cover.position + Vector2(cover.size.x - 3.0, 2.0), Vector2(2.0, cover.size.y - 4.0)), Color("e8dcc0"))
			draw_rect(Rect2(cover.position + Vector2(2.0, 1.0), Vector2(2.0, cover.size.y - 2.0)), Color("4f2e1a"))
			draw_line(c + Vector2(r * 0.15, -r * 0.95), c + Vector2(r * 0.15, r * 1.15), Color("b8443a"), 1.5)
			if dot:
				draw_circle(c + Vector2(r * 0.85, -r * 0.85), r * 0.42, Color("1e140c"))
				draw_circle(c + Vector2(r * 0.85, -r * 0.85), r * 0.32, Color("ff3a2a"))
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
