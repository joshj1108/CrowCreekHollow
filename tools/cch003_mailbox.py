"""CCH-CONSOLIDATED-003 Phase B: the mailbox's frame strip, from three PixelLab candidates of one generation.

Reads art/style_tests/CCH-003/B/raw/gen2/NN.png (create_image_pro 32x48, job ad30b269, style image raw/style.png;
see pixellab-assets.json) and writes art/farm/mailbox.png, five 19x29 frames side by side:
  0 flag down (candidate 19)            1 flag half up (drawn here, between 19 and 18)
  2 flag up (candidate 18's box)        3 the door ajar (19 with the door's seam opened)
  4 the door open (candidate 17's door)
All frames share 19's post and grass, so only the flag and door move. A small brass latch is added to the closed door.
Run from the repository root:  python tools/cch003_mailbox.py
"""
import os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/CCH-003/B/raw/gen2')
OUT = os.path.join(ROOT, 'art/farm/mailbox.png')
CROP = (5, 10, 24, 39)   # x0, y0, x1, y1 (exclusive): the union of every frame's box


def load(i):
    a = np.array(Image.open(os.path.join(RAW, '%02d.png' % i)).convert('RGBA'))
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    return a


def rgb(h):
    return np.array([int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255], np.uint8)


def is_red(p):
    return p[3] and int(p[0]) > int(p[1]) + 25


down, up, opened = load(19), load(18), load(17)
BODY, BODY_LIT, OUTLINE = rgb('363136'), rgb('484447'), rgb('0c0b0c')
FLAG_DARK, FLAG, FLAG_LIT = rgb('471a14'), rgb('984a40'), rgb('9b5249')

# The box without a flag: 19, its lowered flag painted out, the box's lower edge from 18 (which has no flag there).
clean = down.copy()
for y in (19, 20):
    for x in range(14, 23):
        if is_red(clean[y, x]):
            clean[y, x] = BODY_LIT if y == 19 else BODY
clean[20, 23] = OUTLINE
clean[21:24, 13:24] = up[21:24, 13:24]

# 0: flag down is 19 itself.
f_down = down.copy()

# 2: flag up, 18's box over the clean one (rows 10-20); the pole's foot, where 18 had it, stays.
f_up = clean.copy()
f_up[10:21, 8:24] = up[10:21, 8:24]

# 1: the flag halfway, at 45 degrees from its pivot by the box's rear.
f_mid = clean.copy()
for (x, y) in [(16, 19), (17, 18), (18, 17), (19, 16)]:
    f_mid[y, x] = FLAG
    f_mid[y + 1, x] = FLAG_DARK
for (x, y, c) in [(19, 14, FLAG_LIT), (20, 14, FLAG_LIT), (20, 15, FLAG), (21, 15, FLAG), (21, 16, FLAG_DARK),
                  (19, 13, OUTLINE), (20, 13, OUTLINE), (21, 14, OUTLINE), (22, 15, OUTLINE), (22, 16, OUTLINE)]:
    if c is OUTLINE and f_mid[y, x][3]:
        continue   # an outline only where the flag stands against the sky, not over the box
    f_mid[y, x] = c

# 3: the door ajar: the seam between door and box opens to the dark inside.
f_ajar = clean.copy()
for y in range(16, 23):
    f_ajar[y, 12] = OUTLINE
    if f_ajar[y, 8][3]:
        f_ajar[y, 7] = OUTLINE

# 4: the door open: 17's door and mouth over the clean box, 19's post and grass below.
f_open = clean.copy()
f_open[10:28, 0:14] = opened[10:28, 0:14]
f_open[28:, :] = clean[28:, :]

# The door frames keep the lowered flag: the box is checked once its post is read.
for f in (f_ajar, f_open):
    f[19:23, 14:24] = down[19:23, 14:24]

# A brass latch on the closed door.
for f in (f_down, f_mid, f_up):
    f[19, 10] = rgb('8a6a3a')
    f[19, 11] = rgb('6a5230')
    f[18, 10] = rgb('b08a4a')

frames = [f_down, f_mid, f_up, f_ajar, f_open]
x0, y0, x1, y1 = CROP
w, h = x1 - x0, y1 - y0
strip = np.zeros((h, w * len(frames), 4), np.uint8)
for i, f in enumerate(frames):
    strip[:, i * w:(i + 1) * w] = f[y0:y1, x0:x1]
Image.fromarray(strip).save(OUT)
print('wrote', OUT, strip.shape[1], 'x', strip.shape[0])
