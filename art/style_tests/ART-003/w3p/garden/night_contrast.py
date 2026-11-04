# ART-003 W-3 polish (non-production, no generation): corn and pole beans that keep their shape at night.
# ../../w3b/garden/crops_w3b.png -> crops_w3p.png. Only the corn (cell 0) and pole-bean (cell 2) cells change:
# their leaf greens step up one to two values (the darkest leaf green was most of each plant, and went black under
# the night tint), and the bean pole turns from dark brown to weathered grey wood, so it no longer reads as a hole.
# The other six cells, the cell size (16x32) and every silhouette are unchanged: colours only.
#   python night_contrast.py
from PIL import Image

LEAF = {(46, 63, 36): (74, 100, 50), (67, 85, 44): (104, 128, 60), (94, 110, 52): (136, 150, 72),
        (125, 138, 62): (166, 172, 90)}
POLE = {(59, 42, 30): (92, 84, 72), (42, 31, 24): (64, 58, 52), (90, 61, 38): (128, 118, 100),
        (92, 65, 40): (122, 112, 96)}
img = Image.open('../../w3b/garden/crops_w3b.png').convert('RGBA')
px = img.load()
n = 0
for cell, table in ((0, LEAF), (2, {**LEAF, **POLE})):
    for y in range(img.height):
        for x in range(cell * 16, cell * 16 + 16):
            p = px[x, y]
            if p[3] > 200 and p[:3] in table:
                px[x, y] = table[p[:3]] + (p[3],)
                n += 1
img.save('crops_w3p.png')
print('crops_w3p.png:', n, 'pixels recoloured in the corn and bean cells')
