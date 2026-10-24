class_name FarmSprites
extends RefCounted

# Pixel art for the farm, cut from the tileset sheet in art/farm/. Each texture loads once.
# Flipped copies are made from the same image, so a flipped edge piece costs no extra file.
const DIR := "res://art/farm/"
static var _cache := {}


static func tex(name: String, flip_y := false) -> Texture2D:
	var key := "%s|%s" % [name, flip_y]
	if _cache.has(key):
		return _cache[key]
	var img: Image = load(DIR + name + ".png").get_image()
	if flip_y:
		img.flip_y()
	var t := ImageTexture.create_from_image(img)
	_cache[key] = t
	return t


static func variant(x: int, y: int, count: int) -> int:
	var h := (x * 73856093) ^ (y * 19349663) ^ (8 * 83492791)
	return absi(h) % count
