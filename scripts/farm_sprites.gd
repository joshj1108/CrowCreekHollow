class_name FarmSprites
extends RefCounted

# Pixel art for the farm, cut from the tileset sheet in art/farm/. Each texture loads once.
# Flipped copies are made from the same image, so a flipped edge piece costs no extra file.
const DIR := "res://art/farm/"
static var _cache := {}


static func tex(name: String, flip_y := false) -> Texture2D:
	return tex_flipped(name, false, flip_y)


# The texture, mirrored across x and/or y. Mirrored copies are made once and cached.
static func tex_flipped(name: String, flip_x: bool, flip_y: bool) -> Texture2D:
	var key := "%s|%s|%s" % [name, flip_x, flip_y]
	if _cache.has(key):
		return _cache[key]
	var img: Image = load(DIR + name + ".png").get_image()
	if flip_x:
		img.flip_x()
	if flip_y:
		img.flip_y()
	var t := ImageTexture.create_from_image(img)
	_cache[key] = t
	return t


static func variant(x: int, y: int, count: int) -> int:
	var h := (x * 73856093) ^ (y * 19349663) ^ (8 * 83492791)
	return absi(h) % count
