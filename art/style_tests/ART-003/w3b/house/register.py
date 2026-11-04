# ART-003 W-3 Batch B (non-production): hand registration of the chosen Restored-house candidate.
# gen_c_s170p.png (PixelLab pixflux img2img of init.png, strength 170, concept palette, seed 701) -> house_w3b.png.
# Every change is listed here and counted; nothing is resampled.
#   python register.py   ->  house_w3b.png, house_w3b_diff.png (changed pixels in magenta), and the counts
from PIL import Image

src = Image.open('gen_c_s170p.png').convert('RGBA')
W, H = src.size
# 1. Up one pixel, so the stone footing (the wall line) ends at y 149 as the locked sprite needs (it ended at 150).
img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
img.paste(src.crop((0, 1, W, H)), (0, 0))
px = img.load()
opaque = [px[x, y] for y in range(H) for x in range(W) if px[x, y][3] > 200]
OUT = min(opaque, key=lambda c: c[0] + c[1] + c[2])          # the sprite's own outline colour
CLEAR = (0, 0, 0, 0)

# 2. The chimney: a wooden board sat on top of it (y 3..20 after the shift). Clear it, carry the stone up from the
#    chimney's own rows, and close it with a stone cap one pixel wider each side and a dark flue.
for y in range(0, 21):
    for x in range(116, 150):
        px[x, y] = CLEAR
cx0, cx1 = 124, 141                                         # the stone stack's columns, outline included
for y in range(9, 21):
    for x in range(cx0, cx1 + 1):
        px[x, y] = px[x, y + 14]                           # the stone pattern from 14 rows lower
for y in range(9, 21):
    px[cx0, y] = OUT
    px[cx1, y] = OUT
cap = [px[x, 30] for x in range(cx0 + 1, cx1)]
for x in range(cx0 - 1, cx1 + 2):
    px[x, 6] = OUT
    px[x, 9] = OUT
for y in (7, 8):
    px[cx0 - 1, y] = OUT
    px[cx1 + 1, y] = OUT
    for k, x in enumerate(range(cx0, cx1 + 1)):
        c = cap[min(k, len(cap) - 1)]
        px[x, y] = (min(c[0] + 18, 255), min(c[1] + 18, 255), min(c[2] + 16, 255), 255) if y == 7 else c
for x in range(cx0 + 4, cx1 - 3):                           # the flue opening on the cap's top face
    px[x, 7] = (34, 28, 26, 255)

# 3. The gable: the generator left a blank board where the concept has a lit window. Paint one, in the colours of
#    the sprite's own front windows: frame, warm glass, a mullion and a transom, and a sill.
def sample(x, y):
    return px[x, y]
GLASS = sample(44, 105)
GLASS_D = sample(48, 112)
FRAME = sample(38, 112)
for y in range(72, 83):
    for x in range(88, 106):
        edge = x in (88, 105) or y in (72, 82)
        px[x, y] = FRAME if edge else GLASS
for y in range(73, 82):
    px[96, y] = FRAME
    px[97, y] = FRAME
for x in range(89, 105):
    px[x, 77] = FRAME
for x in range(89, 105):
    px[x, 81] = GLASS_D                                     # a darker last row of glass, as on the front windows
for x in range(87, 107):
    px[x, 83] = OUT

# 4. The left edge: a loose vertical board hung off the left wing (x 4..9). Remove it and close the wing's edge.
for y in range(70, H):
    for x in range(0, 10):
        px[x, y] = CLEAR
for y in range(70, 150):
    if px[10, y][3] > 0:
        px[10, y] = OUT

# 5. The steps: three stone treads from the porch (y 150) to the sprite's bottom edge, under the door, using the
#    generated step's own colours; the bottom tread is the widest.
step = [px[x, 151] for x in range(81, 113)]
lite = [px[x, 150] for x in range(81, 113)]
for y in range(150, H):
    for x in range(70, 124):
        px[x, y] = CLEAR
for i, (y0, x0, x1) in enumerate(((150, 82, 111), (153, 80, 113), (156, 78, 115))):
    for y in range(y0, y0 + 3 + (1 if i == 2 else 0)):
        for x in range(x0, x1 + 1):
            k = (x - 81) % len(step)
            if x in (x0, x1) or y == y0 + 2 + (1 if i == 2 else 0):
                px[x, y] = OUT
            else:
                px[x, y] = lite[k] if y == y0 else step[k]

img.save('house_w3b.png')
# The changed-pixel count against the generated candidate (shifted up a pixel, as step 1 is a move, not a redraw).
ref = Image.new('RGBA', (W, H), (0, 0, 0, 0))
ref.paste(src.crop((0, 1, W, H)), (0, 0))
rp = ref.load()
diff = Image.new('RGBA', (W, H), (0, 0, 0, 0))
dp = diff.load()
n = 0
total = sum(1 for y in range(H) for x in range(W) if px[x, y][3] > 0 or rp[x, y][3] > 0)
for y in range(H):
    for x in range(W):
        if px[x, y] != rp[x, y]:
            n += 1
            dp[x, y] = (255, 0, 255, 255)
        elif px[x, y][3] > 0:
            g = sum(px[x, y][:3]) // 3
            dp[x, y] = (g, g, g, 255)
diff.save('house_w3b_diff.png')
print('house_w3b.png: %d of %d sprite pixels changed by hand (%.1f%%) after the 1 px shift' % (n, total, 100.0 * n / total))
