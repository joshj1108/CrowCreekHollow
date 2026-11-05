# ART-003 W-3 Batch C: hand-fix of the generated apple tree (gen/apple.png -> apple_w3c.png). No resampling; every
# colour is from the concept palette. Removes the ground disc under the roots, browns the orange trunk stripe, and
# sets small two-tone apples into the brighter parts of the crown so it reads as a fruit tree, not a maple.
from PIL import Image
import os
here = os.path.dirname(os.path.abspath(__file__))
im = Image.open(os.path.join(here, "..", "gen", "apple.png")).convert("RGBA")
w, h = im.size
px = im.load()
RED, RED_D, RED_DD, HI = (196, 64, 42, 255), (156, 42, 30, 255), (110, 26, 22, 255), (246, 196, 90, 255)
BROWN, BROWN_D = (122, 84, 52, 255), (90, 61, 38, 255)

def kind(p):
    if p[3] < 128: return "."
    if p[1] > p[0] and p[1] > p[2]: return "g"
    if p[0] > 140 and p[1] < 110: return "r"
    if p[0] > 150: return "o"
    return "b"

for y in range(40, h):
    for x in range(w):
        k = kind(px[x, y])
        if y >= 50 and (k == "g" or (k == "o" and not 19 <= x <= 30)):
            px[x, y] = (0, 0, 0, 0)          # the ground disc and the leaves on it
        elif 19 <= x <= 30 and k in "ro":
            px[x, y] = BROWN if k == "o" else BROWN_D   # the trunk's orange stripe
# Apples: a 2x2 fruit (lit top-left) inside a dark rim, on crown pixels away from the edge. Red alone sank into the
# red-orange crown; the rim and highlight are what make each fruit read at game scale.
spots = [(12, 14), (22, 9), (31, 12), (9, 22), (18, 20), (27, 19), (36, 22), (14, 29), (24, 27), (33, 30), (20, 34)]
placed = 0
for x, y in spots:
    if all(px[x + dx, y + dy][3] > 200 for dx in (-1, 0, 1, 2) for dy in (-1, 0, 1, 2)):
        for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
            px[x + dx, y + dy] = RED_DD
        px[x, y], px[x + 1, y], px[x, y + 1], px[x + 1, y + 1] = HI, RED, RED, RED_D
        placed += 1
print("apples placed:", placed)
im.save(os.path.join(here, "apple_w3c.png"))
print("saved")
