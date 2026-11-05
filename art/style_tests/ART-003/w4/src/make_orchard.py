# ART-003 W-4: manual crown variation and harvest dressing for the orchard, from the Batch C fruit trees
# (w3c/orchard/apple_w3c.png, pear_w3c.png). No generation and no resampling: pixels are recoloured, filled from
# their own neighbours or stamped, and every colour already appears in the two trees or the apple barrel.
#   apple_a  the Batch C apple with its crown's outline gaps filled
#   apple_b  a late apple: the darkest reds of the crown turned olive, so the red apples stand out, and four more apples
#   pear_a   the Batch C pear, filled, with nine small pears set into its crown so it reads as fruiting
#   pear_b   a second pear: different fruit spots and a greener crown top
#   windfall_apple, windfall_pear (3x3), basket (11x8): flat harvest dressing laid under some trees
import os
from PIL import Image
here = os.path.dirname(os.path.abspath(__file__))
src = os.path.join(here, "..", "..", "w3c", "orchard")
out = os.path.join(here, "..", "orchard")
OUT_D = (42, 31, 24, 255)
PEAR_RIM = (90, 61, 38, 255)
RED, RED_D, RED_DD, HI = (196, 64, 42, 255), (156, 42, 30, 255), (110, 26, 22, 255), (246, 196, 90, 255)
GOLD, GOLD_D, OLIVE, OLIVE_D, OLIVE_DD = (246, 196, 90, 255), (240, 160, 48, 255), (154, 154, 74, 255), (94, 110, 52, 255), (67, 85, 44, 255)

def load(n):
    return Image.open(os.path.join(src, n)).convert("RGBA")

def fill(im, rows):
    # Close one-pixel notches in the crown's outline: an empty pixel with three or four filled neighbours takes the
    # colour of the neighbour above (or beside). Twice, crown rows only.
    px = im.load()
    w, h = im.size
    for _ in range(2):
        todo = []
        for y in range(1, rows):
            for x in range(1, w - 1):
                if px[x, y][3] > 0:
                    continue
                nb = [px[x, y - 1], px[x - 1, y], px[x + 1, y], px[x, y + 1]]
                if sum(1 for p in nb if p[3] > 200) >= 3:
                    todo.append((x, y, next(p for p in nb if p[3] > 200)))
        for x, y, c in todo:
            px[x, y] = c
    return im

def apple(px, x, y):
    for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
        px[x + dx, y + dy] = RED_DD
    px[x, y], px[x + 1, y], px[x, y + 1], px[x + 1, y + 1] = HI, RED, RED, RED_D

def pear(px, x, y):
    # a 2x3 pear, narrow at the top, in a dark rim: lit gold, gold, olive-gold at the base
    for dx, dy in ((0, -1), (-1, 0), (1, 0), (-1, 1), (2, 1), (-1, 2), (2, 2), (0, 3), (1, 3)):
        px[x + dx, y + dy] = PEAR_RIM   # bark brown, not near-black: a black rim read as an icon at 4x
    px[x, y] = HI
    px[x, y + 1], px[x + 1, y + 1] = GOLD, GOLD_D
    px[x, y + 2], px[x + 1, y + 2] = GOLD_D, OLIVE

def solid(px, x, y, r=2):
    return all(px[x + dx, y + dy][3] > 200 for dx in range(-r, r + 1) for dy in range(-r, r + 2))

# Apples
a = fill(load("apple_w3c.png"), 37)
a.save(os.path.join(out, "apple_a.png"))
b = load("apple_w3c.png")
px = b.load()
for y in range(0, 37):
    for x in range(b.width):
        p = px[x, y]
        if p == RED_DD:
            px[x, y] = OLIVE_DD
        elif p == RED_D and (x + y) % 3:
            px[x, y] = OLIVE_D
# Re-stamp Batch C's apples (fix_apple.py's spots) so their dark rims survive the recolour, and add four.
for x, y in [(12, 14), (22, 9), (31, 12), (9, 22), (18, 20), (27, 19), (36, 22), (14, 29), (24, 27), (33, 30), (20, 34),
             (16, 24), (29, 25), (38, 28), (26, 33)]:
    if solid(px, x, y, 1):
        apple(px, x, y)
fill(b, 37).save(os.path.join(out, "apple_b.png"))

# Pears
def pears(name, spots, greener):
    p = fill(load("pear_w3c.png"), 33)
    px = p.load()
    if greener:   # the crown's top third a step greener
        for y in range(0, 14):
            for x in range(p.width):
                if px[x, y] == GOLD and (x * 3 + y) % 4 == 0:
                    px[x, y] = OLIVE
    n = 0
    for x, y in spots:
        if solid(px, x, y, 1):
            pear(px, x, y)
            n += 1
    p.save(os.path.join(out, name))
    print(name, "pears placed:", n, "of", len(spots))
pears("pear_a.png", [(14, 18), (22, 13), (30, 15), (10, 26), (19, 24), (27, 21), (35, 25), (16, 29), (31, 29)], False)
pears("pear_b.png", [(12, 21), (20, 9), (26, 16), (34, 20), (15, 27), (24, 25), (37, 27), (28, 30), (20, 30)], True)

# Windfalls and a basket
def sprite(rows, pal, name):
    im = Image.new("RGBA", (len(rows[0]), len(rows)), (0, 0, 0, 0))
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c != ".":
                im.putpixel((x, y), pal[c])
    im.save(os.path.join(out, name))
pal = {"o": OUT_D, "h": HI, "r": RED, "d": RED_D, "g": GOLD, "G": GOLD_D, "v": OLIVE,
       "w": (122, 84, 52, 255), "W": (90, 61, 38, 255), "l": (154, 109, 66, 255)}
sprite([".o.", "ohr", "odo"], pal, "windfall_apple.png")
sprite([".o.", "ogo", "oGv"], pal, "windfall_pear.png")
sprite(["..o.o.o.o..",
        ".ohrohrogGo",
        "ordrdrdGvdo",
        "owlwlwlwlwo",
        "oWwWwWwWwWo",
        ".owlwlwlwo.",
        "..oWWWWWo..",
        "...ooooo..."], pal, "basket.png")
print("saved")
