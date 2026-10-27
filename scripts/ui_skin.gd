class_name UiSkin
extends RefCounted

# The UI's SpriteCook art (art/ui/): dark wood frames with iron corner brackets, cut from one UI kit sheet.
# Each piece is a 9-slice: its corners keep their size and its edges and centre stretch. Every function
# returns null when the art is missing, so the caller keeps its flat style.
const DIR := "res://art/ui/"
# Corner size of each piece in its art's pixels (left/right, top/bottom), measured from the pieces.
const MARGINS := {
	"panel": Vector2(34, 34),
	"button": Vector2(22, 18),
	"slot": Vector2(24, 24),
	"bar": Vector2(15, 7),
	"fill": Vector2(3, 3),
}
# A meter's bar is just its channel; the frame is drawn this far outside it, over the iron end caps and
# rails, so the fill's length matches the value. Callers leave this much room around the bar.
const FRAME_OUTSET := Vector2(13, 7)
const CHANNEL_SIZE := Vector2(52, 8)
static var _cache := {}


static func _tex(name: String) -> Texture2D:
	if not _cache.has(name):
		var path := DIR + name + ".png"
		_cache[name] = load(path) if ResourceLoader.exists(path) else null
	return _cache[name]


static func _box(name: String, margin_key: String, content: Vector2) -> StyleBoxTexture:
	var tex := _tex(name)
	if tex == null:
		return null
	var m: Vector2 = MARGINS[margin_key]
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = m.x
	sb.texture_margin_right = m.x
	sb.texture_margin_top = m.y
	sb.texture_margin_bottom = m.y
	# Edges and centre stretch rather than tile: tiling repeats the wood's seams and nail heads.
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.content_margin_left = content.x
	sb.content_margin_right = content.x
	sb.content_margin_top = content.y
	sb.content_margin_bottom = content.y
	return sb


# A large framed panel: menus, the bag and the HUD boxes.
static func panel(content := 18.0) -> StyleBoxTexture:
	return _box("panel", "panel", Vector2(content, content))


# A framed dark slot: hotbar and bag slots, craft tiles and the cards inside a section. Lit is the gold edge.
static func slot(lit: bool, content := 6.0) -> StyleBoxTexture:
	return _box("slot_selected" if lit else "slot", "slot", Vector2(content, content))


# A wooden button in one of its states: normal, hover, pressed or disabled.
static func button(state: String) -> StyleBoxTexture:
	return _box("button_%s" % state, "button", Vector2(14, 8))


# A meter's frame: a dark channel between iron end caps, drawn around the bar.
static func bar_background() -> StyleBoxTexture:
	var sb := _box("bar_frame", "bar", Vector2.ZERO)
	if sb == null:
		return null
	sb.expand_margin_left = FRAME_OUTSET.x
	sb.expand_margin_right = FRAME_OUTSET.x
	sb.expand_margin_top = FRAME_OUTSET.y
	sb.expand_margin_bottom = FRAME_OUTSET.y
	return sb


# A meter's fill, in the need's colour (food, water or warmth).
static func bar_fill(kind: String) -> StyleBoxTexture:
	return _box("bar_fill_%s" % kind, "fill", Vector2.ZERO)


# A frame with no centre, laid over something drawn under it, such as the minimap.
static func frame() -> StyleBoxTexture:
	var sb := panel(0)
	if sb != null:
		sb.draw_center = false
	return sb


# The panel's wood, for filling shapes a 9-slice can't, such as the section wheel's segments.
static func wood() -> Texture2D:
	return _tex("wood")


# Item icons: art/ui/icons.png, a 4-wide atlas of 16-pixel SpriteCook icons, four per row in this order.
# Ore and bars come in iron and copper; the item's tint says which.
const ICONS := [
	"axe", "pick", "hoe", "trowel",
	"hose", "rod", "hammer", "broom",
	"sword", "shield", "bow", "arrow",
	"lantern", "glove", "pack", "anvil",
	"hat", "shirt", "pants", "boots",
	"pendant", "bracer", "bandage", "bowl",
	"crop", "turnip", "pumpkin", "pumpkin_seed",
	"seed", "egg", "milk", "fish",
	"grilled", "smoked", "hash", "soup",
	"fish_stew", "hearty", "dried", "canned",
	"fermented", "firewood", "jar", "log",
	"fiber", "sticks", "resin", "stone",
	"ore", "ore_copper", "bar", "bar_copper",
	"corn",
]
const COPPER_TINTS := ["b87333", "c97f45"]


# The atlas rectangle for an item icon, or an empty rect when there is no icon art for that kind.
static func icon_rect(kind: String, tint: Color) -> Rect2:
	if _tex("icons") == null:
		return Rect2()
	var key := kind
	if (kind == "ore" or kind == "bar") and COPPER_TINTS.has(tint.to_html(false)):
		key = kind + "_copper"
	var i := ICONS.find(key)
	if i < 0:
		return Rect2()
	return Rect2((i % 4) * 16, (i / 4) * 16, 16, 16)


static func icons() -> Texture2D:
	return _tex("icons")


# Styles every state of a button. Focus looks like hover, so keyboard and gamepad focus is easy to see.
# Returns false when the art is missing.
static func style_button(b: Button) -> bool:
	var normal := button("normal")
	if normal == null:
		return false
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", button("hover"))
	b.add_theme_stylebox_override("focus", button("hover"))
	b.add_theme_stylebox_override("pressed", button("pressed"))
	b.add_theme_stylebox_override("disabled", button("disabled"))
	return true
