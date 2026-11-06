"""Render a cave layout with a PixelLab transition (cliff) tileset, to judge sets and vertex rules.
python preview_walls.py TILESET_PREFIX LAYOUT.txt OUT.png MODE
MODE raw: vertices at tile centres = wall; P: vertices = wall with wall south (face kept inside the wall row)."""
import sys, json
import numpy as np
from PIL import Image
pre, lay, out, mode = sys.argv[1:5]
pres = pre.split(',')
metas = [json.load(open(q + '.json'))['tileset_data']['tiles'] for q in pres]
sheets = [Image.open(q + '.png').convert('RGBA') for q in pres]
meta, sheet = metas[0], sheets[0]
rows = [l.rstrip('\n') for l in open(lay) if l.strip()]
H, W = len(rows), len(rows[0])
wall = np.array([[c in '#ci' for c in r] for r in rows])
def w(x, y):
    return True if x < 0 or y < 0 or x >= W or y >= H else wall[y, x]
V = np.zeros((H, W), int)
for y in range(H):
    for x in range(W):
        V[y, x] = 1 if (w(x, y) and (mode == 'raw' or w(x, y + 1))) else 0
# lower vertex directly south of upper -> transition
V2 = V.copy()
for y in range(1, H):
    for x in range(W):
        if V[y, x] == 0 and V[y - 1, x] == 1:
            V2[y, x] = 2
def vat(r, c):
    if 0 <= r < H and 0 <= c < W:
        return V2[r, c]
    return 1
CENTER = {(1, 1), (1, 2), (2, 1), (2, 2)}
def pick(r, c):
    # cell whose 4 corners are vertices (r,c),(r,c+1),(r+1,c),(r+1,c+1); pattern centre is rows 1-2, cols 1-2
    best, bs = None, -1e9
    for t in meta:
        p = t['pattern_4x4']; pat = [p['row_0'], p['row_1'], p['row_2'], p['row_3']]
        s = 0
        for i in range(4):
            for j in range(4):
                want = pat[i][j]
                if want == 255:
                    continue
                have = vat(r - 1 + i, c - 1 + j)
                cen = (i, j) in CENTER
                s += (10 if cen else 1) if have == want else (-30 if cen else -1)
        if s > bs:
            bs, best = s, t
    return best
img = Image.new('RGBA', (W * 16 + 16, H * 16 + 16), (0, 0, 0, 255))
for r in range(-1, H):
    for c in range(-1, W):
        t = pick(r, c); k = ((c * 7349 + r * 1931) ^ (c * 13)) % len(pres)
        t = next(u for u in metas[k] if u['pattern_4x4'] == t['pattern_4x4']); b = t['bounding_box']
        tile = sheets[k].crop((b['x'], b['y'], b['x'] + 16, b['y'] + 16))
        # the cell spans tile centres, so it sits half a tile right/down of the tile grid
        img.paste(tile, (c * 16 + 8 + 8, r * 16 + 8 + 8))
img = img.crop((8, 8, 8 + W * 16, 8 + H * 16))
# tile grid overlay dots for floor tiles
a = np.array(img)
for y in range(H):
    for x in range(W):
        if not wall[y, x]:
            a[y * 16 + 8, x * 16 + 8] = (255, 0, 0, 255)
Image.fromarray(a).resize((W * 16 * 2, H * 16 * 2), Image.NEAREST).save(out)
