# ART-OVERHAUL-001 Stage D finishing pass: trail readability from the existing ground art, no generation.
# Writes art/farm/trek/ground_<g>_df.png beside each original (the originals stay; TrekArt.FINISH picks the _df file).
# Colours used only in the all-trail tiles are lifted a little (more on the pasture, whose trail sat close to its
# grass); colours used only in the all-open tiles are pulled toward their mean value, so the grass is quieter and the
# worn way reads against it. Edge pixels keep whichever palette they belong to, so the dual-grid edges stay as drawn.
import colorsys
from PIL import Image

LIFT = {"forest": 1.07, "pasture": 1.16, "hollow": 1.10}
QUIET = 0.65      # grass value spread kept (1.0 = unchanged)
GRASS_DARK = 0.97

def lum(p):
	return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]

for g in LIFT:
	src = "art/farm/trek/ground_%s.png" % g
	im = Image.open(src).convert("RGBA")
	px = im.load()
	trail, grass = set(), set()
	for i in range(4):
		for y in range(16):
			for x in range(16):
				grass.add(px[64 + i * 16 + x, y])
				trail.add(px[64 + i * 16 + x, 16 + y])
	only_t, only_g = trail - grass, grass - trail
	mean_g = sum(lum(c) for c in only_g) / len(only_g)
	def remap(c):
		if c[3] == 0:
			return c
		h, l, s = colorsys.rgb_to_hls(*[v / 255 for v in c[:3]])
		if c in only_t:
			l = min(1.0, l * LIFT[g])
		elif c in only_g:
			target = (mean_g / 255 + (l - mean_g / 255) * QUIET) * GRASS_DARK
			l = max(0.0, target)
		else:
			return c
		r, gg, b = colorsys.hls_to_rgb(h, l, s)
		return (round(r * 255), round(gg * 255), round(b * 255), c[3])
	out = im.copy()
	op = out.load()
	for y in range(im.height):
		for x in range(im.width):
			op[x, y] = remap(px[x, y])
	out.save(src.replace(".png", "_df.png"))
	print(g, "trail cols", len(only_t), "grass cols", len(only_g))
